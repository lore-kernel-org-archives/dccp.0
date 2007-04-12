From: David Miller <davem@davemloft.net>
Date: Thu, 12 Apr 2007 21:57:10 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <20070412.150214.57468161.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 13 Apr 2007 09:50:30 +1200

> I didn't know this time stamping was expensive but I knew the way we
> were trying to optimise LAN is wrong. I say LAN because a few
> microseconds or even milliseconds difference on a WAN link makes
> bugger all difference in throughput. DCCP takes into account operating
> system granularity etc and if we are running lossless (i.e. receiver
> can cope with receiving link at full speed) then we can transmit at
> line speed. I've tested this myself.

You want the scheduling delays and other issues that can
delay DCCP input packet processing to get factored into
the RTT, so that the sender will pace properly.

Trying to get perfect timestamping and RTT measurements,
and ignoring scheduling delays, is quite foolhardy and shows
a lack of understanding of how queueing really works.
