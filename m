From: Florian Westphal <fw@strlen.de>
Date: Wed, 01 Aug 2018 13:46:28 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <20180801134628.ueyzwg2gszrvk2hc@breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dmitry Vyukov <dvyukov@google.com> wrote:
> If that scenario is possible that a fix would be to make

Looks possible.

> __nf_conntrack_find_get ever return NULL iff it got NULL from
> ____nf_conntrack_find (not if any of the checks has failed).

I don't see why we need to restart on nf_ct_is_dying(), but other
than that this seems ok.
