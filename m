From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 22 Jan 2007 04:10:17 +0000
Subject: [PATCH 1/3] DCCP: recalcuate loss
Message-Id: <200701221710.18018.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This works out when to recalculate the loss rate due to significant
non-loss interval. We do this at time of recalulating loss rate to save
having to do it every packet. Instead we just check if it's time to
recalculate. It looked like there was an early attempt to do this but it
was quite wrong in its implementation.

This is making the code conform to RFC 3448, section 5.4

I've added some extra debugging which is useful in testing as well. In
loss_interval.c I've just used dccp_pr_debug. I tried to use ccid3_pr_debug
but ran into problems with circular references.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 42c9348..1ebb4da 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -36,9 +36,9 @@
 #include "../ccid.h"
 #include "../dccp.h"
 #include "lib/packet_history.h"
-#include "lib/loss_interval.h"
 #include "lib/tfrc.h"
 #include "ccid3.h"
+#include "lib/loss_interval.h"
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static int ccid3_debug;
@@ -401,6 +401,9 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
 	packet->dccphtx_sent   = 1;
 	hctx->ccid3hctx_idle   = 0;
+
+	ccid3_pr_debug("seqno = %llu, rtt = %u\n",
+	   (long long unsigned)packet->dccphtx_seqno, packet->dccphtx_rtt);
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -823,7 +826,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static int ccid3_hc_rx_detect_loss(struct sock *sk,
+static int ccid3_hc_rx_detect_loss(struct sock *sk, struct sk_buff *skb,
                                     struct dccp_rx_hist_entry *packet)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -848,7 +851,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		dccp_li_update_li(sk);
+		dccp_li_update_li(sk, skb);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
@@ -935,7 +938,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	loss = ccid3_hc_rx_detect_loss(sk, packet);
+	loss = ccid3_hc_rx_detect_loss(sk, skb, packet);
 
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
@@ -956,6 +959,15 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		if (loss)
 			break;
 
+		if (hcrx->ccid3hcrx_seq_recalc_loss &&
+		 after48(dccp_hdr_seq(skb), hcrx->ccid3hcrx_seq_recalc_loss)) {
+			ccid3_pr_debug("%s(%p, state=%s) checking loss "
+			   "recalc skb=%llu, recalc_loss = %llu\n",
+			   dccp_role(sk), sk, dccp_state_name(sk->sk_state),
+			   dccp_hdr_seq(skb),hcrx->ccid3hcrx_seq_recalc_loss);
+			break;
+		}
+
 		dccp_timestamp(sk, &now);
 		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
 		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
@@ -968,15 +980,16 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	/* Dealing with packet loss */
-	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
+	/* Dealing with loss intervals*/
+	if (loss)
+		ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
 
 	p_prev = hcrx->ccid3hcrx_p;
 	
 	/* Calculate loss event rate */
 	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+		u32 i_mean = dccp_li_hist_calc_i_mean(hcrx, skb);
 
 		/* Scaling up by 1000000 as fixed decimal */
 		if (i_mean != 0)
@@ -984,7 +997,9 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	} else
 		DCCP_BUG("empty loss history");
 
-	if (hcrx->ccid3hcrx_p > p_prev) {
+	if (hcrx->ccid3hcrx_p != p_prev) {
+		ccid3_pr_debug("p_prev = %u, hcrx_p = %u\n", p_prev,
+		   hcrx->ccid3hcrx_p);
 		ccid3_hc_rx_send_feedback(sk);
 		return;
 	}
@@ -1003,6 +1018,7 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 0;
+	hcrx->ccid3hcrx_seqno_nonloss = 0;
 	return 0;
 }
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 15776a8..885d835 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -151,6 +151,7 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
+ *  @ccid3hcrx_seq_recalc_loss - recalc loss due to nonloss (RFC 3448, 5.4)
  */
 struct ccid3_hc_rx_sock {
 	struct tfrc_rx_info		ccid3hcrx_tfrc;
@@ -169,6 +170,7 @@ struct ccid3_hc_rx_sock {
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
 	u32				ccid3hcrx_elapsed_time;
+	u64				ccid3hcrx_seq_recalc_loss;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index b0826c9..fec5ba3 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -88,31 +88,130 @@ static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {
 	4, 4, 4, 4, 3, 2, 1, 1,
 };
 
-u32 dccp_li_hist_calc_i_mean(struct list_head *list)
+/* This code implements the part of section 5.4 of RFC3448 which says we should
+ * recalculate the average loss interval if we have a sufficient long loss
+ * interval.
+ *
+ * Given that i_mean = weighted average of loss then we can say that
+ * 4*i[0] + 4*i[1] + 4*i[2] + 4*i[3] + 3*i[4] + 2*i[5] + i[6] + i[7] + *  y*(4*i[1] + 4*i[2] + 4*i[3] + 4*i[4] + 3*i[5]+ 2*i[6] + i[7] + i[8])
+ *
+ * the top equation is i_tot0 and the bottom is i_tot1
+ *
+ * where y is a factor so that we don't check as soon as we hit average
+ * interval and waste CPU cycles needlessly. i[0] is the non-loss interval
+ * and i[n] are the loss intervals. We don't need to divide by the sum
+ * of the weighting as these cancel out on each side.
+ *
+ * We can solve for this equation for i[0] which yields:
+ * i[0] + *  ((4*i[1] + 4*i[2] + 4*i[3] + 4*i[4] + 3*i[5]+ 2*i[6] + i[7] + i[8])/4) -
+ *  (y*(4*i[1] + 4*i[2] + 4*i[3] + 3*i[4] + 2*i[5] + i[6] + i[7])/4)
+ *
+ *  The top half is simply i_tot1/4.
+ *  The bottom half is y*(mi_tot0)/4 where mi_tot0 = i_tot0 - I_0
+ *  We don't need to calculate mi_tot0 as this is passed in.
+ */
+
+static u64 dccp_li_hist_recalc_recalcloss(struct sk_buff *skb,
+                                        u32 mi_tot0, u32 i_tot1)
+{
+	u64 recalcloss_seq = dccp_hdr_seq(skb);
+
+	dccp_pr_debug("recalcloss_seq=%llu\n", recalcloss_seq);
+
+	if (!i_tot1) {
+		DCCP_WARN("i_tot0 = 0\n");
+		return 0;
+	}
+
+	/* We don't adjust if > 1 million as will get overflow
+	 * in calculations and not so serious anyway */
+	if (i_tot1 > 1000000) {
+		DCCP_WARN("i_mean > 100000\n");
+		return 0;
+	}
+
+	i_tot1 /= 4;
+	mi_tot0 = (mi_tot0 * (DCCP_LI_RECALC_LOSS_FACTOR+1))/
+	   (DCCP_LI_RECALC_LOSS_FACTOR*4);
+
+	if (mi_tot0 >= i_tot1) {
+		dccp_pr_debug("only incrementing by 1\n");
+		INC48(recalcloss_seq);
+	} else
+		recalcloss_seq = ADD48(recalcloss_seq,(u64)(i_tot1 - mi_tot0));
+
+	dccp_pr_debug("recalcloss_seq=%llu, mi_tot0=%u, i_tot1=%u\n",
+	   recalcloss_seq, mi_tot0, i_tot1);
+
+	return recalcloss_seq;
+}
+
+u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx, struct sk_buff *skb)
 {
 	struct dccp_li_hist_entry *li_entry, *li_next;
-	int i = 0;
+	unsigned int i = 1;
 	u32 i_tot;
 	u32 i_tot0 = 0;
 	u32 i_tot1 = 0;
-	u32 w_tot  = 0;
+	u32 w_tot  = dccp_li_hist_w[0];
+	u64 non_loss = 0;
+	u32 i_mean;
+	struct list_head *list = &hcrx->ccid3hcrx_li_hist;
+
+	/* this "loop" implements section 5.4 of RFC3448. We cover the
+	 * cases of i=1 to n here and case of i=0 down lower. The code is
+	 * real ugly as we use linked lists rather than arrays which we
+	 * should change to. This loop covers the case of 1 to n with 0
+	 * dealt with outside the loop */
 
 	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
 		if (li_entry->dccplih_interval != ~0U) {
-			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
-			w_tot  += dccp_li_hist_w[i];
-			if (i != 0)
-				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
-		}
+			/* this is the calculation of I_0 - the rest of the
+			 * intervals are already stored */
+			if (i = 1) {
+				non_loss = dccp_hdr_seq(skb);
+				non_loss = SUB48(non_loss, li_entry->dccplih_seqno);
+			}
 
+			i_tot1 += li_entry->dccplih_interval
+			   * dccp_li_hist_w[i-1];
+
+			/* as i = 0 to n-1 for i_tot0 we must exclude 8 */
+			if (i != 8) {
+				i_tot0 += li_entry->dccplih_interval
+				   * dccp_li_hist_w[i];
+				w_tot  += dccp_li_hist_w[i];
+			}
 
-		if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
+			dccp_pr_debug("i=%d, interval=%u, seqno=%llu, "
+			  "i_tot0=%u, i_tot1=%u, w_tot=%u\n", i,
+			  li_entry->dccplih_interval,
+			  (u64)li_entry->dccplih_seqno,i_tot0, i_tot1, w_tot);
+		} else
+			dccp_pr_debug("empty loss interval\n");
+
+		if (++i > (DCCP_LI_HIST_IVAL_F_LENGTH+1))
 			break;
 	}
 
-	if (i != DCCP_LI_HIST_IVAL_F_LENGTH)
+	if (i != (DCCP_LI_HIST_IVAL_F_LENGTH+1)) {
+		DCCP_BUG("Length of loss interval list is %u\n", i);
 		return 0;
+	}
+
+	hcrx->ccid3hcrx_seq_recalc_loss +	   dccp_li_hist_recalc_recalcloss(skb, i_tot0, i_tot1);
+
+	/* we do this case of i = 0 from 5.4 of RFC3448 here so that we can
+	 * run recalcloss first */
+	i_tot0 += non_loss * dccp_li_hist_w[0];
 
+	if (i_tot0 > i_tot1)
+		dccp_pr_debug("i_mean recalculated due to high nonloss "
+		   "interval seqno=%llu nonloss=%llu i_tot0=%u, i_tot1=%u\n",
+		   dccp_hdr_seq(skb), non_loss, i_tot0, i_tot1);
 	i_tot = max(i_tot0, i_tot1);
 
 	if (!w_tot) {
@@ -120,7 +219,10 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 		return 1;
 	}
 
-	return i_tot / w_tot;
+	i_mean = i_tot / w_tot;
+	dccp_pr_debug("i_mean=%u\n", i_mean);
+
+	return i_mean;
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
@@ -138,7 +240,7 @@ static int dccp_li_hist_interval_new(struct list_head *list,
 			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
-		entry->dccplih_interval = ~0;
+		entry->dccplih_interval = ~0U;
 		list_add(&entry->dccplih_node, list);
 	}
 
@@ -151,7 +253,7 @@ static int dccp_li_hist_interval_new(struct list_head *list,
  *
  * returns estimated loss interval in usecs */
 
-static u32 dccp_li_calc_first_li(struct sock *sk)
+static u32 dccp_li_calc_first_li(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
@@ -242,13 +344,33 @@ found:
 	dccp_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
-	if (p = 0)
+	if (p = 0) {
+		DCCP_WARN("p=0, fval = %llu\n", fval);
 		return ~0;
-	else
-		return 1000000 / p;
+	} else {
+		u32 new_interval = 1000000 / p;
+		u64 recalc_interval;
+
+		/* check if low value so don't have to do a * and / */
+		if (new_interval < DCCP_LI_RECALC_LOSS_MIN)
+			recalc_interval = new_interval + 1;
+		else
+			recalc_interval = (new_interval *
+			(DCCP_LI_RECALC_LOSS_FACTOR+1)) /
+			DCCP_LI_RECALC_LOSS_FACTOR;
+		hcrx->ccid3hcrx_seq_recalc_loss = dccp_hdr_seq(skb);
+		hcrx->ccid3hcrx_seq_recalc_loss = ADD48(
+		   hcrx->ccid3hcrx_seq_recalc_loss, recalc_interval);
+		dccp_pr_debug("%s(%p), interval=%u, recalc_interval=%llu, "
+		   "seqno=%llu recalc_loss=%llu\n", dccp_role(sk), sk,
+		   new_interval, recalc_interval, dccp_hdr_seq(skb),
+		   hcrx->ccid3hcrx_seq_recalc_loss);
+
+		return new_interval;
+	}
 }
 
-void dccp_li_update_li(struct sock *sk)
+void dccp_li_update_li(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
@@ -263,7 +385,7 @@ void dccp_li_update_li(struct sock *sk)
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = dccp_li_calc_first_li(sk);
+		head->dccplih_interval = dccp_li_calc_first_li(sk, skb);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
@@ -294,6 +416,8 @@ void dccp_li_update_li(struct sock *sk)
 		entry->dccplih_seqno = seq_nonloss;
 		entry->dccplih_interval = seq_temp;
 		entry->dccplih_win_count = win_nonloss;
+		dccp_pr_debug("adding node seqno=%llu, interval=%u\n",
+		   (u64)entry->dccplih_seqno, entry->dccplih_interval);
 	}
 }
 
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 1b45bbc..5c847a4 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -19,6 +19,12 @@
 
 #define DCCP_LI_HIST_IVAL_F_LENGTH  8
 
+/* Value as a reciprocal to check for change in loss through long
+ * non-loss intervals. If you change this you must recheck existing
+ * code for overflow possibilities */
+#define DCCP_LI_RECALC_LOSS_FACTOR 100
+#define DCCP_LI_RECALC_LOSS_MIN 150
+
 struct dccp_li_hist {
 	struct kmem_cache *dccplih_slab;
 };
@@ -32,7 +38,8 @@ struct dccp_li_hist_entry {
 
 extern void dccp_li_hist_purge(struct list_head *list);
 
-extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
+extern u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx,
+   struct sk_buff *skb);
 
-extern void dccp_li_update_li(struct sock *sk);
+extern void dccp_li_update_li(struct sock *sk, struct sk_buff *skb);
 #endif /* _DCCP_LI_HIST_ */
