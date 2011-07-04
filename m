From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:16 +0000
Subject: [PATCH 3/6] dccp: cosmetics of info message
Message-Id: <1309806079-21604-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Change the CCID (de)activation message to start with the
protocol name, as 'CCID' is already in there.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -118,7 +118,7 @@ static int ccid_activate(struct ccid_operations *ccid_ops)
 	if (ccid_ops->ccid_hc_tx_slab = NULL)
 		goto out_free_rx_slab;
 
-	pr_info("CCID: Activated CCID %d (%s)\n",
+	pr_info("DCCP: Activated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 	err = 0;
 out:
@@ -136,7 +136,7 @@ static void ccid_deactivate(struct ccid_operations *ccid_ops)
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
 	ccid_ops->ccid_hc_rx_slab = NULL;
 
-	pr_info("CCID: Deactivated CCID %d (%s)\n",
+	pr_info("DCCP: Deactivated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 }
 
