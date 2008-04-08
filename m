From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:57:58 +0000
Subject: [RFC][PATCH 5/12][NETNS][DCCPV4]: Use proper net to route the reset
Message-Id: <47FBA97B.8050309@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The dccp_v4_route_skb used in dccp_v4_ctl_send_reset, currently
works with init_net's routing tables - fix it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index cad62d8..11d0b85 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -445,7 +445,7 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	return sk;
 }
 
-static struct dst_entry* dccp_v4_route_skb(struct sock *sk,
+static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
@@ -462,7 +462,7 @@ static struct dst_entry* dccp_v4_route_skb(struct sock *sk,
 			  };
 
 	security_skb_classify_flow(skb, &fl);
-	if (ip_route_output_flow(&init_net, &rt, &fl, sk, 0)) {
+	if (ip_route_output_flow(net, &rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
@@ -515,7 +515,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (rxskb->rtable->rt_type != RTN_LOCAL)
 		return;
 
-	dst = dccp_v4_route_skb(ctl_sk, rxskb);
+	dst = dccp_v4_route_skb(net, ctl_sk, rxskb);
 	if (dst = NULL)
 		return;
 
-- 
1.5.3.4

