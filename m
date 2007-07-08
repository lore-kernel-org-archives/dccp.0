From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:41:00 +0000
Subject: [PATCH 5/8]: Sequence number wraparound issues
Message-Id: <200707081241.00243@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Sequence number wraparound issues

This replaces several uses of standard arithmetic with the DCCP sequence
number arithmetic functions. The problem here is that the sequence number
wrap-around was not taken into consideration.

 * Condition "seqp->ccid2s_seq <= prev->ccid2s_seq" has been replaced by
   	dccp_delta_seqno(seqp->ccid2s_seq, prev->ccid2s_seq) >= 0
   since if seqp is `before' prev, then the delta_seqno() is positive.

 * The test whether sequence numbers `a' and `b' are consecutive has the form
   	dccp_delta_seqno(a, b) = 1
 
 * Increment of ccid2hctx_rpseq could be done using dccp_inc_seqno(), but since here
   the incremented ccid2hctx_rpseq = seqno, used assignment instead.
     
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid2.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -59,7 +59,8 @@ static void ccid2_hc_tx_check_sanity(con
 				pipe++;
 
 			/* packets are sent sequentially */
-			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
+			BUG_ON(dccp_delta_seqno(seqp->ccid2s_seq,
+						prev->ccid2s_seq ) >= 0);
 			BUG_ON(time_before(seqp->ccid2s_sent,
 					   prev->ccid2s_sent));
 
@@ -562,8 +563,8 @@ static void ccid2_hc_tx_packet_recv(stru
 		hctx->ccid2hctx_rpseq = seqno;
 	} else {
 		/* check if packet is consecutive */
-		if ((hctx->ccid2hctx_rpseq + 1) = seqno)
-			hctx->ccid2hctx_rpseq++;
+		if (dccp_delta_seqno(hctx->ccid2hctx_rpseq, seqno) = 1)
+			hctx->ccid2hctx_rpseq = seqno;
 		/* it's a later packet */
 		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
 			hctx->ccid2hctx_rpdupack++;
