From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:10 +0000
Subject: [PATCH 3/11][DCCP] ackvec: Introduce dccp_ackvec_slab
Message-Id: <39e6f6c70602031838m266ff98csdc9011e1c8e023b@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11450_21623204.1139020690966"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11450_21623204.1139020690966
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11450_21623204.1139020690966
Content-Type: text/x-patch; name=3.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bax9m
Content-Disposition: attachment; filename="3.patch"

tree 5f23c5d6dc4e941fea9013d0b94c8bfdcc20cd96
parent 0559c9a7ed5e7ff25c931656a6d837b23b68507e
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138893615 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138893615 -0200

[DCCP] ackvec: Introduce dccp_ackvec_slab

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |   34 ++++++++++++++++++++++++++++++++--
 ackvec.h |   12 ++++++++++++
 proto.c  |    9 ++++++++-
 3 files changed, 52 insertions(+), 3 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 3483740..6440825 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -13,10 +13,16 @@
 #include "dccp.h"
 
 #include <linux/dccp.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
 #include <linux/skbuff.h>
+#include <linux/slab.h>
 
 #include <net/sock.h>
 
+static kmem_cache_t *dccp_ackvec_slab;
+
 int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -96,7 +102,7 @@ int dccp_insert_option_ackvec(struct soc
 
 struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
-	struct dccp_ackvec *av = kmalloc(sizeof(*av), priority);
+	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
 
 	if (av != NULL) {
 		av->dccpav_buf_head	=
@@ -115,7 +121,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 
 void dccp_ackvec_free(struct dccp_ackvec *av)
 {
-	kfree(av);
+	kmem_cache_free(dccp_ackvec_slab, av);
 }
 
 static inline u8 dccp_ackvec_state(const struct dccp_ackvec *av,
@@ -420,3 +426,27 @@ int dccp_ackvec_parse(struct sock *sk, c
 				        len, value);
 	return 0;
 }
+
+static char dccp_ackvec_slab_msg[] __initdata =
+	KERN_CRIT "DCCP: Unable to create ack vectors slab cache\n";
+
+int __init dccp_ackvec_init(void)
+{
+	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
+					     sizeof(struct dccp_ackvec), 0,
+					     SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (dccp_ackvec_slab == NULL) {
+		printk(dccp_ackvec_slab_msg);
+		return -ENOBUFS;
+	}
+
+	return 0;
+}
+
+void dccp_ackvec_exit(void)
+{
+	if (dccp_ackvec_slab != NULL) {
+		kmem_cache_destroy(dccp_ackvec_slab);
+		dccp_ackvec_slab = NULL;
+	}
+}
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index f083daf..470bae8 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -71,6 +71,9 @@ struct sock;
 struct sk_buff;
 
 #ifdef CONFIG_IP_DCCP_ACKVEC
+extern int dccp_ackvec_init(void);
+extern void dccp_ackvec_exit(void);
+
 extern struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
 extern void dccp_ackvec_free(struct dccp_ackvec *av);
 
@@ -89,6 +92,15 @@ static inline int dccp_ackvec_pending(co
 	return av->dccpav_sent_len != av->dccpav_vec_len;
 }
 #else /* CONFIG_IP_DCCP_ACKVEC */
+static inline int dccp_ackvec_init(void)
+{
+	return 0;
+}
+
+static inline void dccp_ackvec_exit(void)
+{
+}
+
 static inline struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
 	return NULL;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 568d266..81ad249 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -877,11 +877,17 @@ static int __init dccp_init(void)
 
 	inet_register_protosw(&dccp_v4_protosw);
 
-	rc = dccp_ctl_sock_init();
+	rc = dccp_ackvec_init();
 	if (rc)
 		goto out_unregister_protosw;
+
+	rc = dccp_ctl_sock_init();
+	if (rc)
+		goto out_ackvec_exit;
 out:
 	return rc;
+out_ackvec_exit:
+	dccp_ackvec_exit();
 out_unregister_protosw:
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_protocol, IPPROTO_DCCP);
@@ -923,6 +929,7 @@ static void __exit dccp_fini(void)
 			     sizeof(struct inet_ehash_bucket)));
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	proto_unregister(&dccp_prot);
+	dccp_ackvec_exit();
 }
 
 module_init(dccp_init);

------=_Part_11450_21623204.1139020690966--
