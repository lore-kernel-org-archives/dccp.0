From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 02 May 2008 11:14:12 +0000
Subject: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <20080502202242.74967BC4D@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_msghdr_parse can now parse arbitrary DCCP_SCM_* fields and put them
directly into skb. Now the function also sets deault values and ignores
unknown fields. Moved clearing of used skb fields to dccp_qpolicy_pop.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 net/dccp/output.c  |    3 ---
 net/dccp/proto.c   |   36 ++++++++++++++++++------------------
 net/dccp/qpolicy.c |    3 +++
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index e2030ca..b6229d0 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -257,9 +257,6 @@ static void dccp_xmit_packet(struct sock *sk)
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATA;
 	}
 
-	/* Clear priority value used by the qpolicy subsystem */
-	skb->priority = 0;
-
 	err = dccp_transmit_skb(sk, skb);
 	if (err)
 		dccp_pr_debug("transmit_skb() returned err=%d\n", err);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 53cfb6a..e096256 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -705,10 +705,13 @@ int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 #endif
 
-static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
+static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
 
+	/* Set default values to skb fields used by qpolicies */
+	skb->priority = 0;
+
 	for (; cmsg != NULL; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 
 		if (!CMSG_OK(msg, cmsg))
@@ -719,13 +722,21 @@ static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
 			continue;
 
 		switch (cmsg->cmsg_type) {
+		/*
+		 * Assign the (opaque) qpolicy priority value to skb->priority
+		 *
+		 * We are overloading this skb field for use with the qpolicy
+		 * subystem. The skb->priority is normally used for the
+		 * SO_PRIORITY option, which is initialised from sk_priority
+		 * Since the assignment of sk_priority to skb->priority happens
+		 * later (on layer 3), we overload this field for use with
+		 * queueing priorities as long as the skb is on layer 4.
+		 */
 		case DCCP_SCM_PRIORITY:
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
 				return -EINVAL;
-			*priority = (__u32 *)CMSG_DATA(cmsg);
+			skb->priority = *(__u32 *)CMSG_DATA(cmsg);
 			break;
-		default:
-			return -EINVAL;
 		}
 	}
 	return 0;
@@ -739,15 +750,11 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	const int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
 	int rc, size;
-	__u32 *pprio = NULL;
 	long timeo;
 
 	if (len > dp->dccps_mss_cache)
 		return -EMSGSIZE;
 
-	if (dccp_msghdr_parse(msg, &pprio))
-		return -EINVAL;
-
 	lock_sock(sk);
 
 	if (dccp_qpolicy_full(sk)) {
@@ -778,16 +785,9 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (rc != 0)
 		goto out_discard;
 
-	/*
-	 * Assign the (opaque) qpolicy priority value to skb->priority.
-	 *
-	 * We are overloading this skb field for use with the qpolicy subystem.
-	 * The skb->priority is normally used for the SO_PRIORITY option, which
-	 * is initialised from sk_priority. Since the assignment of sk_priority
-	 * to skb->priority happens later (on layer 3), we overload this field
-	 * for use with queueing priorities as long as the skb is on layer 4.
-	 */
-	skb->priority = pprio = NULL ? 0 : *pprio;
+	rc = dccp_msghdr_parse(msg, skb);
+	if (rc != 0)
+		goto out_discard;
 
 	dccp_qpolicy_push(sk, skb);
 	dccp_write_xmit(sk);
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index b5861c8..6ef3093 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -118,6 +118,9 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
 {
 	struct sk_buff *skb = dccp_qpolicy_top(sk);
 
+	/* Clear skb fields used by the qpolicy subsystem */
+	skb->priority = 0;
+
 	if (skb)
 		skb_unlink(skb, &sk->sk_write_queue);
 	return skb;
-- 
1.5.4.5

