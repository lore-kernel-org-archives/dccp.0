From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 11 Apr 2008 13:59:08 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <20080411135908.GA20937@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
To: dccp@vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

>>>     [DCCP]: Fix skb->cb conflicts with IP
>>>         dev_queue_xmit() and the other IP output functions expect to 
<snip>
>
> Dave, I'm not sure whether you've missed this or expect it
> to go through Arnaldo, just want to make sure it doesn't
> get missed because of a misunderstanding :)
>
>
If it is not too much work, can you please also remove the two attached
hunks which are now redundant thanks to the above patch.


The University of Aberdeen is a charity registered in Scotland, No SC013683.


--NzB8fVQJ5HfG6fxh
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="remove_unused_memset.diff"

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -489,7 +489,6 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 
 		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
 							      ireq->rmt_addr);
-		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -126,7 +126,6 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
-		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 		return net_xmit_eval(err);
 	}

--NzB8fVQJ5HfG6fxh--
