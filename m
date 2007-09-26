From: David Miller <davem@davemloft.net>
Date: Wed, 26 Sep 2007 05:41:27 +0000
Subject: Re: [PATCH 4/6] [DCCP]: Shorten variable names in dccp_check_seqno
Message-Id: <20070925.224127.131933051.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922211008.GI4887@ghostprotocols.net>
In-Reply-To: <20070922211008.GI4887@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 18:10:08 -0300

> This patch is in part required by the next patch; it
> 
>  * replaces 6 instances of `DCCP_SKB_CB(skb)->dccpd_seq' with `seqno';
>  * replaces 7 instances of `DCCP_SKB_CB(skb)->dccpd_ack_seq' with `ackno';
>  * replaces 1 use of dccp_inc_seqno() by unfolding `ADD48' macro in place.
> 
> No changes in algorithm, all changes are text replacement/substitution.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks.
