From: Eric Dumazet <edumazet@google.com>
Date: Wed, 01 Aug 2018 15:37:07 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 8:15 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 1 Aug 2018, Dmitry Vyukov wrote:
>
> > But we are trading 1 indirect call for comparable overhead removed
> > from much more common path. The path that does ctors is also calling
> > into page alloc, which is much more expensive.
> > So ctor should be a net win on performance front, no?
>
> ctor would make it esier to review the flow and guarantee that the object
> always has certain fields set as required before any use by the subsystem.
>
> ctors are run once on allocation of the slab page for all objects in it.
>
> ctors are not called duiring allocation and freeing of objects from the
> slab page. So we could avoid the intialization of the spinlock on each
> object allocation which actually should be faster.


This strategy might have been a win 30 years ago when cpu had no
caches (or too small anyway)

What probability is that the 60 bytes around the spinlock are not
touched after the object is freshly allocated ?

-> None

Writing 60 bytes  in one cache line instead of 64 has really the same
cost. The cache line miss is the real killer.

Feel free to write the patches, test them,  but I doubt you will have any gain.

Remember btw that TCP sockets can be either completely fresh
(socket() call, using memset() to clear the whole object),
or clones (accept() thus copying the parent socket)

The idea of having a ctor() would only be a win if all the fields that
can be initialized in the ctor are contiguous and fill an integral
number of cache lines.
