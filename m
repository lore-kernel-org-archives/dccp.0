From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Aug 2010 05:41:36 +0000
Subject: [PATCH 1/5] ccid: ccid-2/3 code cosmetics
Message-Id: <1282542100-5799-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch collects cosmetics-only changes to separate these from
code changes:
 * update with regard to CodingStyle and whitespace changes,
 * documentation:
   - adding/revising comments,
   - remove CCID-3 RX socket documentation which is either
     duplicate or refers to fields that no longer exist,
 * expand embedded tfrc_tx_info struct inline for consistency,
   removing indirections via #define.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    4 ++--
 net/dccp/ccids/ccid3.h |   19 +++++++------------
 net/dccp/ccids/ccid3.c |   30 ++++++++++++++++++------------
 3 files changed, 27 insertions(+), 26 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -193,8 +193,8 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hc->tx_ssthresh = hc->tx_cwnd / 2;
 	if (hc->tx_ssthresh < 2)
 		hc->tx_ssthresh = 2;
-	hc->tx_cwnd	 = 1;
-	hc->tx_pipe	 = 0;
+	hc->tx_cwnd	= 1;
+	hc->tx_pipe	= 0;
 
 	/* clear state about stuff we sent */
 	hc->tx_seqt = hc->tx_seqh;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -95,14 +95,13 @@ enum ccid3_hc_tx_states {
  * @tx_options_received:  Parsed set of retrieved options
  */
 struct ccid3_hc_tx_sock {
-	struct tfrc_tx_info		tx_tfrc;
-#define tx_x				tx_tfrc.tfrctx_x
-#define tx_x_recv			tx_tfrc.tfrctx_x_recv
-#define tx_x_calc			tx_tfrc.tfrctx_x_calc
-#define tx_rtt				tx_tfrc.tfrctx_rtt
-#define tx_p				tx_tfrc.tfrctx_p
-#define tx_t_rto			tx_tfrc.tfrctx_rto
-#define tx_t_ipi			tx_tfrc.tfrctx_ipi
+	u64				tx_x;
+	u64				tx_x_recv;
+	u32				tx_x_calc;
+	u32				tx_rtt;
+	u32				tx_p;
+	u32				tx_t_rto;
+	u32				tx_t_ipi;
 	u16				tx_s;
 	enum ccid3_hc_tx_states		tx_state:8;
 	u8				tx_last_win_count;
@@ -131,16 +130,12 @@ enum ccid3_hc_rx_states {
 
 /**
  * struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
- * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448 4.3)
- * @rx_rtt:		     Receiver estimate of rtt (non-standard)
- * @rx_p:		     Current loss event rate (RFC 3448 5.4)
  * @rx_last_counter:	     Tracks window counter (RFC 4342, 8.1)
  * @rx_state:		     Receiver state, one of %ccid3_hc_rx_states
  * @rx_bytes_recv:	     Total sum of DCCP payload bytes
  * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448, sec. 4.3)
  * @rx_rtt:		     Receiver estimate of RTT
  * @rx_tstamp_last_feedback: Time at which last feedback was sent
- * @rx_tstamp_last_ack:	     Time at which last feedback was sent
  * @rx_hist:		     Packet history (loss detection + RTT sampling)
  * @rx_li_hist:		     Loss Interval database
  * @rx_s:		     Received packet size in bytes
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -218,9 +218,9 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
+	 * RTO is 0 if and only if no feedback has been received yet.
 	 */
-	if (hc->tx_t_rto = 0 ||	/* no feedback received yet */
-	    hc->tx_p = 0) {
+	if (hc->tx_t_rto = 0 || hc->tx_p = 0) {
 
 		/* halve send rate directly */
 		hc->tx_x = max(hc->tx_x / 2,
@@ -256,7 +256,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hc->tx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hc->tx_t_rto = 0))	/* no feedback received yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
 		t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
@@ -372,7 +372,7 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv;
+	struct ccid3_options_received *opt_recv = &hc->tx_options_received;
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -386,7 +386,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	    hc->tx_state != TFRC_SSTATE_NO_FBACK)
 		return;
 
-	opt_recv = &hc->tx_options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
@@ -489,11 +488,9 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv;
+	struct ccid3_options_received *opt_recv = &hc->tx_options_received;
 	__be32 opt_val;
 
-	opt_recv = &hc->tx_options_received;
-
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
 		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
 		opt_recv->ccid3or_loss_event_rate    = ~0;
@@ -582,6 +579,7 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
 	const struct ccid3_hc_tx_sock *hc;
+	struct tfrc_tx_info tfrc;
 	const void *val;
 
 	/* Listen socks doesn't have a private CCID block */
@@ -591,10 +589,17 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 	hc = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hc->tx_tfrc))
+		if (len < sizeof(tfrc))
 			return -EINVAL;
-		len = sizeof(hc->tx_tfrc);
-		val = &hc->tx_tfrc;
+		tfrc.tfrctx_x	   = hc->tx_x;
+		tfrc.tfrctx_x_recv = hc->tx_x_recv;
+		tfrc.tfrctx_x_calc = hc->tx_x_calc;
+		tfrc.tfrctx_rtt	   = hc->tx_rtt;
+		tfrc.tfrctx_p	   = hc->tx_p;
+		tfrc.tfrctx_rto	   = hc->tx_t_rto;
+		tfrc.tfrctx_ipi	   = hc->tx_t_ipi;
+		len = sizeof(tfrc);
+		val = &tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -749,10 +754,11 @@ static u32 ccid3_first_li(struct sock *sk)
 	x_recv = scaled_div32(hc->rx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hc->rx_x_recv) = 0) {
+		if (hc->rx_x_recv = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
+		x_recv = hc->rx_x_recv;
 	}
 
 	fval = scaled_div(hc->rx_s, hc->rx_rtt);
