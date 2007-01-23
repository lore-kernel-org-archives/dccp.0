From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:40:51 +0000
Subject: [PATCH 2/7]: Wrap computation of RFC3390-initial rate into separate function
Message-Id: <200701231540.51401@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Wrap computation of RFC3390-initial rate into separate function

The CCID 3 and TFRC specs (RFC 4342, RFC 3448, draft-3448bis) make frequent
reference to the computation of the RFC-3390 initial sending rate:

  1. Initial sending rate when RTT is known (RFC 4342, p. 6)
  2. Response to Idle/Application-Limited periods (RFC 4342, 5.1)

This warrants putting the code into its own function, for later code reuse.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -81,6 +81,21 @@ static void ccid3_hc_tx_set_state(struct
 }
 
 /*
+ *	Compute the initial sending rate X_init according to RFC 3390:
+ *		w_init   =    min(4 * MSS, max(2 * MSS, 4380 bytes))
+ *		X_init   =    w_init / RTT
+ *	For consistency with other parts of the code, X_init is scaled by 2^6.
+ */
+static inline u64 rfc3390_initial_rate(struct sock *sk)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+	__u32 w_init = min(4 * dp->dccps_mss_cache,
+			   max(2 * dp->dccps_mss_cache, 4380U));
+
+	return	scaled_div(w_init << 6, ccid3_hc_tx_sk(sk)->ccid3hctx_rtt);
+}
+
+/*
  * Recalculate t_ipi and delta (should be called whenver X changes)
  */
 static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
@@ -471,19 +486,16 @@ static void ccid3_hc_tx_packet_recv(stru
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 */
-			__u32 w_init = min(4 * dp->dccps_mss_cache,
-					   max(2 * dp->dccps_mss_cache, 4380U));
 			hctx->ccid3hctx_rtt  = r_sample;
-			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
-			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
+			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
 				       "R_sample=%dus, X=%llu\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
-				       dp->dccps_mss_cache, w_init,
-				       (int)r_sample,
+				       dp->dccps_mss_cache, (int)r_sample,
 				       hctx->ccid3hctx_x >> 6);
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
