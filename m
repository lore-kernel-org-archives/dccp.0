From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:10:18 +0000
Subject: [PATCH 5/10]: [DCCP] CCID2: Initialize ssthresh to infinity
Message-Id: <20060914171017.GF20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Initialize the slow-start threshold to infinity.  This way, upon connection
initiation, slow-start will be exited only upon a packet loss.  This patch will
allow connections to quickly gain speed.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |    7 +++++--
 ccid2.h |    2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 54a6b7e..699a566 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -678,9 +678,12 @@ static int ccid2_hc_tx_init(struct ccid 
 	int seqcount = ccid2_seq_len;
 	int i;
 
-	/* XXX init variables with proper values */
 	hctx->ccid2hctx_cwnd	  = 1;
-	hctx->ccid2hctx_ssthresh  = 10;
+	/* Initialize ssthresh to infinity.  This means that we will exit the
+	 * initial slow-start after the first packet loss.  This is what we
+	 * want.
+	 */
+	hctx->ccid2hctx_ssthresh  = ~0;
 	hctx->ccid2hctx_numdupack = 3;
 
 	/* XXX init ~ to window size... */
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 451a874..b4cc6c0 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -50,7 +50,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_cwnd;
 	int			ccid2hctx_ssacks;
 	int			ccid2hctx_acks;
-	int			ccid2hctx_ssthresh;
+	unsigned int		ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
 	int			ccid2hctx_numdupack;
 	struct ccid2_seq	*ccid2hctx_seqbuf;
