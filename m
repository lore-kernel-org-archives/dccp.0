From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:25:12 +0000
Subject: [PATCH 5/7] [DCCP]: Fix CCID3 to correct performance
Message-Id: <200608241525.13792.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes CCID3 to give much closer performance to RFC4342.

CCID3 is meant to alter sending rate based on RTT and loss.

The performance was verified against:
http://wand.net.nz/~perry/max_download.php

For example I tested with netem and had the following parameters:
Delayed Acks 1, MSS 256 bytes, RTT 105 ms, packet loss 5%.

This gives a theoretical speed of 71.9 Kbits/s. I measured across three
runs with this patch set and got 70.1 Kbits/s. Without this patchset the
average was 232 Kbits/s which means Linux can't be used for CCID3 research
properly.

I also tested with netem turned off so box just acting as router with 1.2
msec RTT. The performance with this is the same with or without the patch
at around 30 Mbit/s.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 0f85970..dad20c9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -342,6 +342,8 @@ static int ccid3_hc_tx_send_packet(struc
 		new_packet->dccphtx_ccval  			DCCP_SKB_CB(skb)->dccpd_ccval  				hctx->ccid3hctx_last_win_count;
+		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
+				  hctx->ccid3hctx_t_ipi);
 	}
 out:
 	return rc;
@@ -413,7 +415,8 @@ static void ccid3_hc_tx_packet_sent(stru
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		if (len > 0) {
-			hctx->ccid3hctx_t_nom = now;
+			timeval_sub_usecs(&hctx->ccid3hctx_t_nom,
+				  hctx->ccid3hctx_t_ipi);
 			ccid3_calc_new_t_ipi(hctx);
 			ccid3_calc_new_delta(hctx);
 			timeval_add_usecs(&hctx->ccid3hctx_t_nom,
@@ -757,8 +760,7 @@ static void ccid3_hc_rx_send_feedback(st
 	}
 
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_last_counter	     = packet->dccphrx_ccval;
-	hcrx->ccid3hcrx_seqno_last_counter   = packet->dccphrx_seqno;
+	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	/* Convert to multiples of 10us */
@@ -782,7 +784,7 @@ static int ccid3_hc_rx_insert_options(st
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_last_counter;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
 
 	if (dccp_packet_without_ack(skb))
 		return 0;
@@ -854,6 +856,11 @@ static u32 ccid3_hc_rx_calc_first_li(str
 		interval = 1;
 	}
 found:
+	if (!tail) {
+		LIMIT_NETDEBUG(KERN_WARNING "%s: tail is null\n",
+		   __FUNCTION__);
+		return ~0;
+	}
 	rtt = timeval_delta(&tstamp, &tail->dccphrx_tstamp) * 4 / interval;
 	ccid3_pr_debug("%s, sk=%p, approximated RTT to %uus\n",
 		       dccp_role(sk), sk, rtt);
@@ -864,9 +871,20 @@ found:
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
 	x_recv = usecs_div(hcrx->ccid3hcrx_bytes_recv, delta);
 
+	if (x_recv = 0) 
+		x_recv = hcrx->ccid3hcrx_x_recv;
+
 	tmp1 = (u64)x_recv * (u64)rtt;
 	do_div(tmp1,10000000);
 	tmp2 = (u32)tmp1;
+
+	if (!tmp2) {
+		LIMIT_NETDEBUG(KERN_WARNING "tmp2 = 0 "
+		   "%s: x_recv = %u, rtt =%u\n",
+		   __FUNCTION__, x_recv, rtt);
+		return ~0;
+	}
+
 	fval = (hcrx->ccid3hcrx_s * 100000) / tmp2;
 	/* do not alter order above or you will get overflow on 32 bit */
 	p = tfrc_calc_x_reverse_lookup(fval);
@@ -882,31 +900,101 @@ found:
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct dccp_li_hist_entry *next, *head;
+	u64 seq_temp;
 
-	if (seq_loss != DCCP_MAX_SEQNO + 1 &&
-	    list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		struct dccp_li_hist_entry *li_tail;
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
+		if (!dccp_li_hist_interval_new(ccid3_li_hist,
+		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+			return;
 
-		li_tail = dccp_li_hist_interval_new(ccid3_li_hist,
-						    &hcrx->ccid3hcrx_li_hist,
-						    seq_loss, win_loss);
-		if (li_tail = NULL)
+		next = (struct dccp_li_hist_entry *)
+		   hcrx->ccid3hcrx_li_hist.next;
+		next->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+	} else {
+		struct dccp_li_hist_entry *entry;
+		struct list_head *tail;
+		
+		head = (struct dccp_li_hist_entry *)
+		   hcrx->ccid3hcrx_li_hist.next;
+		/* FIXME win count check removed as was wrong */
+		/* should make this check with receive history */
+		/* and compare there as per section 10.2 of RFC4342 */
+
+		/* new loss event detected */
+		/* calculate last interval length */
+		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
+		entry = dccp_li_hist_entry_new(ccid3_li_hist, SLAB_ATOMIC);
+
+		if (entry = NULL) {
+			printk(KERN_CRIT "%s: out of memory\n",__FUNCTION__);
+			dump_stack();
 			return;
-		li_tail->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
-	} else
-		    LIMIT_NETDEBUG(KERN_WARNING "%s: FIXME: find end of "
-				   "interval\n", __FUNCTION__);
+		}
+
+		list_add(&entry->dccplih_node, &hcrx->ccid3hcrx_li_hist);
+
+		tail = hcrx->ccid3hcrx_li_hist.prev;
+		list_del(tail);
+		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
+
+		/* Create the newest interval */
+		entry->dccplih_seqno = seq_loss;
+		entry->dccplih_interval = seq_temp;
+		entry->dccplih_win_count = win_loss;
+	}
 }
 
-static void ccid3_hc_rx_detect_loss(struct sock *sk)
+static int ccid3_hc_rx_detect_loss(struct sock *sk, 
+                                    struct dccp_rx_hist_entry *packet)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	u8 win_loss;
-	const u64 seq_loss = dccp_rx_hist_detect_loss(&hcrx->ccid3hcrx_hist,
-						      &hcrx->ccid3hcrx_li_hist,
-						      &win_loss);
+	struct dccp_rx_hist_entry *rx_hist = dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
+	u64 seqno = packet->dccphrx_seqno;
+	u64 tmp_seqno;
+	int loss = 0;
+	u8 ccval;
+
+
+	tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
+
+	if (!rx_hist || 
+	   follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
+		hcrx->ccid3hcrx_seqno_nonloss = seqno;
+		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
+		goto detect_out;
+	}
+
 
-	ccid3_hc_rx_update_li(sk, seq_loss, win_loss);
+	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno) 
+	   > TFRC_RECV_NUM_LATE_LOSS) {
+		loss = 1;
+		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
+		   hcrx->ccid3hcrx_ccval_nonloss);
+		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
+		dccp_inc_seqno(&tmp_seqno);
+		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
+		dccp_inc_seqno(&tmp_seqno);
+		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist, 
+		   tmp_seqno, &ccval)) {
+		   	hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
+			hcrx->ccid3hcrx_ccval_nonloss = ccval;
+			dccp_inc_seqno(&tmp_seqno);
+		}
+	}
+
+	/* FIXME - this code could be simplified with above while */
+	/* but works at moment */
+	if (follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
+		hcrx->ccid3hcrx_seqno_nonloss = seqno;
+		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
+	}
+
+detect_out:
+	dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
+		   &hcrx->ccid3hcrx_li_hist, packet, 
+		   hcrx->ccid3hcrx_seqno_nonloss);
+	return loss;
 }
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -916,8 +1004,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
 	u8 win_count;
-	u32 p_prev, r_sample, t_elapsed;
-	int ins;
+	u32 p_prev, rtt_prev, r_sample, t_elapsed;
+	int loss;	
 
 	BUG_ON(hcrx = NULL ||
 	       !(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA ||
@@ -932,7 +1020,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	case DCCP_PKT_DATAACK:
 		if (opt_recv->dccpor_timestamp_echo = 0)
 			break;
-		p_prev = hcrx->ccid3hcrx_rtt;
+		rtt_prev = hcrx->ccid3hcrx_rtt;
 		dccp_timestamp(sk, &now);
 		timeval_sub_usecs(&now, opt_recv->dccpor_timestamp_echo * 10);
 		r_sample = timeval_usecs(&now);
@@ -951,8 +1039,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
 					      r_sample / 10;
 
-		if (p_prev != hcrx->ccid3hcrx_rtt)
-			ccid3_pr_debug("%s, New RTT=%luus, elapsed time=%u\n",
+		if (rtt_prev != hcrx->ccid3hcrx_rtt)
+			ccid3_pr_debug("%s, New RTT=%uus, elapsed time=%u\n",
 				       dccp_role(sk), hcrx->ccid3hcrx_rtt,
 				       opt_recv->dccpor_elapsed_time);
 		break;
@@ -973,8 +1061,7 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	win_count = packet->dccphrx_ccval;
 
-	ins = dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
-				      &hcrx->ccid3hcrx_li_hist, packet);
+	loss = ccid3_hc_rx_detect_loss(sk, packet);
 
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
@@ -991,7 +1078,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	case TFRC_RSTATE_DATA:
 		hcrx->ccid3hcrx_bytes_recv += skb->len -
 					      dccp_hdr(skb)->dccph_doff * 4;
-		if (ins != 0)
+		if (loss)
 			break;
 
 		dccp_timestamp(sk, &now);
@@ -1012,7 +1099,6 @@ static void ccid3_hc_rx_packet_recv(stru
 	ccid3_pr_debug("%s, sk=%p(%s), data loss! Reacting...\n",
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
 
-	ccid3_hc_rx_detect_loss(sk);
 	p_prev = hcrx->ccid3hcrx_p;
 	
 	/* Calculate loss event rate */
@@ -1022,6 +1108,9 @@ static void ccid3_hc_rx_packet_recv(stru
 		/* Scaling up by 1000000 as fixed decimal */
 		if (i_mean != 0)
 			hcrx->ccid3hcrx_p = 1000000 / i_mean;
+	} else {
+		printk(KERN_CRIT "%s: empty loss hist\n",__FUNCTION__);
+		dump_stack();
 	}
 
 	if (hcrx->ccid3hcrx_p > p_prev) {
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 22cb9f8..0a2cb75 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -120,9 +120,10 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_x_recv	ccid3hcrx_tfrc.tfrcrx_x_recv
 #define ccid3hcrx_rtt		ccid3hcrx_tfrc.tfrcrx_rtt
 #define ccid3hcrx_p		ccid3hcrx_tfrc.tfrcrx_p
-  	u64			ccid3hcrx_seqno_last_counter:48,
+  	u64			ccid3hcrx_seqno_nonloss:48,
+				ccid3hcrx_ccval_nonloss:4,
 				ccid3hcrx_state:8,
-				ccid3hcrx_last_counter:4;
+				ccid3hcrx_ccval_last_counter:4;
   	u32			ccid3hcrx_bytes_recv;
   	struct timeval		ccid3hcrx_tstamp_last_feedback;
   	struct timeval		ccid3hcrx_tstamp_last_ack;
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index b93d9fc..b818e96 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/module.h>
+#include <net/sock.h>
 
 #include "loss_interval.h"
 
@@ -90,13 +91,13 @@ u32 dccp_li_hist_calc_i_mean(struct list
 	u32 w_tot  = 0;
 
 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
-		if (i < DCCP_LI_HIST_IVAL_F_LENGTH) {
+		if (li_entry->dccplih_interval != ~0) {
 			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
 			w_tot  += dccp_li_hist_w[i];
+			if (i != 0)
+				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
 		}
 
-		if (i != 0)
-			i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
 
 		if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
 			break;
@@ -107,37 +108,36 @@ u32 dccp_li_hist_calc_i_mean(struct list
 
 	i_tot = max(i_tot0, i_tot1);
 
-	/* FIXME: Why do we do this? -Ian McDonald */
-	if (i_tot * 4 < w_tot)
-		i_tot = w_tot * 4;
-
-	return i_tot * 4 / w_tot;
+	if (!w_tot) {
+		LIMIT_NETDEBUG(KERN_WARNING "%s: w_tot = 0\n", __FUNCTION__);
+		return 1;
+	}
+	
+	return i_tot / w_tot;
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-struct dccp_li_hist_entry *dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-						     struct list_head *list,
-						     const u64 seq_loss,
-						     const u8 win_loss)
+int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+   struct list_head *list, const u64 seq_loss, const u8 win_loss)
 {
-	struct dccp_li_hist_entry *tail = NULL, *entry;
+	struct dccp_li_hist_entry *entry;
 	int i;
 
-	for (i = 0; i <= DCCP_LI_HIST_IVAL_F_LENGTH; ++i) {
+	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
 		entry = dccp_li_hist_entry_new(hist, SLAB_ATOMIC);
 		if (entry = NULL) {
 			dccp_li_hist_purge(hist, list);
-			return NULL;
+			dump_stack();
+			return 0;
 		}
-		if (tail = NULL)
-			tail = entry;
+		entry->dccplih_interval = ~0;
 		list_add(&entry->dccplih_node, list);
 	}
 
 	entry->dccplih_seqno     = seq_loss;
 	entry->dccplih_win_count = win_loss;
-	return tail;
+	return 1;
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index dcb370a..0ae85f0 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -52,9 +52,6 @@ extern void dccp_li_hist_purge(struct dc
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern struct dccp_li_hist_entry *
-			dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-						  struct list_head *list,
-						  const u64 seq_loss,
-						  const u8 win_loss);
+extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+   struct list_head *list, const u64 seq_loss, const u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 1c68182..3a976e7 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -112,64 +112,27 @@ struct dccp_rx_hist_entry *
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_find_data_packet);
 
-int dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
+void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 			    struct list_head *rx_list,
 			    struct list_head *li_list,
-			    struct dccp_rx_hist_entry *packet)
+			    struct dccp_rx_hist_entry *packet,
+			    u64 nonloss_seqno)
 {
-	struct dccp_rx_hist_entry *entry, *next, *iter;
+	struct dccp_rx_hist_entry *entry, *next;
 	u8 num_later = 0;
 
-	iter = dccp_rx_hist_head(rx_list);
-	if (iter = NULL)
-		dccp_rx_hist_add_entry(rx_list, packet);
-	else {
-		const u64 seqno = packet->dccphrx_seqno;
-
-		if (after48(seqno, iter->dccphrx_seqno))
-			dccp_rx_hist_add_entry(rx_list, packet);
-		else {
-			if (dccp_rx_hist_entry_data_packet(iter))
-				num_later = 1;
-
-			list_for_each_entry_continue(iter, rx_list,
-						     dccphrx_node) {
-				if (after48(seqno, iter->dccphrx_seqno)) {
-					dccp_rx_hist_add_entry(&iter->dccphrx_node,
-							       packet);
-					goto trim_history;
-				}
-
-				if (dccp_rx_hist_entry_data_packet(iter))
-					num_later++;
-
-				if (num_later = TFRC_RECV_NUM_LATE_LOSS) {
-					dccp_rx_hist_entry_delete(hist, packet);
-					return 1;
-				}
-			}
-
-			if (num_later < TFRC_RECV_NUM_LATE_LOSS)
-				dccp_rx_hist_add_entry(rx_list, packet);
-			/*
-			 * FIXME: else what? should we destroy the packet
-			 * like above?
-			 */
-		}
-	}
+	list_add(&packet->dccphrx_node, rx_list);
 
-trim_history:
-	/*
-	 * Trim history (remove all packets after the NUM_LATE_LOSS + 1
-	 * data packets)
-	 */
 	num_later = TFRC_RECV_NUM_LATE_LOSS + 1;
 
 	if (!list_empty(li_list)) {
 		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
 			if (num_later = 0) {
-				list_del_init(&entry->dccphrx_node);
-				dccp_rx_hist_entry_delete(hist, entry);
+				if (after48(nonloss_seqno, 
+				   entry->dccphrx_seqno)) {
+					list_del_init(&entry->dccphrx_node);
+					dccp_rx_hist_entry_delete(hist, entry);
+				}
 			} else if (dccp_rx_hist_entry_data_packet(entry))
 				--num_later;
 		}
@@ -217,94 +180,10 @@ trim_history:
 				--num_later;
 		}
 	}
-
-	return 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
 
-u64 dccp_rx_hist_detect_loss(struct list_head *rx_list,
-			     struct list_head *li_list, u8 *win_loss)
-{
-	struct dccp_rx_hist_entry *entry, *next, *packet;
-	struct dccp_rx_hist_entry *a_loss = NULL;
-	struct dccp_rx_hist_entry *b_loss = NULL;
-	u64 seq_loss = DCCP_MAX_SEQNO + 1;
-	u8 num_later = TFRC_RECV_NUM_LATE_LOSS;
-
-	list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
-		if (num_later = 0) {
-			b_loss = entry;
-			break;
-		} else if (dccp_rx_hist_entry_data_packet(entry))
-			--num_later;
-	}
-
-	if (b_loss = NULL)
-		goto out;
-
-	num_later = 1;
-	list_for_each_entry_safe_continue(entry, next, rx_list, dccphrx_node) {
-		if (num_later = 0) {
-			a_loss = entry;
-			break;
-		} else if (dccp_rx_hist_entry_data_packet(entry))
-			--num_later;
-	}
-
-	if (a_loss = NULL) {
-		if (list_empty(li_list)) {
-			/* no loss event have occured yet */
-			LIMIT_NETDEBUG("%s: TODO: find a lost data packet by "
-				       "comparing to initial seqno\n",
-				       __FUNCTION__);
-			goto out;
-		} else {
-			LIMIT_NETDEBUG("%s: Less than 4 data pkts in history!",
-				       __FUNCTION__);
-			goto out;
-		}
-	}
-
-	/* Locate a lost data packet */
-	entry = packet = b_loss;
-	list_for_each_entry_safe_continue(entry, next, rx_list, dccphrx_node) {
-		u64 delta = dccp_delta_seqno(entry->dccphrx_seqno,
-					     packet->dccphrx_seqno);
-
-		if (delta != 0) {
-			if (dccp_rx_hist_entry_data_packet(packet))
-				--delta;
-			/*
-			 * FIXME: check this, probably this % usage is because
-			 * in earlier drafts the ndp count was just 8 bits
-			 * long, but now it cam be up to 24 bits long.
-			 */
-#if 0
-			if (delta % DCCP_NDP_LIMIT !-			    (packet->dccphrx_ndp -
-			     entry->dccphrx_ndp) % DCCP_NDP_LIMIT)
-#endif
-			if (delta != packet->dccphrx_ndp - entry->dccphrx_ndp) {
-				seq_loss = entry->dccphrx_seqno;
-				dccp_inc_seqno(&seq_loss);
-			}
-		}
-		packet = entry;
-		if (packet = a_loss)
-			break;
-	}
-out:
-	if (seq_loss != DCCP_MAX_SEQNO + 1)
-		*win_loss = a_loss->dccphrx_ccval;
-	else
-		*win_loss = 0; /* Paranoia */
-
-	return seq_loss;
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_detect_loss);
-
 struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
 {
 	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index aea9c5d..067cf1c 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -166,12 +166,6 @@ static inline void dccp_rx_hist_entry_de
 extern void dccp_rx_hist_purge(struct dccp_rx_hist *hist,
 			       struct list_head *list);
 
-static inline void dccp_rx_hist_add_entry(struct list_head *list,
-					  struct dccp_rx_hist_entry *entry)
-{
-	list_add(&entry->dccphrx_node, list);
-}
-
 static inline struct dccp_rx_hist_entry *
 		dccp_rx_hist_head(struct list_head *list)
 {
@@ -190,10 +184,11 @@ static inline int
 	       entry->dccphrx_type = DCCP_PKT_DATAACK;
 }
 
-extern int dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
+extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 				   struct list_head *rx_list,
 				   struct list_head *li_list,
-				   struct dccp_rx_hist_entry *packet);
+				   struct dccp_rx_hist_entry *packet,
+				   u64 nonloss_seqno);
 
 extern u64 dccp_rx_hist_detect_loss(struct list_head *rx_list,
 				    struct list_head *li_list, u8 *win_loss);
