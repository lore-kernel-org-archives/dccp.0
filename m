From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Sep 2010 10:28:56 +0000
Subject: [PATCH 3/5] dccp ccid-3: remove dead states
Message-Id: <1285064938-5933-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is thanks to an investigation by Leandro Sales de Melo and his
colleagues. They worked out two state diagrams which highlight the fact that
the xxx_TERM states in CCID-3/4 are in fact not necessary.

And this can be confirmed by in turn looking at the code: the xxx_TERM states
are only ever set in ccid3_hc_{rx,tx}_exit(): when CCID-3 sets the state
to xxx_TERM, it is at a time where no more processing should be going on,
hence it is not necessary to introduce a dedicated exit state - this is already
implied by unloading the CCID.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |    2 --
 net/dccp/ccids/ccid3.c |   37 +++++++++----------------------------
 2 files changed, 9 insertions(+), 30 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -77,7 +77,6 @@ enum ccid3_hc_tx_states {
 	TFRC_SSTATE_NO_SENT = 1,
 	TFRC_SSTATE_NO_FBACK,
 	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
 };
 
 /**
@@ -130,7 +129,6 @@ static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
 	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
 };
 
 /**
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -54,7 +54,6 @@ static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
 	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
 	[TFRC_SSTATE_FBACK]    = "FBACK",
-	[TFRC_SSTATE_TERM]     = "TERM",
 	};
 
 	return ccid3_state_names[state];
@@ -208,10 +207,13 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	ccid3_pr_debug("%s(%p, state=%s) - entry\n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hc->tx_state));
 
+	/* Ignore and do not restart after leaving the established state */
+	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
+		goto out;
+
+	/* Reset feedback state to "no feedback received" */
 	if (hc->tx_state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hc->tx_state != TFRC_SSTATE_NO_FBACK)
-		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
@@ -287,8 +289,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hc->tx_state) {
-	case TFRC_SSTATE_NO_SENT:
+	if (hc->tx_state = TFRC_SSTATE_NO_SENT) {
 		sk_reset_timer(sk, &hc->tx_no_feedback_timer, (jiffies +
 			       usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
 		hc->tx_last_win_count	= 0;
@@ -323,9 +324,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		ccid3_update_send_interval(hc);
 
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-		break;
-	case TFRC_SSTATE_NO_FBACK:
-	case TFRC_SSTATE_FBACK:
+
+	} else {
 		delay = ktime_us_delta(hc->tx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
@@ -340,10 +340,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			return (u32)delay / USEC_PER_MSEC;
 
 		ccid3_hc_tx_update_win_count(hc, now);
-		break;
-	case TFRC_SSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return -EINVAL;
 	}
 
 	/* prepare to send now (add options etc.) */
@@ -379,11 +375,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
-	/* ... and only in the established state */
-	if (hc->tx_state != TFRC_SSTATE_FBACK &&
-	    hc->tx_state != TFRC_SSTATE_NO_FBACK)
-		return;
-
 	/*
 	 * Locate the acknowledged packet in the TX history.
 	 *
@@ -529,9 +520,7 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 
-	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
-
 	tfrc_tx_hist_purge(&hc->tx_hist);
 }
 
@@ -590,7 +579,6 @@ static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 	static const char *const ccid3_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
 	[TFRC_RSTATE_DATA]    = "DATA",
-	[TFRC_RSTATE_TERM]    = "TERM",
 	};
 
 	return ccid3_rx_state_names[state];
@@ -616,14 +604,9 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 {
 	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	ktime_t now;
+	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hc->rx_state = TFRC_RSTATE_TERM))
-		return;
-
-	now = ktime_get_real();
-
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
 		hc->rx_x_recv = 0;
@@ -827,8 +810,6 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 
-	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
-
 	tfrc_rx_hist_purge(&hc->rx_hist);
 	tfrc_lh_cleanup(&hc->rx_li_hist);
 }
