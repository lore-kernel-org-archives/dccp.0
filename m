From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 24 Jul 2008 20:13:01 +0000
Subject: Re: [PATCH 2/4] DCCP: Add check for sequence number in ICMPv6
Message-Id: <20080724201301.GA11760@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <488841D2.9040206@cn.fujitsu.com>
In-Reply-To: <488841D2.9040206@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -115,6 +116,14 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> 	if (sk->sk_state = DCCP_CLOSED)
> 		goto out;
>
> +	dp = dccp_sk(sk);
> +	seq = dccp_hdr_seq(dh);
> +	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
> +	    !between48(seq, dp->dccps_awl, dp->dccps_awh)) {
> +		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
> +		goto out;
Here it should say
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
Please compile-test your patches.

Have looked at the others, will do some more testing and submit this set tomorrow.
 
