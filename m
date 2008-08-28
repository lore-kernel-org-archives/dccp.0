From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:09 +0000
Subject: [PATCH 34/37] dccp: Auto-load (when supported) CCID plugins for negotiation
Message-Id: <1219945512-7723-35-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds auto-loading of CCIDs (when module loading is enabled)
for the purpose of feature negotiation.

The problem with loading the CCIDs at the end of feature negotiation is
that this would happen in software interrupt context. Besides, if the host
advertises CCIDs during negotiation, it should have them ready to use, in
case an agreeing peer wants to use it for the connection.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccid.c |   39 +++++++++++++++++++++++++++++----------
 net/dccp/ccid.h |    1 +
 net/dccp/feat.c |    5 +++++
 3 files changed, 35 insertions(+), 10 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -196,22 +196,41 @@ int ccid_unregister(struct ccid_operations *ccid_ops)
 
 EXPORT_SYMBOL_GPL(ccid_unregister);
 
+/**
+ * ccid_request_module  -  Pre-load CCID module for later use
+ * This should be called only from process context (e.g. during connection
+ * setup) and is necessary for later calls to ccid_new (typically in software
+ * interrupt), so that it has the modules available when they are needed.
+ */
+static int ccid_request_module(u8 id)
+{
+	if (!in_atomic()) {
+		ccids_read_lock();
+		if (ccids[id] = NULL) {
+			ccids_read_unlock();
+			return request_module("net-dccp-ccid-%d", id);
+		}
+		ccids_read_unlock();
+	}
+	return 0;
+}
+
+int ccid_request_modules(u8 const *ccid_array, u8 array_len)
+{
+#ifdef CONFIG_KMOD
+	while (array_len--)
+		if (ccid_request_module(ccid_array[array_len]))
+			return -1;
+#endif
+	return 0;
+}
+
 struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
 {
 	struct ccid_operations *ccid_ops;
 	struct ccid *ccid = NULL;
 
 	ccids_read_lock();
-#ifdef CONFIG_KMOD
-	if (ccids[id] = NULL) {
-		/* We only try to load if in process context */
-		ccids_read_unlock();
-		if (gfp & GFP_ATOMIC)
-			goto out;
-		request_module("net-dccp-ccid-%d", id);
-		ccids_read_lock();
-	}
-#endif
 	ccid_ops = ccids[id];
 	if (ccid_ops = NULL)
 		goto out_unlock;
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -108,6 +108,7 @@ extern int  ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
 extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 					  char __user *, int __user *);
 
+extern int    ccid_request_modules(u8 const *ccid_array, u8 array_len);
 extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
 			     gfp_t gfp);
 
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1170,6 +1170,11 @@ int dccp_feat_init(struct sock *sk)
 	    ccid_get_builtin_ccids(&rx.val, &rx.len))
 		return -ENOBUFS;
 
+	/* Pre-load all CCID modules that are going to be advertised */
+	rc = -EUNATCH;
+	if (ccid_request_modules(tx.val, tx.len))
+		goto free_ccid_lists;
+
 	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, tx.val, tx.len) ||
 	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, rx.val, rx.len))
 		goto free_ccid_lists;
-- 
1.6.0.rc2

