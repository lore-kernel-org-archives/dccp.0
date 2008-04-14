From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 14 Apr 2008 07:39:15 +0000
Subject: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
Message-Id: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP] [RFC]: Reworked queueing policy patch set

This is a re-worked version of Tomasz's priority-queueing patch set for
DCCP. The essential internals of his patch set have been left untouched,
in particular the prio/simple algorithms are the same as before.

The changes for which I am asking for comments are:

1. Fewer files: 
---------------
  The patch set originally introduced 4 new files:
        50 net/dccp/qpolicy.c
        48 net/dccp/qpolicy.h
        70 net/dccp/qpolicy_prio.c
        36 net/dccp/qpolicy_simple.c
  Given that each file has less than 100 lines, it seemed better to put them
  all into one file and export the declarations in dccp.h, the result is now:

       143 net/dccp/qpolicy.c
    
  With less than 150 lines, there is still room for a few more policies.

2. Let pop() return result
--------------------------
  * at least for the forseeable future, the underlying queue is sk_write_queue;
  * an skb can not be on two lists at the same time;
  * thus skb_unlink will always be part of implementing pop();
  * having pop() return the skb is more versatile (compare Assembler pop()).

3. Hide internals of implementation
-----------------------------------
  There had been discussion on hiding the internals, the present approach
  * uses symbolic identifiers (enum) to refer to policies;
  * makes the function table local to qpolicy.c, so that
  * dccp_sock only needs to take the policy identifier;
  * makes tx_qlen a socket member of dccp_sock (there was a bug in the 
    implementation -- tx_qlen was shared by all sockets using the same policy);
  * default policy as well as inheriting policy to child socket now implicit:
    - default policy (ID=0) set due to zeroing socket on allocation,
    - inheriting policy due to performing sock_copy() on the policy ID;

4. Clerical changes
-------------------
  Some work done here, such as adding documentation, aligning identifiers etc.


If people (Tomasz in particular) are ok with the changes, I would like to add
this to the test tree, otherwise will keep it separate as subtree "qpolicy" in
	git://eden-feed.erg.abdn.ac.uk/dccp_exp
during discussions.

Gerrit
---
 Documentation/networking/dccp.txt |   11 ++
 include/linux/dccp.h              |   20 +++++
 net/dccp/Makefile                 |    2 
 net/dccp/dccp.h                   |   45 +++++++----
 net/dccp/output.c                 |    6 -
 net/dccp/proto.c                  |   26 ++++++
 net/dccp/qpolicy.c                |  143 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 231 insertions(+), 22 deletions(-)
	
--- /dev/null
+++ b/net/dccp/qpolicy.c
@@ -0,0 +1,143 @@
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
+#include "dccp.h"
+
+/*
+ *	Simple Dequeueing Policy
+ */
+static void simple_push(struct sock *sk, struct sk_buff *skb,
+			const struct dccp_packet_info *dcp)
+{
+	skb_queue_tail(&sk->sk_write_queue, skb);
+}
+
+static int simple_full(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_tx_qlen &&
+	       sk->sk_write_queue.qlen >= dccp_sk(sk)->dccps_tx_qlen;
+}
+
+static struct sk_buff *simple_top(struct sock *sk)
+{
+	return skb_peek(&sk->sk_write_queue);
+}
+
+/*
+ *	Priority-based Dequeueing Policy
+ */
+static struct sk_buff *prio_get_worst_skb(struct sock *sk)
+{
+	struct sk_buff *skb, *worst = NULL;
+	int worstp = -128;
+
+	skb_queue_walk(&sk->sk_write_queue, skb)
+		if (DCCP_SKB_CB(skb)->dccpd_policy.priority >= worstp) {
+			worstp = DCCP_SKB_CB(skb)->dccpd_policy.priority;
+			worst  = skb;
+		}
+	return worst;
+}
+
+static void prio_push(struct sock *sk, struct sk_buff *skb,
+		      const struct dccp_packet_info *dcp)
+{
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+
+	dcb->dccpd_policy.priority = 127;
+	if (dcp)
+		memcpy(&dcb->dccpd_policy, dcp, sizeof(*dcp));
+
+	skb_queue_tail(&sk->sk_write_queue, skb);
+
+	if (sk->sk_write_queue.qlen >= dccp_sk(sk)->dccps_tx_qlen) {
+		struct sk_buff *worst = prio_get_worst_skb(sk);
+
+		skb_unlink(worst, &sk->sk_write_queue);
+		kfree_skb(worst);
+	}
+}
+
+/** we can always push a packet into the queue => queue is never full */
+static int prio_full(struct sock *sk)
+{
+	return 0;
+}
+
+static struct sk_buff *prio_get_best_skb(struct sock *sk)
+{
+	struct sk_buff *skb, *best = NULL;
+	int bestp = 127;
+
+	skb_queue_walk(&sk->sk_write_queue, skb)
+		if (DCCP_SKB_CB(skb)->dccpd_policy.priority <= bestp) {
+			bestp = DCCP_SKB_CB(skb)->dccpd_policy.priority;
+			best  = skb;
+		}
+	return best;
+}
+
+/**
+ * struct dccp_qpolicy_operations  -  TX Packet Dequeueing Interface
+ * @push:	add a new @skb with possibly a struct dccp_packet_info
+ * @full:	indicates that no more packets will be admitted
+ * @top:	peeks at whatever the queueing policy defines as top
+ */
+static struct dccp_qpolicy_operations {
+	void		(*push)	(struct sock *sk, struct sk_buff *skb,
+				 const struct dccp_packet_info *dcp);
+	int		(*full) (struct sock *sk);
+	struct sk_buff*	(*top)  (struct sock *sk);
+
+} qpol_table[DCCPQ_POLICY_MAX] = {
+	[DCCPQ_POLICY_SIMPLE] = {
+		.push = simple_push,
+		.full = simple_full,
+		.top  = simple_top,
+	},
+	[DCCPQ_POLICY_PRIO] = {
+		.push = prio_push,
+		.full = prio_full,
+		.top  = prio_get_best_skb,
+	},
+};
+
+/*
+ * Wrappers for methods provided by policy currently in use
+ */
+void qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghdr *msg)
+{
+	struct dccp_packet_info *dcp = NULL;
+
+	if (msg->msg_control != NULL && msg->msg_controllen = sizeof(*dcp))
+		dcp = (struct dccp_packet_info *)msg->msg_control;
+
+	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb, dcp);
+}
+
+int qpolicy_full(struct sock *sk)
+{
+	return qpol_table[dccp_sk(sk)->dccps_qpolicy].full(sk);
+}
+
+struct sk_buff *qpolicy_top(struct sock *sk)
+{
+	return qpol_table[dccp_sk(sk)->dccps_qpolicy].top(sk);
+}
+
+struct sk_buff *qpolicy_pop(struct sock *sk)
+{
+	struct sk_buff *skb = qpolicy_top(sk);
+
+	if (skb)
+		skb_unlink(skb, &sk->sk_write_queue);
+	return skb;
+}
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -195,6 +195,20 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
+/* DCCP TX Dequeueing Policy */
+enum dccp_packet_dequeueing_policy {
+	DCCPQ_POLICY_SIMPLE,
+	DCCPQ_POLICY_PRIO,
+	DCCPQ_POLICY_MAX
+};
+/**
+ * struct dccp_packet_info  -  Per-packet TX dequeueing information
+ * @priority: packet priority, lower value => packet more likely to be sent
+ */
+struct dccp_packet_info {
+	__s8	priority;
+};
+
 /* DCCP socket options */
 #define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
 #define DCCP_SOCKOPT_SERVICE		2
@@ -208,6 +222,8 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_CCID		13
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
+#define DCCP_SOCKOPT_QPOLICY_ID		16
+#define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -459,6 +475,8 @@ struct dccp_ackvec;
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
  * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
  * @dccps_options_received - parsed set of retrieved options
+ * @dccps_qpolicy - TX dequeueing policy, one of %dccp_packet_dequeueing_policy
+ * @dccps_tx_qlen - maximum length of the TX queue
  * @dccps_role - role of this sock, one of %dccp_role
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
@@ -501,6 +519,8 @@ struct dccp_sock {
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
+	__u8				dccps_qpolicy;
+	__u32				dccps_tx_qlen;
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
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
+	if (qpolicy_full(sk)) {
 		rc = -EAGAIN;
 		goto out_release;
 	}
@@ -729,7 +749,7 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	if (rc != 0)
 		goto out_discard;
 
-	skb_queue_tail(&sk->sk_write_queue, skb);
+	qpolicy_push(sk, skb, msg);
 	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -215,6 +215,18 @@ extern void dccp_reqsk_send_ack(struct s
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
+/*
+ * TX Packet Dequeueing Interface
+ */
+extern void		qpolicy_push(struct sock *sk, struct sk_buff *skb,
+				     struct msghdr *msg);
+extern int		qpolicy_full(struct sock *sk);
+extern struct sk_buff	*qpolicy_top(struct sock *sk);
+extern struct sk_buff	*qpolicy_pop(struct sock *sk);
+
+/*
+ * TX Packet Output and TX Timers
+ */
 extern void dccp_write_xmit(struct sock *sk);
 extern void dccp_write_space(struct sock *sk);
 extern void dccp_flush_write_queue(struct sock *sk, long *time_budget);
@@ -313,14 +325,16 @@ static inline int dccp_bad_service_code(
 
 /**
  * dccp_skb_cb  -  DCCP per-packet control information
- * @dccpd_type: one of %dccp_pkt_type (or unknown)
- * @dccpd_ccval: CCVal field (5.1), see e.g. RFC 4342, 8.1
- * @dccpd_reset_code: one of %dccp_reset_codes
- * @dccpd_reset_data: Data1..3 fields (depend on @dccpd_reset_code)
- * @dccpd_opt_len: total length of all options (5.8) in the packet
- * @dccpd_seq: sequence number
- * @dccpd_ack_seq: acknowledgment number subheader field value
- * This is used for transmission as well as for reception.
+ * @header:		IPv4/6 parameters
+ * @dccpd_type:		one of %dccp_pkt_type (or unknown)
+ * @dccpd_ccval:	CCVal field (5.1), see e.g. RFC 4342, 8.1
+ * @dccpd_reset_code:	one of %dccp_reset_codes
+ * @dccpd_reset_data:	Data1..3 fields (depend on @dccpd_reset_code)
+ * @dccpd_opt_len:	total length of all options (5.8) in the packet
+ * @dccpd_seq:		sequence number
+ * @dccpd_ack_seq:	acknowledgment number subheader field value
+ * @dccpd_policy:	packet dequeueing policy (TX packets only)
+ * This struct is used for transmission as well as for reception.
  */
 struct dccp_skb_cb {
 	union {
@@ -329,13 +343,14 @@ struct dccp_skb_cb {
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
-	__u8  dccpd_type:4;
-	__u8  dccpd_ccval:4;
-	__u8  dccpd_reset_code,
-	      dccpd_reset_data[3];
-	__u16 dccpd_opt_len;
-	__u64 dccpd_seq;
-	__u64 dccpd_ack_seq;
+	__u8			dccpd_type:4;
+	__u8			dccpd_ccval:4;
+	__u8			dccpd_reset_code,
+				dccpd_reset_data[3];
+	__u16			dccpd_opt_len;
+	__u64			dccpd_seq;
+	__u64			dccpd_ack_seq;
+	struct dccp_packet_info	dccpd_policy;
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -45,6 +45,17 @@ http://linux-net.osdl.org/index.php/DCCP
 
 Socket options
 =======
+DCCP_SOCKOPT_QPOLICY_ID sets the dequeueing policy for outgoing packets. It
+takes an integer number as argument and can only be set before establishing
+a connection (i.e. changes during an established connection are not supported).
+Currently defined IDs are "simple" (DCCPQ_POLICY_SIMPLE) and a priority-based
+variant (DCCPQ_POLICY_PRIO). In the latter case, a struct dccp_packet_info can
+be passed as ancillary data in the msg_control field of sendmsg(2).
+
+DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum TX queue length. This is relevant only for
+those TX dequeueing policies that honour this upper bound (currently only the
+simple/default policy does this). This socket option overrides the default value
+of the sysctl /proc/sys/net/dccp/default/tx_qlen.
 
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -238,7 +238,7 @@ static void dccp_xmit_packet(struct sock
 {
 	int err, len;
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct sk_buff *skb = skb_dequeue(&sk->sk_write_queue);
+	struct sk_buff *skb = qpolicy_pop(sk);
 
 	if (unlikely(skb = NULL))
 		return;
@@ -328,7 +328,7 @@ void dccp_write_xmit(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(&sk->sk_write_queue))) {
+	while ((skb = qpolicy_top(sk))) {
 		int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
 		switch (ccid_packet_dequeue_eval(rc)) {
@@ -342,7 +342,7 @@ void dccp_write_xmit(struct sock *sk)
 			dccp_xmit_packet(sk);
 			break;
 		case CCID_PACKET_ERR:
-			skb_dequeue(&sk->sk_write_queue);
+			qpolicy_pop(sk);
 			kfree_skb(skb);
 			dccp_pr_debug("packet discarded due to err=%d\n", rc);
 		}
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o \
-	  output.o proto.o timer.o ackvec.o
+	  output.o proto.o timer.o ackvec.o qpolicy.o
 
 dccp_ipv4-y := ipv4.o
 


The University of Aberdeen is a charity registered in Scotland, No SC013683.

