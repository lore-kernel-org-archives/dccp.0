From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:08 +0000
Subject: [PATCH 1/6] dccp ccid-3: Implement rfc3448bis change to initial-rate computation
Message-Id: <1217340373-12620-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The patch updates CCID-3 with regard to the latest rfc3448bis-06:
 * in the first revisions of the draft, MSS was used for the RFC 3390 window;
 * then (from revision #1 to revision #2), it used the packet size `s';
 * now, in this revision (and apparently final), the value is back to MSS.

This change has an implication for the case when no RTT sample is available,
at the time of sending the first packet:
 * with RTT sample, 2*MSS/RTT <= initial_rate <= 4*MSS/RTT;
 * without RTT sample, the initial rate is one packet (s bytes) per second
   (sec. 4.2), but using s instead of MSS here creates an imbalance, since
   this would further reduce the initial sending rate.

Hence the patch uses MSS (called MPS in RFC 4340) in all places.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -53,18 +53,16 @@ static int ccid3_debug;
 /*
  * Compute the initial sending rate X_init in the manner of RFC 3390:
  *
- *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
+ *	X_init  =  min(4 * MPS, max(2 * MPS, 4380 bytes)) / RTT
  *
- * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
- * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
  * For consistency with other parts of the code, X_init is scaled by 2^6.
  */
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = clamp_t(__u32, 4380U, 2 * hctx->s, 4 * hctx->s);
+	const u32 mps = dccp_sk(sk)->dccps_mss_cache,
+	       w_init = clamp(4380U, 2 * mps, 4 * mps);
 
-	return scaled_div(w_init << 6, hctx->rtt);
+	return scaled_div(w_init << 6, ccid3_hc_tx_sk(sk)->rtt);
 }
 
 /**
@@ -293,7 +291,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
 			 */
 			hctx->rtt = DCCP_FALLBACK_RTT;
-			hctx->x   = hctx->s;
+			hctx->x	  = dp->dccps_mss_cache;
 			hctx->x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
