From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 16 Apr 2008 08:36:29 +0000
Subject: [DCCP] [RFC] [Patchv3 1/1]: Queuing policies -- reworked version
Message-Id: <20080416083629.GB23157@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a reworked version of the patch set, tackling in particular:

  With the recent addition of the inet{,6}_skb_parm to struct dccp_skb_cb there
  is no more room left for any extensions -- the size of the struct now has
  already reached its maximum of 48 bytes.

To support the queueing policy patches developed by Tomasz, this patch therefore
introduces a different concept - to reuse the @priority field of struct sk_buff.

This is possible since all operations are output-only and since skb->priority is
set from sk_priority in net/ipv4/ip_output.c and net/ipv6/ip6_output.c.

sk_priority itself is set from the SO_PRIORITY value in net/core/sock.ci, so that
until the skb is forwarded to the IP layer there is no conflict.

This patch set uses the skb->priority field for DCCP transport-layer queueing
priorities. It does not clear the priority field when passing the skb on to
the IP layer; maybe this should be added.

Other changes:
--------------
 1) the "prio" policy previously used the ordering "lowest priority is best", 
    whereas the SO_PRIORITY setting underlying sk_priority uses "highest
    priority is best".  To make the socket API a bit more intuitive, this
    patch reuses the SO_PRIORITY semantics for the "prio" policy
    -- as remarked in the documentation.
 2) Consolidated the error checking for push() by
   * passing a struct msghdr* instead of its two control member elements,
   * setting the skb->priority only if the msg_controllen matches exactly the
     sizeof(u32),
   * otherwise, the priority is set to 0 (implies lowest possible priority).
 3) Made naming scheme consistent (dccp_qpolicy_xxx for externally visible
    functions and qpolicy_<policyname>_xxx for internal functions).
 4) Added a drop function - I think the simple_push() has become quite good now.

So far compile-tested only.

Gerrit
---
 Documentation/networking/dccp.txt |   15 ++++
 include/linux/dccp.h              |   13 +++
 net/dccp/Makefile                 |    2 
 net/dccp/dccp.h                   |   13 +++
 net/dccp/output.c                 |    7 -
 net/dccp/proto.c                  |   26 ++++++-
 net/dccp/qpolicy.c                |  135 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 203 insertions(+), 8 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -45,6 +45,21 @@ http://linux-net.osdl.org/index.php/DCCP
 
 Socket options
 =======
+DCCP_SOCKOPT_QPOLICY_ID sets the dequeuing policy for outgoing packets. It takes
+a policy ID as argument and can only be set before the connection (i.e. changes
+during an established connection are not supported). Currently, two policies are
+defined: the "simple" policy (DCCPQ_POLICY_SIMPLE), which does nothing special,
+and a priority-based variant (DCCPQ_POLICY_PRIO). The latter allows to pass an
+u32 priority value as ancillary data to sendmsg(), where higher numbers indicate
+a higher packet priority (similar to SO_PRIORITY).
+
+DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum length of the output queue. A zero
+value is always interpreted as unbounded queue length. If different from zero,
+the interpretation of this parameter depends on the current dequeuing policy
+(see above): the "simple" policy will enforce a fixed queue size by returning
+EAGAIN, whereas the "prio" policy enforces a fixed queue length by dropping the
+lowest-priority packet first. The default value for this parameter is
+initialised from /proc/sys/net/dccp/default/tx_qlen.
 
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -195,6 +195,13 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
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
@@ -208,6 +215,8 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_CCID		13
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
+#define DCCP_SOCKOPT_QPOLICY_ID		16
+#define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -459,6 +468,8 @@ struct dccp_ackvec;
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
  * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
  * @dccps_options_received - parsed set of retrieved options
+ * @dccps_qpolicy - TX dequeueing policy, one of %dccp_packet_dequeueing_policy
+ * @dccps_tx_qlen - maximum length of the TX queue
  * @dccps_role - role of this sock, one of %dccp_role
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
@@ -501,6 +512,8 @@ struct dccp_sock {
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
+	__u8				dccps_qpolicy;
+	__u32				dccps_tx_qlen;
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
--- /dev/null
+++ b/net/dccp/qpolicy.c
@@ -0,0 +1,135 @@
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
+#include <asm/unaligned.h>
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
+static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb)
+{
+	qpolicy_simple_push(sk, skb);
+	if (qpolicy_simple_full(sk))
+		dccp_qpolicy_drop(sk, qpolicy_prio_worst_skb(sk));
+}
+
+/* we can always push a packet into the queue => queue is never full */
+static bool qpolicy_prio_full(struct sock *sk)
+{
+	return false;
+}
+
+/**
+ * struct dccp_qpolicy_operations  -  TX Packet Dequeueing Interface
+ * @push:	add a new @skb with possibly a struct dccp_packet_info
+ * @full:	indicates that no more packets will be admitted
+ * @top:	peeks at whatever the queueing policy defines as top
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
+		.push = qpolicy_prio_push,
+		.full = qpolicy_prio_full,
+		.top  = qpolicy_prio_best_skb,
+	},
+};
+
+/*
+ *	Externally visible interface
+ */
+void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghdr *msg)
+{
+	if (msg->msg_control = NULL || msg->msg_controllen != sizeof(__u32))
+		skb->priority = 0;	/* implies lowest-possible priority */
+	else
+		skb->priority = get_unaligned((__u32 *)msg->msg_control);
+
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
+		kfree(skb);
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
+	if (skb)
+		skb_unlink(skb, &sk->sk_write_queue);
+	return skb;
+}
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -215,6 +215,19 @@ extern void dccp_reqsk_send_ack(struct s
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
+/*
+ * TX Packet Dequeueing Interface
+ */
+extern void		dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb,
+					  struct msghdr *msg);
+extern bool		dccp_qpolicy_full(struct sock *sk);
+extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
+extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
+extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
+
+/*
+ * TX Packet Output and TX Timers
+ */
 extern void dccp_write_xmit(struct sock *sk);
 extern void dccp_write_space(struct sock *sk);
 extern void dccp_flush_write_queue(struct sock *sk, long *time_budget);
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o \
-	  output.o proto.o timer.o ackvec.o
+	  qpolicy.o output.o proto.o timer.o ackvec.o
 
 dccp_ipv4-y := ipv4.o
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -238,7 +238,7 @@ static void dccp_xmit_packet(struct sock
 {
 	int err, len;
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct sk_buff *skb = skb_dequeue(&sk->sk_write_queue);
+	struct sk_buff *skb = dccp_qpolicy_pop(sk);
 
 	if (unlikely(skb = NULL))
 		return;
@@ -328,7 +328,7 @@ void dccp_write_xmit(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(&sk->sk_write_queue))) {
+	while ((skb = dccp_qpolicy_top(sk))) {
 		int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
 		switch (ccid_packet_dequeue_eval(rc)) {
@@ -342,8 +342,7 @@ void dccp_write_xmit(struct sock *sk)
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
@@ -187,6 +187,7 @@ int dccp_init_sock(struct sock *sk, cons
 	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
+	dp->dccps_tx_qlen	= sysctl_dccp_tx_qlen;
 
 	INIT_LIST_HEAD(&dp->dccps_featneg);
 	/* control socket doesn't need feat nego */
@@ -540,6 +541,20 @@ static int do_dccp_setsockopt(struct soc
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
@@ -643,6 +658,12 @@ static int do_dccp_getsockopt(struct soc
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
@@ -700,8 +721,7 @@ int dccp_sendmsg(struct kiocb *iocb, str
 
 	lock_sock(sk);
 
-	if (sysctl_dccp_tx_qlen &&
-	    (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+	if (dccp_qpolicy_full(sk)) {
 		rc = -EAGAIN;
 		goto out_release;
 	}
@@ -729,7 +749,7 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	if (rc != 0)
 		goto out_discard;
 
-	skb_queue_tail(&sk->sk_write_queue, skb);
+	dccp_qpolicy_push(sk, skb, msg);
 	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);


The University of Aberdeen is a charity registered in Scotland, No SC013683.

