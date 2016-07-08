From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jul 2016 09:03:57 +0000
Subject: [PATCH net] dccp: avoid deadlock in dccp_v4_ctl_send_reset
Message-Id: <1467968637.17638.44.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

In the prep work I did before enabling BH while handling socket backlog,
I missed two points in DCCP :

1) dccp_v4_ctl_send_reset() uses bh_lock_sock(), assuming BH were
blocked. It is not anymore always true.

2) dccp_v4_route_skb() was using __IP_INC_STATS() instead of
  IP_INC_STATS()

A similar fix was done for TCP, in commit 47dcc20a39d0
("ipv4: tcp: ip_send_unicast_reply() is not BH safe")

Fixes: 7309f8821fd6 ("dccp: do not assume DCCP code is non preemptible")
Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/dccp/ipv4.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5c7e413a3ae407e67565b48a8bd6f43e3b02de4d..25dd25b47d4163625e092c8b96715bb709d85891 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -462,7 +462,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt)) {
-		__IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
+		IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 
@@ -527,17 +527,19 @@ static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 								 rxiph->daddr);
 	skb_dst_set(skb, dst_clone(dst));
 
+	local_bh_disable();
 	bh_lock_sock(ctl_sk);
 	err = ip_build_and_send_pkt(skb, ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
 	bh_unlock_sock(ctl_sk);
 
 	if (net_xmit_eval(err) = 0) {
-		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
-		DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 	}
+	local_bh_enable();
 out:
-	 dst_release(dst);
+	dst_release(dst);
 }
 
 static void dccp_v4_reqsk_destructor(struct request_sock *req)


