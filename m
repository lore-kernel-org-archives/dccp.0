From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:50:43 +0000
Subject: [PATCH 07/15] Convert dccp_sample_rtt to ktime_t
Message-Id: <20070819235043.GK24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   25 ++++++++++---------------
 net/dccp/dccp.h        |    5 +++--
 net/dccp/input.c       |   23 ++++++++++-------------
 3 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1a0c5ed..3524328 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -414,7 +414,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 	struct dccp_tx_hist_entry *packet;
-	struct timeval now;
+	ktime_t now, t_hist;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
@@ -452,13 +452,13 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		dccp_timestamp(sk, &now);
-
+		now = ktime_get_real();
+		t_hist = timeval_to_ktime(packet->dccphtx_tstamp);
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
 		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
-		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
+		r_sample = dccp_sample_rtt(sk, now, &t_hist);
 
 		/*
 		 * Update RTT estimate by
@@ -475,7 +475,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 */
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = timeval_to_ktime(now);
+			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
@@ -882,6 +882,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	struct dccp_rx_hist_entry *packet;
 	u32 p_prev, r_sample, rtt_prev;
 	int loss, payload_size;
+	ktime_t now;
 
 	BUG_ON(hcrx = NULL);
 
@@ -891,14 +892,12 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	case DCCP_PKT_ACK:
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			return;
-	case DCCP_PKT_DATAACK: {
-		struct timeval now;
-
+	case DCCP_PKT_DATAACK:
 		if (opt_recv->dccpor_timestamp_echo = 0)
 			break;
 		rtt_prev = hcrx->ccid3hcrx_rtt;
-		dccp_timestamp(sk, &now);
-		r_sample = dccp_sample_rtt(sk, &now, NULL);
+		now = ktime_get_real();
+		r_sample = dccp_sample_rtt(sk, now, NULL);
 
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			hcrx->ccid3hcrx_rtt = r_sample;
@@ -911,7 +910,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				       dccp_role(sk), sk, hcrx->ccid3hcrx_rtt,
 				       opt_recv->dccpor_elapsed_time);
 		break;
-	}
 	case DCCP_PKT_DATA:
 		break;
 	default: /* We're not interested in other packet types, move along */
@@ -942,9 +940,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		ccid3_hc_rx_send_feedback(sk);
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
-	case TFRC_RSTATE_DATA: {
-		ktime_t now;
-
+	case TFRC_RSTATE_DATA:
 		hcrx->ccid3hcrx_bytes_recv += payload_size;
 		if (loss)
 			break;
@@ -956,7 +952,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			ccid3_hc_rx_send_feedback(sk);
 		}
 		return;
-	}
 	case TFRC_RSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index e2d74cd..20a7bed 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -13,6 +13,7 @@
  */
 
 #include <linux/dccp.h>
+#include <linux/ktime.h>
 #include <net/snmp.h>
 #include <net/sock.h>
 #include <net/tcp.h>
@@ -296,8 +297,8 @@ extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
-extern u32	   dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
-						    struct timeval *t_history);
+extern u32	   dccp_sample_rtt(struct sock *sk, ktime_t t_recv,
+				   ktime_t *t_history);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
diff --git a/net/dccp/input.c b/net/dccp/input.c
index da6ec18..782cdb7 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -301,12 +301,10 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 			goto out_invalid_packet;
 
 		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
-		if (dp->dccps_options_received.dccpor_timestamp_echo) {
-			struct timeval now;
-
-			dccp_timestamp(sk, &now);
-			dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
-		}
+		if (dp->dccps_options_received.dccpor_timestamp_echo)
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk,
+							    ktime_get_real(),
+							    NULL);
 
 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
@@ -593,22 +591,21 @@ EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
  * @t_recv: receive timestamp of packet with timestamp echo
  * @t_hist: packet history timestamp or NULL
  */
-u32 dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
-				     struct timeval *t_hist)
+u32 dccp_sample_rtt(struct sock *sk, ktime_t t_recv, ktime_t *t_hist)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_options_received *or = &dp->dccps_options_received;
-	suseconds_t delta;
+	s64 delta;
 
 	if (t_hist = NULL) {
 		if (!or->dccpor_timestamp_echo) {
 			DCCP_WARN("packet without timestamp echo\n");
 			return DCCP_SANE_RTT_MAX;
 		}
-		timeval_sub_usecs(t_recv, or->dccpor_timestamp_echo * 10);
-		delta = timeval_usecs(t_recv);
+		ktime_sub_us(t_recv, or->dccpor_timestamp_echo * 10);
+		delta = ktime_to_us(t_recv);
 	} else
-		delta = timeval_delta(t_recv, t_hist);
+		delta = ktime_us_delta(t_recv, *t_hist);
 
 	delta -= or->dccpor_elapsed_time * 10;		/* either set or 0 */
 
@@ -616,7 +613,7 @@ u32 dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
 		DCCP_WARN("unusable RTT sample %ld, using min\n", (long)delta);
 		return DCCP_SANE_RTT_MIN;
 	}
-	if (unlikely(delta - (suseconds_t)DCCP_SANE_RTT_MAX > 0)) {
+	if (unlikely(delta - (s64)DCCP_SANE_RTT_MAX > 0)) {
 		DCCP_WARN("RTT sample %ld too large, using max\n", (long)delta);
 		return DCCP_SANE_RTT_MAX;
 	}
-- 
1.5.2.2

