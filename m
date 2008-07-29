From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:47 +0000
Subject: [PATCH 2/7] dccp ccid-3: Remove redundant RX states
Message-Id: <1217325952-12337-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The only state information that the CCID-3 receiver keeps is whether initial
feedback has been sent or not. Further, this overlaps with use of feedback:

 * state = TFRC_RSTATE_NO_DATA as long as no feedback has been sent;
 * state = TFRC_RSTATE_DATA    as soon as the first feedback has been sent.

This patch reduces the duplication, by memorising the type of the last feedback.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   47 +++++------------------------------------------
 net/dccp/ccids/ccid3.h |   14 ++++++++------
 2 files changed, 13 insertions(+), 48 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -114,16 +114,18 @@ static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
     return hctx;
 }
 
-/* TFRC receiver states */
-enum ccid3_hc_rx_states {
-	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
+
+enum ccid3_fback_type {
+	CCID3_FBACK_NONE = 0,
+	CCID3_FBACK_INITIAL,
+	CCID3_FBACK_PERIODIC,
+	CCID3_FBACK_PARAM_CHANGE
 };
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
  *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @state  -  Receiver state, one of %ccid3_hc_rx_states
+ *  @feedback  -  The type of the feedback last sent
  *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @rtt  -  Receiver estimate of RTT
  *  @tstamp_last_feedback  -  Time at which last feedback was sent
@@ -133,7 +135,7 @@ enum ccid3_hc_rx_states {
  */
 struct ccid3_hc_rx_sock {
 	u8				last_counter:4;
-	enum ccid3_hc_rx_states		state:8;
+	enum ccid3_fback_type		feedback:4;
 	u32				x_recv;
 	u32				rtt;
 	ktime_t				tstamp_last_feedback;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -528,40 +528,6 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 /*
  *	Receiver Half-Connection Routines
  */
-
-/* CCID3 feedback types */
-enum ccid3_fback_type {
-	CCID3_FBACK_NONE = 0,
-	CCID3_FBACK_INITIAL,
-	CCID3_FBACK_PERIODIC,
-	CCID3_FBACK_PARAM_CHANGE
-};
-
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
-{
-	static char *ccid3_rx_state_names[] = {
-	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
-	[TFRC_RSTATE_DATA]    = "DATA",
-	};
-
-	return ccid3_rx_state_names[state];
-}
-#endif
-
-static void ccid3_hc_rx_set_state(struct sock *sk,
-				  enum ccid3_hc_rx_states state)
-{
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_hc_rx_states oldstate = hcrx->state;
-
-	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
-		       ccid3_rx_state_name(state));
-	WARN_ON(state = oldstate);
-	hcrx->state = state;
-}
-
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
 				      const struct sk_buff *skb,
 				      enum ccid3_fback_type fbtype)
@@ -577,7 +543,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		hcrx->p_inverse = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case CCID3_FBACK_PARAM_CHANGE:
-		if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
+		if (unlikely(hcrx->feedback = CCID3_FBACK_NONE)) {
 			/*
 			 * rfc3448bis-06, 6.3.1: First packet(s) lost or marked
 			 * FIXME: in rfc3448bis the receiver returns X_recv=0
@@ -626,6 +592,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 	hcrx->tstamp_last_feedback = now;
 	hcrx->last_counter	   = dccp_hdr(skb)->dccph_ccval;
 	hcrx->hist.bytes_recvd	   = 0;
+	hcrx->feedback		   = fbtype;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -675,7 +642,7 @@ static u32 ccid3_first_li(struct sock *sk)
 	 * to give the equivalent of X_target = s/(2*R). Thus fval = 2 and so p
 	 * is about 20.64%. This yields an interval length of 4.84 (rounded up).
 	 */
-	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA))
+	if (unlikely(hcrx->feedback = CCID3_FBACK_NONE))
 		return 5;
 
 	if (hcrx->rtt = 0) {
@@ -719,11 +686,9 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		goto done_receiving;
 	}
 
-	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
-		if (is_data_packet) {
+	if (unlikely(hcrx->feedback = CCID3_FBACK_NONE)) {
+		if (is_data_packet)
 			do_feedback = CCID3_FBACK_INITIAL;
-			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-		}
 		goto update_records;
 	}
 
@@ -764,7 +729,6 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->state = TFRC_RSTATE_NO_DATA;
 	tfrc_lh_init(&hcrx->li_hist);
 	return tfrc_rx_hist_init(&hcrx->hist, sk);
 }
@@ -779,7 +743,6 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
 	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->rtt;
 }
