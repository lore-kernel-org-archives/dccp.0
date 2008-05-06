From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 07:38:05 +0000
Subject: [PATCH 4/4] [CCID-3]: Remove indirection when parsing options
Message-Id: <1210059485-691-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The `options_received' struct is redundant, since it re-duplicates the existing
`p' and `x_recv' fields. This patch removes the sub-struct and migrates the
related format conversion operations (cf. below) to ccid3_hc_tx_parse_options().

The patch also adds a convenience function to convert a reciprocal value into
the loss rate p, performing the scaling and considering the two special cases:

 * 1/(2^32-1) is mapped into 0% as per RFC 4342, 8.5;
 * 1/0        is mapped into the maximum of 100%.

This further fixes a bug in ccid3_hc_rx_getsockopt (1/0 was mapped into ~0U),
which now allows to consistently print the scaled p-values as

	printf("Loss Event Rate = %u.%04u %%\n", rx_info.tfrcrx_p / 10000,
						 rx_info.tfrcrx_p % 10000);

Lastly, documentation about the scaling factor used for fractions was added.

	  ----------------------------------------------
           Why the fields are redundant [can be removed]
	  ----------------------------------------------
The Loss Event Rate p and the Receive Rate x_recv are initially 0 when first
loading CCID-3, as ccid_new() zeroes out the entire ccid3_hc_tx_sock.

When Loss Event Rate or Receive Rate options are received, they are stored by
ccid3_hc_tx_parse_options() into the fields `ccid3or_loss_event_rate' and
`ccid3or_receive_rate' of the sub-struct `options_received' in ccid3_hc_tx_sock.

After parsing (considering only the established state - dccp_rcv_established()),
the packet is passed on to ccid_hc_tx_packet_recv(). This calls the CCID-3
specific routine ccid3_hc_tx_packet_recv(), which performs the following copy
operations between fields of ccid3_hc_tx_sock:

 * hctx->options_received.ccid3or_receive_rate is copied into hctx->x_recv,
   after scaling it for fixpoint arithmetic, by 2^64;
 * hctx->options_received.ccid3or_loss_event_rate is copied into hctx->p,
   considering the above special cases; in addition, a value of 0 here needs to
   be mapped into p=0 (when no Loss Event Rate option has been received yet).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |   27 +++++++++------------------
 net/dccp/ccids/ccid3.h    |    9 +--------
 net/dccp/ccids/lib/tfrc.h |   26 ++++++++++++++++++++++++--
 3 files changed, 34 insertions(+), 28 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -366,11 +366,10 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv = &hctx->options_received;
 	struct tfrc_tx_hist_entry *acked;
 	ktime_t now;
 	unsigned long t_nfb;
-	u32 pinv, r_sample;
+	u32 r_sample;
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -395,17 +394,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	r_sample  = dccp_sample_rtt(sk, ktime_us_delta(now, acked->stamp));
 	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
 
-	/* Update receive rate in units of 64 * bytes/second */
-	hctx->x_recv = opt_recv->ccid3or_receive_rate;
-	hctx->x_recv <<= 6;
-
-	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->ccid3or_loss_event_rate;
-	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->p = 0;
-	else				       /* can not exceed 100% */
-		hctx->p = scaled_div(1, pinv);
-
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
@@ -478,7 +466,6 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 				     u8 option, u8 *optval, u8 optlen)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv = &hctx->options_received;
 	__be32 opt_val;
 
 	switch (option) {
@@ -495,11 +482,16 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 		opt_val = ntohl(get_unaligned((__be32 *)optval));
 
 		if (option = TFRC_OPT_RECEIVE_RATE) {
-			opt_recv->ccid3or_receive_rate = opt_val;
+			/* Receive Rate is kept in units of 64 bytes/second */
+			hctx->x_recv = opt_val;
+			hctx->x_recv <<= 6;
+
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		} else {
-			opt_recv->ccid3or_loss_event_rate = opt_val;
+			/* Update the fixpoint Loss Event Rate fraction */
+			hctx->p = tfrc_invert_loss_rate(opt_val);
+
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		}
@@ -836,8 +828,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 			return -EINVAL;
 		rx_info.tfrcrx_x_recv = hcrx->x_recv;
 		rx_info.tfrcrx_rtt    = hcrx->rtt;
-		rx_info.tfrcrx_p      = hcrx->p_inverse = 0 ? ~0U :
-					   scaled_div(1, hcrx->p_inverse);
+		rx_info.tfrcrx_p      = tfrc_invert_loss_rate(hcrx->p_inverse);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -59,11 +59,6 @@ enum ccid3_options {
 	TFRC_OPT_RECEIVE_RATE	 = 194,
 };
 
-struct ccid3_options_received {
-	u32 ccid3or_loss_event_rate;
-	u32 ccid3or_receive_rate;
-};
-
 /* TFRC sender states */
 enum ccid3_hc_tx_states {
 	TFRC_SSTATE_NO_SENT = 1,
@@ -77,7 +72,7 @@ enum ccid3_hc_tx_states {
  * @x_recv - Receive rate    in 64 * bytes per second
  * @x_calc - Calculated rate in bytes per second
  * @rtt - Estimate of current round trip time in usecs
- * @p - Current loss event rate (0-1) scaled by 1000000
+ * @p - Current loss event rate (0-1) scaled by %TFRC_SCALE
  * @s - Packet size in bytes
  * @t_rto - Nofeedback Timer setting in usecs
  * @t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
@@ -90,7 +85,6 @@ enum ccid3_hc_tx_states {
  * @t_nom - Nominal send time of next packet
  * @delta - Send timer delta (RFC 3448, 4.6) in usecs
  * @hist - Packet history
- * @options_received - Parsed set of retrieved options
  */
 struct ccid3_hc_tx_sock {
 	u64				x;
@@ -109,7 +103,6 @@ struct ccid3_hc_tx_sock {
 	ktime_t				t_nom;
 	u32				delta;
 	struct tfrc_tx_hist_entry	*hist;
-	struct ccid3_options_received	options_received;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -28,11 +28,20 @@ extern int tfrc_debug;
 #define tfrc_pr_debug(format, a...)
 #endif
 
-/* integer-arithmetic divisions of type (a * 1000000)/b */
+/*
+ * Routines and constants to perform scaled fixpoint arithmetic.
+ *
+ * To avoid carrying around the remainder of division operations, we scale all
+ * division operations by %TFRC_SCALE. The current factor is balanced, i.e. will
+ * not produce u32 overflow under reasonable conditions. In places where very
+ * large values could occur, scaled_div32() performs an additional sanity check.
+ */
+#define TFRC_SCALE	1000000
+
 static inline u64 scaled_div(u64 a, u32 b)
 {
 	BUG_ON(b=0);
-	a *= 1000000;
+	a *= TFRC_SCALE;
 	do_div(a, b);
 	return a;
 }
@@ -50,6 +59,19 @@ static inline u32 scaled_div32(u64 a, u32 b)
 }
 
 /**
+ * tfrc_invert_loss_rate  -  Invert reciprocal to give scaled Loss Event Rate p
+ * Maps @reciprocal into a percentage p so that 100% corresponds to %TFRC_SCALE.
+ * The highest possible value, 1/0, is mapped into 100%. The smallest possible
+ * value 1/UINT_MAX is rounded down to 0, using the convention of RFC 4342, 8.5.
+ */
+static inline u32 tfrc_invert_loss_rate(const u32 reciprocal)
+{
+	if (reciprocal = UINT_MAX)
+		return 0;
+	return reciprocal <= 1 ? TFRC_SCALE : scaled_div(1, reciprocal);
+}
+
+/**
  * tfrc_ewma  -  Exponentially weighted moving average
  * @weight: Weight to be used as damping factor, in units of 1/10
  */
-- 
1.5.5



The University of Aberdeen is a charity registered in Scotland, No SC013683.

