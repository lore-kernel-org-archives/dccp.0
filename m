From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 19:15:39 +0000
Subject: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_b/89HNZhFoUK1NV"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--Boundary-00=_b/89HNZhFoUK1NV
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This patch extends dccp_sock structure to include information about queuing
policy to be used for a given socket. The policy description consists of
pointers to policy operations and optional private data.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    4 ++++
 net/dccp/minisocks.c |    2 ++
 net/dccp/proto.c     |    3 +++
 net/dccp/qpolicy.c   |   25 +++++++++++++++++++++----
 net/dccp/qpolicy.h   |   11 +++++++++++
 5 files changed, 41 insertions(+), 4 deletions(-)
-- 
Regards,
Tomasz Grobelny

--Boundary-00=_b/89HNZhFoUK1NV
Content-Type: text/x-patch;
  name="d25487b2b03a0576608617fa3895f07068ad86f7.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="d25487b2b03a0576608617fa3895f07068ad86f7.diff"

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 19fe5bc..3484a4a 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -215,6 +215,8 @@ enum dccp_feature_numbers {
 #define DCCP_SERVICE_LIST_MAX_LEN      32
 /* maximum number of CCID preferences that can be registered at one time */
 #define DCCP_CCID_LIST_MAX_LEN	       16
+/* id of default queuing policy */
+#define DCCP_QPOLICY_DEFAULT		0
 
 #ifdef __KERNEL__
 
@@ -425,6 +427,7 @@ static inline int dccp_list_has_service(const struct dccp_service_list *sl,
 }
 
 struct dccp_ackvec;
+struct dccp_qpolicy;
 
 /**
  * struct dccp_sock - DCCP socket state
@@ -508,6 +511,7 @@ struct dccp_sock {
 	__u8				dccps_sync_scheduled:1;
 	struct tasklet_struct		dccps_xmitlet;
 	struct timer_list		dccps_xmit_timer;
+	struct dccp_qpolicy		*dccps_qpolicy;
 };
 
 static inline struct dccp_sock *dccp_sk(const struct sock *sk)
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 2e5d1a7..f9a6211 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -23,6 +23,7 @@
 #include "ccid.h"
 #include "dccp.h"
 #include "feat.h"
+#include "qpolicy.h"
 
 struct inet_timewait_death_row dccp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
@@ -141,6 +142,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 			return NULL;
 		}
 		dccp_init_xmit_timers(newsk);
+		dccp_qpolicy_init(newsk);
 
 		DCCP_INC_STATS_BH(DCCP_MIB_PASSIVEOPENS);
 	}
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index ea4492b..f3916ac 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -195,6 +195,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 		if (dccp_feat_init(sk))
 			return -EPROTO;
 
+	dccp_qpolicy_init(sk);
 	dccp_init_xmit_timers(sk);
 
 	return 0;
@@ -233,6 +234,8 @@ int dccp_destroy_sock(struct sock *sk)
 	/* clean up feature negotiation state */
 	dccp_feat_list_purge(&dp->dccps_featneg);
 
+	dccp_qpolicy_destroy(sk);
+
 	return 0;
 }
 
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index c6e49e1..71b4b7c 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -18,22 +18,39 @@ struct dccp_qpolicy_operations* qpolicy_operations[] =
 	&simple_policy_operations,
 };
 
+void dccp_qpolicy_init(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	dp->dccps_qpolicy = kmalloc(sizeof(struct dccp_qpolicy), GFP_KERNEL);
+	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
+}
+
+void dccp_qpolicy_destroy(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	kfree(dp->dccps_qpolicy);
+}
+
 void qpolicy_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
 {
-	qpolicy_operations[0]->push(sk, skb, control, controllen);
+	struct dccp_sock *dp = dccp_sk(sk);
+	dp->dccps_qpolicy->qpol_ops->push(sk, skb, control, controllen);
 }
 
 int qpolicy_full(struct sock *sk)
 {
-	return qpolicy_operations[0]->full(sk);
+	struct dccp_sock *dp = dccp_sk(sk);
+	return dp->dccps_qpolicy->qpol_ops->full(sk);
 }
 
 struct sk_buff* qpolicy_top(struct sock *sk)
 {
-	return qpolicy_operations[0]->top(sk);
+	struct dccp_sock *dp = dccp_sk(sk);
+	return dp->dccps_qpolicy->qpol_ops->top(sk);
 }
 
 void qpolicy_pop(struct sock *sk, struct sk_buff *skb)
 {
-	qpolicy_operations[0]->pop(sk, skb);
+	struct dccp_sock *dp = dccp_sk(sk);
+	dp->dccps_qpolicy->qpol_ops->pop(sk, skb);
 }
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index d246322..dd4b94d 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -28,6 +28,17 @@ struct dccp_qpolicy_operations
 	void (*pop)(struct sock *sk, struct sk_buff *skb);
 };
 
+struct dccp_qpolicy
+{
+	struct dccp_qpolicy_operations	*qpol_ops;
+	char				qpol_priv[0];
+};
+
+/** these operate on data that is common to all policies */
+void dccp_qpolicy_init(struct sock *sk);
+void dccp_qpolicy_destroy(struct sock *sk);
+
+/** these are wrappers for methods provided by policy currently in use */
 void qpolicy_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen);
 int qpolicy_full(struct sock *sk);
 struct sk_buff* qpolicy_top(struct sock *sk);

--Boundary-00=_b/89HNZhFoUK1NV--



