From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:58:58 +0000
Subject: [RFC][PATCH 6/12][NETNS][DCCPV4]: Make per-net socket lookup.
Message-Id: <47FBA9C7.5010408@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The inet_lookup family of functions requires a net to lookup
a socket in, so give a proper one to them.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 11d0b85..66f860b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -211,8 +211,9 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 
-	sk = inet_lookup(&init_net, &dccp_hashinfo, iph->daddr, dh->dccph_dport,
-			 iph->saddr, dh->dccph_sport, inet_iif(skb));
+	sk = inet_lookup(dev_net(skb->dev), &dccp_hashinfo,
+			iph->daddr, dh->dccph_dport,
+			iph->saddr, dh->dccph_sport, inet_iif(skb));
 	if (sk = NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
@@ -429,7 +430,7 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	if (req != NULL)
 		return dccp_check_req(sk, skb, req, prev);
 
-	nsk = inet_lookup_established(&init_net, &dccp_hashinfo,
+	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
 				      iph->saddr, dh->dccph_sport,
 				      iph->daddr, dh->dccph_dport,
 				      inet_iif(skb));
@@ -810,7 +811,7 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet_lookup(&init_net, &dccp_hashinfo,
+	sk = __inet_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
 			   iph->saddr, dh->dccph_sport,
 			   iph->daddr, dh->dccph_dport, inet_iif(skb));
 	/*
-- 
1.5.3.4

