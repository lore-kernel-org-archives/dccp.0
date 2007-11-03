From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:03:58 +0000
Subject: [PATCH 1/9] [CCID2]: Disable broken Ack Ratio adaptation algorithm
Message-Id: <200711031323.36246@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This comments out a problematic section comprising a half-finished algorithm:

 - The variable `ccid2hctx_ackloss' is never initialised to a value different from 0 and
   hence in fact is a read-only constant.
 - The `arsent' variable counts packets other than Acks (it is incremented for every packet),
   and there is no test for Ack Loss.
 - The concept of counting Acks as such leads to a complex calculation, and the calculation
   at the moment is inconsistent with this concept.
   The problem is that the number of Acks - rather than the number of windows - is counted,
   which leads to a complex (cubic/quadratic) expression - this is not even implemented.

In its current state, the commented-out algorithm interferes with normal processing by
changing Ack Ratio incorrectly, and at the wrong times.

A new algorithm is necessary, which will not necessarily use the same variables as used by
the unfinished one; hence the old variables have been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   23 +++++++++++++++++++++--
 net/dccp/ccids/ccid2.h |    4 ----
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index d103b70..683d4c2 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -224,8 +224,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hctx->ccid2hctx_sent	= 0;
 
 	/* clear ack ratio state. */
-	hctx->ccid2hctx_arsent	 = 0;
-	hctx->ccid2hctx_ackloss  = 0;
 	hctx->ccid2hctx_rpseq	 = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
@@ -289,6 +287,26 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 
 	hctx->ccid2hctx_sent++;
 
+	/*
+	 * FIXME: The code below is broken and the variables have been removed
+	 * from the socket struct. The `ackloss' variable was always set to 0,
+	 * and with arsent there are several problems:
+	 *  (i) it doesn't just count the number of Acks, but all sent packets;
+	 *  (ii) it is expressed in # of packets, not # of windows, so the
+	 *  comparison below uses the wrong formula: Appendix A of RFC 4341
+	 *  comes up with the number K = cwnd / (R^2 - R) of consecutive windows
+	 *  of data with no lost or marked Ack packets. If arsent were the # of
+	 *  consecutive Acks received without loss, then Ack Ratio needs to be
+	 *  decreased by 1 when
+	 *	      arsent >=  K * cwnd / R  =  cwnd^2 / (R^3 - R^2)
+	 *  where cwnd / R is the number of Acks received per window of data
+	 *  (cf. RFC 4341, App. A). The problems are that
+	 *  - arsent counts other packets as well;
+	 *  - the comparison uses a formula different from RFC 4341;
+	 *  - computing a cubic/quadratic equation each time is too complicated.
+	 *  Hence a different algorithm is needed.
+	 */
+#if 0
 	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
 	hctx->ccid2hctx_arsent++;
 	/* We had an ack loss in this window... */
@@ -316,6 +334,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 			hctx->ccid2hctx_arsent = 0; /* or maybe set it to cwnd*/
 		}
 	}
+#endif
 
 	/* setup RTO timer */
 	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index d9daa53..ed95f8f 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -44,8 +44,6 @@ struct ccid2_seq {
  * @ccid2hctx_acks - ACKS recv in AI phase
  * @ccid2hctx_sent - packets sent in this window
  * @ccid2hctx_lastrtt -time RTT was last measured
- * @ccid2hctx_arsent - packets sent [ack ratio]
- * @ccid2hctx_ackloss - ack was lost in this win
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
 */
@@ -66,8 +64,6 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_sent;
 	unsigned long		ccid2hctx_lastrtt;
 	struct timer_list	ccid2hctx_rtotimer;
-	unsigned long		ccid2hctx_arsent;
-	int			ccid2hctx_ackloss;
 	u64			ccid2hctx_rpseq;
 	int			ccid2hctx_rpdupack;
 	int			ccid2hctx_sendwait;
-- 
1.5.2.2.238.g7cbf2f2-dirty

