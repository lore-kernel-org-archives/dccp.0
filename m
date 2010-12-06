From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 06 Dec 2010 07:44:03 +0000
Subject: [PATCH 1/2] dccp: Policy-based packet dequeueing infrastructure
Message-Id: <1291621444-5927-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>

This patch adds a generic infrastructure for policy-based dequeueing of
TX packets and provides two policies:
 * a simple FIFO policy (which is the default) and
 * a priority based policy (set via socket options).
Both policies honour the tx_qlen sysctl for the maximum size of the write
queue (can be overridden via socket options).

The priority policy uses skb->priority internally to assign an u32 priority
identifier, using the same ranking as SO_PRIORITY. The skb->priority field
is set to 0 when the packet leaves DCCP. The priority is supplied as ancillary
data using cmsg(3), the patch also provides the requisite parsing routines.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   20 ++++++
 include/linux/dccp.h              |   21 ++++++
 net/dccp/Makefile                 |    4 +-
 net/dccp/dccp.h                   |   12 ++++
 net/dccp/output.c                 |    7 +-
 net/dccp/proto.c                  |   67 +++++++++++++++++++-
 net/dccp/qpolicy.c                |  126 +++++++++++++++++++++++++++++++++++++
 7 files changed, 248 insertions(+), 9 deletions(-)
 create mode 100644 net/dccp/qpolicy.c

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -47,6 +47,26 @@ http://linux-net.osdl.org/index.php/DCCP_Testing#Experimental_DCCP_source_tree
 
 Socket options
 =======
+DCCP_SOCKOPT_QPOLICY_ID sets the dequeuing policy for outgoing packets. It takes
+a policy ID as argument and can only be set before the connection (i.e. changes
+during an established connection are not supported). Currently, two policies are
+defined: the "simple" policy (DCCPQ_POLICY_SIMPLE), which does nothing special,
+and a priority-based variant (DCCPQ_POLICY_PRIO). The latter allows to pass an
+u32 priority value as ancillary data to sendmsg(), where higher numbers indicate
+a higher packet priority (similar to SO_PRIORITY). This ancillary data needs to
+be formatted using a cmsg(3) message header filled in as follows:
+	cmsg->cmsg_level = SOL_DCCP;
+	cmsg->cmsg_type	 = DCCP_SCM_PRIORITY;
+	cmsg->cmsg_len	 = CMSG_LEN(sizeof(uint32_t));	/* or CMSG_LEN(4) */
+
+DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum length of the output queue. A zero
+value is always interpreted as unbounded queue length. If different from zero,
+the interpretation of this parameter depends on the current dequeuing policy
+(see above): the "simple" policy will enforce a fixed queue size by returning
+EAGAIN, whereas the "prio" policy enforces a fixed queue length by dropping the
+lowest-priority packet first. The default value for this parameter is
+initialised from /proc/sys/net/dccp/default/tx_qlen.
+
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
 the socket will fall back to 0 (which means that no meaningful service code
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -243,6 +243,18 @@ extern void dccp_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
+/*
+ * TX Packet Dequeueing Interface
+ */
+extern void		dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb);
+extern bool		dccp_qpolicy_full(struct sock *sk);
+extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
+extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
+extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
+
+/*
+ * TX Packet Output and TX Timers
+ */
 extern void   dccp_write_xmit(struct sock *sk);
 extern void   dccp_write_space(struct sock *sk);
 extern void   dccp_flush_write_queue(struct sock *sk, long *time_budget);
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -197,6 +197,21 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
+/* DCCP socket control message types for cmsg */
+enum dccp_cmsg_type {
+	DCCP_SCM_PRIORITY = 1,
+	DCCP_SCM_QPOLICY_MAX = 0xFFFF,
+	/* ^-- Up to here reserved exclusively for qpolicy parameters */
+	DCCP_SCM_MAX
+};
+
+/* DCCP priorities for outgoing/queued packets */
+enum dccp_packet_dequeueing_policy {
+	DCCPQ_POLICY_SIMPLE,
+	DCCPQ_POLICY_PRIO,
+	DCCPQ_POLICY_MAX
+};
+
 /* DCCP socket options */
 #define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
 #define DCCP_SOCKOPT_SERVICE		2
@@ -210,6 +225,8 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_CCID		13
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
+#define DCCP_SOCKOPT_QPOLICY_ID		16
+#define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -458,6 +475,8 @@ struct dccp_ackvec;
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
  * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
  * @dccps_options_received - parsed set of retrieved options
+ * @dccps_qpolicy - TX dequeueing policy, one of %dccp_packet_dequeueing_policy
+ * @dccps_tx_qlen - maximum length of the TX queue
  * @dccps_role - role of this sock, one of %dccp_role
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
@@ -500,6 +519,8 @@ struct dccp_sock {
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
+	__u8				dccps_qpolicy;
+	__u32				dccps_tx_qlen;
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -242,7 +242,7 @@ static void dccp_xmit_packet(struct sock *sk)
 {
 	int err, len;
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct sk_buff *skb = skb_dequeue(&sk->sk_write_queue);
+	struct sk_buff *skb = dccp_qpolicy_pop(sk);
 
 	if (unlikely(skb = NULL))
 		return;
@@ -345,7 +345,7 @@ void dccp_write_xmit(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(&sk->sk_write_queue))) {
+	while ((skb = dccp_qpolicy_top(sk))) {
 		int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
 		switch (ccid_packet_dequeue_eval(rc)) {
@@ -359,8 +359,7 @@ void dccp_write_xmit(struct sock *sk)
 			dccp_xmit_packet(sk);
 			break;
 		case CCID_PACKET_ERR:
-			skb_dequeue(&sk->sk_write_queue);
-			kfree_skb(skb);
+			dccp_qpolicy_drop(sk, skb);
 			dccp_pr_debug("packet discarded due to err=%d\n", rc);
 		}
 	}
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -185,6 +185,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
 	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
+	dp->dccps_tx_qlen	= sysctl_dccp_tx_qlen;
 
 	dccp_init_xmit_timers(sk);
 
@@ -532,6 +533,20 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		err = dccp_setsockopt_cscov(sk, val, true);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_ID:
+		if (sk->sk_state != DCCP_CLOSED)
+			err = -EISCONN;
+		else if (val < 0 || val >= DCCPQ_POLICY_MAX)
+			err = -EINVAL;
+		else
+			dp->dccps_qpolicy = val;
+		break;
+	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
+		if (val < 0)
+			err = -EINVAL;
+		else
+			dp->dccps_tx_qlen = val;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -639,6 +654,12 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		val = dp->dccps_pcrlen;
 		break;
+	case DCCP_SOCKOPT_QPOLICY_ID:
+		val = dp->dccps_qpolicy;
+		break;
+	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
+		val = dp->dccps_tx_qlen;
+		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
@@ -681,6 +702,43 @@ int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 #endif
 
+static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
+{
+	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
+
+	/*
+	 * Assign an (opaque) qpolicy priority value to skb->priority.
+	 *
+	 * We are overloading this skb field for use with the qpolicy subystem.
+	 * The skb->priority is normally used for the SO_PRIORITY option, which
+	 * is initialised from sk_priority. Since the assignment of sk_priority
+	 * to skb->priority happens later (on layer 3), we overload this field
+	 * for use with queueing priorities as long as the skb is on layer 4.
+	 * The default priority value (if nothing is set) is 0.
+	 */
+	skb->priority = 0;
+
+	for (; cmsg != NULL; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+
+		if (cmsg->cmsg_level != SOL_DCCP)
+			continue;
+
+		switch (cmsg->cmsg_type) {
+		case DCCP_SCM_PRIORITY:
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
+				return -EINVAL;
+			skb->priority = *(__u32 *)CMSG_DATA(cmsg);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
 int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 size_t len)
 {
@@ -696,8 +754,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	lock_sock(sk);
 
-	if (sysctl_dccp_tx_qlen &&
-	    (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+	if (dccp_qpolicy_full(sk)) {
 		rc = -EAGAIN;
 		goto out_release;
 	}
@@ -725,7 +782,11 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (rc != 0)
 		goto out_discard;
 
-	skb_queue_tail(&sk->sk_write_queue, skb);
+	rc = dccp_msghdr_parse(msg, skb);
+	if (rc != 0)
+		goto out_discard;
+
+	dccp_qpolicy_push(sk, skb);
 	/*
 	 * The xmit_timer is set if the TX CCID is rate-based and will expire
 	 * when congestion control permits to release further packets into the
new file mode 100644
--- /dev/null
+++ b/net/dccp/qpolicy.c
@@ -0,0 +1,126 @@
+/*
+ *  net/dccp/qpolicy.c
+ *
+ *  Policy-based packet dequeueing interface for DCCP.
+ *
+ *  Copyright (c) 2008 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License v2
+ *  as published by the Free Software Foundation.
+ */
+#include "dccp.h"
+
+/*
+ *	Simple Dequeueing Policy:
+ *	If tx_qlen is different from 0, enqueue up to tx_qlen elements.
+ */
+static void qpolicy_simple_push(struct sock *sk, struct sk_buff *skb)
+{
+	skb_queue_tail(&sk->sk_write_queue, skb);
+}
+
+static bool qpolicy_simple_full(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_tx_qlen &&
+	       sk->sk_write_queue.qlen >= dccp_sk(sk)->dccps_tx_qlen;
+}
+
+static struct sk_buff *qpolicy_simple_top(struct sock *sk)
+{
+	return skb_peek(&sk->sk_write_queue);
+}
+
+/*
+ *	Priority-based Dequeueing Policy:
+ *	If tx_qlen is different from 0 and the queue has reached its upper bound
+ *	of tx_qlen elements, replace older packets lowest-priority-first.
+ */
+static struct sk_buff *qpolicy_prio_best_skb(struct sock *sk)
+{
+	struct sk_buff *skb, *best = NULL;
+
+	skb_queue_walk(&sk->sk_write_queue, skb)
+		if (best = NULL || skb->priority > best->priority)
+			best = skb;
+	return best;
+}
+
+static struct sk_buff *qpolicy_prio_worst_skb(struct sock *sk)
+{
+	struct sk_buff *skb, *worst = NULL;
+
+	skb_queue_walk(&sk->sk_write_queue, skb)
+		if (worst = NULL || skb->priority < worst->priority)
+			worst = skb;
+	return worst;
+}
+
+static bool qpolicy_prio_full(struct sock *sk)
+{
+	if (qpolicy_simple_full(sk))
+		dccp_qpolicy_drop(sk, qpolicy_prio_worst_skb(sk));
+	return false;
+}
+
+/**
+ * struct dccp_qpolicy_operations  -  TX Packet Dequeueing Interface
+ * @push: add a new @skb to the write queue
+ * @full: indicates that no more packets will be admitted
+ * @top:  peeks at whatever the queueing policy defines as its `top'
+ */
+static struct dccp_qpolicy_operations {
+	void		(*push)	(struct sock *sk, struct sk_buff *skb);
+	bool		(*full) (struct sock *sk);
+	struct sk_buff*	(*top)  (struct sock *sk);
+
+} qpol_table[DCCPQ_POLICY_MAX] = {
+	[DCCPQ_POLICY_SIMPLE] = {
+		.push = qpolicy_simple_push,
+		.full = qpolicy_simple_full,
+		.top  = qpolicy_simple_top,
+	},
+	[DCCPQ_POLICY_PRIO] = {
+		.push = qpolicy_simple_push,
+		.full = qpolicy_prio_full,
+		.top  = qpolicy_prio_best_skb,
+	},
+};
+
+/*
+ *	Externally visible interface
+ */
+void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb)
+{
+	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb);
+}
+
+bool dccp_qpolicy_full(struct sock *sk)
+{
+	return qpol_table[dccp_sk(sk)->dccps_qpolicy].full(sk);
+}
+
+void dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb)
+{
+	if (skb != NULL) {
+		skb_unlink(skb, &sk->sk_write_queue);
+		kfree_skb(skb);
+	}
+}
+
+struct sk_buff *dccp_qpolicy_top(struct sock *sk)
+{
+	return qpol_table[dccp_sk(sk)->dccps_qpolicy].top(sk);
+}
+
+struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
+{
+	struct sk_buff *skb = dccp_qpolicy_top(sk);
+
+	if (skb != NULL) {
+		/* Clear any skb fields that we used internally */
+		skb->priority = 0;
+		skb_unlink(skb, &sk->sk_write_queue);
+	}
+	return skb;
+}
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
-
+dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o \
+	  qpolicy.o
 #
 # CCID algorithms to be used by dccp.ko
 #
