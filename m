From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 14:30:21 +0000
Subject: [PATCH 3/8]: Remove duplicate code for Reset from connected socket
Message-Id: <200709251530.21163@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove duplicate code for Reset from connected socket

In this patch, duplicated code is removed for the case when a Reset packet is
sent from a connected socket. This code duplication is between dccp_make_reset
and dccp_transmit_skb, which already contained an (up to now entirely unused)
switch statement to fill in the reset code from the DCCP_SKB_CB.

The only thing that has been removed is the call to dst_clone(dst), since
the queue_xmit functions use sk_dst_cache anyway.

I wasn't sure which purpose inet_sk_rebuild_header served, so I left it in.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   78 +++++++++++++-----------------------------------------
 1 file changed, 19 insertions(+), 59 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -61,6 +61,7 @@ static int dccp_transmit_skb(struct sock
 			set_ack = 0;
 			/* fall through */
 		case DCCP_PKT_DATAACK:
+		case DCCP_PKT_RESET:
 			break;
 
 		case DCCP_PKT_REQUEST:
@@ -73,8 +74,10 @@ static int dccp_transmit_skb(struct sock
 			/* fall through */
 		default:
 			/*
-			 * Only data packets should come through with skb->sk
-			 * set.
+			 * Set owner/destructor: some skbs are allocated via
+			 * alloc_skb (e.g. when retransmission may happen).
+			 * Only Data, DataAck, and Reset packets should come
+			 * through here with skb->sk set.
 			 */
 			WARN_ON(skb->sk);
 			skb_set_owner_w(skb, sk);
@@ -328,72 +331,29 @@ struct sk_buff *dccp_make_response(struc
 
 EXPORT_SYMBOL_GPL(dccp_make_response);
 
-static struct sk_buff *dccp_make_reset(struct sock *sk, struct dst_entry *dst,
-				       const enum dccp_reset_codes code)
-{
-	struct dccp_hdr *dh;
-	struct dccp_sock *dp = dccp_sk(sk);
-	const u32 dccp_header_size = sizeof(struct dccp_hdr) +
-				     sizeof(struct dccp_hdr_ext) +
-				     sizeof(struct dccp_hdr_reset);
-	struct sk_buff *skb = sock_wmalloc(sk, sk->sk_prot->max_header, 1,
-					   GFP_ATOMIC);
-	if (skb = NULL)
-		return NULL;
-
-	/* Reserve space for headers. */
-	skb_reserve(skb, sk->sk_prot->max_header);
-
-	skb->dst = dst_clone(dst);
-
-	dccp_inc_seqno(&dp->dccps_gss);
-
-	DCCP_SKB_CB(skb)->dccpd_reset_code = code;
-	DCCP_SKB_CB(skb)->dccpd_type	   = DCCP_PKT_RESET;
-	DCCP_SKB_CB(skb)->dccpd_seq	   = dp->dccps_gss;
-
-	if (dccp_insert_options(sk, skb)) {
-		kfree_skb(skb);
-		return NULL;
-	}
-
-	dh = dccp_zeroed_hdr(skb, dccp_header_size);
-
-	dh->dccph_sport	= inet_sk(sk)->sport;
-	dh->dccph_dport	= inet_sk(sk)->dport;
-	dh->dccph_doff	= (dccp_header_size +
-			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
-	dh->dccph_type	= DCCP_PKT_RESET;
-	dh->dccph_x	= 1;
-	dccp_hdr_set_seq(dh, dp->dccps_gss);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dp->dccps_gsr);
-
-	dccp_hdr_reset(skb)->dccph_reset_code = code;
-	inet_csk(sk)->icsk_af_ops->send_check(sk, 0, skb);
-
-	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
-	return skb;
-}
-
+/* send Reset on established socket, to close or abort the connection */
 int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 {
+	struct sk_buff *skb;
 	/*
 	 * FIXME: what if rebuild_header fails?
 	 * Should we be doing a rebuild_header here?
 	 */
 	int err = inet_sk_rebuild_header(sk);
 
-	if (err = 0) {
-		struct sk_buff *skb = dccp_make_reset(sk, sk->sk_dst_cache,
-						      code);
-		if (skb != NULL) {
-			memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-			err = inet_csk(sk)->icsk_af_ops->queue_xmit(skb, 0);
-			return net_xmit_eval(err);
-		}
-	}
+	if (err != 0)
+		return err;
+
+	skb = sock_wmalloc(sk, sk->sk_prot->max_header, 1, GFP_ATOMIC);
+	if (skb = NULL)
+		return -ENOBUFS;
+
+	/* Reserve space for headers and prepare control bits. */
+	skb_reserve(skb, sk->sk_prot->max_header);
+	DCCP_SKB_CB(skb)->dccpd_type	   = DCCP_PKT_RESET;
+	DCCP_SKB_CB(skb)->dccpd_reset_code = code;
 
-	return err;
+	return dccp_transmit_skb(sk, skb);
 }
 
 /*
