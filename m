From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:10:00 +0000
Subject: [PATCH 4/10]: [DCCP] CCID2: Fix jiffie wrap issues
Message-Id: <20060914170959.GE20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Jiffies are now handled correctly (I hope) in CCID2.  If they wrap, no problem.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index b1d90c0..54a6b7e 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -27,7 +27,6 @@
  *
  * BUGS:
  * - sequence number wrapping
- * - jiffies wrapping
  */
 
 #include "../ccid.h"
@@ -71,7 +70,8 @@ static void ccid2_hc_tx_check_sanity(con
 
 			/* packets are sent sequentially */
 			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
-			BUG_ON(seqp->ccid2s_sent < prev->ccid2s_sent);
+			BUG_ON(time_before(seqp->ccid2s_sent,
+					   prev->ccid2s_sent));
 			BUG_ON(len > ccid2_seq_len);
 
 			seqp = prev;
@@ -418,8 +418,8 @@ static inline void ccid2_new_ack(struct 
 
 	/* update RTO */
 	if (hctx->ccid2hctx_srtt = -1 ||
-	    (jiffies - hctx->ccid2hctx_lastrtt) >= hctx->ccid2hctx_srtt) {
-		unsigned long r = jiffies - seqp->ccid2s_sent;
+	    time_after(jiffies, hctx->ccid2hctx_lastrtt + hctx->ccid2hctx_srtt)) {
+		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
