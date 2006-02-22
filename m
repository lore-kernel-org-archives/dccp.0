From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 22 Feb 2006 21:38:41 +0000
Subject: [PATCH 4/4] [DCCP] feat: Introduce sysctls for the default features
Message-Id: <11406443213608-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[root@qemu ~]# for a in /proc/sys/net/dccp/default/* ; do echo $a ; cat $a ; done
/proc/sys/net/dccp/default/ack_ratio
2
/proc/sys/net/dccp/default/rx_ccid
3
/proc/sys/net/dccp/default/send_ackvec
1
/proc/sys/net/dccp/default/send_ndp
1
/proc/sys/net/dccp/default/seq_window
100
/proc/sys/net/dccp/default/tx_ccid
3
[root@qemu ~]#

So if wanting to test ccid3 as the tx CCID one can just do:

[root@qemu ~]# echo 3 > /proc/sys/net/dccp/default/tx_ccid
[root@qemu ~]# echo 2 > /proc/sys/net/dccp/default/rx_ccid
[root@qemu ~]# cat /proc/sys/net/dccp/default/[tr]x_ccid
2
3
[root@qemu ~]#

Of course we also need the setsockopt for each app to tell its preferences, but
for testing or defining something other than CCID2 as the default for apps that
don't explicitely set their preference the sysctl interface is handy.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 include/linux/sysctl.h |   16 ++++++
 net/dccp/Makefile      |    2 +
 net/dccp/dccp.h        |   14 +++++
 net/dccp/options.c     |   22 +++++----
 net/dccp/proto.c       |    9 +++
 net/dccp/sysctl.c      |  124 ++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 176 insertions(+), 11 deletions(-)
 create mode 100644 net/dccp/sysctl.c

df0bb8f0450110107ef4c4dc641b3e626e750565
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 42ebee8..195e936 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -209,6 +209,7 @@ enum
 	NET_SCTP,
 	NET_LLC,
 	NET_NETFILTER,
+	NET_DCCP ,
 };
 
 /* /proc/sys/kernel/random */
@@ -569,6 +570,21 @@ enum {
 	__NET_NEIGH_MAX
 };
 
+/* /proc/sys/net/dccp */
+enum {
+	NET_DCCP_DEFAULT=1,
+};
+
+/* /proc/sys/net/dccp/default */
+enum {
+	NET_DCCP_DEFAULT_SEQ_WINDOW  = 1,
+	NET_DCCP_DEFAULT_RX_CCID     = 2,
+	NET_DCCP_DEFAULT_TX_CCID     = 3,
+	NET_DCCP_DEFAULT_ACK_RATIO   = 4,
+	NET_DCCP_DEFAULT_SEND_ACKVEC = 5,
+	NET_DCCP_DEFAULT_SEND_NDP    = 6,
+};
+
 /* /proc/sys/net/ipx */
 enum {
 	NET_IPX_PPROP_BROADCASTING=1,
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 5736ace..7af0569 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -11,6 +11,8 @@ dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.
 
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 
+dccp-$(CONFIG_SYSCTL) += sysctl.o
+
 dccp_diag-y := diag.o
 
 obj-y += ccids/
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 1764adb..f059541 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -433,4 +433,18 @@ static inline void timeval_sub_usecs(str
 	}
 }
 
+#ifdef CONFIG_SYSCTL
+extern int dccp_sysctl_init(void);
+extern void dccp_sysctl_exit(void);
+#else
+static inline int dccp_sysctl_init(void)
+{
+	return 0;
+}
+
+static inline void dccp_sysctl_exit(void)
+{
+}
+#endif
+
 #endif /* _DCCP_H */
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 7d73b33..3ecd319 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -23,19 +23,21 @@
 #include "dccp.h"
 #include "feat.h"
 
-/* stores the default values for new connection. may be changed with sysctl */
-static const struct dccp_options dccpo_default_values = {
-	.dccpo_sequence_window	  = DCCPF_INITIAL_SEQUENCE_WINDOW,
-	.dccpo_rx_ccid		  = DCCPF_INITIAL_CCID,
-	.dccpo_tx_ccid		  = DCCPF_INITIAL_CCID,
-	.dccpo_ack_ratio	  = DCCPF_INITIAL_ACK_RATIO,
-	.dccpo_send_ack_vector	  = DCCPF_INITIAL_SEND_ACK_VECTOR,
-	.dccpo_send_ndp_count	  = DCCPF_INITIAL_SEND_NDP_COUNT,
-};
+int dccp_feat_default_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
+int dccp_feat_default_rx_ccid	      = DCCPF_INITIAL_CCID;
+int dccp_feat_default_tx_ccid	      = DCCPF_INITIAL_CCID;
+int dccp_feat_default_ack_ratio	      = DCCPF_INITIAL_ACK_RATIO;
+int dccp_feat_default_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
+int dccp_feat_default_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
 void dccp_options_init(struct dccp_options *dccpo)
 {
-	memcpy(dccpo, &dccpo_default_values, sizeof(*dccpo));
+	dccpo->dccpo_sequence_window = dccp_feat_default_sequence_window;
+	dccpo->dccpo_rx_ccid	     = dccp_feat_default_rx_ccid;
+	dccpo->dccpo_tx_ccid	     = dccp_feat_default_tx_ccid;
+	dccpo->dccpo_ack_ratio	     = dccp_feat_default_ack_ratio;
+	dccpo->dccpo_send_ack_vector = dccp_feat_default_send_ack_vector;
+	dccpo->dccpo_send_ndp_count  = dccp_feat_default_send_ndp_count;
 }
 
 static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 1e9fdf6..04315c3 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -934,11 +934,17 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_unregister_protosw;
 
-	rc = dccp_ctl_sock_init();
+	rc = dccp_sysctl_init();
 	if (rc)
 		goto out_ackvec_exit;
+
+	rc = dccp_ctl_sock_init();
+	if (rc)
+		goto out_sysctl_exit;
 out:
 	return rc;
+out_sysctl_exit:
+	dccp_sysctl_exit();
 out_ackvec_exit:
 	dccp_ackvec_exit();
 out_unregister_protosw:
@@ -983,6 +989,7 @@ static void __exit dccp_fini(void)
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	proto_unregister(&dccp_prot);
 	dccp_ackvec_exit();
+	dccp_sysctl_exit();
 }
 
 module_init(dccp_init);
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
new file mode 100644
index 0000000..64c89e9
--- /dev/null
+++ b/net/dccp/sysctl.c
@@ -0,0 +1,124 @@
+/*
+ *  net/dccp/sysctl.c
+ *
+ *  An implementation of the DCCP protocol
+ *  Arnaldo Carvalho de Melo <acme@mandriva.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License v2
+ *	as published by the Free Software Foundation.
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/sysctl.h>
+
+#ifndef CONFIG_SYSCTL
+#error This file should not be compiled without CONFIG_SYSCTL defined
+#endif
+
+extern int dccp_feat_default_sequence_window;
+extern int dccp_feat_default_rx_ccid;
+extern int dccp_feat_default_tx_ccid;
+extern int dccp_feat_default_ack_ratio;
+extern int dccp_feat_default_send_ack_vector;
+extern int dccp_feat_default_send_ndp_count;
+
+static struct ctl_table dccp_default_table[] = {
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_SEQ_WINDOW,
+		.procname	= "seq_window",
+		.data		= &dccp_feat_default_sequence_window,
+		.maxlen		= sizeof(dccp_feat_default_sequence_window),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_RX_CCID,
+		.procname	= "rx_ccid",
+		.data		= &dccp_feat_default_rx_ccid,
+		.maxlen		= sizeof(dccp_feat_default_rx_ccid),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_TX_CCID,
+		.procname	= "tx_ccid",
+		.data		= &dccp_feat_default_tx_ccid,
+		.maxlen		= sizeof(dccp_feat_default_tx_ccid),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_ACK_RATIO,
+		.procname	= "ack_ratio",
+		.data		= &dccp_feat_default_ack_ratio,
+		.maxlen		= sizeof(dccp_feat_default_ack_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_SEND_ACKVEC,
+		.procname	= "send_ackvec",
+		.data		= &dccp_feat_default_send_ack_vector,
+		.maxlen		= sizeof(dccp_feat_default_send_ack_vector),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_SEND_NDP,
+		.procname	= "send_ndp",
+		.data		= &dccp_feat_default_send_ndp_count,
+		.maxlen		= sizeof(dccp_feat_default_send_ndp_count),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{ .ctl_name = 0, }
+};
+
+static struct ctl_table dccp_table[] = {
+	{
+		.ctl_name	= NET_DCCP_DEFAULT,
+		.procname	= "default",
+		.mode		= 0555,
+		.child		= dccp_default_table,
+	},
+	{ .ctl_name = 0, },
+};
+
+static struct ctl_table dccp_dir_table[] = {
+	{
+		.ctl_name	= NET_DCCP,
+		.procname	= "dccp",
+		.mode		= 0555,
+		.child		= dccp_table,
+	},
+	{ .ctl_name = 0, },
+};
+
+static struct ctl_table dccp_root_table[] = {
+	{
+		.ctl_name	= CTL_NET,
+		.procname	= "net",
+		.mode		= 0555,
+		.child		= dccp_dir_table,
+	},
+	{ .ctl_name = 0, },
+};
+
+static struct ctl_table_header *dccp_table_header;
+
+int __init dccp_sysctl_init(void)
+{
+	dccp_table_header = register_sysctl_table(dccp_root_table, 1);
+
+	return dccp_table_header != NULL ? 0 : -ENOMEM;
+}
+
+void dccp_sysctl_exit(void)
+{
+	if (dccp_table_header != NULL) {
+		unregister_sysctl_table(dccp_table_header);
+		dccp_table_header = NULL;
+	}
+}
-- 
1.1.GIT


