From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Jan 2009 07:30:49 +0000
Subject: [PATCH 3/3] dccp: Integrate the TFRC library with DCCP
Message-Id: <1230967849-9456-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch integrates the TFRC library, which is a dependency of CCID-3 (and
CCID-4), with the new use of CCIDs in the DCCP module.		

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/Makefile                   |    6 ++++--
 net/dccp/ccid.c                     |    8 +++++++-
 net/dccp/ccids/Kconfig              |    9 ++-------
 net/dccp/ccids/Makefile             |    1 -
 net/dccp/ccids/lib/Makefile         |    3 ---
 net/dccp/ccids/lib/loss_interval.c  |    3 ---
 net/dccp/ccids/lib/packet_history.c |    9 ---------
 net/dccp/ccids/lib/tfrc.c           |   19 ++++---------------
 net/dccp/ccids/lib/tfrc.h           |   11 ++++++++++-
 net/dccp/ccids/lib/tfrc_equation.c  |    4 ----
 net/dccp/feat.c                     |    4 ----
 net/dccp/input.c                    |    2 --
 12 files changed, 27 insertions(+), 52 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -14,7 +14,6 @@ config IP_DCCP_CCID2_DEBUG
 config IP_DCCP_CCID3
 	bool "CCID-3 (TCP-Friendly) (EXPERIMENTAL)"
 	def_bool y if (IP_DCCP = y || IP_DCCP = m)
-	select IP_DCCP_TFRC_LIB
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
@@ -80,12 +79,8 @@ config IP_DCCP_CCID3_RTO
 	    therefore not be performed on WANs.
 
 config IP_DCCP_TFRC_LIB
-	tristate
-	default n
+	def_bool y if IP_DCCP_CCID3
 
 config IP_DCCP_TFRC_DEBUG
-	bool
-	depends on IP_DCCP_TFRC_LIB
-	default y if IP_DCCP_CCID3_DEBUG
-
+	def_bool y if IP_DCCP_CCID3_DEBUG
 endmenu
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -8,6 +8,10 @@ dccp-y := ccid.o feat.o input.o minisock
 # CCID-2 is default (RFC 4340, p. 77) and has Ack Vectors as dependency
 dccp-y += ccids/ccid2.o ackvec.o
 dccp-$(CONFIG_IP_DCCP_CCID3)	+= ccids/ccid3.o
+dccp-$(CONFIG_IP_DCCP_TFRC_LIB) += ccids/lib/tfrc.o		\
+				   ccids/lib/tfrc_equation.o	\
+				   ccids/lib/packet_history.o	\
+				   ccids/lib/loss_interval.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -22,5 +26,3 @@ dccp-$(CONFIG_SYSCTL) += sysctl.o
 
 dccp_diag-y := diag.o
 dccp_probe-y := probe.o
-
-obj-y += ccids/
--- a/net/dccp/ccids/Makefile
+++ /dev/null
@@ -1 +0,0 @@
-obj-y += lib/
--- a/net/dccp/ccids/lib/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
-
-dccp_tfrc_lib-y := tfrc.o tfrc_equation.o packet_history.o loss_interval.o
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -17,7 +17,8 @@
 #include <linux/types.h>
 #include <linux/math64.h>
 #include "../../dccp.h"
-/* internal includes that this module exports: */
+
+/* internal includes that this library exports: */
 #include "loss_interval.h"
 #include "packet_history.h"
 
@@ -66,4 +67,12 @@ extern void tfrc_rx_packet_history_exit(
 
 extern int  tfrc_li_init(void);
 extern void tfrc_li_exit(void);
+
+#ifdef CONFIG_IP_DCCP_TFRC_LIB
+extern int  tfrc_lib_init(void);
+extern void tfrc_lib_exit(void);
+#else
+#define tfrc_lib_init() (0)
+#define tfrc_lib_exit()
+#endif
 #endif /* _TFRC_H_ */
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -1,20 +1,18 @@
 /*
- * TFRC: main module holding the pieces of the TFRC library together
+ * TFRC library initialisation
  *
  * Copyright (c) 2007 The University of Aberdeen, Scotland, UK
  * Copyright (c) 2007 Arnaldo Carvalho de Melo <acme@redhat.com>
  */
-#include <linux/module.h>
-#include <linux/moduleparam.h>
 #include "tfrc.h"
 
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
 
@@ -38,18 +36,9 @@ out:
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
@@ -12,6 +12,7 @@
  */
 
 #include "ccid.h"
+#include "ccids/lib/tfrc.h"
 
 static struct ccid_operations *ccids[] = {
 	&ccid2_ops,
@@ -199,7 +200,10 @@ void ccid_hc_tx_delete(struct ccid *ccid
 
 int __init ccid_initialize_builtins(void)
 {
-	int i, err;
+	int i, err = tfrc_lib_init();
+
+	if (err)
+		return err;
 
 	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
 		err = ccid_activate(ccids[i]);
@@ -211,6 +215,7 @@ int __init ccid_initialize_builtins(void
 unwind_registrations:
 	while(--i >= 0)
 		ccid_deactivate(ccids[i]);
+	tfrc_lib_exit();
 	return err;
 }
 
@@ -220,4 +225,5 @@ void ccid_cleanup_builtins(void)
 
 	for (i = 0; i < ARRAY_SIZE(ccids); i++)
 		ccid_deactivate(ccids[i]);
+	tfrc_lib_exit();
 }
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -60,7 +60,6 @@ void tfrc_lh_cleanup(struct tfrc_loss_hi
 			lh->ring[LIH_INDEX(lh->counter)] = NULL;
 		}
 }
-EXPORT_SYMBOL_GPL(tfrc_lh_cleanup);
 
 static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 {
@@ -121,7 +120,6 @@ u8 tfrc_lh_update_i_mean(struct tfrc_los
 
 	return (lh->i_mean < old_i_mean);
 }
-EXPORT_SYMBOL_GPL(tfrc_lh_update_i_mean);
 
 /* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
 static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
@@ -169,7 +167,6 @@ int tfrc_lh_interval_add(struct tfrc_los
 	}
 	return 1;
 }
-EXPORT_SYMBOL_GPL(tfrc_lh_interval_add);
 
 int __init tfrc_li_init(void)
 {
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -94,7 +94,6 @@ int tfrc_tx_hist_add(struct tfrc_tx_hist
 	*headp	     = entry;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_add);
 
 void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp)
 {
@@ -109,7 +108,6 @@ void tfrc_tx_hist_purge(struct tfrc_tx_h
 
 	*headp = NULL;
 }
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_purge);
 
 u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno,
 		     const ktime_t now)
@@ -127,7 +125,6 @@ u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist
 
 	return rtt;
 }
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
 
 
 /*
@@ -172,7 +169,6 @@ void tfrc_rx_hist_add_packet(struct tfrc
 
 	tfrc_rx_hist_entry_from_skb(entry, skb, ndp);
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
 /* has the packet contained in skb been seen before? */
 int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
@@ -189,7 +185,6 @@ int tfrc_rx_hist_duplicate(struct tfrc_r
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_duplicate);
 
 static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
 {
@@ -390,7 +385,6 @@ int tfrc_rx_handle_loss(struct tfrc_rx_h
 	}
 	return is_new_loss;
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
 
 int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
 {
@@ -412,7 +406,6 @@ out_free:
 	}
 	return -ENOBUFS;
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_alloc);
 
 void tfrc_rx_hist_purge(struct tfrc_rx_hist *h)
 {
@@ -424,7 +417,6 @@ void tfrc_rx_hist_purge(struct tfrc_rx_h
 			h->ring[i] = NULL;
 		}
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_purge);
 
 /**
  * tfrc_rx_hist_rtt_last_s - reference entry to compute RTT samples against
@@ -495,4 +487,3 @@ keep_ref_for_next_time:
 
 	return sample;
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_sample_rtt);
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -659,8 +659,6 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 	return scaled_div32(result, f);
 }
 
-EXPORT_SYMBOL_GPL(tfrc_calc_x);
-
 /**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
  *
@@ -693,5 +691,3 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalu
 	index = tfrc_binsearch(fvalue, 0);
 	return (index + 1) * 1000000 / TFRC_CALC_X_ARRSIZE;
 }
-
-EXPORT_SYMBOL_GPL(tfrc_calc_x_reverse_lookup);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1214,8 +1214,6 @@ const char *dccp_feat_typename(const u8 
 	return NULL;
 }
 
-EXPORT_SYMBOL_GPL(dccp_feat_typename);
-
 const char *dccp_feat_name(const u8 feat)
 {
 	static const char *feature_names[] = {
@@ -1240,6 +1238,4 @@ const char *dccp_feat_name(const u8 feat
 
 	return feature_names[feat];
 }
-
-EXPORT_SYMBOL_GPL(dccp_feat_name);
 #endif /* CONFIG_IP_DCCP_DEBUG */
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -741,5 +741,3 @@ u32 dccp_sample_rtt(struct sock *sk, lon
 
 	return delta;
 }
-
-EXPORT_SYMBOL_GPL(dccp_sample_rtt);
