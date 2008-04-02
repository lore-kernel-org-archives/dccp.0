From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 02 Apr 2008 21:20:12 +0000
Subject: [PATCH 2/5] [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <20080411102603.53281BD3B@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch extends dccp_sock structure to include information about queuing
policy to be used for a given socket. The policy description consists of
pointers to policy operations and optional private data.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    6 ++++++
 net/dccp/minisocks.c |    2 ++
 net/dccp/proto.c     |    1 +
 net/dccp/qpolicy.c   |   15 +++++++++++----
 net/dccp/qpolicy.h   |    8 ++++++++
 5 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 19fe5bc..fa23b04 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -409,6 +409,11 @@ struct dccp_service_list {
 	__be32	dccpsl_list[0];
 };
 
+struct dccp_qpolicy {
+	struct dccp_qpolicy_operations	*qpol_ops;
+	char				qpol_priv[0];
+};
+
 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
 #define DCCP_SERVICE_CODE_IS_ABSENT		0
 
@@ -508,6 +513,7 @@ struct dccp_sock {
 	__u8				dccps_sync_scheduled:1;
 	struct tasklet_struct		dccps_xmitlet;
 	struct timer_list		dccps_xmit_timer;
+	struct dccp_qpolicy		dccps_qpolicy;
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
index ea4492b..7652175 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -195,6 +195,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 		if (dccp_feat_init(sk))
 			return -EPROTO;
 
+	dccp_qpolicy_init(sk);
 	dccp_init_xmit_timers(sk);
 
 	return 0;
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 58d1e2c..3029bd9 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -18,23 +18,30 @@ struct dccp_qpolicy_operations *qpolicy_operations[]  	&simple_policy_operations,
 };
 
+void dccp_qpolicy_init(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	dp->dccps_qpolicy.qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
+}
+
 void qpolicy_push(struct sock *sk, struct sk_buff *skb,
 				void *control, __kernel_size_t controllen)
 {
-	qpolicy_operations[0]->push(sk, skb, control, controllen);
+	dccp_sk(sk)->dccps_qpolicy.qpol_ops->push(sk, skb,
+							control, controllen);
 }
 
 int qpolicy_full(struct sock *sk)
 {
-	return qpolicy_operations[0]->full(sk);
+	return dccp_sk(sk)->dccps_qpolicy.qpol_ops->full(sk);
 }
 
 struct sk_buff *qpolicy_top(struct sock *sk)
 {
-	return qpolicy_operations[0]->top(sk);
+	return dccp_sk(sk)->dccps_qpolicy.qpol_ops->top(sk);
 }
 
 void qpolicy_pop(struct sock *sk, struct sk_buff *skb)
 {
-	qpolicy_operations[0]->pop(sk, skb);
+	dccp_sk(sk)->dccps_qpolicy.qpol_ops->pop(sk, skb);
 }
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index 7776dee..77aa387 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -18,6 +18,9 @@
 #include <linux/dccp.h>
 #include "dccp.h"
 
+/* id of default queuing policy */
+#define DCCP_QPOLICY_DEFAULT	0
+
 struct dccp_qpolicy_operations {
 	unsigned char policy_id;
 
@@ -29,6 +32,11 @@ struct dccp_qpolicy_operations {
 	void (*pop)(struct sock *sk, struct sk_buff *skb);
 };
 
+/** these operate on data that is common to all policies */
+void dccp_qpolicy_init(struct sock *sk);
+void dccp_qpolicy_destroy(struct sock *sk);
+
+/** these are wrappers for methods provided by policy currently in use */
 void qpolicy_push(struct sock *sk, struct sk_buff *skb,
 				void *control, __kernel_size_t controllen);
 int qpolicy_full(struct sock *sk);
-- 
1.5.4.5


