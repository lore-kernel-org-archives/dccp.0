From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 11:28:37 +0000
Subject: [PATCH 3/6] [CCID3]: Hook up with new RX history interface
Message-Id: <11966813202066-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In addition, it makes two corrections too the code:

 1. The receiver of a half-connection does not set window counter values;
    only the sender sets window counters [RFC 4342, sections 5 and 8.1].
 2. The computation of X_recv does currently not conform to TFRC/RFC 3448,
    since this specification requires that X_recv be computed over the last
    R_m seconds (sec. 6.2). The patch tackles this problem as it
      - explicitly distinguishes the types of feedback (using an enum);
      - uses previous value of X_recv when sending feedback due to a parameter change;
      - makes all state changes local to ccid3_hc_tx_packet_recv;
      - assigns feedback type according to incident (previously only used flag `do_feedback').
   Further and detailed information is at
   http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/#8._Computing_X_recv_

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |  292 ++++++++++++++----------------------------------
 net/dccp/ccids/ccid3.h |   38 ++++---
 2 files changed, 102 insertions(+), 228 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 5dea690..ef243dc 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1,6 +1,7 @@
 /*
  *  net/dccp/ccids/ccid3.c
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
@@ -49,8 +50,6 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static struct dccp_rx_hist *ccid3_rx_hist;
-
 /*
  *	Transmitter Half-Connection Routines
  */
@@ -675,52 +674,53 @@ static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
-static void ccid3_hc_rx_send_feedback(struct sock *sk)
+static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
+				      enum ccid3_fback_type fbtype)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_rx_hist_entry *packet;
-	ktime_t now;
-	suseconds_t delta;
-
-	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
+	ktime_t now = ktime_get_real();
+	s64 delta = 0;
 
-	now = ktime_get_real();
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+		return;
 
-	switch (hcrx->ccid3hcrx_state) {
-	case TFRC_RSTATE_NO_DATA:
+	switch (fbtype) {
+	case FBACK_INITIAL:
 		hcrx->ccid3hcrx_x_recv = 0;
+		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
-	case TFRC_RSTATE_DATA:
-		delta = ktime_us_delta(now,
-				       hcrx->ccid3hcrx_tstamp_last_feedback);
-		DCCP_BUG_ON(delta < 0);
-		hcrx->ccid3hcrx_x_recv -			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	case FBACK_PARAM_CHANGE:
+		/*
+		 * When parameters change (new loss or p > p_prev), we do not
+		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
+		 * need to  reuse the previous value of X_recv. However, when
+		 * X_recv was 0 (due to early loss), this would kill X down to
+		 * s/t_mbi (i.e. one packet in 64 seconds).
+		 * To avoid such drastic reduction, we approximate X_recv as
+		 * the number of bytes since last feedback.
+		 * This is a safe fallback, since X is bounded above by X_calc.
+		 */
+		if (hcrx->ccid3hcrx_x_recv > 0)
+			break;
+		/* fall through */
+	case FBACK_PERIODIC:
+		delta = ktime_us_delta(now, hcrx->ccid3hcrx_last_feedback);
+		if (delta <= 0)
+			DCCP_BUG("delta (%ld) <= 0", (long)delta);
+		else
+			hcrx->ccid3hcrx_x_recv +				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 		break;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
-	}
-
-	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), no data packet in history!\n",
-			  dccp_role(sk), sk);
+	default:
 		return;
 	}
+	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
+		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
-	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
-	hcrx->ccid3hcrx_bytes_recv	     = 0;
-
-	if (hcrx->ccid3hcrx_p = 0)
-		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
-	else if (hcrx->ccid3hcrx_p > 1000000) {
-		DCCP_WARN("p (%u) > 100%%\n", hcrx->ccid3hcrx_p);
-		hcrx->ccid3hcrx_pinv = 1;	/* use 100% in this case */
-	} else
-		hcrx->ccid3hcrx_pinv = 1000000 / hcrx->ccid3hcrx_p;
+	hcrx->ccid3hcrx_last_feedback = now;
+	hcrx->ccid3hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->ccid3hcrx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -735,7 +735,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 		return 0;
 
 	hcrx = ccid3_hc_rx_sk(sk);
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
 
 	if (dccp_packet_without_ack(skb))
 		return 0;
@@ -743,8 +742,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if (dccp_insert_option_timestamp(sk, skb) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)))
@@ -753,166 +751,62 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static int ccid3_hc_rx_detect_loss(struct sock *sk,
-				    struct dccp_rx_hist_entry *packet)
+static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *rx_hist -				dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
-	u64 seqno = packet->dccphrx_seqno;
-	u64 tmp_seqno;
-	int loss = 0;
-	u8 ccval;
-
-
-	tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-
-	if (!rx_hist ||
-	   follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
-		goto detect_out;
-	}
-
-
-	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
-	   > TFRC_RECV_NUM_LATE_LOSS) {
-		loss = 1;
-		dccp_li_update_li(sk,
-				  &hcrx->ccid3hcrx_li_hist,
-				  &hcrx->ccid3hcrx_hist,
-				  hcrx->ccid3hcrx_tstamp_last_feedback,
-				  hcrx->ccid3hcrx_s,
-				  hcrx->ccid3hcrx_bytes_recv,
-				  hcrx->ccid3hcrx_x_recv,
-				  hcrx->ccid3hcrx_seqno_nonloss,
-				  hcrx->ccid3hcrx_ccval_nonloss);
-		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-		dccp_inc_seqno(&tmp_seqno);
-		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-		dccp_inc_seqno(&tmp_seqno);
-		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
-		   tmp_seqno, &ccval)) {
-			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-			hcrx->ccid3hcrx_ccval_nonloss = ccval;
-			dccp_inc_seqno(&tmp_seqno);
+	enum   ccid3_fback_type  do_feedback = FBACK_NONE;
+	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
+	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	u8  is_data_packet = dccp_data_packet(skb);
+
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+		if (is_data_packet) {
+			do_feedback = FBACK_INITIAL;
+			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
+			ccid3_hc_rx_update_s(hcrx, payload_size);
 		}
+		goto update_records;
 	}
 
-	/* FIXME - this code could be simplified with above while */
-	/* but works at moment */
-	if (follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
-	}
-
-detect_out:
-	dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
-		   &hcrx->ccid3hcrx_li_hist, packet,
-		   hcrx->ccid3hcrx_seqno_nonloss);
-	return loss;
-}
-
-static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
-{
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	const struct dccp_options_received *opt_recv;
-	struct dccp_rx_hist_entry *packet;
-	u32 p_prev, r_sample, rtt_prev;
-	int loss, payload_size;
-	ktime_t now;
-
-	opt_recv = &dccp_sk(sk)->dccps_options_received;
-
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
-			return;
-	case DCCP_PKT_DATAACK:
-		if (opt_recv->dccpor_timestamp_echo = 0)
-			break;
-		r_sample = dccp_timestamp() - opt_recv->dccpor_timestamp_echo;
-		rtt_prev = hcrx->ccid3hcrx_rtt;
-		r_sample = dccp_sample_rtt(sk, 10 * r_sample);
+	if (tfrc_rx_duplicate(&hcrx->ccid3hcrx_hist, skb))
+		goto done_receiving;
 
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
-			hcrx->ccid3hcrx_rtt = r_sample;
-		else
-			hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
-					      r_sample / 10;
-
-		if (rtt_prev != hcrx->ccid3hcrx_rtt)
-			ccid3_pr_debug("%s(%p), New RTT=%uus, elapsed time=%u\n",
-				       dccp_role(sk), sk, hcrx->ccid3hcrx_rtt,
-				       opt_recv->dccpor_elapsed_time);
-		break;
-	case DCCP_PKT_DATA:
-		break;
-	default: /* We're not interested in other packet types, move along */
-		return;
-	}
-
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, opt_recv->dccpor_ndp,
-					skb, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
-			  "to history, consider it lost!\n", dccp_role(sk), sk);
-		return;
+	if (is_data_packet) {
+		ccid3_hc_rx_update_s(hcrx, payload_size);
+		hcrx->ccid3hcrx_bytes_recv += payload_size;
 	}
 
-	loss = ccid3_hc_rx_detect_loss(sk, packet);
+	/*
+	 *	Handle pending losses and otherwise check for new loss
+	 */
+	if (tfrc_rx_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
+		goto update_records;
 
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
-		return;
+	/*
+	 *	Handle data packets: RTT sampling and monitoring p
+	 */
+	if (unlikely(!is_data_packet))
+		goto update_records;
 
-	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-	ccid3_hc_rx_update_s(hcrx, payload_size);
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
 
-	switch (hcrx->ccid3hcrx_state) {
-	case TFRC_RSTATE_NO_DATA:
-		ccid3_pr_debug("%s(%p, state=%s), skb=%p, sending initial "
-			       "feedback\n", dccp_role(sk), sk,
-			       dccp_state_name(sk->sk_state), skb);
-		ccid3_hc_rx_send_feedback(sk);
-		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-		return;
-	case TFRC_RSTATE_DATA:
-		hcrx->ccid3hcrx_bytes_recv += payload_size;
-		if (loss)
-			break;
+		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+		if (sample != 0)
+			hcrx->ccid3hcrx_rtt +				tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
 
-		now = ktime_get_real();
-		if ((ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_ack) -
-		     (s64)hcrx->ccid3hcrx_rtt) >= 0) {
-			hcrx->ccid3hcrx_tstamp_last_ack = now;
-			ccid3_hc_rx_send_feedback(sk);
-		}
-		return;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
 	}
 
-	/* Dealing with packet loss */
-	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
-		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
+	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+		do_feedback = FBACK_PERIODIC;
 
-	p_prev = hcrx->ccid3hcrx_p;
+update_records:
+	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
 
-	/* Calculate loss event rate */
-	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
-
-		/* Scaling up by 1000000 as fixed decimal */
-		if (i_mean != 0)
-			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else
-		DCCP_BUG("empty loss history");
-
-	if (hcrx->ccid3hcrx_p > p_prev) {
-		ccid3_hc_rx_send_feedback(sk);
-		return;
-	}
+done_receiving:
+	if (do_feedback)
+		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
@@ -922,10 +816,9 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	ccid3_pr_debug("entry\n");
 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
+	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
+		return 1;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	hcrx->ccid3hcrx_tstamp_last_feedback -		hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
 	return 0;
 }
 
@@ -935,8 +828,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	/* Empty packet history */
-	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
+	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
@@ -1013,33 +905,13 @@ MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 
 static __init int ccid3_module_init(void)
 {
-	int rc = -ENOBUFS;
-
-	ccid3_rx_hist = dccp_rx_hist_new("ccid3");
-	if (ccid3_rx_hist = NULL)
-		goto out;
-
-	rc = ccid_register(&ccid3);
-	if (rc != 0)
-		goto out_free_rx;
-out:
-	return rc;
-
-out_free_rx:
-	dccp_rx_hist_delete(ccid3_rx_hist);
-	ccid3_rx_hist = NULL;
-	goto out;
+	return ccid_register(&ccid3);
 }
 module_init(ccid3_module_init);
 
 static __exit void ccid3_module_exit(void)
 {
 	ccid_unregister(&ccid3);
-
-	if (ccid3_rx_hist != NULL) {
-		dccp_rx_hist_delete(ccid3_rx_hist);
-		ccid3_rx_hist = NULL;
-	}
 }
 module_exit(ccid3_module_exit);
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index b842a7d..8f7308b 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -1,7 +1,10 @@
+#ifndef _DCCP_CCID3_H_
+#define _DCCP_CCID3_H_
 /*
  *  net/dccp/ccids/ccid3.h
  *
- *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
@@ -33,9 +36,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#ifndef _DCCP_CCID3_H_
-#define _DCCP_CCID3_H_
-
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/types.h>
@@ -123,26 +123,31 @@ static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
     return hctx;
 }
 
-/* TFRC receiver states */
+/* CCID3 receiver states */
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
 	TFRC_RSTATE_DATA,
 	TFRC_RSTATE_TERM    = 127,
 };
 
+/* CCID3 feedback types */
+enum ccid3_fback_type {
+	FBACK_NONE = 0,
+	FBACK_INITIAL,
+	FBACK_PERIODIC,
+	FBACK_PARAM_CHANGE
+};
+
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
  *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
- *  @ccid3hcrx_seqno_nonloss  -  Last received non-loss sequence number
- *  @ccid3hcrx_ccval_nonloss  -  Last received non-loss Window CCVal
- *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history
+ *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
+ *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
@@ -152,14 +157,11 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
 #define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
 #define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
-	u64				ccid3hcrx_seqno_nonloss:48,
-					ccid3hcrx_ccval_nonloss:4,
-					ccid3hcrx_ccval_last_counter:4;
+	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
-	ktime_t				ccid3hcrx_tstamp_last_feedback;
-	ktime_t				ccid3hcrx_tstamp_last_ack;
-	struct list_head		ccid3hcrx_hist;
+	ktime_t				ccid3hcrx_last_feedback;
+	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
-- 
