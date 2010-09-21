From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Sep 2010 10:28:58 +0000
Subject: [PATCH 5/5] dccp ccid-3: Remove redundant 'options_received' struct
Message-Id: <1285064938-5933-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The `options_received' struct is redundant, since it re-duplicates the existing
`p' and `x_recv' fields. This patch removes the sub-struct and migrates the
format conversion operations to ccid3_hc_tx_parse_options().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |    7 -------
 net/dccp/ccids/ccid3.c |   24 ++++++++----------------
 2 files changed, 8 insertions(+), 23 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -365,11 +365,10 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv = &hc->tx_options_received;
 	struct tfrc_tx_hist_entry *acked;
 	ktime_t now;
 	unsigned long t_nfb;
-	u32 pinv, r_sample;
+	u32 r_sample;
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -394,17 +393,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	r_sample  = dccp_sample_rtt(sk, ktime_us_delta(now, acked->stamp));
 	hc->tx_rtt = tfrc_ewma(hc->tx_rtt, r_sample, 9);
 
-	/* Update receive rate in units of 64 * bytes/second */
-	hc->tx_x_recv = opt_recv->ccid3or_receive_rate;
-	hc->tx_x_recv <<= 6;
-
-	/* Update loss event rate (which is scaled by 1e6) */
-	pinv = opt_recv->ccid3or_loss_event_rate;
-	if (pinv = 0)
-		hc->tx_p = 0;
-	else
-		hc->tx_p = tfrc_invert_loss_event_rate(pinv);
-
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
@@ -476,7 +464,6 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 				     u8 option, u8 *optval, u8 optlen)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
-	struct ccid3_options_received *opt_recv = &hc->tx_options_received;
 	__be32 opt_val;
 
 	switch (option) {
@@ -493,11 +480,16 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 		opt_val = ntohl(get_unaligned((__be32 *)optval));
 
 		if (option = TFRC_OPT_RECEIVE_RATE) {
-			opt_recv->ccid3or_receive_rate = opt_val;
+			/* Receive Rate is kept in units of 64 bytes/second */
+			hc->tx_x_recv = opt_val;
+			hc->tx_x_recv <<= 6;
+
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		} else {
-			opt_recv->ccid3or_loss_event_rate = opt_val;
+			/* Update the fixpoint Loss Event Rate fraction */
+			hc->tx_p = tfrc_invert_loss_event_rate(opt_val);
+
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		}
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -67,11 +67,6 @@ enum ccid3_options {
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
@@ -97,7 +92,6 @@ enum ccid3_hc_tx_states {
  * @tx_t_ld:		  Time last doubled during slow start
  * @tx_t_nom:		  Nominal send time of next packet
  * @tx_hist:		  Packet history
- * @tx_options_received:  Parsed set of retrieved options
  */
 struct ccid3_hc_tx_sock {
 	u64				tx_x;
@@ -115,7 +109,6 @@ struct ccid3_hc_tx_sock {
 	ktime_t				tx_t_ld;
 	ktime_t				tx_t_nom;
 	struct tfrc_tx_hist_entry	*tx_hist;
-	struct ccid3_options_received	tx_options_received;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
