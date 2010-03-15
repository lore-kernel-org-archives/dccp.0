From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Mar 2010 06:13:19 +0000
Subject: net-2.6 [Bug-Fix][dccp]: fix oops caused after failed
Message-Id: <20100315061318.GA6110@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: fix panic caused by failed initialisation

This fixes a kernel panic reported thanks to Andre Noll:

if DCCP is compiled into the kernel and any out of the initialisation
steps in net/dccp/proto.c:dccp_init() fail, a subsequent attempt to create
a SOCK_DCCP socket will panic, since inet{,6}_create() are not prevented
from creating DCCP sockets.

This patch fixes the problem by propagating a failure in dccp_init() to
dccp_v{4,6}_init_net(), and from there to dccp_v{4,6}_init(), so that the
DCCP protocol is not made available if its initialisation fails.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c  |    8 ++++----
 net/dccp/ipv6.c  |    8 ++++----
 net/dccp/proto.c |   16 +++++++++-------
 3 files changed, 17 insertions(+), 15 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -998,11 +998,11 @@ static struct inet_protosw dccp_v4_proto
 
 static int __net_init dccp_v4_init_net(struct net *net)
 {
-	int err;
+	if (dccp_hashinfo.bhash = NULL)
+		return -ESOCKTNOSUPPORT;
 
-	err = inet_ctl_sock_create(&net->dccp.v4_ctl_sk, PF_INET,
-				   SOCK_DCCP, IPPROTO_DCCP, net);
-	return err;
+	return inet_ctl_sock_create(&net->dccp.v4_ctl_sk, PF_INET,
+				    SOCK_DCCP, IPPROTO_DCCP, net);
 }
 
 static void __net_exit dccp_v4_exit_net(struct net *net)
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1191,11 +1191,11 @@ static struct inet_protosw dccp_v6_proto
 
 static int __net_init dccp_v6_init_net(struct net *net)
 {
-	int err;
+	if (dccp_hashinfo.bhash = NULL)
+		return -ESOCKTNOSUPPORT;
 
-	err = inet_ctl_sock_create(&net->dccp.v6_ctl_sk, PF_INET6,
-				   SOCK_DCCP, IPPROTO_DCCP, net);
-	return err;
+	return inet_ctl_sock_create(&net->dccp.v6_ctl_sk, PF_INET6,
+				    SOCK_DCCP, IPPROTO_DCCP, net);
 }
 
 static void __net_exit dccp_v6_exit_net(struct net *net)
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1036,7 +1036,7 @@ static int __init dccp_init(void)
 		     FIELD_SIZEOF(struct sk_buff, cb));
 	rc = percpu_counter_init(&dccp_orphan_count, 0);
 	if (rc)
-		goto out;
+		goto out_fail;
 	rc = -ENOBUFS;
 	inet_hashinfo_init(&dccp_hashinfo);
 	dccp_hashinfo.bind_bucket_cachep @@ -1125,8 +1125,9 @@ static int __init dccp_init(void)
 		goto out_sysctl_exit;
 
 	dccp_timestamping_init();
-out:
-	return rc;
+
+	return 0;
+
 out_sysctl_exit:
 	dccp_sysctl_exit();
 out_ackvec_exit:
@@ -1135,18 +1136,19 @@ out_free_dccp_mib:
 	dccp_mib_exit();
 out_free_dccp_bhash:
 	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
-	dccp_hashinfo.bhash = NULL;
 out_free_dccp_locks:
 	inet_ehash_locks_free(&dccp_hashinfo);
 out_free_dccp_ehash:
 	free_pages((unsigned long)dccp_hashinfo.ehash, ehash_order);
-	dccp_hashinfo.ehash = NULL;
 out_free_bind_bucket_cachep:
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
-	dccp_hashinfo.bind_bucket_cachep = NULL;
 out_free_percpu:
 	percpu_counter_destroy(&dccp_orphan_count);
-	goto out;
+out_fail:
+	dccp_hashinfo.bhash = NULL;
+	dccp_hashinfo.ehash = NULL;
+	dccp_hashinfo.bind_bucket_cachep = NULL;
+	return rc;
 }
 
 static void __exit dccp_fini(void)
