From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:31:20 +0000
Subject: [PATCH 2/2] Modifies CCID4 in order to work with tfrc-sp
Message-Id: <4AD4B968.1030508@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Modifies CCID4 in order to work with tfrc-sp.

Changes:
 - Implements random ecn nonce to be added to sent packets at ccid4
 - Adds parsing of options loss intervals and dropped packets
 - Adds checking of parsed info from options

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work04/net/dccp/ccids/ccid4.h
=================================--- dccp_tree_work04.orig/net/dccp/ccids/ccid4.h	2009-10-12 20:01:07.523059905 -0300
+++ dccp_tree_work04/net/dccp/ccids/ccid4.h	2009-10-12 20:11:01.847156634 -0300
@@ -6,6 +6,13 @@
  *
  *  An implementation of the DCCP protocol
  *
+ *  Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab. For further information
+ *  please see http://embedded.ufcg.edu.br/
+ *  <ivocalado@embedded.ufcg.edu.br> <desadoc@gmail.com> <leandroal@gmail.com>
+ *
  *  Copyright (c) 2007 Leandro Sales, Tommi Saviranta
  *
  *  This code has been developed by the Federal University of Campina Grande
@@ -47,7 +54,7 @@
 #ifndef _DCCP_CCID4_H_
 #define _DCCP_CCID4_H_
 
-#include "lib/tfrc_ccids.h"
+#include "lib/tfrc_ccids_sp.h"
 
 /* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
 #define NOM_PACKET_SIZE            1460
Index: dccp_tree_work04/net/dccp/ccids/ccid4.c
=================================--- dccp_tree_work04.orig/net/dccp/ccids/ccid4.c	2009-10-12 20:01:07.511531378 -0300
+++ dccp_tree_work04/net/dccp/ccids/ccid4.c	2009-10-12 20:13:07.272031863 -0300
@@ -6,6 +6,13 @@
  *
  *  An implementation of the DCCP protocol
  *
+ *  Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab. For further information
+ *  please see http://embedded.ufcg.edu.br/
+ *  <ivocalado@embedded.ufcg.edu.br> <desadoc@gmail.com> <leandroal@gmail.com>
+ *
  *  Copyright (c) 2007 Leandro Sales, Tommi Saviranta
  *
  *  This code has been developed by the Federal University of Campina Grande
@@ -295,9 +302,14 @@
 		if (delay >= TFRC_T_DELTA)
 			return (u32)delay / USEC_PER_MSEC;
 
-		tfrc_hc_tx_update_win_count(hctx, now);
+		tfrc_sp_hc_tx_update_win_count(hctx, now);
 	}
 
+	if (dccp_data_packet(skb))
+		DCCP_SKB_CB(skb)->dccpd_ecn +			tfrc_sp_get_random_ect(&hctx->li_data,
+					       DCCP_SKB_CB(skb)->dccpd_seq);
+
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval  = hctx->last_win_count;
@@ -314,14 +326,15 @@
 	/* Changes to s will become effective the next time X is computed */
 	hctx->s = ccid4_hc_tx_measure_packet_size(sk, len);
 
-	if (tfrc_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss))
-		DCCP_CRIT("packet history - out of memory!");
+	if (tfrc_sp_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss,
+		hctx->last_win_count))
+			DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid4_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	struct tfrc_tx_hist_entry *acked;
+	struct tfrc_tx_hist_entry *acked, *old;
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 r_sample;
@@ -342,7 +355,10 @@
 	if (acked = NULL)
 		return;
 	/* For the sake of RTT sampling, ignore/remove all older entries */
-	tfrc_tx_hist_purge(&acked->next);
+	old = tfrc_tx_hist_two_rtt_old(hctx->hist,
+				       DCCP_SKB_CB(skb)->dccpd_ccval);
+	if (old != NULL)
+		tfrc_sp_tx_hist_purge(&old->next);
 
 	/* Update the moving average for the RTT estimate (RFC 3448, 4.3) */
 	now	  = ktime_get_real();
@@ -375,7 +391,7 @@
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 	if (hctx->p > 0)
-		hctx->x_calc = tfrc_calc_x(NOM_PACKET_SIZE, hctx->rtt, hctx->p);
+		hctx->x_calc = tfrc_sp_calc_x(NOM_PACKET_SIZE, hctx->rtt, hctx->p);
 	ccid4_hc_tx_update_x(sk, &now);
 
 done_computing_x:
@@ -453,6 +469,8 @@
 				     u8 option, u8 *optval, u8 optlen)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct sk_buff *skb;
+	u32 new_p;
 	__be32 opt_val;
 
 	switch (option) {
@@ -477,14 +495,72 @@
 				       dccp_role(sk), sk, opt_val);
 		} else {
 			/* Update the fixpoint Loss Event Rate fraction */
-			hctx->p = tfrc_invert_loss_event_rate(opt_val);
+			hctx->p = tfrc_sp_invert_loss_event_rate(opt_val);
 
 			ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		}
 		break;
 	case TFRC_OPT_DROPPED_PACKETS:
-		/* FIXME: Implement this sock option according to ccid-4 draft */
+		tfrc_sp_parse_dropped_packets_opt(&hctx->li_data,
+						  optval, optlen);
+
+		skb = skb_peek(&sk->sk_receive_queue);
+
+		if (skb = NULL)
+			break;
+
+		if (!tfrc_sp_check_ecn_sum(&hctx->li_data,
+					   optval, optlen, skb)) {
+			/*
+			 * TODO: consider ecn sum test fail
+			 * and update allowed sending rate
+			 */
+		}
+
+		new_p +		tfrc_sp_p_from_loss_intervals_opt(&hctx->li_data,
+						  hctx->hist,
+						  hctx->last_win_count,
+						  DCCP_SKB_CB(skb)->dccpd_seq);
+		if (hctx->p != new_p) {
+			/*
+			 * TODO: use p value obtained
+			 * from loss intervals option
+			 */
+		}
+
+		break;
+	case TFRC_OPT_LOSS_INTERVALS:
+
+		hctx->li_data.skip_length = *optval;
+		tfrc_sp_parse_loss_intervals_opt(&hctx->li_data,
+						 optval, optlen);
+
+		skb = skb_peek(&sk->sk_receive_queue);
+
+		if (skb = NULL)
+			break;
+
+		if (!tfrc_sp_check_ecn_sum(&hctx->li_data,
+					   optval, optlen, skb)) {
+			/*
+			 * TODO: consider ecn sum test fail
+			 * and update allowed sending rate
+			 */
+		}
+
+		new_p +		tfrc_sp_p_from_loss_intervals_opt(&hctx->li_data,
+						  hctx->hist,
+						  hctx->last_win_count,
+						  DCCP_SKB_CB(skb)->dccpd_seq);
+		if (hctx->p != new_p) {
+			/*
+			 * TODO: use p value obtained
+			 * from loss intervals option
+			 */
+		}
 		break;
 	}
 	return 0;
@@ -505,7 +581,8 @@
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	sk_stop_timer(sk, &hctx->no_feedback_timer);
-	tfrc_tx_hist_purge(&hctx->hist);
+	tfrc_sp_tx_hist_purge(&hctx->hist);
+	tfrc_sp_tx_ld_cleanup(&hctx->li_data.ecn_sums_head);
 }
 
 static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
@@ -584,7 +661,7 @@
 		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
 		 * always check whether at least RTT time units were covered.
 		 */
-		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hcrx->x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
 		break;
 	case TFRC_FBACK_PERIODIC:
 		/*
@@ -594,7 +671,7 @@
 		 */
 		if (hcrx->hist.bytes_recvd = 0)
 			goto prepare_for_next_time;
-		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hcrx->x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
 		break;
 	default:
 		return;
@@ -613,7 +690,8 @@
 
 static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	u16 dropped_length, loss_intervals_length;
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
@@ -625,10 +703,24 @@
 	x_recv = htonl(hcrx->x_recv);
 	pinv   = htonl(hcrx->p_inverse);
 
+	loss_intervals_length	+		(hcrx->li_data.counter > TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH) ?
+		 TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH : hcrx->li_data.counter;
+	dropped_length		+		(hcrx->li_data.counter > TFRC_DROP_OPT_MAX_LENGTH) ?
+		 TFRC_DROP_OPT_MAX_LENGTH : hcrx->li_data.counter;
+
+	tfrc_sp_ld_prepare_data(hcrx->hist.loss_count, &hcrx->li_data);
+
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
-			       &x_recv, sizeof(x_recv)))
+			       &x_recv, sizeof(x_recv)) ||
+	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_INTERVALS,
+			       &hcrx->li_data.loss_intervals_opts[0],
+			       1 + loss_intervals_length*9) ||
+	    dccp_insert_option(sk, skb, TFRC_OPT_DROPPED_PACKETS,
+			       &hcrx->li_data.drop_opts[0], dropped_length*3))
 		return -1;
 
 	return 0;
@@ -657,12 +749,12 @@
 	if (unlikely(hcrx->feedback = TFRC_FBACK_NONE))
 		return 5;
 
-	x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+	x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
 	if (x_recv = 0)
 		goto failed;
 
 	fval = scaled_div32(scaled_div(NOM_PACKET_SIZE, rtt), x_recv);
-	p = tfrc_calc_x_reverse_lookup(fval);
+	p = tfrc_sp_calc_x_reverse_lookup(fval);
 
 	ccid4_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
@@ -682,8 +774,9 @@
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_congestion_event(&hcrx->hist, &hcrx->li_hist,
-				     skb, ndp, ccid4_first_li, sk))
+	if (tfrc_sp_rx_congestion_event(&hcrx->hist, &hcrx->li_hist,
+					&hcrx->li_data,
+					skb, ndp, ccid4_first_li, sk))
 		ccid4_hc_rx_send_feedback(sk, skb, TFRC_FBACK_PARAM_CHANGE);
 	/*
 	 * Feedback for first non-empty data packet (RFC 3448, 6.3)
@@ -703,15 +796,18 @@
 	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	tfrc_lh_init(&hcrx->li_hist);
-	return tfrc_rx_hist_init(&hcrx->hist, sk);
+	tfrc_ld_init(&hcrx->li_data);
+
+	return tfrc_sp_rx_hist_init(&hcrx->hist, sk);
 }
 
 static void ccid4_hc_rx_exit(struct sock *sk)
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
-	tfrc_rx_hist_purge(&hcrx->hist);
-	tfrc_lh_cleanup(&hcrx->li_hist);
+	tfrc_sp_rx_hist_purge(&hcrx->hist);
+	tfrc_sp_lh_cleanup(&hcrx->li_hist);
+	tfrc_sp_ld_cleanup(&hcrx->li_data);
 }
 
 static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -733,7 +829,7 @@
 			return -EINVAL;
 		rx_info.tfrcrx_x_recv = hcrx->x_recv;
 		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hcrx->hist);
-		rx_info.tfrcrx_p      = tfrc_invert_loss_event_rate(hcrx->p_inverse);
+		rx_info.tfrcrx_p      = tfrc_sp_invert_loss_event_rate(hcrx->p_inverse);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
@@ -755,7 +851,7 @@
 	.ccid_hc_tx_exit	   = ccid4_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid4_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid4_hc_tx_packet_sent,
-	.ccid_hc_tx_probe	   = tfrc_hc_tx_probe,
+	.ccid_hc_tx_probe	   = tfrc_sp_hc_tx_probe,
 	.ccid_hc_tx_packet_recv	   = ccid4_hc_tx_packet_recv,
 	.ccid_hc_tx_parse_options  = ccid4_hc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
Index: dccp_tree_work04/net/dccp/ccids/Kconfig
=================================--- dccp_tree_work04.orig/net/dccp/ccids/Kconfig	2009-10-12 20:02:20.807391426 -0300
+++ dccp_tree_work04/net/dccp/ccids/Kconfig	2009-10-12 20:02:47.843653027 -0300
@@ -160,7 +160,10 @@
 endif	# IP_DCCP_CCID4
 
 config IP_DCCP_TFRC_LIB
-	def_bool y if (IP_DCCP_CCID3 || IP_DCCP_CCID4)
+	def_bool y if IP_DCCP_CCID3
+
+config IP_DCCP_TFRC_SP_LIB
+	def_bool y if IP_DCCP_CCID4
 
 config IP_DCCP_TFRC_DEBUG
 	def_bool y if (IP_DCCP_CCID3_DEBUG || IP_DCCP_CCID4_DEBUG)

