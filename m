From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 27 Oct 2007 11:34:37 +0000
Subject: [PATCH 6/6]: Larger initial windows also for CCID2
Message-Id: <200710271234.37402@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Larger initial windows also for CCID2

RFC 4341, sec. 5 states that "The cwnd parameter is initialized to at most
four packets for new connections, following the rules from [RFC3390]", which
is implemented by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -741,15 +741,25 @@ static void ccid2_hc_tx_packet_recv(stru
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct dccp_sock *dp = dccp_sk(sk);
+	u32 max_ratio;
 
-	ccid2_change_cwnd(hctx, 1);
-	/* Initialize ssthresh to infinity.  This means that we will exit the
-	 * initial slow-start after the first packet loss.  This is what we
-	 * want.
-	 */
+	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
 	hctx->ccid2hctx_ssthresh  = ~0;
 	hctx->ccid2hctx_numdupack = 3;
 
+	/*
+	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
+	 * packets for new connections, following the rules from [RFC3390]".
+	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
+	 */
+	hctx->ccid2hctx_cwnd = min(4U, max(2U, 4380U / dp->dccps_mss_cache));
+
+	/* Make sure that Ack Ratio is enabled and within bounds. */
+	max_ratio = DIV_ROUND_UP(hctx->ccid2hctx_cwnd, 2);
+	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
+		dp->dccps_l_ack_ratio = max_ratio;
+
 	/* XXX init ~ to window size... */
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
