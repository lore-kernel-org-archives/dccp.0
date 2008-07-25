From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 02:40:32 +0000
Subject: [PATCHv2 3/4] DCCP: Fix to check missing sequence number for ICMP
Message-Id: <48893D20.6020609@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

If we want check the sequence number, the length of dccp packet must not
less than __dccp_basic_hdr_len(dh). If the length of dccp packet is less
than this value, check for sequence number will get unpredictable result.

This patch fix the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8fd4d57..0c5f82d 100644
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




