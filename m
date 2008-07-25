From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 09:02:56 +0000
Subject: [PATCH 4/6] dccp: Add check for sequence number in ICMPv6 message
Message-Id: <1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

This adds a sequence number check for ICMPv6 DCCP error packets, in the same
manner as it has been done for ICMPv4 in the previous patch.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv6.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -89,6 +89,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	struct ipv6hdr *hdr = (struct ipv6hdr *)skb->data;
 	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
+	struct dccp_sock *dp;
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
@@ -116,6 +117,14 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (sk->sk_state = DCCP_CLOSED)
 		goto out;
 
+	dp = dccp_sk(sk);
+	seq = dccp_hdr_seq(dh);
+	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
+	    !between48(seq, dp->dccps_awl, dp->dccps_awh)) {
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+		goto out;
+	}
+
 	np = inet6_sk(sk);
 
 	if (type = ICMPV6_PKT_TOOBIG) {
@@ -168,7 +177,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	icmpv6_err_convert(type, code, &err);
 
-	seq = dccp_hdr_seq(dh);
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
 		struct request_sock *req, **prev;
