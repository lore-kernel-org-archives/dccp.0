From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:04:09 +0000
Subject: [PATCH 4/9] [CCID2]: Replace cwnd assignment-function with assignment
Message-Id: <200711031323.46788@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The current function ccid2_change_cwnd in effect makes only an assignment, as
the test whether cwnd has reached 0 is only required when cwnd is halved.

This patch simplifies the code by replacing the function with the assignment
it performs.

Furthermore, since ssthresh derives from cwnd and appears in many assignments and
comparisons, the type of ssthresh has also been changed to match that of cwnd.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   22 +++++++---------------
 net/dccp/ccids/ccid2.h |    2 +-
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index e32f766..22833e9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -165,12 +165,6 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, u32 val)
-{
-	hctx->ccid2hctx_cwnd = val? : 1;
-	ccid2_pr_debug("changed cwnd to %u\n", hctx->ccid2hctx_cwnd);
-}
-
 static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
 {
 	ccid2_pr_debug("change SRTT to %ld\n", val);
@@ -212,10 +206,10 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 
 	/* adjust pipe, cwnd etc */
 	ccid2_change_pipe(hctx, 0);
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
+	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
-	ccid2_change_cwnd(hctx, 1);
+	hctx->ccid2hctx_cwnd	 = 1;
 
 	/* clear state about stuff we sent */
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
@@ -440,7 +434,7 @@ static inline void ccid2_new_ack(struct sock *sk,
 			/* increase every 2 acks */
 			hctx->ccid2hctx_ssacks++;
 			if (hctx->ccid2hctx_ssacks = 2) {
-				ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd+1);
+				hctx->ccid2hctx_cwnd++;
 				hctx->ccid2hctx_ssacks = 0;
 				*maxincr = *maxincr - 1;
 			}
@@ -453,7 +447,7 @@ static inline void ccid2_new_ack(struct sock *sk,
 		hctx->ccid2hctx_acks++;
 
 		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
-			ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd + 1);
+			hctx->ccid2hctx_cwnd++;
 			hctx->ccid2hctx_acks = 0;
 		}
 	}
@@ -543,10 +537,8 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 
 	hctx->ccid2hctx_last_cong = jiffies;
 
-	ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd >> 1);
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
-	if (hctx->ccid2hctx_ssthresh < 2)
-		hctx->ccid2hctx_ssthresh = 2;
+	hctx->ccid2hctx_cwnd     = hctx->ccid2hctx_cwnd / 2 ? : 1U;
+	hctx->ccid2hctx_ssthresh = max(hctx->ccid2hctx_cwnd, 2U);
 
 	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
 	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->ccid2hctx_cwnd)
@@ -759,7 +751,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	u32 max_ratio;
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
-	hctx->ccid2hctx_ssthresh  = ~0;
+	hctx->ccid2hctx_ssthresh  = ~0U;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 443f08a..b72e955 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -50,9 +50,9 @@ struct ccid2_seq {
 */
 struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
+	u32			ccid2hctx_ssthresh;
 	int			ccid2hctx_ssacks;
 	int			ccid2hctx_acks;
-	unsigned int		ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
 	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
 	int			ccid2hctx_seqbufc;
-- 
1.5.2.2.238.g7cbf2f2-dirty

