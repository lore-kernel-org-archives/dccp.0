From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 08:32:47 +0000
Subject: [PATCH 7/7] [TCP][DCCP]: Consolidate duplicate code which does RFC3390 conversion
Message-Id: <1211877167-10995-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch consolidates the code common to TCP and CCID-2:

 * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c) and
 * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/tcp.h      |   15 +++++++++++++++
 net/dccp/ccids/ccid2.c |    8 ++------
 net/ipv4/tcp_input.c   |   17 ++---------------
 3 files changed, 19 insertions(+), 21 deletions(-)

--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -783,6 +783,21 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 /* Use define here intentionally to get WARN_ON location shown at the caller */
 #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
 
+/*
+ * Convert RFC3390 larger initial windows into an equivalent number of packets.
+ *
+ * John Heffner states:
+ *
+ *	The RFC specifies a window of no more than 4380 bytes
+ *	unless 2*MSS > 4380.  Reading the pseudocode in the RFC
+ *	is a bit misleading because they use a clamp at 4380 bytes
+ *	rather than a multiplier in the relevant range.
+ */
+static inline u32 rfc3390_bytes_to_packets(const u32 bytes)
+{
+	return bytes < 1095 ? 4 : (bytes > 1460 ? 2 : 3);
+}
+
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -708,12 +708,8 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
 	hctx->ssthresh = ~0U;
 
-	/*
-	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
-	 * packets for new connections, following the rules from [RFC3390]".
-	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
-	 */
-	hctx->cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
+	/* Use larger initial windows (RFC 3390, rfc2581bis) */
+	hctx->cwnd = rfc3390_bytes_to_packets(dp->dccps_mss_cache);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
 	max_ratio = DIV_ROUND_UP(hctx->cwnd, 2);
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -808,25 +808,12 @@ void tcp_update_metrics(struct sock *sk)
 	}
 }
 
-/* Numbers are taken from RFC3390.
- *
- * John Heffner states:
- *
- *	The RFC specifies a window of no more than 4380 bytes
- *	unless 2*MSS > 4380.  Reading the pseudocode in the RFC
- *	is a bit misleading because they use a clamp at 4380 bytes
- *	rather than use a multiplier in the relevant range.
- */
 __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
 {
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
-	if (!cwnd) {
-		if (tp->mss_cache > 1460)
-			cwnd = 2;
-		else
-			cwnd = (tp->mss_cache > 1095) ? 3 : 4;
-	}
+	if (!cwnd)
+		cwnd = rfc3390_bytes_to_packets(tp->mss_cache);
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }
 
-- 
1.5.5

