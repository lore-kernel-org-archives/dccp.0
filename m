From: Eric Dumazet <edumazet@google.com>
Date: Wed, 01 Aug 2018 17:18:49 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CANn89iKSwt-1j_p3XvoMTv2NpjJsiv6p7c=xkYKG+zDzcS9hgQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 9:47 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> Proving with numbers is required for a claimed performance improvement
> at the cost of code degradation/increase. For a win-win change there
> is really nothing to prove.

You have to _prove_ it is a win-win.

It is not sufficient to claim it is a win-win.

Sorry, but I do have bugs to take care of.
