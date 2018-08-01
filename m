From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 12:38:19 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+ZNnYojj0x_DoUxeUREaEgzcf3UG=UW_P4vzsnZNjjgMQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 1:40 PM, Florian Westphal <fw@strlen.de> wrote:
> Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Aug 1, 2018 at 12:35 PM, Florian Westphal <fw@strlen.de> wrote:
>> > Dmitry Vyukov <dvyukov@google.com> wrote:
>> >> Still can't grasp all details.
>> >> There is state that we read without taking ct->ct_general.use ref
>> >> first, namely ct->state and what's used by nf_ct_key_equal.
>> >> So let's say the entry we want to find is in the list, but
>> >> ____nf_conntrack_find finds a wrong entry earlier because all state it
>> >> looks at is random garbage, so it returns the wrong entry to
>> >> __nf_conntrack_find_get.
>> >
>> > If an entry can be found, it can't be random garbage.
>> > We never link entries into global table until state has been set up.
>>
>> But... we don't hold a reference to the entry. So say it's in the
>> table with valid state, now ____nf_conntrack_find discovers it, now
>> the entry is removed and reused a dozen of times will all associated
>> state reinitialization. And nf_ct_key_equal looks at it concurrently
>> and decides if it's the entry we are looking for or now. I think
>> unless we hold a ref to the entry, it's state needs to be considered
>> random garbage for correctness reasoning.
>
> It checks if it might be the entry we're looking for.
>
> If this was complete random garbage, scheme would not work, as then
> we could have entry that isn't in table, has nonzero refcount, but
> has its confirmed bit set.
>
> I don't see how that would be possible, any reallocation
> makes sure ct->status has CONFIRMED bit clear before setting refcount
> to nonzero value.
>
> I think this is the scenario you hint at is:
> 1. nf_ct_key_equal is true
> 2. the entry is free'd (or was already free'd)
> 3. we return NULL to caller due to atomic_inc_not_zero() failure
>
> but i fail to see how thats wrong?
>
> Sure, we could restart lookup but how would that help?
>
> We'd not find the 'candidate' entry again.
>
> We might find entry that has been inserted at this very instant but
> newly allocated entries are only inserted into global table until the skb that
> created the nf_conn object has made it through the network stack
> (postrouting for fowarded, or input for local delivery).
>
> So, the likelyhood of such restart finding another candidate is close to 0,
> and won't prevent 'insert race' from happening.


The scenario I have in mind is different and it relates to the fact
that ____nf_conntrack_find will return the right entry if it's
present, but it can also return an unrelated entry because when it
looks at entries they change underneath.

Let's take any 2 fields compared by nf_ct_key_equal for simplicity,
for example, src.u3 and dst.u3.
Let's say we are looking for an entry with src.u3=A and dst.u3=B,
let's call it (A,B).
Let's say there is an existing entry 1 (A,B) in the global list. But
there is also entry 2 (A,C) earlier in the list.
Now, ____nf_conntrack_find starts checking entry 2 (A,C), it checks
that src.u3=A, so so far it looks good.
Now another thread deletes, reuses and reinitilizes entry 2 for (C,B).
Now, ____nf_conntrack_find checks that dst.u3=B, so it concludes that
it's the right entry, because it observed (A,B). Entry 2 is returned
to __nf_conntrack_find_get.
Now another thread marks entry 2 as dying.
Now __nf_conntrack_find_get sees that it's dying and returns NULL to
caller, _but_ the matching entry 1 (A,B) was in the list all that time
and we should have been discovered it, but we didn't because we were
deraield by the wrong entry 2.

If that scenario is possible that a fix would be to make
__nf_conntrack_find_get ever return NULL iff it got NULL from
____nf_conntrack_find (not if any of the checks has failed).
