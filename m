From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 02:41:22 +0000
Subject: [PATCHv2 4/4] DCCP: Add check for missing sequence number in ICMPv6
Message-Id: <48893D52.9090408@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RFC4340 said:
  ICMP Datagram Too Big messages with incorrect or missing Sequence
Numbers may be ignored, or the DCCP implementation may lower the PMTU
only temporarily in response.

This patch add the check for missing sequence number in ICMPv6 message.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/ipv6.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c9b32a8..bc5e305 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -96,6 +96,11 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u64 seq;
 	struct net *net = dev_net(skb->dev);
 
+	if (skb->len < offset + __dccp_basic_hdr_len(dh)) {	
+		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+		return;
+	}
+
 	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));



