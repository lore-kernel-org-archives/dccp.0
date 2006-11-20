From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:52:52 +0000
Subject: [PATCH 2/9] [DCCP]: enable debug messages also for static builds
Message-Id: <20061120205251.GC5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch
  * makes debugging (when configured) work both for static / module build
  * provides generic debugging macros for use in other DCCP / CCID modules
  * adds missing information about debug parameters to Kconfig
  * performs some code tidy-up

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/Kconfig       |    3 +++
 net/dccp/ackvec.c      |   11 ++++-------
 net/dccp/ccids/Kconfig |   14 ++++++++++++--
 net/dccp/ccids/ccid2.c |   16 ++++++----------
 net/dccp/dccp.h        |   19 ++++++++++++-------
 5 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 2fc5e55..b8a68dd 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -38,6 +38,9 @@ config IP_DCCP_DEBUG
 	---help---
 	  Only use this if you're hacking DCCP.
 
+	  When compiling DCCP as a module, this debugging output can be toggled
+	  by setting the parameter dccp_debug of the `dccp' module to 0 or 1.
+
 	  Just say N.
 
 config NET_DCCPPROBE
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index bd20a2c..d34badc 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -318,21 +318,18 @@ out_duplicate:
 #ifdef CONFIG_IP_DCCP_DEBUG
 void dccp_ackvector_print(const u64 ackno, const unsigned char *vector, int len)
 {
-	if (!dccp_debug)
-		return;
-
-	printk("ACK vector len=%d, ackno=%llu |", len,
-	       (unsigned long long)ackno);
+	dccp_pr_debug_cat("ACK vector len=%d, ackno=%llu |", len,
+			 		(unsigned long long)ackno);
 
 	while (len--) {
 		const u8 state = (*vector & DCCP_ACKVEC_STATE_MASK) >> 6;
 		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
 
-		printk("%d,%d|", state, rl);
+		dccp_pr_debug_cat("%d,%d|", state, rl);
 		++vector;
 	}
 
-	printk("\n");
+	dccp_pr_debug_cat("\n");
 }
 
 void dccp_ackvec_print(const struct dccp_ackvec *av)
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 8533dab..ba826d9 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -28,13 +28,20 @@ config IP_DCCP_CCID2
 	  This text was extracted from RFC 4340 (sec. 10.1),
 	  http://www.ietf.org/rfc/rfc4340.txt
 
+	  To compile this CCID as a module, choose M here: the module will be
+	  called dccp_ccid2.
+
 	  If in doubt, say M.
 
 config IP_DCCP_CCID2_DEBUG
-	  bool "CCID2 debug"
+	  bool "CCID2 debugging messages"
 	  depends on IP_DCCP_CCID2
 	  ---help---
-	    Enable CCID2 debug messages.
+	    Enable CCID2-specific debugging messages.
+
+	    When compiling CCID2 as a module, this debugging output can
+	    additionally be toggled by setting the ccid2_debug module
+	    parameter to 0 or 1.
 
 	    If in doubt, say N.
 
@@ -62,6 +69,9 @@ config IP_DCCP_CCID3
 	  This text was extracted from RFC 4340 (sec. 10.2),
 	  http://www.ietf.org/rfc/rfc4340.txt
 	  
+	  To compile this CCID as a module, choose M here: the module will be
+	  called dccp_ccid3.
+
 	  If in doubt, say M.
 
 config IP_DCCP_TFRC_LIB
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 6533cb2..0fb0d66 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -33,18 +33,11 @@ #include "../ccid.h"
 #include "../dccp.h"
 #include "ccid2.h"
 
-static int ccid2_debug;
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-#define ccid2_pr_debug(format, a...) \
-        do { if (ccid2_debug) \
-                printk(KERN_DEBUG "%s: " format, __FUNCTION__, ##a); \
-        } while (0)
-#else
-#define ccid2_pr_debug(format, a...)
-#endif
+static int ccid2_debug;
+#define ccid2_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid2_debug, format, ##a)
 
-#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
@@ -86,7 +79,8 @@ static void ccid2_hc_tx_check_sanity(con
 	BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
 }
 #else
-#define ccid2_hc_tx_check_sanity(hctx) do {} while (0)
+#define ccid2_pr_debug(format, a...)
+#define ccid2_hc_tx_check_sanity(hctx)
 #endif
 
 static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num,
@@ -841,8 +835,10 @@ static struct ccid_operations ccid2 = {
 	.ccid_hc_rx_packet_recv	= ccid2_hc_rx_packet_recv,
 };
 
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 module_param(ccid2_debug, int, 0444);
 MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
+#endif
 
 static __init int ccid2_module_init(void)
 {
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index ecb4e7b..33d86f5 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -26,15 +26,20 @@ #define DCCP_BUG_ON(cond)    do { if (un
 						 __stringify((cond)));	       \
 			     } while (0)
 
+#ifdef MODULE
+#define DCCP_PRINTK(enable, fmt, args...)	do { if (enable)	     \
+							printk(fmt, ##args); \
+					 	} while(0)
+#else
+#define DCCP_PRINTK(enable, fmt, args...)	printk(fmt, ##args)
+#endif
+#define DCCP_PR_DEBUG(enable, fmt, a...)	DCCP_PRINTK(enable, KERN_DEBUG \
+						  "%s: " fmt, __FUNCTION__, ##a)
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern int dccp_debug;
-
-#define dccp_pr_debug(format, a...) \
-	do { if (dccp_debug) \
-		printk(KERN_DEBUG "%s: " format, __FUNCTION__ , ##a); \
-	} while (0)
-#define dccp_pr_debug_cat(format, a...) do { if (dccp_debug) \
-					     printk(format, ##a); } while (0)
+#define dccp_pr_debug(format, a...)	  DCCP_PR_DEBUG(dccp_debug, format, ##a)
+#define dccp_pr_debug_cat(format, a...)   DCCP_PRINTK(dccp_debug, format, ##a)
 #else
 #define dccp_pr_debug(format, a...)
 #define dccp_pr_debug_cat(format, a...)
-- 
1.4.2.1.g3d5c

