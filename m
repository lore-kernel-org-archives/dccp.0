From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:54:35 +0000
Subject: [RFC][PATCH 3/12][NETNS][DCCPV4]: Move the dccp_v4_ctl_sk on the
Message-Id: <47FBA8C2.6090601@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

And replace all its usage with init_net's socket.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/netns/dccp.h |    3 +++
 net/dccp/ipv4.c          |   20 ++++++++++----------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/dccp.h b/include/net/netns/dccp.h
index 056e6ad..e4f16fa 100644
--- a/include/net/netns/dccp.h
+++ b/include/net/netns/dccp.h
@@ -1,7 +1,10 @@
 #ifndef __NETNS_DCCP_H__
 #define __NETNS_DCCP_H__
 
+struct sock;
+
 struct netns_dccp {
+	struct sock *v4_ctl_sk;
 };
 
 #endif
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 10bba03..85931dc 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -32,11 +32,10 @@
 #include "feat.h"
 
 /*
- * This is the global socket data structure used for responding to
+ * The dccp_ctl_sk is the global socket data structure used for responding to
  * the Out-of-the-blue (OOTB) packets. A control sock will be created
  * for this socket at the initialization time.
  */
-static struct sock *dccp_v4_ctl_sk;
 
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -506,6 +505,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	const struct iphdr *rxiph;
 	struct sk_buff *skb;
 	struct dst_entry *dst;
+	struct sock *ctl_sk = init_net.dccp.v4_ctl_sk;
 
 	/* Never send a reset in response to a reset. */
 	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
@@ -514,11 +514,11 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (rxskb->rtable->rt_type != RTN_LOCAL)
 		return;
 
-	dst = dccp_v4_route_skb(dccp_v4_ctl_sk, rxskb);
+	dst = dccp_v4_route_skb(ctl_sk, rxskb);
 	if (dst = NULL)
 		return;
 
-	skb = dccp_ctl_make_reset(dccp_v4_ctl_sk, rxskb);
+	skb = dccp_ctl_make_reset(ctl_sk, rxskb);
 	if (skb = NULL)
 		goto out;
 
@@ -527,10 +527,10 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 								 rxiph->daddr);
 	skb->dst = dst_clone(dst);
 
-	bh_lock_sock(dccp_v4_ctl_sk);
-	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_sk,
+	bh_lock_sock(ctl_sk);
+	err = ip_build_and_send_pkt(skb, ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
-	bh_unlock_sock(dccp_v4_ctl_sk);
+	bh_unlock_sock(ctl_sk);
 
 	if (net_xmit_eval(err) = 0) {
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
@@ -1016,7 +1016,7 @@ static int __init dccp_v4_init(void)
 
 	inet_register_protosw(&dccp_v4_protosw);
 
-	err = inet_ctl_sock_create(&dccp_v4_ctl_sk, PF_INET,
+	err = inet_ctl_sock_create(&init_net.dccp.v4_ctl_sk, PF_INET,
 				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
 	if (err)
 		goto out_unregister_protosw;
@@ -1027,7 +1027,7 @@ static int __init dccp_v4_init(void)
 out:
 	return err;
 out_destroy_ctl_sock:
-	inet_ctl_sock_destroy(dccp_v4_ctl_sk);
+	inet_ctl_sock_destroy(init_net.dccp.v4_ctl_sk);
 out_unregister_protosw:
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
@@ -1039,7 +1039,7 @@ out_proto_unregister:
 static void __exit dccp_v4_exit(void)
 {
 	unregister_pernet_subsys(&dccp_v4_ops);
-	inet_ctl_sock_destroy(dccp_v4_ctl_sk);
+	inet_ctl_sock_destroy(init_net.dccp.v4_ctl_sk);
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	proto_unregister(&dccp_v4_prot);
-- 
1.5.3.4

