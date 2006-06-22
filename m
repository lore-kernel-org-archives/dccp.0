From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:56:21 +0000
Subject: [PATCH 06/11] CCID2: Initialize ssthresh to "infinity"
Message-Id: <20060622175621.GF4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Initialize the slow-start threshold to "infinity".  This way, upon connection
initiation, slow-start will be exited only upon a packet loss.  This patch will
allow connections to quickly gain speed.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 72fdc26..c11201b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -724,9 +724,8 @@ static int ccid2_hc_tx_init(struct ccid 
 {
         struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	/* XXX init variables with proper values */
 	hctx->ccid2hctx_cwnd	  = 1;
-	hctx->ccid2hctx_ssthresh  = 10;
+	hctx->ccid2hctx_ssthresh  = 666666; /* "infinite" [for a while] */
 	hctx->ccid2hctx_numdupack = 3;
 	hctx->ccid2hctx_seqbufc   = 0;
 
