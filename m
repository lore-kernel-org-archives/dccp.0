From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:09 +0000
Subject: [PATCH 2/6] dccp ccid-3: Measuring the TX packet size s with regard to rfc3448bis-06
Message-Id: <1217340373-12620-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

rfc3448bis allows three different ways of tracking the packet size `s':

 1. using the MSS/MPS (at initialisation, 4.2, and in 4.1 (1));
 2. using the average of `s' (in 4.1);
 3. using the maximum of `s' (in 4.2).

Instead of hard-coding a single interpretation of rfc3448bis, this implements
a choice of all three alternatives and suggests the first as default, since it
is the option which is most consistent with other parts of the specification.

The patch further deprecates the update of t_ipi whenever `s' changes. The gains
of doing this are only small since a change of s takes effect at the next
instant X is updated:
 * when the next feedback comes in (within one RTT or less);
 * when the nofeedback timer expires (within at most 4 RTTs).

Further, there are complications caused by updating t_ipi whenever s changes:
 * if t_ipi had previously been updated to effect oscillation prevention (4.5),
   then it is impossible to make the same adjustment to t_ipi again, thus
   counter-acting the algorithm;
 * s may be updated any time and a modification of t_ipi depends on the current
   state (e.g. no oscillation prevention is done in the absence of feedback);
 * in rev-06 of rfc3448bis, there are more possible cases, depending on whether
   the sender is in slow-start (t_ipi <= R/W_init), or in congestion-avoidance,
   limited by X_recv or the throughput equation (t_ipi <= t_mbi).

These side effects may not be desirable. The only case I can think of where such
an update makes sense is to recompute X_calc when p > 0 and when s changes
(not done by this patch).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |   25 +++++++++++++++++++++++--
 net/dccp/ccids/ccid3.c |   27 +++++++++++++++------------
 2 files changed, 38 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -63,9 +63,9 @@ config IP_DCCP_CCID3
 
 	  If in doubt, say M.
 
+if IP_DCCP_CCID3
 config IP_DCCP_CCID3_DEBUG
 	  bool "CCID3 debugging messages"
-	  depends on IP_DCCP_CCID3
 	  ---help---
 	    Enable CCID3-specific debugging messages.
 
@@ -75,10 +75,30 @@ config IP_DCCP_CCID3_DEBUG
 
 	    If in doubt, say N.
 
+choice
+	  prompt "Select method for measuring the packet size s"
+	  default IP_DCCP_CCID3_MEASURE_S_AS_MPS
+
+config IP_DCCP_CCID3_MEASURE_S_AS_MPS
+	  bool "Always use MPS in place of s"
+	  ---help---
+	    This use is recommended as it is consistent with the initialisation
+	    of X and suggested when s varies (rfc3448bis, (1) in section 4.1).
+config IP_DCCP_CCID3_MEASURE_S_AS_AVG
+	  bool "Use moving average"
+	  ---help---
+	    An alternative way of tracking s, also supported by rfc3448bis.
+	    This used to be the default for CCID-3 in previous kernels.
+config IP_DCCP_CCID3_MEASURE_S_AS_MAX
+	  bool "Track the maximum payload length"
+	  ---help---
+	    An experimental method based on tracking the maximum packet size.
+endchoice
+
 config IP_DCCP_CCID3_RTO
 	  int "Use higher bound for nofeedback timer"
 	  default 100
-	  depends on IP_DCCP_CCID3 && EXPERIMENTAL
+	  depends on EXPERIMENTAL
 	  ---help---
 	    Use higher lower bound for nofeedback timer expiration.
 
@@ -105,6 +125,7 @@ config IP_DCCP_CCID3_RTO
 	    The purpose of the nofeedback timer is to slow DCCP down when there
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.
+endif
 
 config IP_DCCP_TFRC_LIB
 	tristate
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -136,17 +136,18 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 }
 
 /*
- *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
- *	@len: DCCP packet payload size in bytes
+ * ccid3_hc_tx_measure_packet_size  -  Measuring the packet size `s' (sec 4.1)
+ * @new_len: DCCP payload size in bytes (not used by all methods)
  */
-static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
+static u32 ccid3_hc_tx_measure_packet_size(struct sock *sk, const u16 new_len)
 {
-	const u16 old_s = hctx->s;
-
-	hctx->s = tfrc_ewma(hctx->s, len, 9);
-
-	if (hctx->s != old_s)
-		ccid3_update_send_interval(hctx);
+#if   defined(CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_AVG)
+	return tfrc_ewma(ccid3_hc_tx_sk(sk)->s, new_len, 9);
+#elif defined(CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MAX)
+	return max(ccid3_hc_tx_sk(sk)->s, new_len);
+#else /* CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS	*/
+	return dccp_sk(sk)->dccps_mss_cache;
+#endif
 }
 
 /*
@@ -271,8 +272,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		/* Set t_0 for initial packet */
 		hctx->t_nom = now;
 
-		hctx->s = skb->len;
-
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
 		 * to RFC 4342. This implements the initialisation procedure of
@@ -294,6 +293,9 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			hctx->x	  = dp->dccps_mss_cache;
 			hctx->x <<= 6;
 		}
+
+		/* Compute t_ipi = s / X */
+		hctx->s = ccid3_hc_tx_measure_packet_size(sk, skb->len);
 		ccid3_update_send_interval(hctx);
 
 	} else {
@@ -326,7 +328,8 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	ccid3_hc_tx_update_s(hctx, len);
+	/* Changes to s will become effective the next time X is computed */
+	hctx->s = ccid3_hc_tx_measure_packet_size(sk, len);
 
 	if (tfrc_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
