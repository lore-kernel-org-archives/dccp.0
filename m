From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:58:27 +0000
Subject: [PATCH 4/6]: Simplify interface of dccp_sample_rtt
Message-Id: <200706091958.27168@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Simplify interface of dccp_sample_rtt

The third parameter of dccp_sample_rtt now becomes useless and is removed.

Also combined the subtraction of the timestamp echo and the elapsed time.
This is safe, since (a) presence of timestamp echo is tested first and (b)
elapsed time is either present and non-zero or it is not set and equals 0
due to the memset in dccp_parse_options.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h  |    3 +--
 net/dccp/input.c |   40 ++++++++++++++--------------------------
 2 files changed, 15 insertions(+), 28 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -299,8 +299,7 @@ extern int	   dccp_v4_connect(struct soc
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
-extern u32	   dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
-						    struct timeval *t_history);
+extern u32	   dccp_sample_rtt(struct sock *sk, long candidate);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -303,9 +303,12 @@ static int dccp_rcv_request_sent_state_p
 		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
 		if (dp->dccps_options_received.dccpor_timestamp_echo) {
 			struct timeval now;
+			long d;
 
 			dccp_timestamp(sk, &now);
-			dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
+			d = timeval_usecs(&now)
+			  - 10*dp->dccps_options_received.dccpor_timestamp_echo;
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, d);
 		}
 
 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
@@ -587,37 +590,22 @@ discard:
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
-u32 dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
-				     struct timeval *t_hist)
+u32 dccp_sample_rtt(struct sock *sk, long delta)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_options_received *or = &dp->dccps_options_received;
-	suseconds_t delta;
-
-	if (t_hist = NULL) {
-		if (!or->dccpor_timestamp_echo) {
-			DCCP_WARN("packet without timestamp echo\n");
-			return DCCP_SANE_RTT_MAX;
-		}
-		timeval_sub_usecs(t_recv, or->dccpor_timestamp_echo * 10);
-		delta = timeval_usecs(t_recv);
-	} else
-		delta = timeval_delta(t_recv, t_hist);
-
-	delta -= or->dccpor_elapsed_time * 10;		/* either set or 0 */
+	/* dccpor_elapsed_time is either zeroed out or set and > 0 */
+	delta -= dccp_sk(sk)->dccps_options_received.dccpor_elapsed_time * 10;
 
 	if (unlikely(delta <= 0)) {
-		DCCP_WARN("unusable RTT sample %ld, using min\n", (long)delta);
+		DCCP_WARN("unusable RTT sample %ld, using min\n", delta);
 		return DCCP_SANE_RTT_MIN;
 	}
-	if (unlikely(delta - (suseconds_t)DCCP_SANE_RTT_MAX > 0)) {
-		DCCP_WARN("RTT sample %ld too large, using max\n", (long)delta);
+	if (unlikely(delta > DCCP_SANE_RTT_MAX)) {
+		DCCP_WARN("RTT sample %ld too large, using max\n", delta);
 		return DCCP_SANE_RTT_MAX;
 	}
 
