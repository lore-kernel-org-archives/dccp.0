From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Mar 2010 06:14:21 +0000
Subject: test-tree: logging message cosmetics
Message-Id: <20100315061421.GB6110@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: cosmetics of info message

Change the CCID (de)activation message to start with the
protocol name, as 'CCID' is already in there.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -119,7 +119,7 @@ static int ccid_activate(struct ccid_ope
 	if (ccid_ops->ccid_hc_tx_slab = NULL)
 		goto out_free_rx_slab;
 
-	pr_info("CCID: Activated CCID %d (%s)\n",
+	pr_info("DCCP: Activated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 	err = 0;
 out:
@@ -137,7 +137,7 @@ static void ccid_deactivate(struct ccid_
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
 	ccid_ops->ccid_hc_rx_slab = NULL;
 
-	pr_info("CCID: Deactivated CCID %d (%s)\n",
+	pr_info("DCCP: Deactivated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 }
 
