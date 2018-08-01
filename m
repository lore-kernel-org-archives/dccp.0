From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Aug 2018 13:52:40 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <CACT4Y+ay6+UTLMr4K_RTTubjzpGZXe2n7T8Q=kC=Q1baHshkHQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 1, 2018 at 3:46 PM, Florian Westphal <fw@strlen.de> wrote:
> Dmitry Vyukov <dvyukov@google.com> wrote:
>> If that scenario is possible that a fix would be to make
>
> Looks possible.
>
>> __nf_conntrack_find_get ever return NULL iff it got NULL from
>> ____nf_conntrack_find (not if any of the checks has failed).
>
> I don't see why we need to restart on nf_ct_is_dying(), but other
> than that this seems ok.

Because it can be a wrong entry dying. When we check dying, we don't
yet know if we are looking at the right entry or not. If we
successfully acquire a reference, then recheck nf_ct_key_equal and
_then_ check dying, then we don't need to restart on dying. But with
the current check order, we need to restart on dying too.
