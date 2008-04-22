From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Apr 2008 17:41:52 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080422174152.GD6039@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| If we iron this out we could finally return to the main subject of this 
| thread. That is Patch v2 by me and Gerrit...
| -- 
Fully agree - we just need to decide whether or not to use skb->priority.

Below is as far as I got in integrating your patch last week, it shows
only the major changes. The following bits have been updated:

 * skb->priority now cleared before passing the skb onto layer 3;
 * order of statements in prio_push() reversed (first dropping worst
   skb and then pushing the new skb - this is better when e.g.
   tx_qlen=1);
 * added general parsing routine for cmsg(3) socket control messages
   and defined one for the SOL_DCCP socket level; thanks to advice
   by Dave Miller



A new and updated version has been uploaded to

    git://eden-feed.erg.abdn.ac.uk/dccp_exp
    subtree `qpolicy'

The implementation needs some more testing.

I have uploaded matching userspace code to 

http://www.erg.abdn.ac.uk/users/gerrit/dccp/packet_prio_tests.tar.gz

Will send an update next week and then we can discuss my edits, it
remains your patch. Simply too busy this week.


Gerrit

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -195,6 +195,12 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
+/* DCCP socket control message types for cmsg */
+enum dccp_cmsg_type {
+	DCCP_SCM_PRIORITY = 1,
+	DCCP_SCM_MAX
+};
+
 /* DCCP priorities for outgoing/queued packets */
 enum dccp_packet_dequeueing_policy {
 	DCCPQ_POLICY_SIMPLE,
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -706,6 +706,32 @@ int compat_dccp_getsockopt(struct sock *
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 #endif
 
+static int dccp_msghdr_parse(struct msghdr *msg, __u32 **priority)
+{
+	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
+
+	for (; cmsg != NULL; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+
+		/* Only look at DCCP-related socket control messages */
+		if (cmsg->cmsg_level != SOL_DCCP)
+			continue;
+
+		switch (cmsg->cmsg_type) {
+		case DCCP_SCM_PRIORITY:
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u32)))
+				return -EINVAL;
+			*priority = (__u32 *)CMSG_DATA(cmsg);
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
@@ -714,11 +740,15 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	const int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
 	int rc, size;
+	__u32 *pprio = NULL;
 	long timeo;
 
 	if (len > dp->dccps_mss_cache)
 		return -EMSGSIZE;
 
+	if (dccp_msghdr_parse(msg, &pprio))
+		return -EINVAL;
+
 	lock_sock(sk);
 
 	if (dccp_qpolicy_full(sk)) {
@@ -749,7 +779,9 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	if (rc != 0)
 		goto out_discard;
 
-	dccp_qpolicy_push(sk, skb, msg);
+	skb->priority = pprio != NULL ? *pprio : 0;
+
+	dccp_qpolicy_push(sk, skb);
 	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -97,13 +102,8 @@ static struct dccp_qpolicy_operations {
 /*
  *	Externally visible interface
  */
-void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb, struct msghdr *msg)
+void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb)
 {
-	if (msg->msg_control = NULL || msg->msg_controllen != sizeof(__u32))
-		skb->priority = 0;	/* implies lowest-possible priority */
-	else
-		skb->priority = get_unaligned((__u32 *)msg->msg_control);
-
 	qpol_table[dccp_sk(sk)->dccps_qpolicy].push(sk, skb);
 }
 
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -51,7 +51,11 @@ during an established connection are not
 defined: the "simple" policy (DCCPQ_POLICY_SIMPLE), which does nothing special,
 and a priority-based variant (DCCPQ_POLICY_PRIO). The latter allows to pass an
 u32 priority value as ancillary data to sendmsg(), where higher numbers indicate
-a higher packet priority (similar to SO_PRIORITY).
+a higher packet priority (similar to SO_PRIORITY). This ancillary data needs to
+be formatted using a cmsg(3) message header filled in as follows:
+	cmsg->cmsg_level = SOL_DCCP;
+	cmsg->cmsg_type	 = DCCP_SCM_PRIORITY;
+	cmsg->cmsg_len	 = CMSG_LEN(sizeof(uint32_t));
 
 DCCP_SOCKOPT_QPOLICY_TXQLEN sets the maximum length of the output queue. A zero
 value is always interpreted as unbounded queue length. If different from zero,
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -257,6 +257,9 @@ static void dccp_xmit_packet(struct sock
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATA;
 	}
 
+	/* Clear priority value used by the qpolicy subsystem */
+	skb->priority = 0;
+
 	err = dccp_transmit_skb(sk, skb);
 	if (err)
 		dccp_pr_debug("transmit_skb() returned err=%d\n", err);
-- 


The University of Aberdeen is a charity registered in Scotland, No SC013683.

