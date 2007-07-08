From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:41:16 +0000
Subject: [PATCH 8/8]: Initialisation assignments of 0 are redundant
Message-Id: <200707081241.16713@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Initialisation assignments of 0 are redundant

Assigning initial values of `0' is redundant when loading a new CCID structure,
since in net/dccp/ccid.c the entire CCID structure is zeroed out prior to
initialisation in ccid_new():

	struct ccid {
		struct ccid_operations *ccid_ops;
		char		       ccid_priv[0];
	};

	// ...
	if (rx) {
		memset(ccid + 1, 0, ccid_ops->ccid_hc_rx_obj_size);
		if (ccid->ccid_ops->ccid_hc_rx_init != NULL &&
		    ccid->ccid_ops->ccid_hc_rx_init(ccid, sk) != 0)
			goto out_free_ccid;
	} else {
		memset(ccid + 1, 0, ccid_ops->ccid_hc_tx_obj_size);
		/* analogous to the rx case */
	}

This patch therefore removes the redundant assignments. Thanks to Arnaldo for
the inspiration.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    4 ----
 net/dccp/ccids/ccid3.c |   10 ++--------
 2 files changed, 2 insertions(+), 12 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -750,20 +750,16 @@ static int ccid2_hc_tx_init(struct ccid 
 	 */
 	hctx->ccid2hctx_ssthresh  = ~0;
 	hctx->ccid2hctx_numdupack = 3;
-	hctx->ccid2hctx_seqbufc   = 0;
 
 	/* XXX init ~ to window size... */
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
-	hctx->ccid2hctx_sent	 = 0;
 	hctx->ccid2hctx_rto	 = 3 * HZ;
 	ccid2_change_srtt(hctx, -1);
 	hctx->ccid2hctx_rttvar	 = -1;
-	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
-	hctx->ccid2hctx_high_ack = 0;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -568,9 +568,6 @@ static int ccid3_hc_tx_init(struct ccid 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_s     = 0;
-	hctx->ccid3hctx_rtt   = 0;
-	hctx->ccid3hctx_t_rto = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
 
@@ -867,13 +864,10 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	ccid3_pr_debug("entry\n");
 
-	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
-		return 1;
 	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	hcrx->ccid3hcrx_s     = 0;
-	hcrx->ccid3hcrx_rtt   = 0;
-	return 0;
+
+	return tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
