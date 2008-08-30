From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 30 Aug 2008 17:25:01 +0000
Subject: Re: [PATCH 0/37] --- Summary of revision changes so far
Message-Id: <20080830172501.GB26846@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Below is the summary of changes after the revision.
Thanks to everyone who sent comments and suggestions.

I will wait a few more days for further comments and then
prepare a pull request. 

It is not a problem to send comments, patches and suggestions afterwards.
Changes can then go into the test tree or, in case there are any errors,
be added.


The statistics are:
-------------------
 include/linux/dccp.h |    6 ++--
 net/dccp/ackvec.h    |    3 --
 net/dccp/ccid.h      |   13 +++++++--
 net/dccp/feat.c      |   71 ++++++++++++++++++++++++++-------------------------
 net/dccp/probe.c     |    2 -
 net/dccp/proto.c     |   41 +++++++++++++++++------------
 6 files changed, 78 insertions(+), 58 deletions(-)


--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -228,10 +228,12 @@ enum dccp_packet_dequeueing_policy {
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
+/* maximum size of a single TLV-encoded option (sans type/len bytes) */
+#define DCCP_SINGLE_OPT_MAXLEN         253
+/* maximum number of CCID preferences that can be registered at one time */
+#define DCCP_CCID_LIST_MAX_LEN         (DCCP_SINGLE_OPT_MAXLEN - 2)
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
-/* maximum number of CCID preferences that can be registered at one time */
-#define DCCP_CCID_LIST_MAX_LEN	       16
 
 #ifdef __KERNEL__
 
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -11,12 +11,11 @@
  *	published by the Free Software Foundation.
  */
 
+#include <linux/dccp.h>
 #include <linux/compiler.h>
 #include <linux/list.h>
 #include <linux/types.h>
 
-/* maximum size of a single TLV-encoded option (sans type/len bytes) */
-#define DCCP_SINGLE_OPT_MAXLEN	253
 /*
  * Ack Vector buffer space is static, in multiples of %DCCP_SINGLE_OPT_MAXLEN,
  * the maximum size of a single Ack Vector. Setting %DCCPAV_NUM_ACKVECS to 1
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -108,9 +108,18 @@ extern int    ccid_request_modules(u8 const *ccid_array, u8 array_len);
 extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
 			     gfp_t gfp);
 
-static inline int ccid_get_current_id(struct dccp_sock *dp, bool rx)
+static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
 {
-	struct ccid *ccid = rx ? dp->dccps_hc_rx_ccid : dp->dccps_hc_tx_ccid;
+	struct ccid *ccid = dp->dccps_hc_rx_ccid;
+
+	if (ccid = NULL || ccid->ccid_ops = NULL)
+		return -1;
+	return ccid->ccid_ops->ccid_id;
+}
+
+static inline int ccid_get_current_tx_ccid(struct dccp_sock *dp)
+{
+	struct ccid *ccid = dp->dccps_hc_tx_ccid;
 
 	if (ccid = NULL || ccid->ccid_ops = NULL)
 		return -1;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -387,8 +387,11 @@ static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 
 static void dccp_feat_val_destructor(u8 feat_num, dccp_feat_val *val)
 {
-	if (val && dccp_feat_type(feat_num) = FEAT_SP)
+	if (unlikely(val = NULL))
+		return;
+	if (dccp_feat_type(feat_num) = FEAT_SP)
 		kfree(val->sp.vec);
+	memset(val, 0, sizeof(*val));
 }
 
 static struct dccp_feat_entry *
@@ -422,57 +425,57 @@ static void dccp_feat_entry_destructor(struct dccp_feat_entry *entry)
 }
 
 /*
- *	List management functions
+ * List management functions
+ *
+ * Feature negotiation lists rely on and maintain the following invariants:
+ * - each feat_num in the list is known, i.e. we know its type and default value
+ * - each feat_num/is_local combination is unique (old entries are overwritten)
+ * - SP values are always freshly allocated
+ * - list is sorted in increasing order of feature number (faster lookup)
  */
+static struct dccp_feat_entry *dccp_feat_list_lookup(struct list_head *fn_list,
+						     u8 feat_num, bool is_local)
+{
+	struct dccp_feat_entry *entry;
+
+	list_for_each_entry(entry, fn_list, node)
+		if (entry->feat_num = feat_num && entry->is_local = is_local)
+			return entry;
+		else if (entry->feat_num > feat_num)
+			break;
+	return NULL;
+}
 
 /**
  * dccp_feat_entry_new  -  Central list update routine (called by all others)
- * @fn: list to add to
- * @feat: feature number
- * @is_local: whether the local (1) or remote feature with number @feat is meant
- * The function maintains and relies on the following invariants:
- *  - each feat_num in the list is known, ie. we know its type and default value
- *  - each feat_num/is_local combination is unique (old entries are overwritten)
- *  - SP values are always freshly allocated
- *  - list is sorted in increasing order of feature number (faster lookup)
+ * @head:  list to add to
+ * @feat:  feature number
+ * @local: whether the local (1) or remote feature with number @feat is meant
+ * This is the only constructor and serves to ensure the above invariants.
  */
 static struct dccp_feat_entry *
-	      dccp_feat_entry_new(struct list_head *fn, u8 feat, u8 is_local)
+	      dccp_feat_entry_new(struct list_head *head, u8 feat, bool local)
 {
 	struct dccp_feat_entry *entry;
-	struct list_head *pos_head = fn;
 
-	list_for_each(pos_head, fn) {
-		entry = list_entry(pos_head, struct dccp_feat_entry, node);
-		if (feat < entry->feat_num)
-			break;
-		if (entry->feat_num = feat && entry->is_local = is_local) {
+	list_for_each_entry(entry, head, node)
+		if (entry->feat_num = feat && entry->is_local = local) {
 			dccp_feat_val_destructor(entry->feat_num, &entry->val);
 			return entry;
+		} else if (entry->feat_num > feat) {
+			head = &entry->node;
+			break;
 		}
-	}
-	entry = kmalloc(sizeof(struct dccp_feat_entry), gfp_any());
+
+	entry = kmalloc(sizeof(*entry), gfp_any());
 	if (entry != NULL) {
 		entry->feat_num = feat;
-		entry->is_local = is_local;
-		list_add_tail(&entry->node, pos_head);
+		entry->is_local = local;
+		list_add_tail(&entry->node, head);
 	}
 	return entry;
 }
 
-static struct dccp_feat_entry *dccp_feat_list_lookup(struct list_head *fn_list,
-						     u8 feat_num, u8 is_local)
-{
-	struct dccp_feat_entry *entry;
-
-	list_for_each_entry(entry, fn_list, node)
-		if (entry->feat_num = feat_num && entry->is_local = is_local)
-			return entry;
-		else if (entry->feat_num > feat_num)
-			break;
-	return NULL;
-}
-
 /**
  * dccp_feat_push_change  -  Add/overwrite a Change option in the list
  * @fn_list: feature-negotiation list to update
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -55,7 +55,7 @@ static void jdccp_write_xmit(struct sock *sk)
 	struct ccid3_hc_tx_sock *hctx = NULL;
 	struct timespec tv;
 	char buf[256];
-	int len, ccid = ccid_get_current_id(dccp_sk(sk), false);
+	int len, ccid = ccid_get_current_tx_ccid(dccp_sk(sk));
 
 	if (ccid = DCCPC_CCID3)
 		hctx = ccid3_hc_tx_sk(sk);
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -440,11 +440,6 @@ static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
 
 	if (cscov < 0 || cscov > 15)
 		return -EINVAL;
-
-	if (rx)
-		dccp_sk(sk)->dccps_pcrlen = cscov;
-	else
-		dccp_sk(sk)->dccps_pcslen = cscov;
 	/*
 	 * Populate a list of permissible values, in the range cscov...15. This
 	 * is necessary since feature negotiation of single values only works if
@@ -464,6 +459,12 @@ static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
 
 	rc = dccp_feat_register_sp(sk, DCCPF_MIN_CSUM_COVER, rx, list, len);
 
+	if (rc = 0) {
+		if (rx)
+			dccp_sk(sk)->dccps_pcrlen = cscov;
+		else
+			dccp_sk(sk)->dccps_pcslen = cscov;
+	}
 	kfree(list);
 	return rc;
 }
@@ -481,11 +482,13 @@ static int dccp_setsockopt_ccid(struct sock *sk, int type,
 	if (val = NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(val, optval, optlen))
-		rc = -EFAULT;
+	if (copy_from_user(val, optval, optlen)) {
+		kfree(val);
+		return -EFAULT;
+	}
 
 	lock_sock(sk);
-	if (!rc && (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID))
+	if (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID)
 		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);
 
 	if (!rc && (type = DCCP_SOCKOPT_RX_CCID || type = DCCP_SOCKOPT_CCID))
@@ -514,16 +517,16 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RX_CCID:
 	case DCCP_SOCKOPT_TX_CCID:
 		return dccp_setsockopt_ccid(sk, optname, optval, optlen);
-	default:
-		if (optlen < sizeof(int))
-			return -EINVAL;
+	}
 
-		if (get_user(val, (int __user *)optval))
-			return -EFAULT;
+	if (optlen < (int)sizeof(int))
+		return -EINVAL;
 
-		if (optname = DCCP_SOCKOPT_SERVICE)
-			return dccp_setsockopt_service(sk, val, optval, optlen);
-	}
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	if (optname = DCCP_SOCKOPT_SERVICE)
+		return dccp_setsockopt_service(sk, val, optval, optlen);
 
 	lock_sock(sk);
 	switch (optname) {
@@ -642,8 +645,12 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_AVAILABLE_CCIDS:
 		return ccid_getsockopt_builtin_ccids(sk, len, optval, optlen);
 	case DCCP_SOCKOPT_TX_CCID:
+		val = ccid_get_current_tx_ccid(dp);
+		if (val < 0)
+			return -ENOPROTOOPT;
+		break;
 	case DCCP_SOCKOPT_RX_CCID:
-		val = ccid_get_current_id(dp, optname = DCCP_SOCKOPT_RX_CCID);
+		val = ccid_get_current_rx_ccid(dp);
 		if (val < 0)
 			return -ENOPROTOOPT;
 		break;
