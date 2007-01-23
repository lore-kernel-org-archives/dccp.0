From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:41:01 +0000
Subject: [PATCH 4/7]: Provide function for RTT sampling
Message-Id: <200701231541.01730@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Provide function for RTT sampling

A recurring problem, in particular in the CCID code, is that RTT samples
from packets with timestamp echo and elapsed time options need to be taken.

This service is provided via a new function dccp_sample_rtt in this patch.
Furthermore, to protect against `insane' RTT samples, the sampled value
is bounded between 100 microseconds and 4 seconds - for which u32 is sufficient.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h  |   10 ++++++++--
 net/dccp/input.c |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -71,11 +71,15 @@ extern void dccp_time_wait(struct sock *
 /* RFC 1122, 4.2.3.1 initial RTO value */
 #define DCCP_TIMEOUT_INIT ((unsigned)(3 * HZ))
 
+#define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
+
+/* bounds for sampled RTT values from packet exchanges (in usec) */
+#define DCCP_SANE_RTT_MIN	100
+#define DCCP_SANE_RTT_MAX	(4 * USEC_PER_SEC)
+
 /* Maximal interval between probes for local resources.  */
 #define DCCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ / 2U))
 
-#define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
-
 /* sysctl variables for DCCP */
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
@@ -293,6 +297,8 @@ extern int	   dccp_v4_connect(struct soc
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
+extern u32	   dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
+						    struct timeval *t_history);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -590,3 +590,43 @@ discard:
 }
 
 EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
+
+/**
+ * dccp_sample_rtt  -  Sample RTT from packet exchange
+ *
+ * @sk:     connected dccp_sock
+ * @t_recv: receive timestamp of packet with timestamp echo
+ * @t_hist: packet history timestamp or NULL
+ */
+u32 dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
+				     struct timeval *t_hist)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_options_received *or = &dp->dccps_options_received;
+	suseconds_t delta;
+
+	if (t_hist = NULL) {
+		if (!or->dccpor_timestamp_echo) {
+			DCCP_WARN("packet without timestamp echo\n");
+			return DCCP_SANE_RTT_MAX;
+		}
+		timeval_sub_usecs(t_recv, or->dccpor_timestamp_echo * 10);
+		delta = timeval_usecs(t_recv);
+	} else
+		delta = timeval_delta(t_recv, t_hist);
+
+	delta -= or->dccpor_elapsed_time * 10;		/* either set or 0 */
+
+	if (unlikely(delta <= 0)) {
+		DCCP_WARN("unusable RTT sample %ld, using min\n", (long)delta);
+		return DCCP_SANE_RTT_MIN;
+	}
+	if (unlikely(delta - (suseconds_t)DCCP_SANE_RTT_MAX > 0)) {
+		DCCP_WARN("RTT sample %ld too large, using max\n", (long)delta);
+		return DCCP_SANE_RTT_MAX;
+	}
+
+	return delta;
+}
+
+EXPORT_SYMBOL_GPL(dccp_sample_rtt);
