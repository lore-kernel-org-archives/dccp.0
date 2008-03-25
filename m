From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:11 +0000
Subject: [PATCH 7/7] [CCID-3]: Remove dead states
Message-Id: <1206462011-24907-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is thanks to an investigation by Leandro Sales de Melo and his
colleagues. They worked out two state diagrams which highlight the fact that
the xxx_TERM states in CCID-3/4 are in fact not necessary.

And this can be confirmed by in turn looking at the code: the xxx_TERM states
are only ever set in ccid3_hc_{rx,tx}_exit(). These two functions are part
of the following call chain:

 * ccid_hc_{tx,rx}_exit() are called from ccid_delete() only;
 * ccid_delete() invokes ccid_hc_{tx,rx}_exit() in the way of a destructor:
   after calling ccid_hc_{tx,rx}_exit(), the CCID is released from memory;
 * ccid_delete() is in turn called only by ccid_hc_{tx,rx}_delete();
 * ccid_hc_{tx,rx}_delete() is called only if 
   - feature negotiation failed   (dccp_feat_activate_values()),
   - when changing the RX/TX CCID (to eject the current CCID),
   - when destroying the socket   (in dccp_destroy_sock()).

In other words, when CCID-3 sets the state to xxx_TERM, it is at a time where
no more processing should be going on, hence it is not necessary to introduce
a dedicated exit state - this is implicit when unloading the CCID.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   21 +--------------------
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 1 insertion(+), 22 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -56,7 +56,6 @@ static const char *ccid3_tx_state_name(e
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
 	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
 	[TFRC_SSTATE_FBACK]    = "FBACK",
-	[TFRC_SSTATE_TERM]     = "TERM",
 	};
 
 	return ccid3_state_names[state];
@@ -340,10 +339,6 @@ static int ccid3_hc_tx_send_packet(struc
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
-		break;
-	case TFRC_SSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return -EINVAL;
 	}
 
 	/* prepare to send now (add options etc.) */
@@ -379,10 +374,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	    !(dcb->dccpd_type = DCCP_PKT_ACK ||
 	      dcb->dccpd_type = DCCP_PKT_DATAACK))
 		return;
-	/* ... and only in the established state */
-	if (hctx->state != TFRC_SSTATE_FBACK &&
-	    hctx->state != TFRC_SSTATE_NO_FBACK)
-		return;
 
 	opt_recv = &hctx->options_received;
 	now = ktime_get_real();
@@ -557,9 +548,7 @@ static void ccid3_hc_tx_exit(struct sock
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->no_feedback_timer);
-
 	tfrc_tx_hist_purge(&hctx->hist);
 }
 
@@ -618,7 +607,6 @@ static const char *ccid3_rx_state_name(e
 	static char *ccid3_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
 	[TFRC_RSTATE_DATA]    = "DATA",
-	[TFRC_RSTATE_TERM]    = "TERM",
 	};
 
 	return ccid3_rx_state_names[state];
@@ -644,14 +632,9 @@ static void ccid3_hc_rx_send_feedback(st
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	ktime_t now;
+	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hcrx->state = TFRC_RSTATE_TERM))
-		return;
-
-	now = ktime_get_real();
-
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
 		hcrx->x_recv = 0;
@@ -855,8 +838,6 @@ static void ccid3_hc_rx_exit(struct sock
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 
-	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
-
 	tfrc_rx_hist_purge(&hcrx->hist);
 	tfrc_lh_cleanup(&hcrx->li_hist);
 }
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -72,7 +72,6 @@ enum ccid3_hc_tx_states {
 	TFRC_SSTATE_NO_SENT = 1,
 	TFRC_SSTATE_NO_FBACK,
 	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
 };
 
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
@@ -127,7 +126,6 @@ static inline struct ccid3_hc_tx_sock *c
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
 	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
 };
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
