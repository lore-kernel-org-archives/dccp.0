From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:59:10 +0000
Subject: [PATCH 5/8] Share ccid3_hc_tx_parse_options function and rename it to the new naming schema
Message-Id: <200712201359.11111.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Share ccid3_hc_tx_parse_options function and rename it to the new naming schema

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -427,68 +427,6 @@ done_computing_x:
 		       "(%luus)\n", usecs_to_jiffies(t_nfb), t_nfb);
 }
 
-static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
-				     unsigned char len, u16 idx,
-				     unsigned char *value)
-{
-	int rc = 0;
-	const struct dccp_sock *dp = dccp_sk(sk);
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	struct tfrc_options_received *opt_recv;
-	__be32 opt_val;
-
-	opt_recv = &hctx->tfrchctx_options_received;
-
-	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
-		opt_recv->tfrcor_seqno	      = dp->dccps_gsr;
-		opt_recv->tfrcor_loss_event_rate    = ~0;
-		opt_recv->tfrcor_loss_intervals_idx = 0;
-		opt_recv->tfrcor_loss_intervals_len = 0;
-		opt_recv->tfrcor_receive_rate	      = 0;
-	}
-
-	switch (option) {
-	case TFRC_OPT_LOSS_EVENT_RATE:
-		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
-			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_loss_event_rate);
-		}
-		break;
-	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->tfrcor_loss_intervals_idx = idx;
-		opt_recv->tfrcor_loss_intervals_len = len;
-		ccid3_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
-			       dccp_role(sk), sk,
-			       opt_recv->tfrcor_loss_intervals_idx,
-			       opt_recv->tfrcor_loss_intervals_len);
-		break;
-	case TFRC_OPT_RECEIVE_RATE:
-		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_RECEIVE_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
-			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_receive_rate);
-		}
-		break;
-	}
-
-	return rc;
-}
-
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
@@ -823,7 +761,7 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
-	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
+	.ccid_hc_tx_parse_options  = tfrc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid3_hc_rx_exit,
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -454,71 +454,6 @@ done_computing_x:
 		       "(%luus)\n", usecs_to_jiffies(t_nfb), t_nfb);
 }
 
-static int ccid4_hc_tx_parse_options(struct sock *sk, unsigned char option,
-				     unsigned char len, u16 idx,
-				     unsigned char *value)
-{
-	int rc = 0;
-	const struct dccp_sock *dp = dccp_sk(sk);
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	struct tfrc_options_received *opt_recv;
-	u32 opt_val;
-
-	opt_recv = &hctx->tfrchctx_options_received;
-
-	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
-		opt_recv->tfrcor_seqno		     = dp->dccps_gsr;
-		opt_recv->tfrcor_loss_event_rate    = ~0;
-		opt_recv->tfrcor_loss_intervals_idx = 0;
-		opt_recv->tfrcor_loss_intervals_len = 0;
-		opt_recv->tfrcor_receive_rate	     = 0;
-	}
-
-	switch (option) {
-	case TFRC_OPT_LOSS_EVENT_RATE:
-		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((u32 *)value);
-			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
-			ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_loss_event_rate);
-		}
-		break;
-	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->tfrcor_loss_intervals_idx = idx;
-		opt_recv->tfrcor_loss_intervals_len = len;
-		ccid4_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
-			       dccp_role(sk), sk,
-			       opt_recv->tfrcor_loss_intervals_idx,
-			       opt_recv->tfrcor_loss_intervals_len);
-		break;
-	case TFRC_OPT_RECEIVE_RATE:
-		if (unlikely(len != 4)) {
-			DCCP_WARN("%s(%p), invalid len %d "
-				  "for TFRC_OPT_RECEIVE_RATE\n",
-				  dccp_role(sk), sk, len);
-			rc = -EINVAL;
-		} else {
-			opt_val = get_unaligned((u32 *)value);
-			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
-			ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
-				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_receive_rate);
-		}
-		break;
-		case TFRC_OPT_DROPPED_PACKETS:
-		/* FIXME: Implement this sock option according to ccid-4 draft */
-		break;
-	}
-
-	return rc;
-}
-
 static int ccid4_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
@@ -850,7 +785,7 @@ static struct ccid_operations ccid4 = {
 	.ccid_hc_tx_send_packet	   = ccid4_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid4_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid4_hc_tx_packet_recv,
-	.ccid_hc_tx_parse_options  = ccid4_hc_tx_parse_options,
+	.ccid_hc_tx_parse_options  = tfrc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid4_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid4_hc_rx_exit,
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -63,3 +63,70 @@ inline void tfrc_hc_tx_update_win_count(
 }
 
 EXPORT_SYMBOL_GPL(tfrc_hc_tx_update_win_count);
+
+int tfrc_tx_parse_options(struct sock *sk, unsigned char option,
+				     unsigned char len, u16 idx,
+				     unsigned char *value)
+{
+	int rc = 0;
+	const struct dccp_sock *dp = dccp_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_options_received *opt_recv;
+	u32 opt_val;
+
+	opt_recv = &hctx->ttx_options_received;
+
+	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
+		opt_recv->tfrcor_seqno		    = dp->dccps_gsr;
+		opt_recv->tfrcor_loss_event_rate    = ~0;
+		opt_recv->tfrcor_loss_intervals_idx = 0;
+		opt_recv->tfrcor_loss_intervals_len = 0;
+		opt_recv->tfrcor_receive_rate	    = 0;
+	}
+
+	switch (option) {
+	case TFRC_OPT_LOSS_EVENT_RATE:
+		if (unlikely(len != 4)) {
+			DCCP_WARN("%s(%p), invalid len %d "
+				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
+				  dccp_role(sk), sk, len);
+			rc = -EINVAL;
+		} else {
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
+			/*ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
+				       dccp_role(sk), sk,
+				       opt_recv->tfrcor_loss_event_rate);*/
+		}
+		break;
+	case TFRC_OPT_LOSS_INTERVALS:
+		opt_recv->tfrcor_loss_intervals_idx = idx;
+		opt_recv->tfrcor_loss_intervals_len = len;
+		/*ccid4_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
+			       dccp_role(sk), sk,
+			       opt_recv->tfrcor_loss_intervals_idx,
+			       opt_recv->tfrcor_loss_intervals_len);*/
+		break;
+	case TFRC_OPT_RECEIVE_RATE:
+		if (unlikely(len != 4)) {
+			DCCP_WARN("%s(%p), invalid len %d "
+				  "for TFRC_OPT_RECEIVE_RATE\n",
+				  dccp_role(sk), sk, len);
+			rc = -EINVAL;
+		} else {
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
+			/*ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
+				       dccp_role(sk), sk,
+				       opt_recv->tfrcor_receive_rate);*/
+		}
+		break;
+	case TFRC_OPT_DROPPED_PACKETS:
+		/* FIXME: Implement this sock option according to ccid-4 draft */
+		break;
+	}
+
+	return rc;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_tx_parse_options);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -193,3 +193,6 @@ extern u32 tfrc_hc_tx_idle_rtt(struct tf
 
 extern void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
 				          ktime_t now);
+
+extern int tfrc_tx_parse_options(struct sock *sk, unsigned char option,
+			     unsigned char len, u16 idx, unsigned char *value);
