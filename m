From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 15:53:00 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+axXa3HXG7ZoJSmP-g2QqtnvQ77oUZuioX-V9Ydi-56Dw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 5:37 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Aug 1, 2018 at 8:15 AM Christopher Lameter <cl@linux.com> wrote:
>>
>> On Wed, 1 Aug 2018, Dmitry Vyukov wrote:
>>
>> > But we are trading 1 indirect call for comparable overhead removed
>> > from much more common path. The path that does ctors is also calling
>> > into page alloc, which is much more expensive.
>> > So ctor should be a net win on performance front, no?
>>
>> ctor would make it esier to review the flow and guarantee that the object
>> always has certain fields set as required before any use by the subsystem.
>>
>> ctors are run once on allocation of the slab page for all objects in it.
>>
>> ctors are not called duiring allocation and freeing of objects from the
>> slab page. So we could avoid the intialization of the spinlock on each
>> object allocation which actually should be faster.
>
>
> This strategy might have been a win 30 years ago when cpu had no
> caches (or too small anyway)
>
> What probability is that the 60 bytes around the spinlock are not
> touched after the object is freshly allocated ?
>
> -> None
>
> Writing 60 bytes  in one cache line instead of 64 has really the same
> cost. The cache line miss is the real killer.
>
> Feel free to write the patches, test them,  but I doubt you will have any gain.
>
> Remember btw that TCP sockets can be either completely fresh
> (socket() call, using memset() to clear the whole object),
> or clones (accept() thus copying the parent socket)
>
> The idea of having a ctor() would only be a win if all the fields that
> can be initialized in the ctor are contiguous and fill an integral
> number of cache lines.

Code size can have some visible performance impact too.

But either way, what you say only means that ctors are not necessary
significantly faster. But your original point was that they are
slower.
If they are not slower, then what Andrey said seems to make sense:
some gain on code comprehension front re type-stability invariant +
some gain on performance front (even if not too big) and no downsides.
