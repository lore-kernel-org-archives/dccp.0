From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:56:14 +0000
Subject: [RFC][PATCH 4/12][NETNS][DCCPV4]: Actually create ctl socket on each
Message-Id: <47FBA923.6070807@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Move the call to inet_ctl_sock_create to init callback (and
inet_ctl_sock_destroy to exit one) and use proper ctl sock
in dccp_v4_ctl_send_reset.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 85931dc..cad62d8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -505,7 +505,8 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	const struct iphdr *rxiph;
 	struct sk_buff *skb;
 	struct dst_entry *dst;
-	struct sock *ctl_sk = init_net.dccp.v4_ctl_sk;
+	struct net *net = dev_net(rxskb->dst->dev);
+	struct sock *ctl_sk = net->dccp.v4_ctl_sk;
 
 	/* Never send a reset in response to a reset. */
 	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
@@ -991,11 +992,16 @@ static struct inet_protosw dccp_v4_protosw = {
 
 static int dccp_v4_init_net(struct net *net)
 {
-	return 0;
+	int err;
+
+	err = inet_ctl_sock_create(&net->dccp.v4_ctl_sk, PF_INET,
+				   SOCK_DCCP, IPPROTO_DCCP, net);
+	return err;
 }
 
 static void dccp_v4_exit_net(struct net *net)
 {
+	inet_ctl_sock_destroy(net->dccp.v4_ctl_sk);
 }
 
 static struct pernet_operations dccp_v4_ops = {
@@ -1016,19 +1022,12 @@ static int __init dccp_v4_init(void)
 
 	inet_register_protosw(&dccp_v4_protosw);
 
-	err = inet_ctl_sock_create(&init_net.dccp.v4_ctl_sk, PF_INET,
-				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
-	if (err)
-		goto out_unregister_protosw;
-
 	err = register_pernet_subsys(&dccp_v4_ops);
 	if (err)
 		goto out_destroy_ctl_sock;
 out:
 	return err;
 out_destroy_ctl_sock:
-	inet_ctl_sock_destroy(init_net.dccp.v4_ctl_sk);
-out_unregister_protosw:
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 out_proto_unregister:
@@ -1039,7 +1038,6 @@ out_proto_unregister:
 static void __exit dccp_v4_exit(void)
 {
 	unregister_pernet_subsys(&dccp_v4_ops);
-	inet_ctl_sock_destroy(init_net.dccp.v4_ctl_sk);
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	proto_unregister(&dccp_v4_prot);
-- 
1.5.3.4

