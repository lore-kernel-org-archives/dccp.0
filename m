From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 10 Dec 2005 19:28:43 +0000
Subject: [PATCH 4/6][DCCP]: Just rename dccp_v4_prot to dccp_prot
Message-Id: <39e6f6c70512101128h3e2acfdeqfe11b1696c91c7e8@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22603_33220441.1134242923644"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22603_33220441.1134242923644
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_22603_33220441.1134242923644
Content-Type: text/x-patch; name=4.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="4.patch"

tree 36f553f750bd064cb81e741810caf5663b52bc1b
parent c2cb719caa3b4ebc11fcec9f3da2739a285edaf4
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134240751 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134240751 -0200

[DCCP]: Just rename dccp_v4_prot to dccp_prot

To match TCP equivalent.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 dccp.h  |    2 +-
 ipv4.c  |    2 +-
 proto.c |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f97b85d..e711f85 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -59,7 +59,7 @@ extern void dccp_time_wait(struct sock *
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
-extern struct proto dccp_v4_prot;
+extern struct proto dccp_prot;
 
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index da11758..fd9fcbd 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1317,7 +1317,7 @@ static struct request_sock_ops dccp_requ
 	.send_reset	= dccp_v4_ctl_send_reset,
 };
 
-struct proto dccp_v4_prot = {
+struct proto dccp_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
 	.close			= dccp_close,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7b30c12..9cb2989 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -684,7 +684,7 @@ extern struct net_proto_family inet_fami
 static struct inet_protosw dccp_v4_protosw = {
 	.type		= SOCK_DCCP,
 	.protocol	= IPPROTO_DCCP,
-	.prot		= &dccp_v4_prot,
+	.prot		= &dccp_prot,
 	.ops		= &inet_dccp_ops,
 	.capability	= -1,
 	.no_check	= 0,
@@ -769,7 +769,7 @@ static int __init dccp_init(void)
 {
 	unsigned long goal;
 	int ehash_order, bhash_order, i;
-	int rc = proto_register(&dccp_v4_prot, 1);
+	int rc = proto_register(&dccp_prot, 1);
 
 	if (rc)
 		goto out;
@@ -872,7 +872,7 @@ out_free_bind_bucket_cachep:
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	dccp_hashinfo.bind_bucket_cachep = NULL;
 out_proto_unregister:
-	proto_unregister(&dccp_v4_prot);
+	proto_unregister(&dccp_prot);
 	goto out;
 }
 
@@ -895,7 +895,7 @@ static void __exit dccp_fini(void)
 		   get_order(dccp_hashinfo.ehash_size *
 			     sizeof(struct inet_ehash_bucket)));
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
-	proto_unregister(&dccp_v4_prot);
+	proto_unregister(&dccp_prot);
 }
 
 module_init(dccp_init);

------=_Part_22603_33220441.1134242923644--
