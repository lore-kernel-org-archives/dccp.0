From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 10:41:09 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+aHWpgDZygXv=smWwdVMWfjpedyajuVvvLDGMK-wFD5Lw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 12:35 PM, Florian Westphal <fw@strlen.de> wrote:
> Dmitry Vyukov <dvyukov@google.com> wrote:
>> Still can't grasp all details.
>> There is state that we read without taking ct->ct_general.use ref
>> first, namely ct->state and what's used by nf_ct_key_equal.
>> So let's say the entry we want to find is in the list, but
>> ____nf_conntrack_find finds a wrong entry earlier because all state it
>> looks at is random garbage, so it returns the wrong entry to
>> __nf_conntrack_find_get.
>
> If an entry can be found, it can't be random garbage.
> We never link entries into global table until state has been set up.


But... we don't hold a reference to the entry. So say it's in the
table with valid state, now ____nf_conntrack_find discovers it, now
the entry is removed and reused a dozen of times will all associated
state reinitialization. And nf_ct_key_equal looks at it concurrently
and decides if it's the entry we are looking for or now. I think
unless we hold a ref to the entry, it's state needs to be considered
random garbage for correctness reasoning.


>> Now (nf_ct_is_dying(ct) || !atomic_inc_not_zero(&ct->ct_general.use))
>> check in __nf_conntrack_find_get passes, and it returns NULL to the
>> caller (which means entry is not present).
>
> So entry is going away or marked as dead which for us is same as
> 'not present', we need to allocate a new entry.
>
>> While in reality the entry
>> is present, but we were just looking at the wrong one.
>
> We never add tuples that are identical to the global table.
>
> If N cores receive identical packets at same time with no prior state, all
> will allocate a new conntrack, but we notice this when we try to insert the
> nf_conn entries into the table.
>
> Only one will succeed, other cpus have to cope with this.
> (worst case: all raced packets are dropped along with their conntrack
>  object).
>
> For lookup, we have following scenarios:
>
> 1. It doesn't exist -> new allocation needed
> 2. It exists, not dead, has nonzero refount -> use it
> 3. It exists, but marked as dying -> new allocation needed
> 4. It exists but has 0 reference count -> new allocation needed
> 5. It exists, we get reference, but 2nd nf_ct_key_equal check
>    fails.  We saw a matching 'old incarnation' that just got
>    re-used on other core.  -> retry lookup
>
>> Also I am not sure about order of checks in (nf_ct_is_dying(ct) ||
>> !atomic_inc_not_zero(&ct->ct_general.use)), because checking state
>> before taking the ref is only a best-effort hint, so it can actually
>> be a dying entry when we take a ref.
>
> Yes, it can also become a dying entry after we took the reference.
>
>> So shouldn't it read something like the following?
>>
>>         rcu_read_lock();
>> begin:
>>         h = ____nf_conntrack_find(net, zone, tuple, hash);
>>         if (h) {
>>                 ct = nf_ct_tuplehash_to_ctrack(h);
>>                 if (!atomic_inc_not_zero(&ct->ct_general.use))
>>                         goto begin;
>>                 if (unlikely(nf_ct_is_dying(ct)) ||
>>                     unlikely(!nf_ct_key_equal(h, tuple, zone, net))) {
>>                         nf_ct_put(ct);
>
> It would be ok to make this change, but dying bit can be set
> at any time e.g. because userspace tells kernel to flush the conntrack table.
> So refcount is always > 0 when the DYING bit is set.
>
> I don't see why it would be a problem.
>
> nf_conn struct will stay valid until all cpus have dropped references.
> The check in lookup function only serves to hide the known-to-go-away entry.
