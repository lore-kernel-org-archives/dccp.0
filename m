From: Christopher Lameter <cl@linux.com>
Date: Wed, 01 Aug 2018 15:15:51 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 1 Aug 2018, Dmitry Vyukov wrote:

> But we are trading 1 indirect call for comparable overhead removed
> from much more common path. The path that does ctors is also calling
> into page alloc, which is much more expensive.
> So ctor should be a net win on performance front, no?

ctor would make it esier to review the flow and guarantee that the object
always has certain fields set as required before any use by the subsystem.

ctors are run once on allocation of the slab page for all objects in it.

ctors are not called duiring allocation and freeing of objects from the
slab page. So we could avoid the intialization of the spinlock on each
object allocation which actually should be faster.

