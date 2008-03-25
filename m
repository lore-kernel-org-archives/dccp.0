From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:09 +0000
Subject: [PATCH 5/7] [TCP][DCCP]: Consolidate duplicated code for RFC3390 conversion
Message-Id: <1206462011-24907-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While fixing a sparse warning in DCCP I found that the same code (conversion of
RFC3390 bytes-to-packets) appears identically in 3 different places:

 * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c);
 * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341);
 * CCID-3 uses RFC 3390 in a packet-oriented manner
   (RFC 4342, rfc3448bis).

This patch consolidates the code common to both TCP and DCCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/tcp.h      |   14 ++++++++++++++
 net/dccp/ccids/ccid2.c |    8 ++------
 net/dccp/ccids/ccid3.c |    5 +----
 net/ipv4/tcp_input.c   |   17 ++---------------
 4 files changed, 19 insertions(+), 25 deletions(-)

--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -809,25 +809,12 @@ void tcp_update_metrics(struct sock *sk)
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
 
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -770,6 +770,21 @@ static inline __u32 tcp_current_ssthresh
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
@@ -598,12 +598,8 @@ static int ccid2_hc_tx_init(struct ccid 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
 	hctx->ssthresh  = ~0U;
 
-	/*
-	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
-	 * packets for new connections, following the rules from [RFC3390]".
-	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
-	 */
-	hctx->cwnd = min(4U, max(2U, 4380U / dp->dccps_mss_cache));
+	/* Use larger initial windows (RFC 3390, rfc2581bis) */
+	hctx->cwnd = rfc3390_bytes_to_packets(dp->dccps_mss_cache);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
 	max_ratio = DIV_ROUND_UP(hctx->cwnd, 2);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -81,15 +81,12 @@ static void ccid3_hc_tx_set_state(struct
  *
  *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
  *
- * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
- * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
  * For consistency with other parts of the code, X_init is scaled by 2^6.
  */
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const u32 w_init = min_t(u32, 4 * hctx->s,
-				 max_t(u32, 2 * hctx->s, 4380U));
+	const u32 w_init = hctx->s * rfc3390_bytes_to_packets(hctx->s);
 
 	return scaled_div(w_init << 6, hctx->rtt);
 }
