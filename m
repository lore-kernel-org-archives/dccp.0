From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:54:47 +0000
Subject: [PATCH 04/11] CCID2: Fix jiffie wrap issues
Message-Id: <20060622175447.GD4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Jiffies are now handled correctly (I hope) in CCID2.  If they wrap, no problem.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 6fe9cb9..f953016 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -27,7 +27,6 @@
  *
  * BUGS:
  * - sequence number wrapping
- * - jiffies wrapping
  */
 
 #include <linux/config.h>
@@ -72,7 +71,8 @@ static void ccid2_hc_tx_check_sanity(con
 
 			/* packets are sent sequentially */
 			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
-			BUG_ON(seqp->ccid2s_sent < prev->ccid2s_sent);
+			BUG_ON(time_before(seqp->ccid2s_sent,
+					   prev->ccid2s_sent));
 			BUG_ON(len > ccid2_seq_len);
 
 			seqp = prev;
@@ -419,8 +419,9 @@ static inline void ccid2_new_ack(struct 
 
 	/* update RTO */
 	if (hctx->ccid2hctx_srtt = -1 ||
-	    (jiffies - hctx->ccid2hctx_lastrtt) >= hctx->ccid2hctx_srtt) {
-		unsigned long r = jiffies - seqp->ccid2s_sent;
+	    ((long)jiffies - (long)hctx->ccid2hctx_lastrtt) >+	     hctx->ccid2hctx_srtt) {
+		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
