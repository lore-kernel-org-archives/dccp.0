From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 21:09:50 +0000
Subject: [PATCH 3/6] [DCCP]: Simplify interface of dccp_sample_rtt
Message-Id: <20070922210950.GH4887@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The third parameter of dccp_sample_rtt now becomes useless and is removed.

Also combined the subtraction of the timestamp echo and the elapsed time.
This is safe, since (a) presence of timestamp echo is tested first and (b)
elapsed time is either present and non-zero or it is not set and equals 0
due to the memset in dccp_parse_options.

To avoid measuring option-processing time, the timestamp for measuring the
initial Request/Response RTT sample is taken directly when the function is
called (the Linux implementation always adds a timestamp on the Request,
so there is no loss in doing this).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    6 +++---
 net/dccp/dccp.h        |    3 +--
 net/dccp/input.c       |   44 +++++++++++++++-----------------------------
 3 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index e16f9bb..0bb338b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -448,7 +448,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
 		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
-		r_sample = dccp_sample_rtt(sk, now, &packet->dccphtx_tstamp);
+		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->dccphtx_tstamp));
 
 		/*
 		 * Update RTT estimate by
@@ -881,9 +881,9 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	case DCCP_PKT_DATAACK:
 		if (opt_recv->dccpor_timestamp_echo = 0)
 			break;
+		r_sample = dccp_timestamp() - opt_recv->dccpor_timestamp_echo;
 		rtt_prev = hcrx->ccid3hcrx_rtt;
-		now = ktime_get_real();
-		r_sample = dccp_sample_rtt(sk, now, NULL);
+		r_sample = dccp_sample_rtt(sk, 10 * r_sample);
 
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			hcrx->ccid3hcrx_rtt = r_sample;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index a75c740..bd4645b 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -297,8 +297,7 @@ extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
-extern u32	   dccp_sample_rtt(struct sock *sk, ktime_t t_recv,
-				   ktime_t *t_history);
+extern u32	   dccp_sample_rtt(struct sock *sk, long delta);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 782cdb7..3b65170 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -280,6 +280,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 	if (dh->dccph_type = DCCP_PKT_RESPONSE) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		struct dccp_sock *dp = dccp_sk(sk);
+		long tstamp = dccp_timestamp();
 
 		/* Stop the REQUEST timer */
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
@@ -300,11 +301,10 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (dccp_parse_options(sk, skb))
 			goto out_invalid_packet;
 
-		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
-		if (dp->dccps_options_received.dccpor_timestamp_echo)
-			dp->dccps_syn_rtt = dccp_sample_rtt(sk,
-							    ktime_get_real(),
-							    NULL);
+		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
+		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
+			    dp->dccps_options_received.dccpor_timestamp_echo));
 
 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
@@ -585,36 +585,22 @@ discard:
 EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
 
 /**
- * dccp_sample_rtt  -  Sample RTT from packet exchange
- *
- * @sk:     connected dccp_sock
- * @t_recv: receive timestamp of packet with timestamp echo
- * @t_hist: packet history timestamp or NULL
+ *  dccp_sample_rtt  -  Validate and finalise computation of RTT sample
+ *  @delta:	number of microseconds between packet and acknowledgment
+ *  The routine is kept generic to work in different contexts. It should be
+ *  called immediately when the ACK used for the RTT sample arrives.
  */
-u32 dccp_sample_rtt(struct sock *sk, ktime_t t_recv, ktime_t *t_hist)
+u32 dccp_sample_rtt(struct sock *sk, long delta)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_options_received *or = &dp->dccps_options_received;
-	s64 delta;
-
-	if (t_hist = NULL) {
-		if (!or->dccpor_timestamp_echo) {
-			DCCP_WARN("packet without timestamp echo\n");
-			return DCCP_SANE_RTT_MAX;
-		}
-		ktime_sub_us(t_recv, or->dccpor_timestamp_echo * 10);
-		delta = ktime_to_us(t_recv);
-	} else
-		delta = ktime_us_delta(t_recv, *t_hist);
-
-	delta -= or->dccpor_elapsed_time * 10;		/* either set or 0 */
+	/* dccpor_elapsed_time is either zeroed out or set and > 0 */
+	delta -= dccp_sk(sk)->dccps_options_received.dccpor_elapsed_time * 10;
 
 	if (unlikely(delta <= 0)) {
-		DCCP_WARN("unusable RTT sample %ld, using min\n", (long)delta);
+		DCCP_WARN("unusable RTT sample %ld, using min\n", delta);
 		return DCCP_SANE_RTT_MIN;
 	}
-	if (unlikely(delta - (s64)DCCP_SANE_RTT_MAX > 0)) {
-		DCCP_WARN("RTT sample %ld too large, using max\n", (long)delta);
+	if (unlikely(delta > DCCP_SANE_RTT_MAX)) {
+		DCCP_WARN("RTT sample %ld too large, using max\n", delta);
 		return DCCP_SANE_RTT_MAX;
 	}
 
-- 
1.5.3.1

