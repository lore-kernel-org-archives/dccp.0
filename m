From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 24 Apr 2008 21:51:30 +0000
Subject: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Message-Id: <20080424220704.0483DBC12@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Separate internal (in-kernel) storage of per packet data from external
interface (which is now an easily extensible structure).

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    9 +++++++++
 net/dccp/dccp.h      |    3 ++-
 net/dccp/proto.c     |   14 +++++---------
 net/dccp/qpolicy.c   |   20 ++++++++++++++------
 4 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 5c27e27..6d2c79a 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -98,6 +98,15 @@ struct dccp_hdr_reset {
 					dccph_reset_data[3];
 };
 
+/**
+ * struct dccp_qpolicy_prio_info - information used by prio queuing policy
+ *
+ * @priority - packet priority (bigger value sent first)
+ */
+struct dccp_qpolicy_prio_info {
+	__s8	priority;
+};
+
 enum dccp_pkt_type {
 	DCCP_PKT_REQUEST = 0,
 	DCCP_PKT_RESPONSE,
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 726337d..f0e77d9 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -218,7 +218,8 @@ extern void dccp_send_sync(struct sock *sk, const u64 seq,
 /*
  * TX Packet Dequeueing Interface
  */
-extern void		dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb);
+extern void		dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb,
+						struct cmsghdr *cmsg_qpolicy);
 extern bool		dccp_qpolicy_full(struct sock *sk);
 extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
 extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e6cc48b..022c5a2 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -706,7 +706,7 @@ int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 #endif
 
-static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
+static int dccp_msghdr_parse(struct msghdr *msg, struct cmsghdr **cmsg_qpolicy)
 {
 	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
 
@@ -721,9 +721,7 @@ static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
 
 		switch (cmsg->cmsg_type) {
 		case DCCP_SCM_PRIORITY:
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
-				return -EINVAL;
-			*priority = (__u32 *)CMSG_DATA(cmsg);
+			*cmsg_qpolicy = cmsg;
 			break;
 		default:
 			return -EINVAL;
@@ -740,13 +738,13 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	const int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
 	int rc, size;
-	__u32 *pprio = NULL;
+	struct cmsghdr *cmsg_qpolicy = NULL;
 	long timeo;
 
 	if (len > dp->dccps_mss_cache)
 		return -EMSGSIZE;
 
-	if (dccp_msghdr_parse(msg, &pprio))
+	if (dccp_msghdr_parse(msg, &cmsg_qpolicy))
 		return -EINVAL;
 
 	lock_sock(sk);
@@ -779,9 +777,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (rc != 0)
 		goto out_discard;
 
-	skb->priority = pprio != NULL ? *pprio : 0;
-
-	dccp_qpolicy_push(sk, skb);
+	dccp_qpolicy_push(sk, skb, cmsg_qpolicy);
 	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 4755908..09a6057 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -16,7 +16,8 @@
  *	Simple Dequeueing Policy:
  *	If tx_qlen is different from 0, enqueue up to tx_qlen elements.
  */
-static void qpolicy_simple_push(struct sock *sk, struct sk_buff *skb)
+static void qpolicy_simple_push(struct sock *sk, struct sk_buff *skb,
+				struct cmsghdr *cmsg)
 {
 	skb_queue_tail(&sk->sk_write_queue, skb);
 }
@@ -57,8 +58,13 @@ static struct sk_buff *qpolicy_prio_worst_skb(struct sock *sk)
 	return worst;
 }
 
-static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb)
+static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb,
+				struct cmsghdr *cmsg)
 {
+	struct dccp_qpolicy_prio_info info;
+	memcpy(&info, CMSG_DATA(cmsg), min(cmsg->cmsg_len, sizeof(info)));
+	skb->priority = info.priority;
+	printk("pushing prio: %d\n", skb->priority);
 	if (qpolicy_simple_full(sk)) {
 		struct sk_buff *worst =qpolicy_prio_worst_skb(sk);
 
@@ -66,7 +72,7 @@ static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb)
 			printk("%s: dropping worst %u/%u\n", __FUNCTION__,worst->priority,skb->priority);
 		dccp_qpolicy_drop(sk, worst);
 	}
-	qpolicy_simple_push(sk, skb);
+	qpolicy_simple_push(sk, skb, cmsg);
 }
 
 /* we can always push a packet into the queue => queue is never full */
@@ -82,7 +88,8 @@ static bool qpolicy_prio_full(struct sock *sk)
  * @top:	peeks at whatever the queueing policy defines as top
  */
 static struct dccp_qpolicy_operations {
-	void		(*push)	(struct sock *sk, struct sk_buff *skb);
+	void		(*push)	(struct sock *sk, struct sk_buff *skb,
+					struct cmsghdr *cmsg);
 	bool		(*full) (struct sock *sk);
 	struct sk_buff*	(*top)  (struct sock *sk);
 
@@ -102,9 +109,10 @@ static struct dccp_qpolicy_operations {
 /*
  *	Externally visible interface
  */
-void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb)
+void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb,
+			struct cmsghdr *cmsg_qpolicy)
 {
-	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb);
+	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb, cmsg_qpolicy);
 }
 
 bool dccp_qpolicy_full(struct sock *sk)
-- 
1.5.4.5

