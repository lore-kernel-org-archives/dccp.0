From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 08 Dec 2006 13:26:33 +0000
Subject: Re: [Patchv3 4/12]: Deprecate ccid_hc_tx_insert_options
Message-Id: <200612081326.33942@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Please find below the revised patch which now removes  
the function ccid_hc_tx_insert_options completely from 
the interface. 

I have compile-tested this and 
uploaded it as 16d_deprecate_tx_insert_options.diff


------------------------> Patchv3 <-------------------------------------

[CCID 3]: Deprecate ccid_hc_tx_insert_options

 The function ccid3_hc_tx_insert_options only does a redundant no-op, 
 as the operation 

  DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;

 is already performed _unconditionally_ in ccid3_hc_tx_send_packet.

 Since there is further no current need for this function, it is removed
 entirely. Since furthermore, there is actually no present need for the
 entire interface function ccid_hc_tx_insert_options, it was decided to
 remove it also, to clean up the interface.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |   10 ----------
 net/dccp/ccids/ccid3.c |   12 ------------
 net/dccp/options.c     |    5 -----
 3 files changed, 27 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -551,17 +551,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 }
 
-static int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	BUG_ON(hctx = NULL);
-
-	if (sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN)
-		DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
-	return 0;
-}
-
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 				     unsigned char len, u16 idx,
 				     unsigned char *value)
@@ -1216,7 +1205,6 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
-	.ccid_hc_tx_insert_options = ccid3_hc_tx_insert_options,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -43,8 +43,6 @@ struct ccid_operations {
 						    unsigned char* value);
 	int		(*ccid_hc_rx_insert_options)(struct sock *sk,
 						     struct sk_buff *skb);
-	int		(*ccid_hc_tx_insert_options)(struct sock *sk,
-						     struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_recv)(struct sock *sk,
 						  struct sk_buff *skb);
 	int		(*ccid_hc_tx_parse_options)(struct sock *sk,
@@ -146,14 +144,6 @@ static inline int ccid_hc_rx_parse_optio
 	return rc;
 }
 
-static inline int ccid_hc_tx_insert_options(struct ccid *ccid, struct sock *sk,
-					    struct sk_buff *skb)
-{
-	if (ccid->ccid_ops->ccid_hc_tx_insert_options != NULL)
-		return ccid->ccid_ops->ccid_hc_tx_insert_options(sk, skb);
-	return 0;
-}
-
 static inline int ccid_hc_rx_insert_options(struct ccid *ccid, struct sock *sk,
 					    struct sk_buff *skb)
 {
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -557,11 +557,6 @@ int dccp_insert_options(struct sock *sk,
 			return -1;
 		dp->dccps_hc_rx_insert_options = 0;
 	}
-	if (dp->dccps_hc_tx_insert_options) {
-		if (ccid_hc_tx_insert_options(dp->dccps_hc_tx_ccid, sk, skb))
-			return -1;
-		dp->dccps_hc_tx_insert_options = 0;
-	}
 
 	/* Feature negotiation */
 	/* Data packets can't do feat negotiation */
