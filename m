From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 09:02:57 +0000
Subject: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Message-Id: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Unlike TCP, which only needs 8 octets of original packet data, DCCP requires
minimally 12 bytes for ICMP-payload sequence number checks.

This patch replaces the insufficient length constant of 8 with a dynamic
value of __dccp_basic_hdr_len(). This is safer, since it takes into account
the switch between 24bit/48bit sequence numbers (`X' bit in RFC 4340, 5.1).

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
