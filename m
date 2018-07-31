From: Eric Dumazet <edumazet@google.com>
Date: Tue, 31 Jul 2018 18:16:28 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CANn89iLjk-mV3kZGASvZQtYaBDy9sbo=NW4Tt_V=dOP_-b=VNQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 31, 2018 at 10:51 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
>
> Is it OK to overwrite ct->status? It seems that are some read and
> writes to it right after atomic_inc_not_zero.

If it is after a (successful) atomic_inc_not_zero(),
the object is guaranteed to be alive (not freed or about to be freed).

About readind/writing a specific field, all traditional locking rules apply.

For TCP socket, we would generally grab the socket lock before
reading/writing various fields.

ct->status seems to be manipulated with set_bit() and clear_bit()
which are SMP safe.
