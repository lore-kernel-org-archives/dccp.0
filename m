From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:59:06 +0000
Subject: [PATCH 09/11] CCID2: Add Kconfig option for CCID2 debug
Message-Id: <20060622175906.GI4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Allow the user to choose whether or not to enable CCID2 debugging via Kconfig.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index ca00191..25fb4f6 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -30,6 +30,14 @@ config IP_DCCP_CCID2
 
 	  If in doubt, say M.
 
+config IP_DCCP_CCID2_DEBUG
+	  bool "CCID2 debug"
+	  depends on IP_DCCP_CCID2
+	  ---help---
+	    Enable CCID2 debug messages.
+	    
+	    If in doubt, say N.
+
 config IP_DCCP_CCID3
 	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
 	depends on IP_DCCP
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index f0bc0b6..db0f1f1 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -36,8 +36,7 @@ #include "ccid2.h"
 
 static int ccid2_debug;
 
-#undef CCID2_DEBUG
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 #define ccid2_pr_debug(format, a...) \
         do { if (ccid2_debug) \
                 printk(KERN_DEBUG "%s: " format, __FUNCTION__, ##a); \
@@ -46,7 +45,7 @@ #else
 #define ccid2_pr_debug(format, a...)
 #endif
 
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
@@ -340,7 +339,7 @@ static void ccid2_hc_tx_packet_sent(stru
 	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
 		ccid2_start_rto_timer(sk);
 
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("Sent: seq=%llu\n", seq);
 	do {
