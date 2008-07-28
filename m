From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:13:58 +0000
Subject: [PATCH 2/7] dccp ccid-3: Simplified handling of TX states
Message-Id: <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since CCIDs are only used during the established phase of a connection,
they have very little internal state; this specifically reduces to:

 * "no packet sent" if and only if s = 0, for the TX packet size s;

 * when the first packet has been sent (i.e. `s' > 0), the question is whether
   or not feedback has been received:
   - if a feedback packet is received, "feedback = yes" is set,
   - if the nofeedback timer expires,  "feedback = no"  is set.

Thus the CCID only needs to remember state about whether or not feedback
has been received. This is now implemented using a boolean flag, which is
toggled when a feedback packet arrives or the nofeedback timer expires.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   41 ++++++-----------------------------------
 net/dccp/ccids/ccid3.h |   11 ++---------
 2 files changed, 8 insertions(+), 44 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -70,13 +70,6 @@ enum ccid3_options {
 	TFRC_OPT_RECEIVE_RATE	 = 194,
 };
 
-/* TFRC sender states */
-enum ccid3_hc_tx_states {
-	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-};
-
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
  * @x - Current sending rate in 64 * bytes per second
@@ -87,7 +80,7 @@ enum ccid3_hc_tx_states {
  * @s - Packet size in bytes
  * @t_rto - Nofeedback Timer setting in usecs
  * @t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @state - Sender state, one of %ccid3_hc_tx_states
+ * @feedback - Whether feedback has been received or not
  * @last_win_count - Last window counter sent
  * @t_last_win_count - Timestamp of earliest packet with
  *                     last_win_count value sent
@@ -105,7 +98,7 @@ struct ccid3_hc_tx_sock {
 	u32				t_rto;
 	u32				t_ipi;
 	u16				s;
-	enum ccid3_hc_tx_states		state:8;
+	bool				feedback:1;
 	u8				last_win_count;
 	ktime_t				t_last_win_count;
 	struct timer_list		no_feedback_timer;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,31 +49,6 @@ static int ccid3_debug;
 /*
  *	Transmitter Half-Connection Routines
  */
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
-{
-	static char *ccid3_state_names[] = {
-	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
-	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
-	[TFRC_SSTATE_FBACK]    = "FBACK",
-	};
-
-	return ccid3_state_names[state];
-}
-#endif
-
-static void ccid3_hc_tx_set_state(struct sock *sk,
-				  enum ccid3_hc_tx_states state)
-{
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	enum ccid3_hc_tx_states oldstate = hctx->state;
-
-	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
-		       ccid3_tx_state_name(state));
-	WARN_ON(state = oldstate);
-	hctx->state = state;
-}
 
 /*
  * Compute the initial sending rate X_init in the manner of RFC 3390:
@@ -206,16 +181,15 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		goto restart_timer;
 	}
 
-	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->state));
+	ccid3_pr_debug("%s(%p) entry with%s feedback\n", dccp_role(sk), sk,
+		       hctx->feedback ? "" : "out");
 
 	/* Ignore and do not restart after leaving the established state */
 	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
 		goto out;
 
 	/* Reset feedback state to "no feedback received" */
-	if (hctx->state = TFRC_SSTATE_FBACK)
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
+	hctx->feedback = false;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
@@ -290,7 +264,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	if (hctx->state = TFRC_SSTATE_NO_SENT) {
+	if (hctx->s = 0) {
 		sk_reset_timer(sk, &hctx->no_feedback_timer, (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
 		hctx->last_win_count   = 0;
@@ -324,8 +298,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		}
 		ccid3_update_send_interval(hctx);
 
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-
 	} else {
 		delay = ktime_us_delta(hctx->t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
@@ -396,8 +368,8 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->state = TFRC_SSTATE_NO_FBACK) {
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+	if (!hctx->feedback) {
+		hctx->feedback = true;
 
 		if (hctx->t_rto = 0) {
 			/*
@@ -502,7 +474,6 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->state = TFRC_SSTATE_NO_SENT;
 	hctx->hist  = NULL;
 	setup_timer(&hctx->no_feedback_timer,
 		    ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
