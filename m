From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 02 Dec 2007 21:36:56 +0000
Subject: [PATCH 7/7] [TFRC] New rx history code
Message-Id: <1196631416-17778-8-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Credit here goes to Gerrit Renker, that provided the initial implementation for
this new codebase.

I modified it just to try to make it closer to the existing API, hide details from
the CCIDs and fix a couple bugs found in the initial implementation.

Original changeset comment from Gerrit:
      -----------
This provides a new, self-contained and generic RX history service for TFRC
based protocols.

Details:
 * new data structure, initialisation and cleanup routines;
 * allocation of dccp_rx_hist entries local to packet_history.c,
   as a service exported by the dccp_tfrc_lib module.
 * interface to automatically track highest-received seqno;
 * receiver-based RTT estimation (needed for instance by RFC 3448, 6.3.1);
 * a generic function to test for `data packets' as per  RFC 4340, sec. 7.7.
      -----------

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c                       |  255 ++++++++----------------
 net/dccp/ccids/ccid3.h                       |   14 +-
 net/dccp/ccids/lib/loss_interval.c           |   14 +-
 net/dccp/ccids/lib/packet_history.c          |  277 +++++++++++++++-----------
 net/dccp/ccids/lib/packet_history.h          |   82 +++-----
 net/dccp/ccids/lib/packet_history_internal.h |   67 ++++++
 6 files changed, 353 insertions(+), 356 deletions(-)
 create mode 100644 net/dccp/ccids/lib/packet_history_internal.h

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 5ff5aab..af64c1d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -641,6 +641,15 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 /*
  *	Receiver Half-Connection Routines
  */
+
+/* CCID3 feedback types */
+enum ccid3_fback_type {
+	CCID3_FBACK_NONE = 0,
+	CCID3_FBACK_INITIAL,
+	CCID3_FBACK_PERIODIC,
+	CCID3_FBACK_PARAM_CHANGE
+};
+
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
@@ -673,53 +682,60 @@ static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
-static void ccid3_hc_rx_send_feedback(struct sock *sk)
+static void ccid3_hc_rx_send_feedback(struct sock *sk,
+				      const struct sk_buff *skb,
+				      enum ccid3_fback_type fbtype)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct tfrc_rx_hist_entry *packet;
 	ktime_t now;
-	suseconds_t delta;
+	s64 delta = 0;
 
 	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
 
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+		return;
+
 	now = ktime_get_real();
 
-	switch (hcrx->ccid3hcrx_state) {
-	case TFRC_RSTATE_NO_DATA:
+	switch (fbtype) {
+	case CCID3_FBACK_INITIAL:
 		hcrx->ccid3hcrx_x_recv = 0;
+		hcrx->ccid3hcrx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
 		break;
-	case TFRC_RSTATE_DATA:
-		delta = ktime_us_delta(now,
-				       hcrx->ccid3hcrx_tstamp_last_feedback);
-		DCCP_BUG_ON(delta < 0);
-		hcrx->ccid3hcrx_x_recv -			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	case CCID3_FBACK_PARAM_CHANGE:
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
+	case CCID3_FBACK_PERIODIC:
+		delta = ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_feedback);
+		if (delta <= 0)
+			DCCP_BUG("delta (%ld) <= 0", (long)delta);
+		else
+			hcrx->ccid3hcrx_x_recv +				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 		break;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
+	default:
 		return;
 	}
 
-	packet = tfrc_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), no data packet in history!\n",
-			  dccp_role(sk), sk);
-		return;
-	}
+	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
+		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = packet->tfrchrx_ccval;
+	hcrx->ccid3hcrx_last_counter	     = dccp_hdr(skb)->dccph_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
-	if (hcrx->ccid3hcrx_p = 0)
-		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
-	else if (hcrx->ccid3hcrx_p > 1000000) {
-		DCCP_WARN("p (%u) > 100%%\n", hcrx->ccid3hcrx_p);
-		hcrx->ccid3hcrx_pinv = 1;	/* use 100% in this case */
-	} else
-		hcrx->ccid3hcrx_pinv = 1000000 / hcrx->ccid3hcrx_p;
-
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 }
@@ -753,162 +769,52 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 static int ccid3_hc_rx_detect_loss(struct sock *sk,
 				    struct tfrc_rx_hist_entry *packet)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct tfrc_rx_hist_entry *rx_hist -				tfrc_rx_hist_head(&hcrx->ccid3hcrx_hist);
-	u64 seqno = packet->tfrchrx_seqno;
-	u64 tmp_seqno;
-	int loss = 0;
-	u8 ccval;
-
-
-	tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-
-	if (!rx_hist ||
-	   follows48(packet->tfrchrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->tfrchrx_ccval;
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
-		while (tfrc_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
-		   tmp_seqno, &ccval)) {
-			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-			hcrx->ccid3hcrx_ccval_nonloss = ccval;
-			dccp_inc_seqno(&tmp_seqno);
-		}
-	}
-
-	/* FIXME - this code could be simplified with above while */
-	/* but works at moment */
-	if (follows48(packet->tfrchrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->tfrchrx_ccval;
-	}
-
-detect_out:
-	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist,
-				&hcrx->ccid3hcrx_li_hist, packet,
-				hcrx->ccid3hcrx_seqno_nonloss);
-	return loss;
+	return 0;
 }
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	const struct dccp_options_received *opt_recv;
-	struct tfrc_rx_hist_entry *packet;
-	u32 p_prev, r_sample, rtt_prev;
-	int loss, payload_size;
-	ktime_t now;
-
-	opt_recv = &dccp_sk(sk)->dccps_options_received;
+	const u32 payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	const u32 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
+	enum ccid3_fback_type do_feedback = CCID3_FBACK_NONE;
+	const bool is_data_packet = dccp_data_packet(skb);
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
+	if (hcrx->ccid3hcrx_state != TFRC_RSTATE_NO_DATA) {
+		if (tfrc_rx_hist_duplicate(&hcrx->ccid3hcrx_hist, skb))
 			return;
-	case DCCP_PKT_DATAACK:
-		if (opt_recv->dccpor_timestamp_echo = 0)
-			break;
-		r_sample = dccp_timestamp() - opt_recv->dccpor_timestamp_echo;
-		rtt_prev = hcrx->ccid3hcrx_rtt;
-		r_sample = dccp_sample_rtt(sk, 10 * r_sample);
-
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
-	packet = tfrc_rx_hist_entry_new(opt_recv->dccpor_ndp, skb, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
-			  "to history, consider it lost!\n", dccp_role(sk), sk);
-		return;
-	}
-
-	loss = ccid3_hc_rx_detect_loss(sk, packet);
-
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
-		return;
-
-	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-	ccid3_hc_rx_update_s(hcrx, payload_size);
 
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
-
-		now = ktime_get_real();
-		if ((ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_ack) -
-		     (s64)hcrx->ccid3hcrx_rtt) >= 0) {
-			hcrx->ccid3hcrx_tstamp_last_ack = now;
-			ccid3_hc_rx_send_feedback(sk);
+		    /* Handle pending losses and otherwise check for new loss */
+		if (!tfrc_rx_hist_new_loss_indicated(&hcrx->ccid3hcrx_hist,
+						     skb, ndp) &&
+		    /* Handle data packets: RTT sampling and monitoring p */
+		    is_data_packet)  {
+
+			if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
+				const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+				if (sample != 0)
+					hcrx->ccid3hcrx_rtt +						tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
+			}
+
+			ccid3_hc_rx_update_s(hcrx, payload_size);
+			/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
+			if (SUB16(dccp_hdr(skb)->dccph_ccval,
+				  hcrx->ccid3hcrx_last_counter) > 3)
+				do_feedback = CCID3_FBACK_PERIODIC;
 		}
-		return;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
-	}
-
-	/* Dealing with packet loss */
-	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
-		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
-
-	p_prev = hcrx->ccid3hcrx_p;
+	} else if (is_data_packet) {
+		do_feedback = CCID3_FBACK_INITIAL;
+		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
+		hcrx->ccid3hcrx_s = payload_size;
+ 	}
 
-	/* Calculate loss event rate */
-	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+	hcrx->ccid3hcrx_bytes_recv += payload_size;
 
-		/* Scaling up by 1000000 as fixed decimal */
-		if (i_mean != 0)
-			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else
-		DCCP_BUG("empty loss history");
+	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
 
-	if (hcrx->ccid3hcrx_p > p_prev) {
-		ccid3_hc_rx_send_feedback(sk);
-		return;
-	}
+	if (do_feedback)
+		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
@@ -918,11 +824,8 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	ccid3_pr_debug("entry\n");
 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	hcrx->ccid3hcrx_tstamp_last_feedback -		hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
-	return 0;
+	return tfrc_rx_hist_alloc(&hcrx->ccid3hcrx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index b842a7d..3c33dc6 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -1,7 +1,8 @@
 /*
  *  net/dccp/ccids/ccid3.h
  *
- *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *
  *  An implementation of the DCCP protocol
  *
@@ -135,9 +136,7 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
  *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
- *  @ccid3hcrx_seqno_nonloss  -  Last received non-loss sequence number
- *  @ccid3hcrx_ccval_nonloss  -  Last received non-loss Window CCVal
- *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
@@ -152,14 +151,11 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
 #define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
 #define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
-	u64				ccid3hcrx_seqno_nonloss:48,
-					ccid3hcrx_ccval_nonloss:4,
-					ccid3hcrx_ccval_last_counter:4;
+	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_tstamp_last_feedback;
-	ktime_t				ccid3hcrx_tstamp_last_ack;
-	struct list_head		ccid3hcrx_hist;
+	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index a5f59af..71080ca 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -16,6 +16,7 @@
 #include "../../dccp.h"
 #include "loss_interval.h"
 #include "packet_history.h"
+#include "packet_history_internal.h"
 #include "tfrc.h"
 
 #define DCCP_LI_HIST_IVAL_F_LENGTH  8
@@ -129,6 +130,13 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 				 u16 s, u32 bytes_recv,
 				 u32 previous_x_recv)
 {
+/*
+ * FIXME:
+ * Will be rewritten in the upcoming new loss intervals code. 
+ * Has to be commented ou because it relies on the old rx history
+ * data structures
+ */
+#if 0
 	struct tfrc_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
@@ -216,10 +224,10 @@ found:
 	dccp_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		      "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
-	if (p = 0)
-		return ~0;
-	else
+	if (p != 0)
 		return 1000000 / p;
+#endif
+	return ~0;
 }
 
 void dccp_li_update_li(struct sock *sk,
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 255cca1..80ad4cd 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -36,7 +36,10 @@
  */
 
 #include <linux/string.h>
+#include <linux/slab.h>
 #include "packet_history.h"
+#include "../../dccp.h"
+#include "packet_history_internal.h"
 
 /**
  *  tfrc_tx_hist_entry  -  Simple singly-linked TX history list
@@ -111,154 +114,195 @@ u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno,
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
 
-/*
- * 	Receiver History Routines
+/**
+ * tfrc_rx_hist_index - index to reach n-th entry after loss_start
  */
-static struct kmem_cache *tfrc_rx_hist_slab;
+static inline u8 tfrc_rx_hist_index(const struct tfrc_rx_hist *h, const u8 n)
+{
+	return (h->loss_start + n) & TFRC_NDUPACK;
+}
 
-struct tfrc_rx_hist_entry *tfrc_rx_hist_entry_new(const u32 ndp,
-						  const struct sk_buff *skb,
-						  const gfp_t prio)
+/**
+ * tfrc_rx_hist_last_rcv - entry with highest-received-seqno so far
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_last_rcv(const struct tfrc_rx_hist *h)
 {
-	struct tfrc_rx_hist_entry *entry = kmem_cache_alloc(tfrc_rx_hist_slab,
-							    prio);
+	return h->ring + tfrc_rx_hist_index(h, h->loss_count);
+}
 
-	if (entry != NULL) {
-		const struct dccp_hdr *dh = dccp_hdr(skb);
+/**
+ * tfrc_rx_hist_entry - return the n-th history entry after loss_start
+ */
+static inline struct tfrc_rx_hist_entry *
+		tfrc_rx_hist_entry(const struct tfrc_rx_hist *h, const u8 n)
+{
+	return h->ring + tfrc_rx_hist_index(h, n);
+}
 
-		entry->tfrchrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-		entry->tfrchrx_ccval = dh->dccph_ccval;
-		entry->tfrchrx_type  = dh->dccph_type;
-		entry->tfrchrx_ndp   = ndp;
-		entry->tfrchrx_tstamp = ktime_get_real();
-	}
+/**
+ * tfrc_rx_hist_loss_prev - entry with highest-received-seqno before loss was detected
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_loss_prev(const struct tfrc_rx_hist *h)
+{
+	return h->ring + h->loss_start;
+}
+
+/*
+ * 	Receiver History Routines
+ */
+static struct kmem_cache *tfrc_rx_hist_slab;
 
-	return entry;
+void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
+			     const struct sk_buff *skb,
+			     const u32 ndp)
+{
+	struct tfrc_rx_hist_entry *entry = tfrc_rx_hist_last_rcv(h);
+	const struct dccp_hdr *dh = dccp_hdr(skb);
+
+	entry->tfrchrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	entry->tfrchrx_ccval = dh->dccph_ccval;
+	entry->tfrchrx_type  = dh->dccph_type;
+	entry->tfrchrx_ndp   = ndp;
+	entry->tfrchrx_tstamp = ktime_get_real();
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_entry_new);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
 static inline void tfrc_rx_hist_entry_delete(struct tfrc_rx_hist_entry *entry)
 {
 	kmem_cache_free(tfrc_rx_hist_slab, entry);
 }
 
-int tfrc_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-			    u8 *ccval)
+/* has the packet contained in skb been seen before? */
+int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 {
-	struct tfrc_rx_hist_entry *packet = NULL, *entry;
+	const u64 seq = DCCP_SKB_CB(skb)->dccpd_seq;
+	int i;
 
-	list_for_each_entry(entry, list, tfrchrx_node)
-		if (entry->tfrchrx_seqno = seq) {
-			packet = entry;
-			break;
-		}
+	if (dccp_delta_seqno(tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno, seq) <= 0)
+		return 1;
 
-	if (packet)
-		*ccval = packet->tfrchrx_ccval;
+	for (i = 1; i <= h->loss_count; i++)
+		if (tfrc_rx_hist_entry(h, i)->tfrchrx_seqno = seq)
+			return 1;
 
-	return packet != NULL;
+	return 0;
 }
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_duplicate);
 
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_find_entry);
-struct tfrc_rx_hist_entry *
-		tfrc_rx_hist_find_data_packet(const struct list_head *list)
+/* initialise loss detection and disable RTT sampling */
+static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
 {
-	struct tfrc_rx_hist_entry *entry, *packet = NULL;
+	h->loss_count = 1;
+}
 
-	list_for_each_entry(entry, list, tfrchrx_node)
-		if (entry->tfrchrx_type = DCCP_PKT_DATA ||
-		    entry->tfrchrx_type = DCCP_PKT_DATAACK) {
-			packet = entry;
-			break;
-		}
+/* indicate whether previously a packet was detected missing */
+static inline int tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
+{
+	return h->loss_count;
+}
 
-	return packet;
+/* any data packets missing between last reception and skb ? */
+int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
+				    const struct sk_buff *skb, u32 ndp)
+{
+	int delta = dccp_delta_seqno(tfrc_rx_hist_last_rcv(h)->tfrchrx_seqno,
+				     DCCP_SKB_CB(skb)->dccpd_seq);
+
+	if (delta > 1 && ndp < delta)
+		tfrc_rx_hist_loss_indicated(h);
+
+	return tfrc_rx_hist_loss_pending(h);
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_new_loss_indicated);
+
+void tfrc_rx_hist_purge(struct tfrc_rx_hist *h)
+{
+	kmem_cache_free(tfrc_rx_hist_slab, h->ring);
+	h->ring = NULL;
 }
 
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_find_data_packet);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_purge);
 
-void tfrc_rx_hist_add_packet(struct list_head *rx_list,
-			     struct list_head *li_list,
-			     struct tfrc_rx_hist_entry *packet,
-			     u64 nonloss_seqno)
+int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
 {
-	struct tfrc_rx_hist_entry *entry, *next;
-	u8 num_later = 0;
-
-	list_add(&packet->tfrchrx_node, rx_list);
-
-	num_later = TFRC_RECV_NUM_LATE_LOSS + 1;
-
-	if (!list_empty(li_list)) {
-		list_for_each_entry_safe(entry, next, rx_list, tfrchrx_node) {
-			if (num_later = 0) {
-				if (after48(nonloss_seqno,
-				   entry->tfrchrx_seqno)) {
-					list_del_init(&entry->tfrchrx_node);
-					tfrc_rx_hist_entry_delete(entry);
-				}
-			} else if (tfrc_rx_hist_entry_data_packet(entry))
-				--num_later;
-		}
-	} else {
-		int step = 0;
-		u8 win_count = 0; /* Not needed, but lets shut up gcc */
-		int tmp;
-		/*
-		 * We have no loss interval history so we need at least one
-		 * rtt:s of data packets to approximate rtt.
-		 */
-		list_for_each_entry_safe(entry, next, rx_list, tfrchrx_node) {
-			if (num_later = 0) {
-				switch (step) {
-				case 0:
-					step = 1;
-					/* OK, find next data packet */
-					num_later = 1;
-					break;
-				case 1:
-					step = 2;
-					/* OK, find next data packet */
-					num_later = 1;
-					win_count = entry->tfrchrx_ccval;
-					break;
-				case 2:
-					tmp = win_count - entry->tfrchrx_ccval;
-					if (tmp < 0)
-						tmp += TFRC_WIN_COUNT_LIMIT;
-					if (tmp > TFRC_WIN_COUNT_PER_RTT + 1) {
-						/*
-						 * We have found a packet older
-						 * than one rtt remove the rest
-						 */
-						step = 3;
-					} else /* OK, find next data packet */
-						num_later = 1;
-					break;
-				case 3:
-					list_del_init(&entry->tfrchrx_node);
-					tfrc_rx_hist_entry_delete(entry);
-					break;
-				}
-			} else if (tfrc_rx_hist_entry_data_packet(entry))
-				--num_later;
-		}
-	}
+	h->ring = kmem_cache_alloc(tfrc_rx_hist_slab, GFP_ATOMIC);
+	h->loss_count = h->loss_start = 0;
+	return h->ring = NULL;
 }
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_alloc);
 
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
+/**
+ * tfrc_rx_hist_rtt_last_s - reference entry to compute RTT samples against
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_rtt_last_s(const struct tfrc_rx_hist *h)
+{
+	return h->ring;
+}
 
-void tfrc_rx_hist_purge(struct list_head *list)
+/**
+ * tfrc_rx_hist_rtt_prev_s: previously suitable (wrt rtt_last_s) RTT-sampling entry
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_rtt_prev_s(const struct tfrc_rx_hist *h)
 {
-	struct tfrc_rx_hist_entry *entry, *next;
+	return h->ring + h->rtt_sample_prev;
+}
 
-	list_for_each_entry_safe(entry, next, list, tfrchrx_node) {
-		list_del_init(&entry->tfrchrx_node);
-		tfrc_rx_hist_entry_delete(entry);
+/**
+ * tfrc_rx_hist_sample_rtt  -  Sample RTT from timestamp / CCVal
+ * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
+ * to compute a sample with given data - calling function should check this.
+ */
+u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
+{
+	u32 sample = 0,
+	    delta_v = SUB16(dccp_hdr(skb)->dccph_ccval,
+	    		    tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
+
+	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
+		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
+			sample = SUB16(tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_ccval,
+				       tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
+			if (sample)
+				sample = 4 / sample *
+				         ktime_us_delta(tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_tstamp,
+							tfrc_rx_hist_rtt_last_s(h)->tfrchrx_tstamp);
+			else    /*
+				 * FIXME: This condition is in principle not
+				 * possible but occurs when CCID is used for
+				 * two-way data traffic. I have tried to trace
+				 * it, but the cause does not seem to be here.
+				 */
+				DCCP_BUG("please report to dccp@vger.kernel.org"
+					 " => prev = %u, last = %u",
+					 tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_ccval,
+					 tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
+		} else if (delta_v < 1) {
+			h->rtt_sample_prev = 1;
+			goto keep_ref_for_next_time;
+		}
+
+	} else if (delta_v = 4) /* optimal match */
+		sample = ktime_to_us(net_timedelta(tfrc_rx_hist_rtt_last_s(h)->tfrchrx_tstamp));
+	else {			 /* suboptimal match */
+		h->rtt_sample_prev = 2;
+		goto keep_ref_for_next_time;
 	}
-}
 
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_purge);
+	if (unlikely(sample > DCCP_SANE_RTT_MAX)) {
+		DCCP_WARN("RTT sample %u too large, using max\n", sample);
+		sample = DCCP_SANE_RTT_MAX;
+	}
+
+	h->rtt_sample_prev = 0;	       /* use current entry as next reference */
+keep_ref_for_next_time:
+
+	return sample;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_sample_rtt);
 
 __init int packet_history_init(void)
 {
@@ -269,7 +313,8 @@ __init int packet_history_init(void)
 		goto out_err;
 
 	tfrc_rx_hist_slab = kmem_cache_create("tfrc_rx_hist",
-					      sizeof(struct tfrc_rx_hist_entry), 0,
+					      (sizeof(struct tfrc_rx_hist_entry) *
+					       (TFRC_NDUPACK + 1)), 0,
 					      SLAB_HWCACHE_ALIGN, NULL);
 	if (tfrc_rx_hist_slab = NULL)
 		goto out_free_tx;
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 5b0b983..6871e51 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -37,15 +37,9 @@
 #define _DCCP_PKT_HIST_
 
 #include <linux/ktime.h>
-#include <linux/list.h>
-#include <linux/slab.h>
-#include "tfrc.h"
+#include <linux/types.h>
 
-/* Number of later packets received before one is considered lost */
-#define TFRC_RECV_NUM_LATE_LOSS	 3
-
-#define TFRC_WIN_COUNT_PER_RTT	 4
-#define TFRC_WIN_COUNT_LIMIT	16
+struct sk_buff;
 
 struct tfrc_tx_hist_entry;
 
@@ -54,54 +48,38 @@ extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
 extern u32  tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head,
 			     const u64 seqno, const ktime_t now);
 
-/*
- * 	Receiver History data structures and declarations
- */
-struct tfrc_rx_hist_entry {
-	struct list_head tfrchrx_node;
-	u64		 tfrchrx_seqno:48,
-			 tfrchrx_ccval:4,
-			 tfrchrx_type:4;
-	u32		 tfrchrx_ndp; /* In fact it is from 8 to 24 bits */
-	ktime_t		 tfrchrx_tstamp;
-};
-
-extern struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_entry_new(const u32 ndp,
-					       const struct sk_buff *skb,
-					       const gfp_t prio);
+struct tfrc_rx_hist_entry;
 
-static inline struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_head(struct list_head *list)
-{
-	struct tfrc_rx_hist_entry *head = NULL;
+/* Subtraction a-b modulo-16, respects circular wrap-around */
+#define SUB16(a, b) (((a) + 16 - (b)) & 0xF)
 
-	if (!list_empty(list))
-		head = list_entry(list->next, struct tfrc_rx_hist_entry,
-				  tfrchrx_node);
-	return head;
-}
+/* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
+#define TFRC_NDUPACK 3
 
-extern int tfrc_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-				   u8 *ccval);
-extern struct tfrc_rx_hist_entry *
-		tfrc_rx_hist_find_data_packet(const struct list_head *list);
-
-extern void tfrc_rx_hist_add_packet(struct list_head *rx_list,
-				    struct list_head *li_list,
-				    struct tfrc_rx_hist_entry *packet,
-				    u64 nonloss_seqno);
-
-extern void tfrc_rx_hist_purge(struct list_head *list);
+/**
+ * tfrc_rx_hist  -  RX history structure for TFRC-based protocols
+ *
+ * @ring:		Packet history for RTT sampling and loss detection
+ * @loss_count:		Number of entries in circular history
+ * @loss_start:		Movable index (for loss detection)
+ * @rtt_sample_prev:	Used during RTT sampling, points to candidate entry
+ */
+struct tfrc_rx_hist {
+	struct tfrc_rx_hist_entry *ring;
+	u8			  loss_count:2,
+				  loss_start:2;
+#define rtt_sample_prev		  loss_start
+};
 
-static inline int
-	tfrc_rx_hist_entry_data_packet(const struct tfrc_rx_hist_entry *entry)
-{
-	return entry->tfrchrx_type = DCCP_PKT_DATA ||
-	       entry->tfrchrx_type = DCCP_PKT_DATAACK;
-}
+extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
+				    const struct sk_buff *skb, const u32 ndp);
 
-extern u64 tfrc_rx_hist_detect_loss(struct list_head *rx_list,
-				    struct list_head *li_list, u8 *win_loss);
+extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
+extern int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
+					   const struct sk_buff *skb, u32 ndp);
+extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
+				   const struct sk_buff *skb);
+extern int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
+extern void tfrc_rx_hist_purge(struct tfrc_rx_hist *h);
 
 #endif /* _DCCP_PKT_HIST_ */
diff --git a/net/dccp/ccids/lib/packet_history_internal.h b/net/dccp/ccids/lib/packet_history_internal.h
new file mode 100644
index 0000000..70d5c31
--- /dev/null
+++ b/net/dccp/ccids/lib/packet_history_internal.h
@@ -0,0 +1,67 @@
+#ifndef _DCCP_PKT_HIST_INT_
+#define _DCCP_PKT_HIST_INT_
+/*
+ *  Packet RX/TX history data structures and routines for TFRC-based protocols.
+ *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *
+ *  This code has been developed by the University of Waikato WAND
+ *  research group. For further information please see http://www.wand.net.nz/
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
+ *
+ *  This code also uses code from Lulea University, rereleased as GPL by its
+ *  authors:
+ *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *
+ *  Changes to meet Linux coding standards, to make it meet latest ccid3 draft
+ *  and to make it work as a loadable module in the DCCP stack written by
+ *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>.
+ *
+ *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/dccp.h>
+#include <linux/ktime.h>
+#include <linux/types.h>
+
+#define TFRC_WIN_COUNT_LIMIT 16
+
+/**
+ * tfrc_rx_hist_entry - Store information about a single received packet
+ * @tfrchrx_seqno:	DCCP packet sequence number
+ * @tfrchrx_ccval:	window counter value of packet (RFC 4342, 8.1)
+ * @tfrchrx_ndp:	the NDP count (if any) of the packet
+ * @tfrchrx_tstamp:	actual receive time of packet
+ */
+struct tfrc_rx_hist_entry {
+	u64	tfrchrx_seqno:48,
+		tfrchrx_ccval:4,
+		tfrchrx_type:4;
+	u32	tfrchrx_ndp; /* In fact it is from 8 to 24 bits */
+	ktime_t	tfrchrx_tstamp;
+};
+
+static inline bool tfrc_rx_hist_entry_data_packet(const struct tfrc_rx_hist_entry *h)
+{
+	return h->tfrchrx_type = DCCP_PKT_DATA	   ||
+	       h->tfrchrx_type = DCCP_PKT_DATAACK ||
+	       h->tfrchrx_type = DCCP_PKT_REQUEST ||
+	       h->tfrchrx_type = DCCP_PKT_RESPONSE;
+}
+
+#endif /* _DCCP_PKT_HIST_INT_ */
-- 
1.5.3.4

