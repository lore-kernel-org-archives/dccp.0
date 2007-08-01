From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 01 Aug 2007 14:07:58 +0000
Subject: [PATCHv2 5/5]: Revert use of MSS instead of s
Message-Id: <200708011507.58199@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This revision of the patch
 * takes on board Ian's suggestion to clarify from where the
   use of `s' instead of `MSS' came from (also use revision of draft
   that is referred to)
 * now uses min_t/max_t instead of min/max. This is necessary, since
   the target type is __u32, but `s' is u16, so that a compiler warning
   resulted.
 * Ian, I have added the signed-off you provided. If not ok with current
   version, please let me know.

----------------------------> Patch v2 <-----------------------------------
[CCID3]: Revert use of MSS instead of s

This updates the CCID3 code with regard to two instances of using `MSS' in place of `s':

 1. The RFC3390-based initial rate. Both rfc3448bis as well as the Faster Restart
    draft now consistently use `s' instead of MSS. Swapping MSS for s had been done
    shortly after revision 01 of rfc3448bis, but that change subsequently disappeared.

 2. According to section 4.2 of rfc3448bis: "If the sender is ready to send data when
    it does not yet have a round trip sample, the value of X is set to s bytes per 
    second, for segment size s [...]"

Apart from tracking documents, this change makes sense: in particular, it avoids gross
over-estimation if the packet size `s' is small (imagine a VoIP application with sd
bytes and MSS according to Ethernet jumbo frames).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -77,18 +77,21 @@ static void ccid3_hc_tx_set_state(struct
 }
 
 /*
- * Compute the initial sending rate X_init according to RFC 3390:
- *	w_init   =    min(4 * MSS, max(2 * MSS, 4380 bytes))
- *	X_init   =    w_init / RTT
+ * Compute the initial sending rate X_init in the manner of RFC 3390:
+ *
+ *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
+ *
+ * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
+ * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
  * For consistency with other parts of the code, X_init is scaled by 2^6.
  */
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
-	const __u32 w_init = min(4 * dp->dccps_mss_cache,
-				 max(2 * dp->dccps_mss_cache, 4380U));
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
+				   max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
 
-	return scaled_div(w_init << 6, ccid3_hc_tx_sk(sk)->ccid3hctx_rtt);
+	return scaled_div(w_init << 6, hctx->ccid3hctx_rtt);
 }
 
 /*
@@ -333,7 +336,7 @@ static int ccid3_hc_tx_send_packet(struc
 			hctx->ccid3hctx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X = MSS/second */
-			hctx->ccid3hctx_x = dp->dccps_mss_cache;
+			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
 			hctx->ccid3hctx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
