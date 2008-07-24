From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 24 Jul 2008 08:51:15 +0000
Subject: [PATCH 4/4] DCCP: Add check for missing sequence number in ICMPv6
Message-Id: <48884283.8070705@cn.fujitsu.com>
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

diff -Nurp a/net/dccp/ipv6.c b/net/dccp/ipv6.c
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -95,6 +95,12 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	__u64 seq;
 
+	if (skb->len < offset + 12 ||
+	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
+		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP_MIB_INERRORS);
+		return;
+	}
+
 	sk = inet6_lookup(dev_net(skb->dev), &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));



