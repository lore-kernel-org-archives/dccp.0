From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:37 +0000
Subject: [PATCH 10/25] Share ccid-3 options enum and struct via tfrc_ccids
Message-Id: <200710312130.37882.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid-3 options enum and struct via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -416,7 +416,7 @@ static void ccid4_hc_tx_packet_sent(stru
 static void ccid4_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
-	struct ccid4_options_received *opt_recv;
+	struct tfrc_options_received *opt_recv;
 	ktime_t t_send, now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -442,14 +442,14 @@ static void ccid4_hc_tx_packet_recv(stru
 		return;
 	}
 
-	opt_recv = &hctx->ccid4hctx_options_received;
+	opt_recv = &hctx->tfrchctx_options_received;
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid4hctx_x_recv = opt_recv->ccid4or_receive_rate;
+	hctx->ccid4hctx_x_recv = opt_recv->tfrcor_receive_rate;
 	hctx->ccid4hctx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->ccid4or_loss_event_rate;
+	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 		hctx->ccid4hctx_p = 0;
 	else				       /* can not exceed 100% */
@@ -540,17 +540,17 @@ static int ccid4_hc_tx_parse_options(str
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
-	struct ccid4_options_received *opt_recv;
+	struct tfrc_options_received *opt_recv;
 	u32 opt_val;
 
-	opt_recv = &hctx->ccid4hctx_options_received;
+	opt_recv = &hctx->tfrchctx_options_received;
 
-	if (opt_recv->ccid4or_seqno != dp->dccps_gsr) {
-		opt_recv->ccid4or_seqno		     = dp->dccps_gsr;
-		opt_recv->ccid4or_loss_event_rate    = ~0;
-		opt_recv->ccid4or_loss_intervals_idx = 0;
-		opt_recv->ccid4or_loss_intervals_len = 0;
-		opt_recv->ccid4or_receive_rate	     = 0;
+	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
+		opt_recv->tfrcor_seqno		     = dp->dccps_gsr;
+		opt_recv->tfrcor_loss_event_rate    = ~0;
+		opt_recv->tfrcor_loss_intervals_idx = 0;
+		opt_recv->tfrcor_loss_intervals_len = 0;
+		opt_recv->tfrcor_receive_rate	     = 0;
 	}
 
 	switch (option) {
@@ -562,19 +562,19 @@ static int ccid4_hc_tx_parse_options(str
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((u32 *)value);
-			opt_recv->ccid4or_loss_event_rate = ntohl(opt_val);
+			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
 			ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->ccid4or_loss_event_rate);
+				       opt_recv->tfrcor_loss_event_rate);
 		}
 		break;
 	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->ccid4or_loss_intervals_idx = idx;
-		opt_recv->ccid4or_loss_intervals_len = len;
+		opt_recv->tfrcor_loss_intervals_idx = idx;
+		opt_recv->tfrcor_loss_intervals_len = len;
 		ccid4_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
 			       dccp_role(sk), sk,
-			       opt_recv->ccid4or_loss_intervals_idx,
-			       opt_recv->ccid4or_loss_intervals_len);
+			       opt_recv->tfrcor_loss_intervals_idx,
+			       opt_recv->tfrcor_loss_intervals_len);
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
@@ -584,10 +584,10 @@ static int ccid4_hc_tx_parse_options(str
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((u32 *)value);
-			opt_recv->ccid4or_receive_rate = ntohl(opt_val);
+			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
 			ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->ccid4or_receive_rate);
+				       opt_recv->tfrcor_receive_rate);
 		}
 		break;
 	}
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -62,20 +62,6 @@
  */
 #define CCID4HCTX_H    36
 
-enum ccid4_options {
-	TFRC_OPT_LOSS_EVENT_RATE = 192,
-	TFRC_OPT_LOSS_INTERVALS	 = 193,
-	TFRC_OPT_RECEIVE_RATE	 = 194,
-};
-
-struct ccid4_options_received {
-	u64 ccid4or_seqno:48,
-	    ccid4or_loss_intervals_idx:16;
-	u16 ccid4or_loss_intervals_len;
-	u32 ccid4or_loss_event_rate;
-	u32 ccid4or_receive_rate;
-};
-
 /* TFRC sender states */
 enum ccid4_hc_tx_states {
 	TFRC_SSTATE_NO_SENT = 1,
@@ -123,7 +109,7 @@ struct ccid4_hc_tx_sock {
 	ktime_t				ccid4hctx_t_nom;
 	u32				ccid4hctx_delta;
 	struct tfrc_tx_hist_head	ccid4hctx_hist;
-	struct ccid4_options_received	ccid4hctx_options_received;
+	struct tfrc_options_received	tfrchctx_options_received;
 };
 
 static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -31,3 +31,17 @@
 #define TFRC_T_MBI		   64
 
 #endif /* _TFRC_CCIDS_H_ */
+
+enum tfrc_options {
+	TFRC_OPT_LOSS_EVENT_RATE = 192,
+	TFRC_OPT_LOSS_INTERVALS	 = 193,
+	TFRC_OPT_RECEIVE_RATE	 = 194,
+};
+
+struct tfrc_options_received {
+	u64 tfrcor_seqno:48,
+	    tfrcor_loss_intervals_idx:16;
+	u16 tfrcor_loss_intervals_len;
+	u32 tfrcor_loss_event_rate;
+	u32 tfrcor_receive_rate;
+};
Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -390,7 +390,7 @@ static void ccid3_hc_tx_packet_sent(stru
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv;
+	struct tfrc_options_received *opt_recv;
 	ktime_t t_send, now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -416,14 +416,14 @@ static void ccid3_hc_tx_packet_recv(stru
 		return;
 	}
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->tfrchctx_options_received;
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+	hctx->ccid3hctx_x_recv = opt_recv->tfrcor_receive_rate;
 	hctx->ccid3hctx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->ccid3or_loss_event_rate;
+	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 		hctx->ccid3hctx_p = 0;
 	else				       /* can not exceed 100% */
@@ -514,17 +514,17 @@ static int ccid3_hc_tx_parse_options(str
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv;
+	struct tfrc_options_received *opt_recv;
 	__be32 opt_val;
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->tfrchctx_options_received;
 
-	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
-		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
-		opt_recv->ccid3or_loss_event_rate    = ~0;
-		opt_recv->ccid3or_loss_intervals_idx = 0;
-		opt_recv->ccid3or_loss_intervals_len = 0;
-		opt_recv->ccid3or_receive_rate	     = 0;
+	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
+		opt_recv->tfrcor_seqno	      = dp->dccps_gsr;
+		opt_recv->tfrcor_loss_event_rate    = ~0;
+		opt_recv->tfrcor_loss_intervals_idx = 0;
+		opt_recv->tfrcor_loss_intervals_len = 0;
+		opt_recv->tfrcor_receive_rate	      = 0;
 	}
 
 	switch (option) {
@@ -536,19 +536,19 @@ static int ccid3_hc_tx_parse_options(str
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->ccid3or_loss_event_rate = ntohl(opt_val);
+			opt_recv->tfrcor_loss_event_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->ccid3or_loss_event_rate);
+				       opt_recv->tfrcor_loss_event_rate);
 		}
 		break;
 	case TFRC_OPT_LOSS_INTERVALS:
-		opt_recv->ccid3or_loss_intervals_idx = idx;
-		opt_recv->ccid3or_loss_intervals_len = len;
+		opt_recv->tfrcor_loss_intervals_idx = idx;
+		opt_recv->tfrcor_loss_intervals_len = len;
 		ccid3_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
 			       dccp_role(sk), sk,
-			       opt_recv->ccid3or_loss_intervals_idx,
-			       opt_recv->ccid3or_loss_intervals_len);
+			       opt_recv->tfrcor_loss_intervals_idx,
+			       opt_recv->tfrcor_loss_intervals_len);
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
@@ -558,10 +558,10 @@ static int ccid3_hc_tx_parse_options(str
 			rc = -EINVAL;
 		} else {
 			opt_val = get_unaligned((__be32 *)value);
-			opt_recv->ccid3or_receive_rate = ntohl(opt_val);
+			opt_recv->tfrcor_receive_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
-				       opt_recv->ccid3or_receive_rate);
+				       opt_recv->tfrcor_receive_rate);
 		}
 		break;
 	}
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -39,20 +39,6 @@
 #include "lib/tfrc_ccids.h"
 #include "../ccid.h"
 
-enum ccid3_options {
-	TFRC_OPT_LOSS_EVENT_RATE = 192,
-	TFRC_OPT_LOSS_INTERVALS	 = 193,
-	TFRC_OPT_RECEIVE_RATE	 = 194,
-};
-
-struct ccid3_options_received {
-	u64 ccid3or_seqno:48,
-	    ccid3or_loss_intervals_idx:16;
-	u16 ccid3or_loss_intervals_len;
-	u32 ccid3or_loss_event_rate;
-	u32 ccid3or_receive_rate;
-};
-
 /* TFRC sender states */
 enum ccid3_hc_tx_states {
 	TFRC_SSTATE_NO_SENT = 1,
@@ -100,7 +86,7 @@ struct ccid3_hc_tx_sock {
 	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
 	struct tfrc_tx_hist_head	ccid3hctx_hist;
-	struct ccid3_options_received	ccid3hctx_options_received;
+	struct tfrc_options_received	tfrchctx_options_received;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
