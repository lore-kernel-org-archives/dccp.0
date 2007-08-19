From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:49:47 +0000
Subject: [PATCH 04/15] Convert ccid3hcrx_tstamp_last_ack to ktime_t
Message-Id: <20070819234947.GH24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   22 ++++++++++++++--------
 net/dccp/ccids/ccid3.h |    2 +-
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 42d3dbc..63051eb 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -876,7 +876,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
 	u32 p_prev, r_sample, rtt_prev;
 	int loss, payload_size;
 
@@ -888,7 +887,9 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	case DCCP_PKT_ACK:
 		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
 			return;
-	case DCCP_PKT_DATAACK:
+	case DCCP_PKT_DATAACK: {
+		struct timeval now;
+
 		if (opt_recv->dccpor_timestamp_echo = 0)
 			break;
 		rtt_prev = hcrx->ccid3hcrx_rtt;
@@ -906,6 +907,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				       dccp_role(sk), sk, hcrx->ccid3hcrx_rtt,
 				       opt_recv->dccpor_elapsed_time);
 		break;
+	}
 	case DCCP_PKT_DATA:
 		break;
 	default: /* We're not interested in other packet types, move along */
@@ -936,18 +938,21 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		ccid3_hc_rx_send_feedback(sk);
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
-	case TFRC_RSTATE_DATA:
+	case TFRC_RSTATE_DATA: {
+		ktime_t now;
+
 		hcrx->ccid3hcrx_bytes_recv += payload_size;
 		if (loss)
 			break;
 
-		dccp_timestamp(sk, &now);
-		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
-		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
+		now = ktime_get_real();
+		if ((ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_ack) -
+		     (s64)hcrx->ccid3hcrx_rtt) >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
 			ccid3_hc_rx_send_feedback(sk);
 		}
 		return;
+	}
 	case TFRC_RSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return;
@@ -984,8 +989,9 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
-	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
+	hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
+	hcrx->ccid3hcrx_tstamp_last_feedback +		ktime_to_timeval(hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index dcb6b67..a69cf88 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -153,7 +153,7 @@ struct ccid3_hc_rx_sock {
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
 	struct timeval			ccid3hcrx_tstamp_last_feedback;
-	struct timeval			ccid3hcrx_tstamp_last_ack;
+	ktime_t				ccid3hcrx_tstamp_last_ack;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
-- 
1.5.2.2

