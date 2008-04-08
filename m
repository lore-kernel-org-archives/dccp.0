From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 17:28:36 +0000
Subject: [RFC][PATCH 11/12][NETNS][DCCPV6]: Actually create ctl socket on
Message-Id: <47FBAB44.9050901@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Move the call to inet_ctl_sock_create to init callback (and
inet_ctl_sock_destroy to exit one) and use proper ctl sock
in dccp_v6_ctl_send_reset.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv6.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 109dab3..a866690 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -295,7 +295,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
 	struct flowi fl;
-	struct sock *ctl_sk = init_net.dccp.v6_ctl_sk;
+	struct net *net = dev_net(rxskb->dst->dev);
+	struct sock *ctl_sk = net->dccp.v6_ctl_sk;
 
 	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
 		return;
@@ -1173,11 +1174,16 @@ static struct inet_protosw dccp_v6_protosw = {
 
 static int dccp_v6_init_net(struct net *net)
 {
-	return 0;
+	int err;
+
+	err = inet_ctl_sock_create(&net->dccp.v6_ctl_sk, PF_INET6,
+				   SOCK_DCCP, IPPROTO_DCCP, net);
+	return err;
 }
 
 static void dccp_v6_exit_net(struct net *net)
 {
+	inet_ctl_sock_destroy(net->dccp.v6_ctl_sk);
 }
 
 static struct pernet_operations dccp_v6_ops = {
@@ -1198,11 +1204,6 @@ static int __init dccp_v6_init(void)
 
 	inet6_register_protosw(&dccp_v6_protosw);
 
-	err = inet_ctl_sock_create(&init_net.dccp.v6_ctl_sk, PF_INET6,
-				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
-	if (err != 0)
-		goto out_unregister_protosw;
-
 	err = register_pernet_subsys(&dccp_v6_ops);
 	if (err != 0)
 		goto out_destroy_ctl_sock;
@@ -1210,8 +1211,6 @@ out:
 	return err;
 
 out_destroy_ctl_sock:
-	inet_ctl_sock_destroy(init_net.dccp.v6_ctl_sk);
-out_unregister_protosw:
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
 out_unregister_proto:
@@ -1222,7 +1221,6 @@ out_unregister_proto:
 static void __exit dccp_v6_exit(void)
 {
 	unregister_pernet_subsys(&dccp_v6_ops);
-	inet_ctl_sock_destroy(init_net.dccp.v6_ctl_sk);
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
 	proto_unregister(&dccp_v6_prot);
-- 
1.5.3.4

