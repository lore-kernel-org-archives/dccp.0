From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:37 +0000
Subject: [PATCH 12/18] [CCID2]: Replace pipe assignment-function with assignment
Message-Id: <1195950103-18102-13-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The function ccid2_change_pipe only does an assignment. This patch simplifies the code by
replacing the function with the assignment it performs.

Furthermore, the type of pipe is promoted from `signed' to unsigned (increasing the range).
As a result, a BUG_ON test for negative values now becomes obsolete (for safety not removed,
but replaced with a less annoying `DCCP_BUG').

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   16 ++++++----------
 net/dccp/ccids/ccid2.h |    3 ++-
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 747fa1c..237007b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -171,11 +171,6 @@ static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
 	hctx->ccid2hctx_srtt = val;
 }
 
-static void ccid2_change_pipe(struct ccid2_hc_tx_sock *hctx, long val)
-{
-	hctx->ccid2hctx_pipe = val;
-}
-
 static void ccid2_start_rto_timer(struct sock *sk);
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -205,11 +200,11 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	ccid2_start_rto_timer(sk);
 
 	/* adjust pipe, cwnd etc */
-	ccid2_change_pipe(hctx, 0);
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
 	hctx->ccid2hctx_cwnd	 = 1;
+	hctx->ccid2hctx_pipe	 = 0;
 
 	/* clear state about stuff we sent */
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
@@ -248,8 +243,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 
 	BUG_ON(!hctx->ccid2hctx_sendwait);
 	hctx->ccid2hctx_sendwait = 0;
-	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe + 1);
-	BUG_ON(hctx->ccid2hctx_pipe < 0);
+	hctx->ccid2hctx_pipe++;
 
 	/* There is an issue.  What if another packet is sent between
 	 * packet_send() and packet_sent().  Then the sequence number would be
@@ -519,8 +513,10 @@ static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe-1);
-	BUG_ON(hctx->ccid2hctx_pipe < 0);
+	if (hctx->ccid2hctx_pipe = 0)
+		DCCP_BUG("pipe = 0");
+	else
+		hctx->ccid2hctx_pipe--;
 
 	if (hctx->ccid2hctx_pipe = 0)
 		ccid2_hc_tx_kill_rto_timer(sk);
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index b72e955..bc659f0 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -42,6 +42,7 @@ struct ccid2_seq {
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
+ * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
  * @ccid2hctx_ssacks - ACKs recv in slow start
  * @ccid2hctx_acks - ACKS recv in AI phase
  * @ccid2hctx_lastrtt -time RTT was last measured
@@ -51,9 +52,9 @@ struct ccid2_seq {
 struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
 	u32			ccid2hctx_ssthresh;
+	u32			ccid2hctx_pipe;
 	int			ccid2hctx_ssacks;
 	int			ccid2hctx_acks;
-	int			ccid2hctx_pipe;
 	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
 	int			ccid2hctx_seqbufc;
 	struct ccid2_seq	*ccid2hctx_seqh;
-- 
1.5.3.4

