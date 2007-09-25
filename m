From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 25 Sep 2007 14:51:27 +0000
Subject: Re: [PATCH 3/8]: Remove duplicate code for Reset from connected
Message-Id: <20070925145127.GG18348@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.21163@strip-the-willow>
In-Reply-To: <200709251530.21163@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 25, 2007 at 03:30:21PM +0100, Gerrit Renker escreveu:
> [DCCP]: Remove duplicate code for Reset from connected socket
> 
> In this patch, duplicated code is removed for the case when a Reset packet is
> sent from a connected socket. This code duplication is between dccp_make_reset
> and dccp_transmit_skb, which already contained an (up to now entirely unused)
> switch statement to fill in the reset code from the DCCP_SKB_CB.
> 
> The only thing that has been removed is the call to dst_clone(dst), since
> the queue_xmit functions use sk_dst_cache anyway.
> 
> I wasn't sure which purpose inet_sk_rebuild_header served, so I left it in.

I'll check this later, to finally remove that comment in dccp_send_reset

> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Looks ok, applying.

- Arnaldo
