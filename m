From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 17:30:08 +0000
Subject: [RFC][PATCH 12/12][NETNS][DCCPV6]: Make per-net socket lookup.
Message-Id: <47FBABA0.8050209@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The inet6_lookup family of functions requires a net to lookup
a socket in, so give a proper one to them.

No more things to do for dccpv6, since routing is OK and the
ipv4-like transport layer filtering is not done for ipv6.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv6.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index a866690..94e0c94 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -94,7 +94,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	__u64 seq;
 
-	sk = inet6_lookup(&init_net, &dccp_hashinfo, &hdr->daddr, dh->dccph_dport,
+	sk = inet6_lookup(dev_net(skb->dev), &dccp_hashinfo,
+			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
 
 	if (sk = NULL) {
@@ -359,7 +360,7 @@ static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 	if (req != NULL)
 		return dccp_check_req(sk, skb, req, prev);
 
-	nsk = __inet6_lookup_established(&init_net, &dccp_hashinfo,
+	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
 					 &iph->saddr, dh->dccph_sport,
 					 &iph->daddr, ntohs(dh->dccph_dport),
 					 inet6_iif(skb));
@@ -790,8 +791,8 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet6_lookup(&init_net, &dccp_hashinfo, &ipv6_hdr(skb)->saddr,
-			    dh->dccph_sport,
+	sk = __inet6_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
+			    &ipv6_hdr(skb)->saddr, dh->dccph_sport,
 			    &ipv6_hdr(skb)->daddr, ntohs(dh->dccph_dport),
 			    inet6_iif(skb));
 	/*
-- 
1.5.3.4

