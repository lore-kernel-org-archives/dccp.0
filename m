From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 19:15:44 +0000
Subject: [DCCP]: Add priority queuing policy
Message-Id: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_g/89HSr4rKQIKx3"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--Boundary-00=_g/89HSr4rKQIKx3
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This patch adds queuing policy that allows applications to prioritize packets.
Each packet may (but is not required to) have attached information about its
importance relative to other packets on this socket. If bandwidth is limited
(as defined by CCID in use) less important packets are dropped before sending.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 net/dccp/Makefile       |    2 +-
 net/dccp/dccp.h         |    6 +++
 net/dccp/qpolicy.c      |    2 +
 net/dccp/qpolicy_prio.c |   88 
+++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 97 insertions(+), 1 deletions(-)
 create mode 100644 net/dccp/qpolicy_prio.c
-- 
Regards,
Tomasz Grobelny

--Boundary-00=_g/89HSr4rKQIKx3
Content-Type: text/x-patch;
  name="2c45163637ed2698c9787372e5d5dc99231d4754.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="2c45163637ed2698c9787372e5d5dc99231d4754.diff"

diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 5f56132..849797f 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o \
 	  output.o proto.o timer.o ackvec.o \
-	  qpolicy.o qpolicy_simple.o
+	  qpolicy.o qpolicy_simple.o qpolicy_prio.o
 
 dccp_ipv4-y := ipv4.o
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 02a2b26..ef94f42 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -330,10 +330,16 @@ struct dccp_skb_cb {
 	__u16 dccpd_opt_len;
 	__u64 dccpd_seq;
 	__u64 dccpd_ack_seq;
+	char  dccpd_policy[16];
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+struct dccp_policy_prio {
+	s8	priority;
+};
+#define SKB_PRIO(__skbcb) ((struct dccp_policy_prio *)&((__skbcb)->dccpd_policy[0]))
+
 /* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 71b4b7c..df8861a 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -13,9 +13,11 @@
 #include "qpolicy.h"
 
 extern struct dccp_qpolicy_operations simple_policy_operations;
+extern struct dccp_qpolicy_operations prio_policy_operations;
 struct dccp_qpolicy_operations* qpolicy_operations[] =
 {
 	&simple_policy_operations,
+	&prio_policy_operations,
 };
 
 void dccp_qpolicy_init(struct sock *sk)
diff --git a/net/dccp/qpolicy_prio.c b/net/dccp/qpolicy_prio.c
new file mode 100644
index 0000000..2fde6e5
--- /dev/null
+++ b/net/dccp/qpolicy_prio.c
@@ -0,0 +1,88 @@
+/*
+ *  net/dccp/qpolicy_prio.c
+ *
+ *  An implementation of the DCCP protocol
+ *
+ *  Copyright (c) 2008 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License v2
+ *  as published by the Free Software Foundation.
+ */
+
+#include "qpolicy.h"
+#define POLICY_ID 1
+
+struct sk_buff *dccp_queue_get_worst(struct sk_buff_head *list)
+{
+	int i, worstp = -128;
+	struct sk_buff *curr=(struct sk_buff*)list;
+	struct sk_buff *worst=NULL;
+	struct dccp_skb_cb *dcb;
+	for(i=0;i<list->qlen;i++)
+	{
+		curr=curr->next;
+		dcb = DCCP_SKB_CB(curr);
+		if(SKB_PRIO(dcb)->priority > worstp)
+		{
+			worstp=SKB_PRIO(dcb)->priority;
+			worst=curr;
+		}
+	}
+	return worst;
+}
+
+void prio_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
+{
+	struct dccp_policy_prio *dcp = (struct dccp_policy_prio *)control;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+	SKB_PRIO(dcb)->priority = 127;
+	if(dcp)
+		memcpy(SKB_PRIO(dcb), dcp, min(sizeof(struct dccp_policy_prio), controllen));
+	skb_queue_tail(&sk->sk_write_queue, skb);
+	if(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)
+	{
+		struct sk_buff* worst=dccp_queue_get_worst(&sk->sk_write_queue);
+		skb_unlink(worst, &sk->sk_write_queue);
+		kfree_skb(worst);
+	}
+}
+
+/** no matter what we can push a packet into the queue => queue is never full */
+int prio_full(struct sock *sk)
+{
+	return 0;
+}
+
+struct sk_buff* prio_top(struct sock *sk)
+{
+	int i, bestp=127;
+	struct sk_buff *curr=(struct sk_buff*)(&sk->sk_write_queue);
+	struct sk_buff *best=NULL;
+	struct dccp_skb_cb *dcb;
+	for(i=0;i<sk->sk_write_queue.qlen;i++)
+	{
+		curr=curr->next;
+		dcb = DCCP_SKB_CB(curr);
+		if(SKB_PRIO(dcb)->priority < bestp)
+		{
+			bestp=SKB_PRIO(dcb)->priority;
+			best=curr;
+		}
+	}
+	return best;
+}
+
+void prio_pop(struct sock *sk, struct sk_buff *skb)
+{
+	skb_unlink(skb, &sk->sk_write_queue);
+}
+
+struct dccp_qpolicy_operations prio_policy_operations =
+{
+	.policy_id = POLICY_ID,
+	.push = prio_push,
+	.full = prio_full,
+	.top = prio_top,
+	.pop = prio_pop,
+};

--Boundary-00=_g/89HSr4rKQIKx3--



