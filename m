From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 29 Nov 2007 11:21:27 +0000
Subject: [Announce]: Test-tree updated with 2.6.25 changes backported
Message-Id: <20071129112127.GF17629@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have backported Arnaldo's changes to the test tree by inserting a
dummy patch; all the other patches have been updated relative to this.

The set of patches has been uploaded, it remains fully bisectable (just verified).
Work with regard to the more recent changes will have to be done later.

The Faster Restart tree has been updated, there were only positioning changes.

In the CCID4 tree, two new changes have been updated that were in the 2.6.25 CCID3 tree:


--- b/net/dccp/ccids/lib/tfrc_ccids.c
+++ b/net/dccp/ccids/lib/tfrc_ccids.c
@@ -37,7 +37,7 @@
 {
 	u32 delta = ktime_us_delta(now, hctx->tfrchctx_t_last_win_count);
 
-	return delta/hctx->tfrchctx_rtt;
+	return delta / hctx->tfrchctx_rtt;
 }
 
 EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
--- b/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -542,11 +542,8 @@
 
 	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
 	tfrc_tx_hist_init(&hctx->tfrchctx_hist, ccid4_tx_hist);
-
-	hctx->tfrchctx_no_feedback_timer.function -				ccid4_hc_tx_no_feedback_timer;
-	hctx->tfrchctx_no_feedback_timer.data     = (unsigned long)sk;
-	init_timer(&hctx->tfrchctx_no_feedback_timer);
+	setup_timer(&hctx->tfrchctx_no_feedback_timer,
+			ccid4_hc_tx_no_feedback_timer, (unsigned long)sk);
 
 	return 0;
 }


Please have a look at the changes - the CCID4 tree has also been
updated, compile-tested and uploaded.
