From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 17 May 2008 15:28:21 +0000
Subject: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Message-Id: <20080517155916.34622BD22@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since packets with invalid cmsg parameters can be rejected by kernel there
is a need to allow applications to access information on available policies
and their respective cmsg parameters at runtime. This patch simplifies
maintaining compatibility between userspace applications and DCCP code.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    5 +++
 net/dccp/dccp.h      |    4 +++
 net/dccp/proto.c     |    2 +
 net/dccp/qpolicy.c   |   67 +++++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 69 insertions(+), 9 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 5c27e27..950ecd5 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -226,6 +226,11 @@ enum dccp_packet_dequeueing_policy {
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
+#define DCCP_SOCKOPT_QPOLICY_MIN	256
+#define DCCP_SOCKOPT_QPOLICY_AVAILABLE	256
+#define DCCP_SOCKOPT_QPOLICY_PARAMS	257
+#define DCCP_SOCKOPT_QPOLICY_MAX	512
+
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
 /* maximum number of CCID preferences that can be registered at one time */
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index c6e1a9c..1610807 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -223,6 +223,10 @@ extern bool		dccp_qpolicy_full(struct sock *sk);
 extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
 extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
 extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
+extern int		dccp_qpolicy_getsockopt(struct sock *sk, int len,
+						int optname,
+						char __user *optval,
+						int __user *optlen);
 
 /*
  * TX Packet Output and TX Timers
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index bdc4126..c9596ff 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -669,6 +669,8 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case 192 ... 255:
 		return ccid_hc_tx_getsockopt(dp->dccps_hc_tx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
+	case DCCP_SOCKOPT_QPOLICY_MIN ... DCCP_SOCKOPT_QPOLICY_MAX:
+		return dccp_qpolicy_getsockopt(sk, len, optname, optval, optlen);
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 4270c7f..ba4f6a1 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -9,6 +9,7 @@
  *  modify it under the terms of the GNU General Public License v2
  *  as published by the Free Software Foundation.
  */
+#include <linux/dccp.h>
 #include <asm/unaligned.h>
 #include "dccp.h"
 
@@ -64,6 +65,28 @@ static bool qpolicy_prio_full(struct sock *sk)
 	return false;
 }
 
+static int put_table(u32 *table, int psize, int len,
+				char __user *optval, int __user *optlen)
+{
+	if (len < psize)
+		return -EINVAL;
+	if (put_user(psize, optlen) || copy_to_user(optval, table, psize))
+		return -EFAULT;
+	return 0;
+}
+
+static int prio_params[] = {
+	DCCP_SCM_PRIORITY,
+};
+
+static int qpolicy_prio_getsockopt(struct sock *sk, int len, int optname,
+				char __user *optval, int __user *optlen)
+{
+	if (optname != DCCP_SOCKOPT_QPOLICY_PARAMS)
+		return -ENOPROTOOPT;
+	return put_table(prio_params, sizeof(prio_params), len, optval, optlen);
+}
+
 /**
  * struct dccp_qpolicy_operations  -  TX Packet Dequeueing Interface
  * @push: add a new @skb with possibly a struct dccp_packet_info
@@ -71,20 +94,24 @@ static bool qpolicy_prio_full(struct sock *sk)
  * @top:  peeks at whatever the queueing policy defines as its top
  */
 static struct dccp_qpolicy_operations {
-	void		(*push)	(struct sock *sk, struct sk_buff *skb);
-	bool		(*full) (struct sock *sk);
-	struct sk_buff*	(*top)  (struct sock *sk);
+	void		(*push)	     (struct sock *sk, struct sk_buff *skb);
+	bool		(*full)	     (struct sock *sk);
+	struct sk_buff*	(*top)	     (struct sock *sk);
+	int		(*getsockopt)(struct sock *sk, int len, int optname,
+				      char __user *optval, int __user *optlen);
 
 } qpol_table[DCCPQ_POLICY_MAX] = {
 	[DCCPQ_POLICY_SIMPLE] = {
-		.push = qpolicy_simple_push,
-		.full = qpolicy_simple_full,
-		.top  = qpolicy_simple_top,
+		.push		= qpolicy_simple_push,
+		.full		= qpolicy_simple_full,
+		.top		= qpolicy_simple_top,
+		.getsockopt	= NULL,
 	},
 	[DCCPQ_POLICY_PRIO] = {
-		.push = qpolicy_simple_push,
-		.full = qpolicy_prio_full,
-		.top  = qpolicy_prio_best_skb,
+		.push		= qpolicy_simple_push,
+		.full		= qpolicy_prio_full,
+		.top		= qpolicy_prio_best_skb,
+		.getsockopt	= qpolicy_prio_getsockopt,
 	},
 };
 
@@ -125,3 +152,25 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
 		skb_unlink(skb, &sk->sk_write_queue);
 	return skb;
 }
+
+static int qpolicy_numbers[] = {
+	DCCPQ_POLICY_SIMPLE,
+	DCCPQ_POLICY_PRIO,
+};
+
+int dccp_qpolicy_getsockopt(struct sock *sk, int len, int optname,
+				char __user *optval, int __user *optlen)
+{
+	switch (optname) {
+	case DCCP_SOCKOPT_QPOLICY_AVAILABLE:
+		return put_table(qpolicy_numbers, sizeof(qpolicy_numbers),
+							len, optval, optlen);
+	default:
+		if ( qpol_table[dccp_sk(sk)->dccps_qpolicy].getsockopt != NULL)
+			return qpol_table[dccp_sk(sk)->dccps_qpolicy].getsockopt
+				(sk, len, optname, optval, optlen);
+		else
+			return -ENOPROTOOPT;
+	}
+	return 0;
+}
-- 
1.5.4.5

