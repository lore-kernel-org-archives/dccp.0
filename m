From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Wed, 09 Jul 2008 22:50:40 +0000
Subject: [PATCH 1/1] [DCCP][QPOLICY]: More strict controlling of supplied parameters v2
Message-Id: <20080710200543.AD02ABD27@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ensure that cmsg->cmsg_type value is valid for qpolicy that is currently in use.
Slightly revised version after comments from Gerrit.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 net/dccp/dccp.h    |    1 +
 net/dccp/proto.c   |    3 +++
 net/dccp/qpolicy.c |   23 +++++++++++++++++------
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9c60d01..286bb34 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -241,6 +241,7 @@ extern bool		dccp_qpolicy_full(struct sock *sk);
 extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
 extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
 extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
+extern bool		dccp_qpolicy_param_ok(struct sock *sk, __be32 param);
 
 /*
  * TX Packet Output and TX Timers
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d818606..582d37d 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -733,6 +733,9 @@ static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 		if (cmsg->cmsg_level != SOL_DCCP)
 			continue;
 
+		if (!dccp_qpolicy_param_ok(skb->sk, cmsg->cmsg_type))
+			return -EINVAL;
+
 		switch (cmsg->cmsg_type) {
 		case DCCP_SCM_PRIORITY:
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 414696b..27383f8 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -73,17 +73,20 @@ static struct dccp_qpolicy_operations {
 	void		(*push)	(struct sock *sk, struct sk_buff *skb);
 	bool		(*full) (struct sock *sk);
 	struct sk_buff*	(*top)  (struct sock *sk);
+	__be32		params;
 
 } qpol_table[DCCPQ_POLICY_MAX] = {
 	[DCCPQ_POLICY_SIMPLE] = {
-		.push = qpolicy_simple_push,
-		.full = qpolicy_simple_full,
-		.top  = qpolicy_simple_top,
+		.push   = qpolicy_simple_push,
+		.full   = qpolicy_simple_full,
+		.top    = qpolicy_simple_top,
+		.params = 0,
 	},
 	[DCCPQ_POLICY_PRIO] = {
-		.push = qpolicy_simple_push,
-		.full = qpolicy_prio_full,
-		.top  = qpolicy_prio_best_skb,
+		.push   = qpolicy_simple_push,
+		.full   = qpolicy_prio_full,
+		.top    = qpolicy_prio_best_skb,
+		.params = DCCP_SCM_PRIORITY,
 	},
 };
 
@@ -124,3 +127,11 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
 		skb_unlink(skb, &sk->sk_write_queue);
 	return skb;
 }
+
+bool dccp_qpolicy_param_ok(struct sock *sk, __be32 param)
+{
+	/* check if exactly one bit is set */
+	if (!param || (param & (param - 1)))
+		return false;
+	return (qpol_table[dccp_sk(sk)->dccps_qpolicy].params & param) = param;
+}
-- 
1.5.4.5

