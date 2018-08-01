From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 09:10:22 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+ZkgqDT77dshHg+hBtc9YPW-eZ8wVQA9LTDQ6q_y99oiQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 10:46 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Jul 31, 2018 at 8:51 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Tue, Jul 31, 2018 at 10:49 AM Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>>
>>> So the re-use might initialize the fields lazily, not necessarily using a ctor.
>>
>> In particular, the pattern that nf_conntrack uses looks like it is safe.
>>
>> If you have a well-defined refcount, and use "atomic_inc_not_zero()"
>> to guard the speculative RCU access section, and use
>> "atomic_dec_and_test()" in the freeing section, then you should be
>> safe wrt new allocations.
>>
>> If you have a completely new allocation that has "random stale
>> content", you know that it cannot be on the RCU list, so there is no
>> speculative access that can ever see that random content.
>>
>> So the only case you need to worry about is a re-use allocation, and
>> you know that the refcount will start out as zero even if you don't
>> have a constructor.
>>
>> So you can think of the refcount itself as always having a zero
>> constructor, *BUT* you need to be careful with ordering.
>>
>> In particular, whoever does the allocation needs to then set the
>> refcount to a non-zero value *after* it has initialized all the other
>> fields. And in particular, it needs to make sure that it uses the
>> proper memory ordering to do so.
>>
>> And in this case, we have
>>
>>   static struct nf_conn *
>>   __nf_conntrack_alloc(struct net *net,
>>   {
>>         ...
>>         atomic_set(&ct->ct_general.use, 0);
>>
>> which is a no-op for the re-use case (whether racing or not, since any
>> "inc_not_zero" users won't touch it), but initializes it to zero for
>> the "completely new object" case.
>>
>> And then, the thing that actually exposes it to the speculative walkers does:
>>
>>   int
>>   nf_conntrack_hash_check_insert(struct nf_conn *ct)
>>   {
>>         ...
>>         smp_wmb();
>>         /* The caller holds a reference to this object */
>>         atomic_set(&ct->ct_general.use, 2);
>>
>> which means that it stays as zero until everything is actually set up,
>> and then the optimistic walker can use the other fields (including
>> spinlocks etc) to verify that it's actually the right thing. The
>> smp_wmb() means that the previous initialization really will be
>> visible before the object is visible.
>>
>> Side note: on some architectures it might help to make that "smp_wmb
>> -> atomic_set()" sequence be am "smp_store_release()" instead. Doesn't
>> matter on x86, but might matter on arm64.
>>
>> NOTE! One thing to be very worried about is that re-initializing
>> whatever RCU lists means that now the RCU walker may be walking on the
>> wrong list so the walker may do the right thing for this particular
>> entry, but it may miss walking *other* entries. So then you can get
>> spurious lookup failures, because the RCU walker never walked all the
>> way to the end of the right list. That ends up being a much more
>> subtle bug.
>>
>> But the nf_conntrack case seems to get that right too, see the restart
>> in ____nf_conntrack_find().
>>
>> So I don't see anything wrong in nf_conntrack.
>>
>> But yes, using SLAB_TYPESAFE_BY_RCU is very very subtle. But most of
>> the subtleties have nothing to do with having a constructor, they are
>> about those "make sure memory ordering wrt refcount is right" and
>> "restart speculative RCU walk" issues that actually happen regardless
>> of having a constructor or not.
>
>
> Thank you, this is very enlightening.
>
> So the type-stable invariant is established by initialization of the
> object after the first kmem_cache_alloc, and then we rely on the fact
> that repeated initialization does not break the invariant, which works
> because the state is very simple (including debug builds, i.e. no
> ODEBUG nor magic values).


Still can't grasp all details.
There is state that we read without taking ct->ct_general.use ref
first, namely ct->state and what's used by nf_ct_key_equal.
So let's say the entry we want to find is in the list, but
____nf_conntrack_find finds a wrong entry earlier because all state it
looks at is random garbage, so it returns the wrong entry to
__nf_conntrack_find_get.
Now (nf_ct_is_dying(ct) || !atomic_inc_not_zero(&ct->ct_general.use))
check in __nf_conntrack_find_get passes, and it returns NULL to the
caller (which means entry is not present). While in reality the entry
is present, but we were just looking at the wrong one.

Also I am not sure about order of checks in (nf_ct_is_dying(ct) ||
!atomic_inc_not_zero(&ct->ct_general.use)), because checking state
before taking the ref is only a best-effort hint, so it can actually
be a dying entry when we take a ref.

So shouldn't it read something like the following?

        rcu_read_lock();
begin:
        h = ____nf_conntrack_find(net, zone, tuple, hash);
        if (h) {
                ct = nf_ct_tuplehash_to_ctrack(h);
                if (!atomic_inc_not_zero(&ct->ct_general.use))
                        goto begin;
                if (unlikely(nf_ct_is_dying(ct)) ||
                    unlikely(!nf_ct_key_equal(h, tuple, zone, net))) {
                        nf_ct_put(ct);
                        goto begin;
                }
        }
        rcu_read_unlock();
        return h;
