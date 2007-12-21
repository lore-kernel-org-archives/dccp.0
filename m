From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:33:12 +0000
Subject: [PATCHv2 5/8] Share ccid3_hc_tx_parse_options function and rename it to the new naming schema
Message-Id: <200712210133.12907.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Share ccid3_hc_tx_parse_options function and rename it to the new naming schema

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

--------------------> Patch v2 <-------------------------

The first version of this patch doest apply properly in the current ccid4 branch. This new version it is ok.

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -430,68 +430,6 @@ done_computing_x:
 			   jiffies + usecs_to_jiffies(t_nfb));
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
-	opt_recv = &hctx->ttx_options_received;
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
@@ -797,9 +735,9 @@ static int ccid3_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->trx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->trx_rtt;
-		rx_info.tfrcrx_p      = hcrx->trx_pinv = 0 ? ~0U :
+		rx_info.x_recv = hcrx->trx_x_recv;
+		rx_info.rtt    = hcrx->trx_rtt;
+		rx_info.p      = hcrx->trx_pinv = 0 ? ~0U :
 					   scaled_div(1, hcrx->trx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
@@ -824,7 +762,7 @@ static struct ccid_operations ccid3 = {
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
@@ -467,71 +467,6 @@ done_computing_x:
 			   jiffies + usecs_to_jiffies(t_nfb));
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
-	opt_recv = &hctx->ttx_options_received;
-
-	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
-		opt_recv->tfrcor_seqno		    = dp->dccps_gsr;
-		opt_recv->tfrcor_loss_event_rate    = ~0;
-		opt_recv->tfrcor_loss_intervals_idx = 0;
-		opt_recv->tfrcor_loss_intervals_len = 0;
-		opt_recv->tfrcor_receive_rate	    = 0;
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
@@ -834,9 +769,9 @@ static int ccid4_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->trx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->trx_rtt;
-		rx_info.tfrcrx_p      = hcrx->trx_pinv = 0 ? ~0U :
+		rx_info.x_recv = hcrx->trx_x_recv;
+		rx_info.rtt    = hcrx->trx_rtt;
+		rx_info.p      = hcrx->trx_pinv = 0 ? ~0U :
 					   scaled_div(1, hcrx->trx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
@@ -861,7 +796,7 @@ static struct ccid_operations ccid4 = {
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
@@ -11,6 +11,13 @@
  */
 #include "tfrc_ccids.h"
 
+#ifdef CONFIG_IP_DCCP_TFRC_DEBUG
+extern int tfrc_debug;
+#define tfrc_pr_debug(format, a...)	DCCP_PR_DEBUG(tfrc_debug, format, ##a)
+#else
+#define tfrc_pr_debug(format, a...)
+#endif
+
 /*
  * Compute the initial sending rate X_init in the manner of RFC 3390:
  *
@@ -64,3 +71,69 @@ inline void tfrc_hc_tx_update_win_count(
 
 EXPORT_SYMBOL_GPL(tfrc_hc_tx_update_win_count);
 
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
+			tfrc_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
+				       dccp_role(sk), sk,
+				       opt_recv->tfrcor_loss_event_rate);
+		}
+		break;
+	case TFRC_OPT_LOSS_INTERVALS:
+		opt_recv->tfrcor_loss_intervals_idx = idx;
+		opt_recv->tfrcor_loss_intervals_len = len;
+		tfrc_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
+			       dccp_role(sk), sk,
+			       opt_recv->tfrcor_loss_intervals_idx,
+			       opt_recv->tfrcor_loss_intervals_len);
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
+			tfrc_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
+				       dccp_role(sk), sk,
+				       opt_recv->tfrcor_receive_rate);
+		}
+		break;
+		case TFRC_OPT_DROPPED_PACKETS:
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
+			unsigned char len, u16 idx, unsigned char *value);
Index: ccid4.latest/net/dccp/probe.c
=================================--- ccid4.latest.orig/net/dccp/probe.c
+++ ccid4.latest/net/dccp/probe.c
@@ -97,10 +97,10 @@ static int jdccp_sendmsg(struct kiocb *i
 			       "%llu %llu %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
 			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
-			       hctx->tfrchctx_s, hctx->tfrchctx_rtt,
-			       hctx->tfrchctx_p, hctx->tfrchctx_x_calc,
-			       hctx->tfrchctx_x_recv >> 6,
-			       hctx->tfrchctx_x >> 6, hctx->tfrchctx_t_ipi);
+			       hctx->ttx_s, hctx->ttx_rtt,
+			       hctx->ttx_p, hctx->ttx_x_calc,
+			       hctx->ttx_x_recv >> 6,
+			       hctx->ttx_x >> 6, hctx->ttx_t_ipi);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
