From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Dec 2008 08:08:21 +0000
Subject: [RFC] [Patch 3/4] dccp: Add unregister function
Message-Id: <20081220080821.GD3853@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Add unregister function

This adds an unregister function to facilitate unloading the DCCP module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h  |    3 ++-
 net/dccp/ccid.c  |   48 +++++++++++++++++++++++++++---------------------
 net/dccp/proto.c |    3 ++-
 3 files changed, 31 insertions(+), 23 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -91,7 +91,8 @@ extern struct ccid_operations ccid2_ops;
 extern struct ccid_operations ccid3_ops;
 #endif
 
-extern int ccids_register_builtins(void);
+extern int  ccid_register_builtins(void);
+extern void ccid_unregister_builtins(void);
 
 struct ccid {
 	struct ccid_operations *ccid_ops;
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -123,7 +123,7 @@ static int ccid_register(struct ccid_ope
 	return 0;
 }
 
-static int ccid_unregister(struct ccid_operations *ccid_ops)
+static void ccid_unregister(struct ccid_operations *ccid_ops)
 {
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
 	ccid_ops->ccid_hc_tx_slab = NULL;
@@ -132,28 +132,8 @@ static int ccid_unregister(struct ccid_o
 
 	pr_info("CCID: Unregistered CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
-	return 0;
-}
-
-int ccids_register_builtins(void)
-{
-	int i, err;
-
-	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
-		err = ccid_register(ccids[i]);
-		if (err)
-			goto unwind_registrations;
-	}
-
-	return 0;
-
-unwind_registrations:
-	while(--i >= 0)
-		ccid_unregister(ccids[i]);
-	return err;
 }
 
-
 static struct ccid_operations *ccid_find_by_id(const u8 id)
 {
 	int i;
@@ -231,3 +211,29 @@ void ccid_hc_tx_delete(struct ccid *ccid
 }
 
 EXPORT_SYMBOL_GPL(ccid_hc_tx_delete);
+
+int __init ccid_register_builtins(void)
+{
+	int i, err;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
+		err = ccid_register(ccids[i]);
+		if (err)
+			goto unwind_registrations;
+	}
+
+	return 0;
+
+unwind_registrations:
+	while(--i >= 0)
+		ccid_unregister(ccids[i]);
+	return err;
+}
+
+void ccid_unregister_builtins(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++)
+		ccid_unregister(ccids[i]);
+}
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1119,7 +1119,7 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_ackvec_exit;
 
-	rc = ccids_register_builtins();
+	rc = ccid_register_builtins();
 	if (rc)
 		goto out_sysctl_exit;
 
@@ -1148,6 +1148,7 @@ out_free_bind_bucket_cachep:
 
 static void __exit dccp_fini(void)
 {
+	ccid_unregister_builtins();
 	dccp_mib_exit();
 	free_pages((unsigned long)dccp_hashinfo.bhash,
 		   get_order(dccp_hashinfo.bhash_size *
