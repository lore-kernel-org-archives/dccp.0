From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:59:18 +0000
Subject: [PATCH 7/8] Fix name schema for option received struct
Message-Id: <200712201359.18542.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Fix name schema for option received struct.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -347,11 +347,11 @@ static void ccid3_hc_tx_packet_recv(stru
 	hctx->ttx_rtt = tfrc_ewma(hctx->ttx_rtt, r_sample, 9);
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ttx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->ttx_x_recv = opt_recv->trx_receive_rate;
 	hctx->ttx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->tfrcor_loss_event_rate;
+	pinv = opt_recv->trx_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 		hctx->ttx_p = 0;
 	else				       /* can not exceed 100% */
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -374,11 +374,11 @@ static void ccid4_hc_tx_packet_recv(stru
 	hctx->ttx_rtt = tfrc_ewma(hctx->ttx_rtt, r_sample, 9);
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ttx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->ttx_x_recv = opt_recv->trx_receive_rate;
 	hctx->ttx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->tfrcor_loss_event_rate;
+	pinv = opt_recv->trx_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 		hctx->ttx_p = 0;
 	else				       /* can not exceed 100% */
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -76,12 +76,12 @@ int tfrc_tx_parse_options(struct sock *s
 
 	opt_recv = &hctx->ttx_options_received;
 
-	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
-		opt_recv->tfrcor_seqno		    = dp->dccps_gsr;
-		opt_recv->tfrcor_loss_event_rate    = ~0;
-		opt_recv->tfrcor_loss_intervals_idx = 0;
-		opt_recv->tfrcor_loss_intervals_len = 0;
-		opt_recv->tfrcor_receive_rate	    = 0;
+	if (opt_recv->trx_seqno != dp->dccps_gsr) {
+		opt_recv->trx_seqno		 = dp->dccps_gsr;
+		opt_recv->trx_loss_event_rate    = ~0;
+		opt_recv->trx_loss_intervals_idx = 0;
+		opt_recv->trx_loss_intervals_len = 0;
+		opt_recv->trx_receive_rate	 = 0;
 	}
 
 	switch (option) {
@@ -93,19 +93,19 @@ int tfrc_tx_parse_options(struct sock *s
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((u32 *)value);
-			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
+			opt_recv->trx_loss_event_rate = ntohl(opt_val);
 			/*ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_loss_event_rate);*/
+				       opt_recv->trx_loss_event_rate);*/
 		}
 		break;
 	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->tfrcor_loss_intervals_idx = idx;
-		opt_recv->tfrcor_loss_intervals_len = len;
+		opt_recv->trx_loss_intervals_idx = idx;
+		opt_recv->trx_loss_intervals_len = len;
 		/*ccid4_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
 			       dccp_role(sk), sk,
-			       opt_recv->tfrcor_loss_intervals_idx,
-			       opt_recv->tfrcor_loss_intervals_len);*/
+			       opt_recv->trx_loss_intervals_idx,
+			       opt_recv->trx_loss_intervals_len);*/
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
@@ -115,10 +115,10 @@ int tfrc_tx_parse_options(struct sock *s
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((u32 *)value);
-			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
+			opt_recv->trx_receive_rate = ntohl(opt_val);
 			/*ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->tfrcor_receive_rate);*/
+				       opt_recv->trx_receive_rate);*/
 		}
 		break;
 	case TFRC_OPT_DROPPED_PACKETS:
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -39,13 +39,13 @@ enum tfrc_options {
 };
 
 struct tfrc_options_received {
-	u64  tfrcor_seqno:48;
-	u64  tfrcor_loss_intervals_idx:16;
-	u16  tfrcor_dropped_packets_idx;
-	u16  tfrcor_loss_intervals_len;
-	u16  tfrcor_dropped_packets_len;
-	u32  tfrcor_loss_event_rate;
-	u32  tfrcor_receive_rate;
+	u64  trx_seqno:48;
+	u64  trx_loss_intervals_idx:16;
+	u16  trx_dropped_packets_idx;
+	u16  trx_loss_intervals_len;
+	u16  trx_dropped_packets_len;
+	u32  trx_loss_event_rate;
+	u32  trx_receive_rate;
 };
 
 /* TFRC sender states */
