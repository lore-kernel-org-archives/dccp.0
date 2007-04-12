From: David Miller <davem@davemloft.net>
Date: Thu, 12 Apr 2007 21:22:11 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <20070412.142211.99480331.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 18:14:54 -0300

>  This patch replaces calls to do_gettimeofday at the receiver CCID 3
>  with skb timestamps. The skb timestamps are computed earlier in the
>  receive path, experimental measurements have shown that up to several
>  hundred microseconds can lie between the skb receive timestamp and the
>  timestamp taken when CCID 3 receives the packet. This difference has
>  a negative impact on RTT estimation (reduced accuracy).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

And this creates an even deeper dependency on the global packet
timestamping facility.  Those are supposed to be enabled only
in obscure circumstances because timestamping every packet is
incredibly expensive.

Please find a better way.
