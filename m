From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:42:35 +0000
Subject: Re: [PATCH 6/6] [DCCP]: Parameter renaming
Message-Id: <20070925.224235.27796755.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922211033.GK4887@ghostprotocols.net>
In-Reply-To: <20070922211033.GK4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:10:33 -0300

> The parameter `seq' of dccp_send_sync() is in fact an acknowledgement number
> and not a sequence number - thus renamed by this patch into `ackno'.
> 
> Secondly, a `critical' warning is added when a Sync/SyncAck could not be sent.
> 
> Sanity: I have checked all other functions that are called in dccp_transmit_skb,
>         there are no clashes with the use of dccpd_ack_seq; no other function is
>         using this slot at the same time.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks.
