From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:12:27 +0000
Subject: [PATCH 7/10]: [DCCP] CCID2: Add Kconfig option for CCID2 debug
Message-Id: <20060914171227.GH20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Allow the user to choose whether or not to enable CCID2 debugging via Kconfig.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 Kconfig |    8 ++++++++
 ccid2.c |    7 +++----
 2 files changed, 11 insertions(+), 4 deletions(-)

------------------------------------------------------------------------------

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
index e0acd1b..dbcda7e 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -35,8 +35,7 @@ #include "ccid2.h"
 
 static int ccid2_debug;
 
-#undef CCID2_DEBUG
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 #define ccid2_pr_debug(format, a...) \
         do { if (ccid2_debug) \
                 printk(KERN_DEBUG "%s: " format, __FUNCTION__, ##a); \
@@ -47,7 +46,7 @@ #endif
 
 static const int ccid2_seq_len = 128;
 
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
@@ -295,7 +294,7 @@ static void ccid2_hc_tx_packet_sent(stru
 	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
 		ccid2_start_rto_timer(sk);
 
-#ifdef CCID2_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("Sent: seq=%llu\n", seq);
 	do {
