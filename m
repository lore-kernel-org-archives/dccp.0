From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 01 Aug 2018 09:03:18 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 07/31/2018 09:51 PM, Linus Torvalds wrote:
> On Tue, Jul 31, 2018 at 10:49 AM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> So the re-use might initialize the fields lazily, not necessarily using a ctor.
> 
> In particular, the pattern that nf_conntrack uses looks like it is safe.
> 
> If you have a well-defined refcount, and use "atomic_inc_not_zero()"
> to guard the speculative RCU access section, and use
> "atomic_dec_and_test()" in the freeing section, then you should be
> safe wrt new allocations.
> 
> If you have a completely new allocation that has "random stale
> content", you know that it cannot be on the RCU list, so there is no
> speculative access that can ever see that random content.
> 
> So the only case you need to worry about is a re-use allocation, and
> you know that the refcount will start out as zero even if you don't
> have a constructor.
> 
> So you can think of the refcount itself as always having a zero
> constructor, *BUT* you need to be careful with ordering.
> 
> In particular, whoever does the allocation needs to then set the
> refcount to a non-zero value *after* it has initialized all the other
> fields. And in particular, it needs to make sure that it uses the
> proper memory ordering to do so.
> 
> And in this case, we have
> 
>   static struct nf_conn *
>   __nf_conntrack_alloc(struct net *net,
>   {
>         ...
>         atomic_set(&ct->ct_general.use, 0);
> 
> which is a no-op for the re-use case (whether racing or not, since any
> "inc_not_zero" users won't touch it), but initializes it to zero for
> the "completely new object" case.
> 
> And then, the thing that actually exposes it to the speculative walkers does:
> 
>   int
>   nf_conntrack_hash_check_insert(struct nf_conn *ct)
>   {
>         ...
>         smp_wmb();
>         /* The caller holds a reference to this object */
>         atomic_set(&ct->ct_general.use, 2);
> 
> which means that it stays as zero until everything is actually set up,
> and then the optimistic walker can use the other fields (including
> spinlocks etc) to verify that it's actually the right thing. The
> smp_wmb() means that the previous initialization really will be
> visible before the object is visible.
> 
> Side note: on some architectures it might help to make that "smp_wmb
> -> atomic_set()" sequence be am "smp_store_release()" instead. Doesn't
> matter on x86, but might matter on arm64.
> 
> NOTE! One thing to be very worried about is that re-initializing
> whatever RCU lists means that now the RCU walker may be walking on the
> wrong list so the walker may do the right thing for this particular
> entry, but it may miss walking *other* entries. So then you can get
> spurious lookup failures, because the RCU walker never walked all the
> way to the end of the right list. That ends up being a much more
> subtle bug.
> 
> But the nf_conntrack case seems to get that right too, see the restart
> in ____nf_conntrack_find().
> 
> So I don't see anything wrong in nf_conntrack.
> 
> But yes, using SLAB_TYPESAFE_BY_RCU is very very subtle. But most of
> the subtleties have nothing to do with having a constructor, they are
> about those "make sure memory ordering wrt refcount is right" and
> "restart speculative RCU walk" issues that actually happen regardless
> of having a constructor or not.
> 

I see, thanks. I just don't see any point or advantage of *not* using the constructor
with SLAB_TYPESAFE_BY_RCU caches.
There is always must be a small part of initialization code that could be placed
in constructor. And it's better to put that part into constructor to avoid initializing
what's already has been initialized. If people use SLAB_TYPESAFE_BY_RCU instead of traditional
kfree_rcu() for cache-efficiency and because they want to reuse the object faster, than avoiding
few writes into cache-hot data doesn't look like a bad idea.
E.g. nf_conntrack case could at least move the spin_lock_init() and atomic_set(&ct->ct_general.use, 0)
in the constructor.

I can't think of any advantage in not having the constructor. 
