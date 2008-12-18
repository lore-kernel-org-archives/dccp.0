From: David Miller <davem@davemloft.net>
Date: Thu, 18 Dec 2008 00:08:19 +0000
Subject: Re: [PATCH] dccp_diag: LISTEN sockets don't have CCIDs
Message-Id: <20081217.160819.99264095.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081217200332.GY14518@ghostprotocols.net>
In-Reply-To: <20081217200332.GY14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Dec 2008 18:03:32 -0200

> And thus when we try to use 'ss -danemi' on these sockets that have no
> ccid blocks (data collected using systemtap after I fixed the problem):
> 
> dccp_diag_get_info sk=0xffff8801220a3100, dp->dccps_hc_rx_ccid=0x0000000000000000, dp->dccps_hc_tx_ccid=0x0000000000000000
> 
> We get an OOPS:
 ...
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6, thanks!
