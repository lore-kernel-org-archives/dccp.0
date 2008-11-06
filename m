From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 06 Nov 2008 05:40:13 +0000
Subject: [PATCH 3/4] dccp: Query supported CCIDs
Message-Id: <1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides a data structure to record which CCIDs are locally supported
and three accessor functions:
 - a test function for internal use which is used to validate CCID requests
   made by the user;
 - a copy function so that the list can be used for feature-negotiation;
 - documented getsockopt() support so that the user can query capabilities.

The data structure is a table which is filled in at compile-time with the
list of available CCIDs (which in turn depends on the Kconfig choices).

Using the copy function for cloning the list of supported CCIDs is useful for
feature negotiation, since the negotiation is now with the full list of available
CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation
will not fail if the peer requests to use CCID3 instead of CCID2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    4 +++
 include/linux/dccp.h              |    1 +
 net/dccp/ccid.c                   |   48 +++++++++++++++++++++++++++++++++++++
 net/dccp/ccid.h                   |    5 ++++
 net/dccp/feat.c                   |    4 +++
 net/dccp/proto.c                  |    2 +
 6 files changed, 64 insertions(+), 0 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -57,6 +57,10 @@ can be set before calling bind().
 DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
 size (application payload size) in bytes, see RFC 4340, section 14.
 
+DCCP_SOCKOPT_AVAILABLE_CCIDS is also read-only and returns the list of CCIDs
+supported by the endpoint (see include/linux/dccp.h for symbolic constants).
+The caller needs to provide a sufficiently large (> 2) array of type uint8_t.
+
 DCCP_SOCKOPT_SERVER_TIMEWAIT enables the server (listening socket) to hold
 timewait state when closing the connection (RFC 4340, 8.3). The usual case is
 that the closing server sends a CloseReq, whereupon the client holds timewait
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -209,6 +209,7 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SERVER_TIMEWAIT	6
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
+#define DCCP_SOCKOPT_AVAILABLE_CCIDS	12
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -103,6 +103,11 @@ static inline void *ccid_priv(const struct ccid *ccid)
 	return (void *)ccid->ccid_priv;
 }
 
+extern bool ccid_support_check(u8 const *ccid_array, u8 array_len);
+extern int  ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
+extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
+					  char __user *, int __user *);
+
 extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
 			     gfp_t gfp);
 
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -13,6 +13,13 @@
 
 #include "ccid.h"
 
+static u8 builtin_ccids[] = {
+	DCCPC_CCID2,		/* CCID2 is supported by default */
+#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
+	DCCPC_CCID3,
+#endif
+};
+
 static struct ccid_operations *ccids[CCID_MAX];
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 static atomic_t ccids_lockct = ATOMIC_INIT(0);
@@ -86,6 +93,47 @@ static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 	}
 }
 
+/* check that up to @array_len members in @ccid_array are supported */
+bool ccid_support_check(u8 const *ccid_array, u8 array_len)
+{
+	u8 i, j, found;
+
+	for (i = 0, found = 0; i < array_len; i++, found = 0) {
+		for (j = 0; !found && j < ARRAY_SIZE(builtin_ccids); j++)
+			found = (ccid_array[i] = builtin_ccids[j]);
+		if (!found)
+			return false;
+	}
+	return true;
+}
+
+/**
+ * ccid_get_builtin_ccids  -  Provide copy of `builtin' CCID array
+ * @ccid_array: pointer to copy into
+ * @array_len: value to return length into
+ * This function allocates memory - caller must see that it is freed after use.
+ */
+int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
+{
+	*ccid_array = kmemdup(builtin_ccids, sizeof(builtin_ccids), gfp_any());
+	if (*ccid_array = NULL)
+		return -ENOBUFS;
+	*array_len = ARRAY_SIZE(builtin_ccids);
+	return 0;
+}
+
+int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	if (len < sizeof(builtin_ccids))
+		return -EINVAL;
+
+	if (put_user(sizeof(builtin_ccids), optlen) ||
+	    copy_to_user(optval, builtin_ccids, sizeof(builtin_ccids)))
+		return -EFAULT;
+	return 0;
+}
+
 int ccid_register(struct ccid_operations *ccid_ops)
 {
 	int err = -ENOBUFS;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -383,6 +383,10 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
 	    !dccp_feat_sp_list_ok(feat, sp_val, sp_len))
 		return -EINVAL;
 
+	/* Avoid negotiating alien CCIDs by only advertising supported ones */
+	if (feat = DCCPF_CCID && !ccid_support_check(sp_val, sp_len))
+		return -EOPNOTSUPP;
+
 	if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
 		return -ENOMEM;
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -649,6 +649,8 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_GET_CUR_MPS:
 		val = dp->dccps_mss_cache;
 		break;
+	case DCCP_SOCKOPT_AVAILABLE_CCIDS:
+		return ccid_getsockopt_builtin_ccids(sk, len, optval, optlen);
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
 		break;
