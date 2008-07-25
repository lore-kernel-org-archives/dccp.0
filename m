From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 02:38:33 +0000
Subject: [PATCHv2 2/4] DCCP: Add check for sequence number in ICMPv6 message
Message-Id: <48893CA9.6020500@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RFC4340 said:
  ICMP Datagram Too Big messages with incorrect or missing Sequence
Numbers may be ignored, or the DCCP implementation may lower the PMTU
only temporarily in response.

This patch add the check for sequence number in ICMPv6 message.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/ipv6.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3bc6656..c9b32a8 100644
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



