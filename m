From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Oct 2007 09:51:51 +0000
Subject: [PATCH 2/5]: More informative registration
Message-Id: <200710121051.51875@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID]: More informative registration

The patch makes the registration messages of CCID 2/3 a bit more
informative: instead of repeating the CCID number as currently done,

        "CCID: Registered CCID 2 (ccid2)"  or
        "CCID: Registered CCID 3 (ccid3)",

the descriptive names of the CCID's (from RFCs) are now used:

	"CCID: Registered CCID 2 (TCP-like)" and
	"CCID: Registered CCID 3 (TCP-Friendly Rate Control)".

To allow spaces in the name, the slab name string has been changed to
refer to the numeric CCID identifier, using the same format as before.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.c        |    8 ++++----
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -140,15 +140,15 @@ int ccid_register(struct ccid_operations
 
 	ccid_ops->ccid_hc_rx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
-					       "%s_hc_rx_sock",
-					       ccid_ops->ccid_name);
+					       "ccid%u_hc_rx_sock",
+					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_rx_slab = NULL)
 		goto out;
 
 	ccid_ops->ccid_hc_tx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
-					       "%s_hc_tx_sock",
-					       ccid_ops->ccid_name);
+					       "ccid%u_hc_tx_sock",
+					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_tx_slab = NULL)
 		goto out_free_rx_slab;
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -800,7 +800,7 @@ static void ccid2_hc_rx_packet_recv(stru
 
 static struct ccid_operations ccid2 = {
 	.ccid_id		= DCCPC_CCID2,
-	.ccid_name		= "ccid2",
+	.ccid_name		= "TCP-like",
 	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
 	.ccid_hc_tx_init	= ccid2_hc_tx_init,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -910,7 +910,7 @@ static int ccid3_hc_rx_getsockopt(struct
 
 static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
-	.ccid_name		   = "ccid3",
+	.ccid_name		   = "TCP-Friendly Rate Control",
 	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
