From: David Miller <davem@davemloft.net>
Date: Thu, 03 Feb 2011 01:07:50 +0000
Subject: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <20110202.170750.229739784.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Signed-off-by: David S. Miller <davem@davemloft.net>
---

I've left the DCCP code to keep using RFC3390 logic, if they
wish to adopt this change in their code they can do so by
simply deleting the rfc33390_bytes_to_packets() function and
using TCP_INIT_CWND in their assignment.

 include/net/tcp.h      |   12 +++---------
 net/dccp/ccids/ccid2.c |    9 +++++++++
 net/ipv4/tcp_input.c   |    2 +-
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9179111..7118668 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do exp. backoff */
 
+/* TCP initial congestion window */
+#define TCP_INIT_CWND		10
+
 extern struct inet_timewait_death_row tcp_death_row;
 
 /* sysctl variables for tcp */
@@ -799,15 +802,6 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 /* Use define here intentionally to get WARN_ON location shown at the caller */
 #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
 
-/*
- * Convert RFC 3390 larger initial window into an equivalent number of packets.
- * This is based on the numbers specified in RFC 5681, 3.1.
- */
-static inline u32 rfc3390_bytes_to_packets(const u32 smss)
-{
-	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
-}
-
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index e96d5e8..fadecd2 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -583,6 +583,15 @@ done:
 	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
 }
 
+/*
+ * Convert RFC 3390 larger initial window into an equivalent number of packets.
+ * This is based on the numbers specified in RFC 5681, 3.1.
+ */
+static inline u32 rfc3390_bytes_to_packets(const u32 smss)
+{
+	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
+}
+
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hc = ccid_priv(ccid);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eb7f82e..2f692ce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -817,7 +817,7 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
 	if (!cwnd)
-		cwnd = rfc3390_bytes_to_packets(tp->mss_cache);
+		cwnd = TCP_INIT_CWND;
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }
 
-- 
1.7.4

