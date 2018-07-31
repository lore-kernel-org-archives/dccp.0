From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2018 17:49:28 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 31, 2018 at 10:36 AM Christopher Lameter <cl@linux.com> wrote:
>
> If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?

.. because the object can be accessed (by RCU) after the refcount has
gone down to zero, and the thing has been released.

That's the whole and only point of SLAB_TYPESAFE_BY_RCU.

That flag basically says:

  "I may end up accessing this object *after* it has been free'd,
because there may be RCU lookups in flight"

This has nothing to do with constructors. It's ok if the object gets
reused as an object of the same type and does *not* get
re-initialized, because we're perfectly fine seeing old stale data.

What it guarantees is that the slab isn't shared with any other kind
of object, _and_ that the underlying pages are free'd after an RCU
quiescent period (so the pages aren't shared with another kind of
object either during an RCU walk).

And it doesn't necessarily have to have a constructor, because the
thing that a RCU walk will care about is

 (a) guaranteed to be an object that *has* been on some RCU list (so
it's not a "new" object)

 (b) the RCU walk needs to have logic to verify that it's still the
*same* object and hasn't been re-used as something else.

So the re-use might initialize the fields lazily, not necessarily using a ctor.

And the point of using SLAB_TYPESAFE_BY_RCU is that using the more
traditional RCU freeing - where you free each object one by one with
an RCU delay - can be prohibitively slow and have a huge memory
overhead (because of big chunks of memory that are queued for
freeing).

In contrast, a SLAB_TYPESAFE_BY_RCU memory gets free'd and re-used
immediately, but because it gets reused as the same kind of object,
the RCU walker can "know" what parts have meaning for re-use, in a way
it couidn't if the re-use was random.

That said, it *is* subtle, and people should be careful.

                 Linus
