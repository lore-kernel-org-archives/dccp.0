From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:14:01 +0000
Subject: [PATCH 5/7] dccp tfrc: Perform early loss detection
Message-Id: <1217268843-19667-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This enables the TFRC code to begin loss detection (as soon as the module
is loaded), using the latest updates from rfc3448bis-06, 6.3.1:

 * when the first data packet(s) are lost or marked, set
 * X_target = s/(2*R) => f(p) = s/(R * X_target) = 2,
 * corresponding to a loss rate of ~ 20.64%.

The handle_loss() function is now called right at the begin of rx_packet_recv()
and thus no longer protected against duplicates: hence a call to rx_duplicate()
has been added.  Such a call makes sense now, as the previous patch initialises
the first entry with a sequence number of GSR.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   48 ++++++++++++++++++++++++++++------
 net/dccp/ccids/lib/packet_history.c |    3 ++
 2 files changed, 42 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -577,6 +577,28 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		hcrx->p_inverse = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case CCID3_FBACK_PARAM_CHANGE:
+		if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
+			/*
+			 * rfc3448bis-06, 6.3.1: First packet(s) lost or marked
+			 * FIXME: in rfc3448bis the receiver returns X_recv=0
+			 * here as it normally would in the first feedback packet.
+			 * However this is not possible yet, since the code still
+			 * uses RFC 3448, i.e.
+			 *    If (p > 0)
+			 *      Calculate X_calc using the TCP throughput equation.
+			 *      X = max(min(X_calc, 2*X_recv), s/t_mbi);
+			 * would bring X down to s/t_mbi. That is why we return
+			 * X_recv according to rfc3448bis-06 for the moment.
+			 */
+			u32 rtt = hcrx->rtt ? : DCCP_FALLBACK_RTT, s = hcrx->s;
+
+			if (s = 0) {
+				DCCP_WARN("No sample for s, using fallback\n");
+				s = TCP_MIN_RCVMSS;
+			}
+			hcrx->x_recv = scaled_div32(s, 2 * rtt);
+			break;
+		}
 		/*
 		 * When parameters change (new loss or p > p_prev), we do not
 		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
@@ -650,6 +672,14 @@ static u32 ccid3_first_li(struct sock *sk)
 	u32 x_recv, p, delta;
 	u64 fval;
 
+	/*
+	 * rfc3448bis-06, 6.3.1: First data packet(s) are marked or lost. Set p
+	 * to give the equivalent of X_target = s/(2*R). Thus fval = 2 and so p
+	 * is about 20.64%. This yields an interval length of 4.84 (rounded up).
+	 */
+	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA))
+		return 5;
+
 	if (hcrx->rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
 		hcrx->rtt = DCCP_FALLBACK_RTT;
@@ -683,6 +713,15 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
+	/*
+	 * Perform loss detection and handle pending losses
+	 */
+	if (tfrc_rx_handle_loss(&hcrx->hist, &hcrx->li_hist,
+				skb, ndp, ccid3_first_li, sk)) {
+		do_feedback = CCID3_FBACK_PARAM_CHANGE;
+		goto done_receiving;
+	}
+
 	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
@@ -710,15 +749,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hcrx->bytes_recv += payload;
 	}
 
-	/*
-	 * Perform loss detection and handle pending losses
-	 */
-	if (tfrc_rx_handle_loss(&hcrx->hist, &hcrx->li_hist,
-				skb, ndp, ccid3_first_li, sk)) {
-		do_feedback = CCID3_FBACK_PARAM_CHANGE;
-		goto done_receiving;
-	}
-
 	if (tfrc_rx_hist_loss_pending(&hcrx->hist))
 		return; /* done receiving */
 
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -335,6 +335,9 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 {
 	int is_new_loss = 0;
 
+	if (tfrc_rx_hist_duplicate(h, skb))
+		return 0;
+
 	if (h->loss_count = 0) {
 		__do_track_loss(h, skb, ndp);
 	} else if (h->loss_count = 1) {
