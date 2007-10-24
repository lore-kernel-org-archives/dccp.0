From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 13:11:57 +0000
Subject: [PATCH 5/5] [CCID2/3]: Initialisation assignments of 0 are
Message-Id: <20071024131157.GH6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    4 ----
 net/dccp/ccids/ccid3.c |    4 ----
 2 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 426008e..d694656 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -750,20 +750,16 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
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
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 05f263e..19b3358 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -604,8 +604,6 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_s     = 0;
-	hctx->ccid3hctx_rtt   = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
@@ -966,8 +964,6 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
 	hcrx->ccid3hcrx_tstamp_last_feedback  		hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
-	hcrx->ccid3hcrx_s   = 0;
-	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
 }
 
-- 
1.5.3.4

