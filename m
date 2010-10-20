From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 20 Oct 2010 02:54:36 +0000
Subject: [PATCH] net: make ctl_path local and const
Message-Id: <1287543276-4511-1-git-send-email-xiaosuo@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/appletalk/sysctl_net_atalk.c        |   12 ++++++------
 net/ax25/sysctl_net_ax25.c              |   11 +++++------
 net/bridge/br_netfilter.c               |   13 +++++++------
 net/dccp/sysctl.c                       |   14 +++++++-------
 net/decnet/sysctl_net_decnet.c          |   12 ++++++------
 net/ipv4/devinet.c                      |   10 +++++-----
 net/ipv4/route.c                        |   25 ++++++++++++-------------
 net/ipx/sysctl_net_ipx.c                |   11 +++++------
 net/irda/irsysctl.c                     |   12 ++++++------
 net/llc/sysctl_net_llc.c                |   12 ++++++------
 net/netfilter/nf_conntrack_standalone.c |    9 ++++-----
 net/netfilter/nf_log.c                  |   15 +++++++--------
 net/netrom/sysctl_net_netrom.c          |   12 ++++++------
 net/phonet/sysctl.c                     |   12 ++++++------
 net/rds/ib_sysctl.c                     |   17 +++++++++--------
 net/rds/iw_sysctl.c                     |   17 +++++++++--------
 net/rds/sysctl.c                        |   16 ++++++++--------
 net/rose/sysctl_net_rose.c              |   12 ++++++------
 net/sctp/sysctl.c                       |   12 ++++++------
 net/unix/sysctl_net_unix.c              |   11 +++++------
 net/x25/sysctl_net_x25.c                |   12 ++++++------
 21 files changed, 137 insertions(+), 140 deletions(-)
diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 04e9c0d..b92f269 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -42,16 +42,16 @@ static struct ctl_table atalk_table[] = {
 	{ },
 };
 
-static struct ctl_path atalk_path[] = {
-	{ .procname = "net", },
-	{ .procname = "appletalk", },
-	{ }
-};
-
 static struct ctl_table_header *atalk_table_header;
 
 void atalk_register_sysctl(void)
 {
+	const struct ctl_path atalk_path[] = {
+		{ .procname = "net", },
+		{ .procname = "appletalk", },
+		{ }
+	};
+
 	atalk_table_header = register_sysctl_paths(atalk_path, atalk_table);
 }
 
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index ebe0ef3..6d461ae 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -34,12 +34,6 @@ static struct ctl_table_header *ax25_table_header;
 static ctl_table *ax25_table;
 static int ax25_table_size;
 
-static struct ctl_path ax25_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ax25", },
-	{ }
-};
-
 static const ctl_table ax25_param_table[] = {
 	{
 		.procname	= "ip_default_mode",
@@ -163,6 +157,11 @@ void ax25_register_sysctl(void)
 {
 	ax25_dev *ax25_dev;
 	int n, k;
+	const struct ctl_path ax25_path[] = {
+		{ .procname = "net", },
+		{ .procname = "ax25", },
+		{ }
+	};
 
 	spin_lock_bh(&ax25_dev_lock);
 	for (ax25_table_size = sizeof(ctl_table), ax25_dev = ax25_dev_list; ax25_dev != NULL; ax25_dev = ax25_dev->next)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 7f9ce96..6a89631 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -990,17 +990,18 @@ static ctl_table brnf_table[] = {
 	},
 	{ }
 };
-
-static struct ctl_path brnf_path[] = {
-	{ .procname = "net", },
-	{ .procname = "bridge", },
-	{ }
-};
 #endif
 
 int __init br_netfilter_init(void)
 {
 	int ret;
+#ifdef CONFIG_SYSCTL
+	const struct ctl_path brnf_path[] = {
+		{ .procname = "net", },
+		{ .procname = "bridge", },
+		{ }
+	};
+#endif
 
 	ret = dst_entries_init(&fake_dst_ops);
 	if (ret < 0)
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 5639438..bfb80d1 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -96,17 +96,17 @@ static struct ctl_table dccp_default_table[] = {
 	{ }
 };
 
-static struct ctl_path dccp_path[] = {
-	{ .procname = "net", },
-	{ .procname = "dccp", },
-	{ .procname = "default", },
-	{ }
-};
-
 static struct ctl_table_header *dccp_table_header;
 
 int __init dccp_sysctl_init(void)
 {
+	const struct ctl_path dccp_path[] = {
+		{ .procname = "net", },
+		{ .procname = "dccp", },
+		{ .procname = "default", },
+		{ }
+	};
+
 	dccp_table_header = register_sysctl_paths(dccp_path,
 			dccp_default_table);
 
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index be3eb8e..910927f 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -350,14 +350,14 @@ static ctl_table dn_table[] = {
 	{ }
 };
 
-static struct ctl_path dn_path[] = {
-	{ .procname = "net", },
-	{ .procname = "decnet", },
-	{ }
-};
-
 void dn_register_sysctl(void)
 {
+	const struct ctl_path dn_path[] = {
+		{ .procname = "net", },
+		{ .procname = "decnet", },
+		{ }
+	};
+
 	dn_table_header = register_sysctl_paths(dn_path, dn_table);
 }
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c2ff48f..06c55fe 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1519,11 +1519,6 @@ static struct ctl_table ctl_forward_entry[] = {
 	{ },
 };
 
-static __net_initdata struct ctl_path net_ipv4_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ },
-};
 #endif
 
 static __net_init int devinet_init_net(struct net *net)
@@ -1533,6 +1528,11 @@ static __net_init int devinet_init_net(struct net *net)
 #ifdef CONFIG_SYSCTL
 	struct ctl_table *tbl = ctl_forward_entry;
 	struct ctl_table_header *forw_hdr;
+	const struct ctl_path net_ipv4_path[] = {
+		{ .procname = "net", },
+		{ .procname = "ipv4", },
+		{ },
+	};
 #endif
 
 	err = -ENOMEM;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ff98983..13bbac4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3182,12 +3182,6 @@ static struct ctl_table ipv4_skeleton[]  	{ }
 };
 
-static __net_initdata struct ctl_path ipv4_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ },
-};
-
 static struct ctl_table ipv4_route_flush_table[] = {
 	{
 		.procname	= "flush",
@@ -3198,16 +3192,15 @@ static struct ctl_table ipv4_route_flush_table[] = {
 	{ },
 };
 
-static __net_initdata struct ctl_path ipv4_route_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ .procname = "route", },
-	{ },
-};
-
 static __net_init int sysctl_route_net_init(struct net *net)
 {
 	struct ctl_table *tbl;
+	const struct ctl_path ipv4_route_path[] = {
+		{ .procname = "net", },
+		{ .procname = "ipv4", },
+		{ .procname = "route", },
+		{ },
+	};
 
 	tbl = ipv4_route_flush_table;
 	if (!net_eq(net, &init_net)) {
@@ -3343,6 +3336,12 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
+	const struct ctl_path ipv4_path[] = {
+		{ .procname = "net", },
+		{ .procname = "ipv4", },
+		{ },
+	};
+
 	register_sysctl_paths(ipv4_path, ipv4_skeleton);
 }
 #endif
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index bd6dca0..2cd92d2 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -27,16 +27,15 @@ static struct ctl_table ipx_table[] = {
 	{ },
 };
 
-static struct ctl_path ipx_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipx", },
-	{ }
-};
-
 static struct ctl_table_header *ipx_table_header;
 
 void ipx_register_sysctl(void)
 {
+	const struct ctl_path ipx_path[] = {
+		{ .procname = "net", },
+		{ .procname = "ipx", },
+		{ }
+	};
 	ipx_table_header = register_sysctl_paths(ipx_path, ipx_table);
 }
 
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index d0b70da..b177680 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -235,12 +235,6 @@ static ctl_table irda_table[] = {
 	{ }
 };
 
-static struct ctl_path irda_path[] = {
-	{ .procname = "net", },
-	{ .procname = "irda", },
-	{ }
-};
-
 static struct ctl_table_header *irda_table_header;
 
 /*
@@ -251,6 +245,12 @@ static struct ctl_table_header *irda_table_header;
  */
 int __init irda_sysctl_register(void)
 {
+	const struct ctl_path irda_path[] = {
+		{ .procname = "net", },
+		{ .procname = "irda", },
+		{ }
+	};
+
 	irda_table_header = register_sysctl_paths(irda_path, irda_table);
 	if (!irda_table_header)
 		return -ENOMEM;
diff --git a/net/llc/sysctl_net_llc.c b/net/llc/sysctl_net_llc.c
index e2ebe35..bb7c153 100644
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -79,16 +79,16 @@ static struct ctl_table llc_table[] = {
 	{ },
 };
 
-static struct ctl_path llc_path[] = {
-	{ .procname = "net", },
-	{ .procname = "llc", },
-	{ }
-};
-
 static struct ctl_table_header *llc_table_header;
 
 int __init llc_sysctl_init(void)
 {
+	const struct ctl_path llc_path[] = {
+		{ .procname = "net", },
+		{ .procname = "llc", },
+		{ }
+	};
+
 	llc_table_header = register_sysctl_paths(llc_path, llc_table);
 
 	return llc_table_header ? 0 : -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index eb973fc..87529bb 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -407,14 +407,13 @@ static ctl_table nf_ct_netfilter_table[] = {
 	{ }
 };
 
-static struct ctl_path nf_ct_path[] = {
-	{ .procname = "net", },
-	{ }
-};
-
 static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	struct ctl_table *table;
+	const struct ctl_path nf_ct_path[] = {
+		{ .procname = "net", },
+		{ }
+	};
 
 	if (net_eq(net, &init_net)) {
 		nf_ct_netfilter_header diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 7df37fd..ad170df 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -209,13 +209,6 @@ static const struct file_operations nflog_file_ops = {
 #endif /* PROC_FS */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_path nf_log_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "netfilter", },
-	{ .procname = "nf_log", },
-	{ }
-};
-
 static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 static struct ctl_table_header *nf_log_dir_header;
@@ -264,6 +257,12 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 static __init int netfilter_log_sysctl_init(void)
 {
 	int i;
+	const struct ctl_path nf_log_sysctl_path[] = {
+		{ .procname = "net", },
+		{ .procname = "netfilter", },
+		{ .procname = "nf_log", },
+		{ }
+	};
 
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
 		snprintf(nf_log_sysctl_fnames[i-NFPROTO_UNSPEC], 3, "%d", i);
@@ -278,7 +277,7 @@ static __init int netfilter_log_sysctl_init(void)
 	}
 
 	nf_log_dir_header = register_sysctl_paths(nf_log_sysctl_path,
-				       nf_log_sysctl_table);
+						  nf_log_sysctl_table);
 	if (!nf_log_dir_header)
 		return -ENOMEM;
 
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 1e0fa9e..235840a 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -146,14 +146,14 @@ static ctl_table nr_table[] = {
 	{ }
 };
 
-static struct ctl_path nr_path[] = {
-	{ .procname = "net", },
-	{ .procname = "netrom", },
-	{ }
-};
-
 void __init nr_register_sysctl(void)
 {
+	const struct ctl_path nr_path[] = {
+		{ .procname = "net", },
+		{ .procname = "netrom", },
+		{ }
+	};
+
 	nr_table_header = register_sysctl_paths(nr_path, nr_table);
 }
 
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index cea1c7d..5363afe 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -93,14 +93,14 @@ static struct ctl_table phonet_table[] = {
 	{ }
 };
 
-static struct ctl_path phonet_ctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "phonet", },
-	{ },
-};
-
 int __init phonet_sysctl_init(void)
 {
+	const struct ctl_path phonet_ctl_path[] = {
+		{ .procname = "net", },
+		{ .procname = "phonet", },
+		{ },
+	};
+
 	phonet_table_hrd = register_sysctl_paths(phonet_ctl_path, phonet_table);
 	return phonet_table_hrd = NULL ? -ENOMEM : 0;
 }
diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index fc3da37..301a504 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -106,13 +106,6 @@ ctl_table rds_ib_sysctl_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_ib_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ .procname = "ib", },
-	{ }
-};
-
 void rds_ib_sysctl_exit(void)
 {
 	if (rds_ib_sysctl_hdr)
@@ -121,7 +114,15 @@ void rds_ib_sysctl_exit(void)
 
 int rds_ib_sysctl_init(void)
 {
-	rds_ib_sysctl_hdr = register_sysctl_paths(rds_ib_sysctl_path, rds_ib_sysctl_table);
+	const struct ctl_path rds_ib_sysctl_path[] = {
+		{ .procname = "net", },
+		{ .procname = "rds", },
+		{ .procname = "ib", },
+		{ }
+	};
+
+	rds_ib_sysctl_hdr = register_sysctl_paths(rds_ib_sysctl_path,
+						  rds_ib_sysctl_table);
 	if (!rds_ib_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index 23e3a9a..27b338f 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -109,13 +109,6 @@ ctl_table rds_iw_sysctl_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_iw_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ .procname = "iw", },
-	{ }
-};
-
 void rds_iw_sysctl_exit(void)
 {
 	if (rds_iw_sysctl_hdr)
@@ -124,7 +117,15 @@ void rds_iw_sysctl_exit(void)
 
 int rds_iw_sysctl_init(void)
 {
-	rds_iw_sysctl_hdr = register_sysctl_paths(rds_iw_sysctl_path, rds_iw_sysctl_table);
+	const struct ctl_path rds_iw_sysctl_path[] = {
+		{ .procname = "net", },
+		{ .procname = "rds", },
+		{ .procname = "iw", },
+		{ }
+	};
+
+	rds_iw_sysctl_hdr = register_sysctl_paths(rds_iw_sysctl_path,
+						  rds_iw_sysctl_table);
 	if (!rds_iw_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index 25ad0c7..13fa563 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -92,13 +92,6 @@ static ctl_table rds_sysctl_rds_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ }
-};
-
-
 void rds_sysctl_exit(void)
 {
 	if (rds_sysctl_reg_table)
@@ -107,10 +100,17 @@ void rds_sysctl_exit(void)
 
 int rds_sysctl_init(void)
 {
+	const struct ctl_path rds_sysctl_path[] = {
+		{ .procname = "net", },
+		{ .procname = "rds", },
+		{ }
+	};
+
 	rds_sysctl_reconnect_min = msecs_to_jiffies(1);
 	rds_sysctl_reconnect_min_jiffies = rds_sysctl_reconnect_min;
 
-	rds_sysctl_reg_table = register_sysctl_paths(rds_sysctl_path, rds_sysctl_rds_table);
+	rds_sysctl_reg_table = register_sysctl_paths(rds_sysctl_path,
+						     rds_sysctl_rds_table);
 	if (!rds_sysctl_reg_table)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index df6d9da..ed3da3b 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -118,14 +118,14 @@ static ctl_table rose_table[] = {
 	{ }
 };
 
-static struct ctl_path rose_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rose", },
-	{ }
-};
-
 void __init rose_register_sysctl(void)
 {
+	const struct ctl_path rose_path[] = {
+		{ .procname = "net", },
+		{ .procname = "rose", },
+		{ }
+	};
+
 	rose_table_header = register_sysctl_paths(rose_path, rose_table);
 }
 
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 832590b..6e4855e 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -255,17 +255,17 @@ static ctl_table sctp_table[] = {
 	{ /* sentinel */ }
 };
 
-static struct ctl_path sctp_path[] = {
-	{ .procname = "net", },
-	{ .procname = "sctp", },
-	{ }
-};
-
 static struct ctl_table_header * sctp_sysctl_header;
 
 /* Sysctl registration.  */
 void sctp_sysctl_register(void)
 {
+	const struct ctl_path sctp_path[] = {
+		{ .procname = "net", },
+		{ .procname = "sctp", },
+		{ }
+	};
+
 	sctp_sysctl_header = register_sysctl_paths(sctp_path, sctp_table);
 }
 
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 397cffe..397a837 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -26,15 +26,14 @@ static ctl_table unix_table[] = {
 	{ }
 };
 
-static struct ctl_path unix_path[] = {
-	{ .procname = "net", },
-	{ .procname = "unix", },
-	{ },
-};
-
 int __net_init unix_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
+	const struct ctl_path unix_path[] = {
+		{ .procname = "net", },
+		{ .procname = "unix", },
+		{ },
+	};
 
 	table = kmemdup(unix_table, sizeof(unix_table), GFP_KERNEL);
 	if (table = NULL)
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index d2efd29..fcd74db 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -73,14 +73,14 @@ static struct ctl_table x25_table[] = {
 	{ 0, },
 };
 
-static struct ctl_path x25_path[] = {
-	{ .procname = "net", },
-	{ .procname = "x25", },
-	{ }
-};
-
 void __init x25_register_sysctl(void)
 {
+	const struct ctl_path x25_path[] = {
+		{ .procname = "net", },
+		{ .procname = "x25", },
+		{ }
+	};
+
 	x25_table_header = register_sysctl_paths(x25_path, x25_table);
 }
 
