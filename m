From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:53:20 +0000
Subject: [RFC][PATCH 2/12][NETNS][DCCPV4]: Add dummy per-net operations.
Message-Id: <47FBA877.7070601@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

They will be responsible for ctl socket initialization, but
currently they are void.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b12803b..10bba03 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -989,6 +989,20 @@ static struct inet_protosw dccp_v4_protosw = {
 	.flags		= INET_PROTOSW_ICSK,
 };
 
+static int dccp_v4_init_net(struct net *net)
+{
+	return 0;
+}
+
+static void dccp_v4_exit_net(struct net *net)
+{
+}
+
+static struct pernet_operations dccp_v4_ops = {
+	.init	= dccp_v4_init_net,
+	.exit	= dccp_v4_exit_net,
+};
+
 static int __init dccp_v4_init(void)
 {
 	int err = proto_register(&dccp_v4_prot, 1);
@@ -1006,8 +1020,14 @@ static int __init dccp_v4_init(void)
 				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
 	if (err)
 		goto out_unregister_protosw;
+
+	err = register_pernet_subsys(&dccp_v4_ops);
+	if (err)
+		goto out_destroy_ctl_sock;
 out:
 	return err;
+out_destroy_ctl_sock:
+	inet_ctl_sock_destroy(dccp_v4_ctl_sk);
 out_unregister_protosw:
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
@@ -1018,6 +1038,7 @@ out_proto_unregister:
 
 static void __exit dccp_v4_exit(void)
 {
+	unregister_pernet_subsys(&dccp_v4_ops);
 	inet_ctl_sock_destroy(dccp_v4_ctl_sk);
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
-- 
1.5.3.4

