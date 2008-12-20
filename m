From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Dec 2008 08:08:26 +0000
Subject: [RFC] [Patch 4/4] dccp: Integrate the TFRC library (dependency)
Message-Id: <20081220080826.GE3853@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Integrate the TFRC library objects into DCCP

The TFRC library is a dependency of the CCID-3 (and CCID-4)
modules. The patch updates the Kconfig menu and Makefiles.

Note -- This solution is simple, I am sure that it can be
done better and thus welcome suggestions to improve the
conditional build statement below.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/Makefile           |    7 +++++--
 net/dccp/ccid.c             |    5 +++++
 net/dccp/ccid.h             |    9 +++++++++
 net/dccp/ccids/Kconfig      |    5 ++---
 net/dccp/ccids/Makefile     |    1 -
 net/dccp/ccids/lib/Makefile |    3 ---
 net/dccp/ccids/lib/tfrc.c   |   15 +++------------
 7 files changed, 24 insertions(+), 21 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -16,7 +16,6 @@ config IP_DCCP_CCID2_DEBUG
 config IP_DCCP_CCID3
 	bool "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
 	def_bool y if (IP_DCCP = y || IP_DCCP = m)
-	select IP_DCCP_TFRC_LIB
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
@@ -83,8 +82,8 @@ config IP_DCCP_CCID3_RTO
 	    therefore not be performed on WANs.
 
 config IP_DCCP_TFRC_LIB
-	tristate
-	default n
+	bool
+	def_bool y if (IP_DCCP_CCID3 = y)
 
 config IP_DCCP_TFRC_DEBUG
 	bool
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -5,6 +5,11 @@ dccp-y := ccid.o feat.o input.o minisock
 
 dccp-$(CONFIG_IP_DCCP_CCID3) += ccids/ccid3.o
 
+dccp-$(CONFIG_IP_DCCP_TFRC_LIB) += ccids/lib/tfrc.o		\
+				   ccids/lib/tfrc_equation.o	\
+				   ccids/lib/packet_history.o	\
+				   ccids/lib/loss_interval.o
+
 dccp_ipv4-y := ipv4.o
 
 # build dccp_ipv6 as module whenever either IPv6 or DCCP is a module
@@ -18,5 +23,3 @@ dccp-$(CONFIG_SYSCTL) += sysctl.o
 
 dccp_diag-y := diag.o
 dccp_probe-y := probe.o
-
-obj-y += ccids/
--- a/net/dccp/ccids/lib/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
-
-dccp_tfrc_lib-y := tfrc.o tfrc_equation.o packet_history.o loss_interval.o
--- a/net/dccp/ccids/Makefile
+++ /dev/null
@@ -1 +0,0 @@
-obj-y += lib/
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -11,10 +11,10 @@
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
 int tfrc_debug;
 module_param(tfrc_debug, bool, 0644);
-MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
+MODULE_PARM_DESC(tfrc_debug, "Enable TFRC debug messages");
 #endif
 
-static int __init tfrc_module_init(void)
+int __init tfrc_lib_init(void)
 {
 	int rc = tfrc_li_init();
 
@@ -38,18 +38,9 @@ out:
 	return rc;
 }
 
-static void __exit tfrc_module_exit(void)
+void __exit tfrc_lib_exit(void)
 {
 	tfrc_rx_packet_history_exit();
 	tfrc_tx_packet_history_exit();
 	tfrc_li_exit();
 }
-
-module_init(tfrc_module_init);
-module_exit(tfrc_module_exit);
-
-MODULE_AUTHOR("Gerrit Renker <gerrit@erg.abdn.ac.uk>, "
-	      "Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@redhat.com>");
-MODULE_DESCRIPTION("DCCP TFRC library");
-MODULE_LICENSE("GPL");
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -216,6 +216,9 @@ int __init ccid_register_builtins(void)
 {
 	int i, err;
 
+	err = tfrc_lib_init();
+	if (err)
+		return err;
 	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
 		err = ccid_register(ccids[i]);
 		if (err)
@@ -225,6 +228,7 @@ int __init ccid_register_builtins(void)
 	return 0;
 
 unwind_registrations:
+	tfrc_lib_exit();
 	while(--i >= 0)
 		ccid_unregister(ccids[i]);
 	return err;
@@ -236,4 +240,5 @@ void ccid_unregister_builtins(void)
 
 	for (i = 0; i < ARRAY_SIZE(ccids); i++)
 		ccid_unregister(ccids[i]);
+	tfrc_lib_exit();
 }
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -91,6 +91,15 @@ extern struct ccid_operations ccid2_ops;
 extern struct ccid_operations ccid3_ops;
 #endif
 
+/* The TFRC library is a dependency of CCID-3 */
+#ifdef CONFIG_IP_DCCP_TFRC_LIB
+extern	int  tfrc_lib_init(void);
+extern	void tfrc_lib_exit(void);
+#else
+#define	tfrc_lib_init() (0)
+#define	tfrc_lib_exit()
+#endif
+
 extern int  ccid_register_builtins(void);
 extern void ccid_unregister_builtins(void);
 
