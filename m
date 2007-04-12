From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 12 Apr 2007 21:50:30 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <5640c7e00704121450i7d78da2et30e450e453d80030@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, David Miller <davem@davemloft.net> wrote:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Thu, 12 Apr 2007 18:14:54 -0300
>
> >  This patch replaces calls to do_gettimeofday at the receiver CCID 3
> >  with skb timestamps. The skb timestamps are computed earlier in the
> >  receive path, experimental measurements have shown that up to several
> >  hundred microseconds can lie between the skb receive timestamp and the
> >  timestamp taken when CCID 3 receives the packet. This difference has
> >  a negative impact on RTT estimation (reduced accuracy).
> >
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> > Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
>
> And this creates an even deeper dependency on the global packet
> timestamping facility.  Those are supposed to be enabled only
> in obscure circumstances because timestamping every packet is
> incredibly expensive.
>
> Please find a better way.

I didn't know this time stamping was expensive but I knew the way we
were trying to optimise LAN is wrong. I say LAN because a few
microseconds or even milliseconds difference on a WAN link makes
bugger all difference in throughput. DCCP takes into account operating
system granularity etc and if we are running lossless (i.e. receiver
can cope with receiving link at full speed) then we can transmit at
line speed. I've tested this myself.

This illustrates a trend by you Gerrit to try and micro-optimise what
you perceive as bottlenecks and not realise the impact. You have been
also promoting possible use of hrtimers which would be even worse for
example in far of terms of loading a system.

Gerrit - you send us a missive on how we should humbly accept your
patches and stop arguing with you. Obviously Eddie (co-author of DCCP
spec) and myself (converted DCCP CCID3 to Linux 2.6) aren't good
enough. Maybe now Dave Miller says something you will listen or do you
need Linus Torvalds to tell you to stop being a fucking idiot at
times? Yes you write lots of good code but you write some bad code at
times also. I probably write more bad code than you and less volume of
code but I try to listen. Stop pretending to be a deity.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
