From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 03 Apr 2008 18:18:02 +0000
Subject: [PATCH 3/5] [DCCP]: Add priority queuing policy
Message-Id: <20080411102603.B939ABD3E@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch adds queuing policy that allows applications to prioritize packets.
Each packet may (but is not required to) have attached information about its
importance relative to other packets on this socket. If bandwidth is limited
(as defined by CCID in use) less important packets are dropped before sending.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h    |    8 ++++
 net/dccp/Makefile       |    2 +-
 net/dccp/dccp.h         |    1 +
 net/dccp/qpolicy.c      |    2 +
 net/dccp/qpolicy_prio.c |   84 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 96 insertions(+), 1 deletions(-)
 create mode 100644 net/dccp/qpolicy_prio.c

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index fa23b04..dfae04f 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -98,6 +98,14 @@ struct dccp_hdr_reset {
 					dccph_reset_data[3];
 };
 
+/**
+ * dccp_packet_info - DCCP per-packet qpolicy specific information
+ * @priority: packet priority, lower value => packet more likely to be sent
+ */
+struct dccp_packet_info {
+	__s8	priority;
+};
+
 enum dccp_pkt_type {
 	DCCP_PKT_REQUEST = 0,
 	DCCP_PKT_RESPONSE,
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
index 02a2b26..0b6d8e0 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -330,6 +330,7 @@ struct dccp_skb_cb {
 	__u16 dccpd_opt_len;
 	__u64 dccpd_seq;
 	__u64 dccpd_ack_seq;
+	struct dccp_packet_info dccpd_policy;
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 3029bd9..57b5797 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -13,9 +13,11 @@
 #include "qpolicy.h"
 
 extern struct dccp_qpolicy_operations simple_policy_operations;
+extern struct dccp_qpolicy_operations prio_policy_operations;
 struct dccp_qpolicy_operations *qpolicy_operations[]  {
 	&simple_policy_operations,
+	&prio_policy_operations,
 };
 
 void dccp_qpolicy_init(struct sock *sk)
diff --git a/net/dccp/qpolicy_prio.c b/net/dccp/qpolicy_prio.c
new file mode 100644
index 0000000..c2680b2
--- /dev/null
+++ b/net/dccp/qpolicy_prio.c
@@ -0,0 +1,84 @@
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
+static struct sk_buff *get_worst_skb(struct sk_buff_head *list)
+{
+	int i, worstp = -128;
+	struct sk_buff *curr = (struct sk_buff *)list;
+	struct sk_buff *worst = NULL;
+	struct dccp_skb_cb *dcb;
+	for (i = 0; i < list->qlen; i++) {
+		curr = curr->next;
+		dcb = DCCP_SKB_CB(curr);
+		if (dcb->dccpd_policy.priority >= worstp) {
+			worstp = dcb->dccpd_policy.priority;
+			worst = curr;
+		}
+	}
+	return worst;
+}
+
+void prio_push(struct sock *sk, struct sk_buff *skb,
+		void *control, __kernel_size_t controllen)
+{
+	struct dccp_packet_info *dcp = (struct dccp_packet_info *)control;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+	int controllength = min(sizeof(struct dccp_packet_info), controllen);
+	dcb->dccpd_policy.priority = 127;
+	if (dcp)
+		memcpy(&dcb->dccpd_policy, dcp, controllength);
+	skb_queue_tail(&sk->sk_write_queue, skb);
+	if (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen) {
+		struct sk_buff *worst = get_worst_skb(&sk->sk_write_queue);
+		skb_unlink(worst, &sk->sk_write_queue);
+		kfree_skb(worst);
+	}
+}
+
+/** we can always push a packet into the queue => queue is never full */
+int prio_full(struct sock *sk)
+{
+	return 0;
+}
+
+struct sk_buff *prio_top(struct sock *sk)
+{
+	int i, bestp = 127;
+	struct sk_buff *curr = (struct sk_buff *)(&sk->sk_write_queue);
+	struct sk_buff *best = NULL;
+	struct dccp_skb_cb *dcb;
+	for (i = 0; i < sk->sk_write_queue.qlen; i++) {
+		curr = curr->next;
+		dcb = DCCP_SKB_CB(curr);
+		if (dcb->dccpd_policy.priority <= bestp) {
+			bestp = dcb->dccpd_policy.priority;
+			best = curr;
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
+struct dccp_qpolicy_operations prio_policy_operations = {
+	.policy_id = POLICY_ID,
+	.push = prio_push,
+	.full = prio_full,
+	.top = prio_top,
+	.pop = prio_pop,
+};
-- 
1.5.4.5


