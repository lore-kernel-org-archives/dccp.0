From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 02 Apr 2008 20:10:13 +0000
Subject: [PATCH 1/5] [DCCP]: Start implementation of queuing policies
Message-Id: <20080411102602.16463BD37@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch moves code responsible for enqueuing and dequeuing packets to
separate file. It also defines simple interface for queuing policy. For now
there is only one policy that doesn't change kernel behaviour.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 net/dccp/Makefile         |    3 ++-
 net/dccp/output.c         |    8 +++++---
 net/dccp/proto.c          |    6 +++---
 net/dccp/qpolicy.c        |   40 ++++++++++++++++++++++++++++++++++++++++
 net/dccp/qpolicy.h        |   38 ++++++++++++++++++++++++++++++++++++++
 net/dccp/qpolicy_simple.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 132 insertions(+), 7 deletions(-)
 create mode 100644 net/dccp/qpolicy.c
 create mode 100644 net/dccp/qpolicy.h
 create mode 100644 net/dccp/qpolicy_simple.c

diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index b68440b..5f56132 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,7 +1,8 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o \
-	  output.o proto.o timer.o ackvec.o
+	  output.o proto.o timer.o ackvec.o \
+	  qpolicy.o qpolicy_simple.o
 
 dccp_ipv4-y := ipv4.o
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 2c38587..2b072d3 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -20,6 +20,7 @@
 #include "ackvec.h"
 #include "ccid.h"
 #include "dccp.h"
+#include "qpolicy.h"
 
 static inline void dccp_event_ack_sent(struct sock *sk)
 {
@@ -239,7 +240,8 @@ static void dccp_xmit_packet(struct sock *sk)
 {
 	int err, len;
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct sk_buff *skb = skb_dequeue(&sk->sk_write_queue);
+	struct sk_buff *skb = qpolicy_top(sk);
+	qpolicy_pop(sk, skb);
 
 	if (unlikely(skb = NULL))
 		return;
@@ -329,7 +331,7 @@ void dccp_write_xmit(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(&sk->sk_write_queue))) {
+	while ((skb = qpolicy_top(sk))) {
 		int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
 		switch (ccid_packet_dequeue_eval(rc)) {
@@ -343,7 +345,7 @@ void dccp_write_xmit(struct sock *sk)
 			dccp_xmit_packet(sk);
 			break;
 		case CCID_PACKET_ERR:
-			skb_dequeue(&sk->sk_write_queue);
+			qpolicy_pop(sk, skb);
 			kfree_skb(skb);
 			dccp_pr_debug("packet discarded due to err=%d\n", rc);
 		}
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index cbb8650..ea4492b 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -36,6 +36,7 @@
 #include "ccid.h"
 #include "dccp.h"
 #include "feat.h"
+#include "qpolicy.h"
 
 DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
@@ -700,8 +701,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	lock_sock(sk);
 
-	if (sysctl_dccp_tx_qlen &&
-	    (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+	if (qpolicy_full(sk)) {
 		rc = -EAGAIN;
 		goto out_release;
 	}
@@ -729,7 +729,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (rc != 0)
 		goto out_discard;
 
-	skb_queue_tail(&sk->sk_write_queue, skb);
+	qpolicy_push(sk, skb, msg->msg_control, msg->msg_controllen);
 	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
new file mode 100644
index 0000000..58d1e2c
--- /dev/null
+++ b/net/dccp/qpolicy.c
@@ -0,0 +1,40 @@
+/*
+ *  net/dccp/qpolicy.c
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
+
+extern struct dccp_qpolicy_operations simple_policy_operations;
+struct dccp_qpolicy_operations *qpolicy_operations[] +{
+	&simple_policy_operations,
+};
+
+void qpolicy_push(struct sock *sk, struct sk_buff *skb,
+				void *control, __kernel_size_t controllen)
+{
+	qpolicy_operations[0]->push(sk, skb, control, controllen);
+}
+
+int qpolicy_full(struct sock *sk)
+{
+	return qpolicy_operations[0]->full(sk);
+}
+
+struct sk_buff *qpolicy_top(struct sock *sk)
+{
+	return qpolicy_operations[0]->top(sk);
+}
+
+void qpolicy_pop(struct sock *sk, struct sk_buff *skb)
+{
+	qpolicy_operations[0]->pop(sk, skb);
+}
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
new file mode 100644
index 0000000..7776dee
--- /dev/null
+++ b/net/dccp/qpolicy.h
@@ -0,0 +1,38 @@
+/*
+ *  net/dccp/qpolicy.h
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
+#ifndef _QPOLICY_H
+#define _QPOLICY_H
+
+#include <linux/kernel.h>
+#include <linux/socket.h>
+#include <linux/dccp.h>
+#include "dccp.h"
+
+struct dccp_qpolicy_operations {
+	unsigned char policy_id;
+
+	/* Interface Routines */
+	void (*push)(struct sock *sk, struct sk_buff *skb,
+			void *control, __kernel_size_t controllen);
+	int (*full)(struct sock *sk);
+	struct sk_buff* (*top)(struct sock *sk);
+	void (*pop)(struct sock *sk, struct sk_buff *skb);
+};
+
+void qpolicy_push(struct sock *sk, struct sk_buff *skb,
+				void *control, __kernel_size_t controllen);
+int qpolicy_full(struct sock *sk);
+struct sk_buff *qpolicy_top(struct sock *sk);
+void qpolicy_pop(struct sock *sk, struct sk_buff *skb);
+
+#endif /* _QPOLICY_H */
diff --git a/net/dccp/qpolicy_simple.c b/net/dccp/qpolicy_simple.c
new file mode 100644
index 0000000..cd78e51
--- /dev/null
+++ b/net/dccp/qpolicy_simple.c
@@ -0,0 +1,44 @@
+/*
+ *  net/dccp/qpolicy_simple.c
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
+#define POLICY_ID 0
+
+void simple_push(struct sock *sk, struct sk_buff *skb,
+			void *control, __kernel_size_t controllen)
+{
+	skb_queue_tail(&sk->sk_write_queue, skb);
+}
+
+int simple_full(struct sock *sk)
+{
+	return (sysctl_dccp_tx_qlen &&
+		(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen));
+}
+
+struct sk_buff *simple_top(struct sock *sk)
+{
+	return skb_peek(&sk->sk_write_queue);
+}
+
+void simple_pop(struct sock *sk, struct sk_buff *skb)
+{
+	skb_unlink(skb, &sk->sk_write_queue);
+}
+
+struct dccp_qpolicy_operations simple_policy_operations = {
+	.policy_id = POLICY_ID,
+	.push = simple_push,
+	.full = simple_full,
+	.top = simple_top,
+	.pop = simple_pop,
+};
-- 
1.5.4.5


