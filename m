From: David Miller <davem@davemloft.net>
Date: Thu, 12 Apr 2007 21:21:03 +0000
Subject: Re: [PATCH 06/29] Use skb timestamp for TX side
Message-Id: <20070412.142103.10320549.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070412211446.GG21292@ghostprotocols.net>
In-Reply-To: <20070412211446.GG21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 18:14:46 -0300

>  This patch uses skb timestamps (and provides the necessary enable/disable
>  mechanism) instead of layer-4 timestamping. This affords a more accurate
>  RTT estimation.
> 
> Background:
> 
>  The sender currently computes the timestamp of received (Ack) packets when
>  the packet is delivered to layer 4. The skb timestamp is taken earlier, and
>  the differences are notable: dDuring test runs under different load conditions,
>  the layer-4 timestamp was observed to be on average up to 100 microseconds,
>  in the extreme up to a millisecond, later than the skb timestamp.
>  This has a negative impact on the RTT estimation (reduced accuracy).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

This patch screws the entire system over with the overhead of
timestamping every packet processed as soon as there are DCCP sockets
using ccid3.

I'll pull this in for now, but you must find a better way before
I merge this to Linus for 2.6.22
