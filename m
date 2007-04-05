From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:55 +0000
Subject: [PATCH 27/43]: Accurately determine idle & application-limited periods
Message-Id: <200704051635.55172@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Accurately determine idle & application-limited periods

This fixes/updates the handling of idle and application-limited periods in CCID3,
which currently is broken: there is no detection as to how long a sender has been
idle; there is only one flag which is toggled in between function calls.

This patch implements detection of idle/application-limited periods on the basis
of draft rfc3448bis-01, taking into account the time during which the sender
has indeed not sent anything (i.e. has been idle); the condition now is:
  If the sender has not sent anything during the last two RTTs, 
  it gets the bonus of a larger initial window (from RFC 3390).
Further support for this definition of idleness is found in the specification of
CCID 2 (RFC 4341): in section 6.2.1, the timeout interval for detecting quiescence
(aka idleness) is set to max(0.2 sec, 2 * RTT). 

Being obsolete now, the `idle' flag is removed.

NB: This patch could be extended at a later stage to experiment with different idleness
    definitions (e.g. RFC 2581, 4.1), by using selectable functions which codify the
    respective definition and which could be configured to use. However, the main purpose
    here is to fix the currently broken quiescence-detection by using a workable solution.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   55 +++++++++++++++++++++---------------
 net/dccp/ccids/ccid3.h              |    2 -
 net/dccp/ccids/lib/packet_history.c |   21 +++++++++++++
 net/dccp/ccids/lib/packet_history.h |    1 
 4 files changed, 55 insertions(+), 24 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -90,7 +90,6 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
  *				 with last_win_count value sent
  * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
- * @ccid3hctx_idle - Flag indicating that sender is idling
  * @ccid3hctx_t_ld - Time last doubled during slow start
  * @ccid3hctx_t_nom - Nominal send time of next packet
  * @ccid3hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
@@ -109,7 +108,6 @@ struct ccid3_hc_tx_sock {
 	u16				ccid3hctx_s;
 	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
-	u8				ccid3hctx_idle;
 	struct timeval			ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
 	struct timeval			ccid3hctx_t_ld;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -109,34 +109,51 @@ static inline void ccid3_update_send_int
 		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
 
 }
-/*
- * Update X by
- *    If (p > 0)
- *       X_calc = calcX(s, R, p);
- *       X = max(min(X_calc, 2 * X_recv), s / t_mbi);
- *    Else
- *       If (now - tld >= R)
- *          X = max(min(2 * X, 2 * X_recv), s / R);
- *          tld = now;
- *
- * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
- *       fine-grained resolution of sending rates. This requires scaling by 2^6
- *       throughout the code. Only X_calc is unscaled (in bytes/second).
- *
+
+/**
+ *  ccid3_hc_tx_idle  -  Whether sender is idle or application-limited
+ *  @now: Current time needs to be supplied
+ *  Returns the number of full RTTs during which the sender has been idle.
+ */
+static int ccid3_hc_tx_idle(struct ccid3_hc_tx_sock *hctx, struct timeval *now)
+{
+	struct timeval last_send;
+	suseconds_t delta;
+
+	if (! dccp_tx_hist_last_send_time(&hctx->ccid3hctx_hist, &last_send))
+		return 0;
+	delta = timeval_delta(now, &last_send);
+	return delta <= 0? 0 : delta/hctx->ccid3hctx_rtt;
+}
+
+/**
+ *  ccid3_hc_tx_update_x  -  Recompute allowed sending rate X
+ *  @now: Recent timestamp when available; can be left NULL
+ *  Computation is according to rfc3448bis-01, section 4.3.
+ *  Note: X and X_recv are both stored in units of 64 * bytes/second, to
+ *  support fine-grained resolution of sending rates. This requires scaling
+ *  by 2^6  throughout the code. Only X_calc is unscaled (in bytes/second).
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct timeval right_now;
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
 
+	if (now = NULL) {
+		do_gettimeofday(&right_now);
+		now = &right_now;
+	}
+
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
-	 * when idling [RFC 4342, 5.1]. See also draft-ietf-dccp-rfc3448bis.
+	 * when idling [RFC 4342, 5.1]. Definition of idling is from rfc3448bis:
+	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (unlikely(hctx->ccid3hctx_idle)) {
+	if (ccid3_hc_tx_idle(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
 		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
 	}
@@ -270,8 +287,6 @@ static void ccid3_hc_tx_no_feedback_time
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
 			(unsigned long long)hctx->ccid3hctx_x);
 
-	hctx->ccid3hctx_idle = 1;
-
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
@@ -377,7 +392,6 @@ static int ccid3_hc_tx_send_packet(struc
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
-	hctx->ccid3hctx_idle = 0;
 
 	/* set the nominal send time for the next following packet */
 	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
@@ -535,9 +549,6 @@ done_computing_x:
 
 	ccid3_pr_debug("Scheduled no feedback timer to expire in %lu jiffies"
 		       "(%luus)\n", usecs_to_jiffies(t_nfb), t_nfb);
-
-	/* set idle flag */
-	hctx->ccid3hctx_idle = 1;
 }
 
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -70,6 +70,7 @@ static inline struct dccp_tx_hist_entry 
 
 extern int dccp_tx_hist_get_send_time(struct dccp_tx_hist *, struct list_head *,
 				      u64 seq, struct timeval *t_send);
+extern int dccp_tx_hist_last_send_time(struct list_head *, struct timeval *);
 
 extern void dccp_tx_hist_add_entry(struct list_head *, struct dccp_tx_hist_entry *);
 
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -138,6 +138,27 @@ int dccp_tx_hist_get_send_time(struct dc
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_get_send_time);
 
+/**
+ *  dccp_tx_hist_last_send_time  -  Retrieve last send timestamp
+ *  @list:   TX history list head
+ *  Returns 1 if a meaningful last send time exists, 0 otherwise.
+ */
+int dccp_tx_hist_last_send_time(struct list_head *list, struct timeval *t_last)
+{
+	struct dccp_tx_hist_entry *last = NULL;
+
+	read_lock_bh(&dccp_tx_hist_lock);
+	if (!list_empty(list)) {
+		last = list_entry(list->next, typeof(*last), dccphtx_node);
+		*t_last = last->dccphtx_tstamp;
+	}
+	read_unlock_bh(&dccp_tx_hist_lock);
+
+	return (last != NULL);
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_last_send_time);
+
 void dccp_tx_hist_add_entry(struct list_head *list,
 			    struct dccp_tx_hist_entry *entry)
 {
