From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Nov 2016 03:30:48 +0000
Subject: [PATCH net] ipv6: dccp: fix out of bound access in dccp_v6_err()
Message-Id: <1478143848.7065.429.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

dccp_v6_err() does not use pskb_may_pull() and might access garbage.

We only need 4 bytes at the beginning of the DCCP header, like TCP,
so the 8 bytes pulled in icmpv6_notify() are more than enough.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv6.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3828f94b234c..3d35277a0b41 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -70,7 +70,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			u8 type, u8 code, int offset, __be32 info)
 {
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
-	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
+	const struct dccp_hdr *dh;
 	struct dccp_sock *dp;
 	struct ipv6_pinfo *np;
 	struct sock *sk;
@@ -78,12 +78,13 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u64 seq;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < offset + sizeof(*dh) ||
-	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
-				  ICMP6_MIB_INERRORS);
-		return;
-	}
+	/* Only need dccph_dport & dccph_sport which are the first
+	 * 4 bytes in dccp header.
+	 * Our caller (icmpv6_notify()) already pulled 8 bytes for us.
+	 */
+	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_sport) > 8);
+	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
+	dh = (struct dccp_hdr *)(skb->data + offset);
 
 	sk = __inet6_lookup_established(net, &dccp_hashinfo,
 					&hdr->daddr, dh->dccph_dport,


