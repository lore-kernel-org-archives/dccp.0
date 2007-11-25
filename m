From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:34 +0000
Subject: [PATCH 09/18] [CCID2]: Remove unused variable
Message-Id: <1195950103-18102-10-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This removes a variable `ccid2hctx_sent' which is incremented but
never referenced/read (i.e., dead code).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    4 ----
 net/dccp/ccids/ccid2.h |    2 --
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index a901202..9fa0eb5 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -221,7 +221,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
 	hctx->ccid2hctx_ssacks	= 0;
 	hctx->ccid2hctx_acks	= 0;
-	hctx->ccid2hctx_sent	= 0;
 
 	/* clear ack ratio state. */
 	hctx->ccid2hctx_rpseq	 = 0;
@@ -285,8 +284,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd,
 		       hctx->ccid2hctx_pipe);
 
-	hctx->ccid2hctx_sent++;
-
 	/*
 	 * FIXME: The code below is broken and the variables have been removed
 	 * from the socket struct. The `ackloss' variable was always set to 0,
@@ -517,7 +514,6 @@ static inline void ccid2_new_ack(struct sock *sk,
 		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
 			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
 			       hctx->ccid2hctx_rto, HZ, r);
-		hctx->ccid2hctx_sent = 0;
 	}
 
 	/* we got a new ack, so re-start RTO timer */
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index ed95f8f..6d0b4e3 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -42,7 +42,6 @@ struct ccid2_seq {
  *
  * @ccid2hctx_ssacks - ACKs recv in slow start
  * @ccid2hctx_acks - ACKS recv in AI phase
- * @ccid2hctx_sent - packets sent in this window
  * @ccid2hctx_lastrtt -time RTT was last measured
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
@@ -61,7 +60,6 @@ struct ccid2_hc_tx_sock {
 	long			ccid2hctx_rto;
 	long			ccid2hctx_srtt;
 	long			ccid2hctx_rttvar;
-	int			ccid2hctx_sent;
 	unsigned long		ccid2hctx_lastrtt;
 	struct timer_list	ccid2hctx_rtotimer;
 	u64			ccid2hctx_rpseq;
-- 
1.5.3.4

