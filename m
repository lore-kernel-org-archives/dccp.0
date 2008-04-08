From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 17:26:39 +0000
Subject: [RFC][PATCH 8/12][NETNS][DCCPV6]: Add dummy per-net operations.
Message-Id: <47FBAACF.1060700@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

They will be responsible for ctl socket initialization, but
currently they are void.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv6.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b657dea..2ca5291 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1171,6 +1171,20 @@ static struct inet_protosw dccp_v6_protosw = {
 	.flags		= INET_PROTOSW_ICSK,
 };
 
+static int dccp_v6_init_net(struct net *net)
+{
+	return 0;
+}
+
+static void dccp_v6_exit_net(struct net *net)
+{
+}
+
+static struct pernet_operations dccp_v6_ops = {
+	.init   = dccp_v6_init_net,
+	.exit   = dccp_v6_exit_net,
+};
+
 static int __init dccp_v6_init(void)
 {
 	int err = proto_register(&dccp_v6_prot, 1);
@@ -1188,8 +1202,15 @@ static int __init dccp_v6_init(void)
 				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
 	if (err != 0)
 		goto out_unregister_protosw;
+
+	err = register_pernet_subsys(&dccp_v6_ops);
+	if (err != 0)
+		goto out_destroy_ctl_sock;
 out:
 	return err;
+
+out_destroy_ctl_sock:
+	inet_ctl_sock_destroy(dccp_v6_ctl_sk);
 out_unregister_protosw:
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
@@ -1200,6 +1221,7 @@ out_unregister_proto:
 
 static void __exit dccp_v6_exit(void)
 {
+	unregister_pernet_subsys(&dccp_v6_ops);
 	inet_ctl_sock_destroy(dccp_v6_ctl_sk);
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
-- 
1.5.3.4

