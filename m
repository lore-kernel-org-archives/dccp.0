From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 14:30:33 +0000
Subject: v2 [PATCH 6/7] dccp: Fix incorrect length check for ICMPv4 packets
Message-Id: <20080725143033.GC7422@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Unlike TCP, which only needs 8 octets of original packet data, DCCP requires
minimally 12 or 16 bytes for ICMP-payload sequence number checks.

This patch replaces the insufficient length constant of 8 with a dynamic
value, using the routine introduced previously.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -196,8 +196,8 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 static void dccp_v4_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (struct iphdr *)skb->data;
-	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data +
-							(iph->ihl << 2));
+	const u8 offset = (iph->ihl << 2);
+	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
 	struct dccp_sock *dp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(skb)->type;
@@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (dccp_skb_too_short(skb, offset)) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
