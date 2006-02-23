From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 6/7] [DCCP]: Rename init_dccp_v4_mibs to dccp_mib_init
Message-Id: <114073277898-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

And introduce dccp_mib_exit grouping previously open coded sequence.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/proto.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

2250710f2979bf1e47bba2f6e3fcadfd9a686071
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a57a8b6..c048d5b 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -933,7 +933,7 @@ void dccp_ctl_sock_exit(void)
 EXPORT_SYMBOL_GPL(dccp_ctl_sock_exit);
 #endif
 
-static int __init init_dccp_v4_mibs(void)
+static int __init dccp_mib_init(void)
 {
 	int rc = -ENOMEM;
 
@@ -955,6 +955,13 @@ out_free_one:
 
 }
 
+static int dccp_mib_exit(void)
+{
+	free_percpu(dccp_statistics[0]);
+	free_percpu(dccp_statistics[1]);
+	dccp_statistics[0] = dccp_statistics[1] = NULL;
+}
+
 static int thash_entries;
 module_param(thash_entries, int, 0444);
 MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
@@ -1044,7 +1051,7 @@ static int __init dccp_init(void)
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
 
-	rc = init_dccp_v4_mibs();
+	rc = dccp_mib_init();
 	if (rc)
 		goto out_free_dccp_bhash;
 
@@ -1075,9 +1082,7 @@ out_unregister_protosw:
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_protocol, IPPROTO_DCCP);
 out_free_dccp_v4_mibs:
-	free_percpu(dccp_statistics[0]);
-	free_percpu(dccp_statistics[1]);
-	dccp_statistics[0] = dccp_statistics[1] = NULL;
+	dccp_mib_exit();
 out_free_dccp_bhash:
 	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
 	dccp_hashinfo.bhash = NULL;
@@ -1102,8 +1107,7 @@ static void __exit dccp_fini(void)
 	if (inet_del_protocol(&dccp_protocol, IPPROTO_DCCP) < 0)
 		printk(dccp_del_proto_err_msg);
 
-	free_percpu(dccp_statistics[0]);
-	free_percpu(dccp_statistics[1]);
+	dccp_mib_exit();
 	free_pages((unsigned long)dccp_hashinfo.bhash,
 		   get_order(dccp_hashinfo.bhash_size *
 			     sizeof(struct inet_bind_hashbucket)));
-- 
1.2.2.gd27d


