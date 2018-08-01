From: Christopher Lameter <cl@linux.com>
Date: Wed, 01 Aug 2018 16:22:02 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <01000164f64bd525-be13e04f-18a9-4f7f-a44b-0c0fcec33b71-000000@email.amazonses.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 1 Aug 2018, Eric Dumazet wrote:

> The idea of having a ctor() would only be a win if all the fields that
> can be initialized in the ctor are contiguous and fill an integral
> number of cache lines.

Ok. Its reducing code size and makes the object status more consistent.
Isn't that enough?

