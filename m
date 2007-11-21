From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:23 +0000
Subject: [PATCH 01/11] [CCID3]: Revert use of MSS instead of s
Message-Id: <1195658913-24840-2-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This updates the CCID3 code with regard to two instances of using `MSS' in place of `s':

 1. The RFC3390-based initial rate: both rfc3448bis as well as the Faster Restart
    draft now consistently use `s' instead of MSS.

 2. Now agrees with section 4.2 of rfc3448bis: "If the sender is ready to send data when
    it does not yet have a round trip sample, the value of X is set to s bytes per
    second, for segment size s [...]"

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index dfe1aa7..567146f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -83,18 +83,21 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
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
@@ -336,8 +339,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 		} else {
-			/* Sender does not have RTT sample: X = MSS/second */
-			hctx->ccid3hctx_x = dp->dccps_mss_cache;
+			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
+			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
 			hctx->ccid3hctx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
-- 
1.5.3.4

