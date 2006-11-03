From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Nov 2006 14:32:02 +0000
Subject: [PATCH 3/6] dccp: Add CCID3 debug support to Kconfig
Message-Id: <200611031432.02559@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Add CCID3 debug support to Kconfig

This adds a CCID3 debug option to the configuration menu
-- which is missing in Kconfig, but already used by the code.

To enable debugging, set CONFIG_IP_DCCP_CCID3_DEBUG=y

(Hence adding a counterpart of the analogous CCID2 option in
 http://www.mail-archive.com/dccp@vger.kernel.org/msg00372.html  ).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |   11 +++++++++++
 net/dccp/ccids/ccid3.c |   16 ++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)


--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -60,13 +60,11 @@ static u32 usecs_div(const u32 a, const 
 	return (b >= 2 * div) ? tmp / (b / div) : tmp;
 }
 
-static int ccid3_debug;
 
-#ifdef CCID3_DEBUG
-#define ccid3_pr_debug(format, a...) \
-	do { if (ccid3_debug) \
-		printk(KERN_DEBUG "%s: " format, __FUNCTION__, ##a); \
-	} while (0)
+
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+static int ccid3_debug;
+#define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
 #else
 #define ccid3_pr_debug(format, a...)
 #endif
@@ -83,7 +81,7 @@ enum ccid3_hc_tx_states {
 	TFRC_SSTATE_TERM,
 };
 
-#ifdef CCID3_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
 	static char *ccid3_state_names[] = {
@@ -695,7 +693,7 @@ enum ccid3_hc_rx_states {
 	TFRC_RSTATE_TERM    = 127,
 };
 
-#ifdef CCID3_DEBUG
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
 	static char *ccid3_rx_state_names[] = {
@@ -1261,8 +1259,10 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_getsockopt	   = ccid3_hc_tx_getsockopt,
 };
  
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 module_param(ccid3_debug, int, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
+#endif
 
 static __init int ccid3_module_init(void)
 {
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -78,4 +78,15 @@ config IP_DCCP_TFRC_LIB
 	depends on IP_DCCP_CCID3
 	def_tristate IP_DCCP_CCID3
 
+config IP_DCCP_CCID3_DEBUG
+	  bool "CCID3 debugging messages"
+	  depends on IP_DCCP_CCID3
+	  ---help---
+	    Enable CCID3-specific debugging messages.
+
+	    When compiling CCID3 as a module, this debugging output can
+	    additionally be toggled by setting the ccid3_debug module
+	    parameter to 0 or 1.
+
+	    If in doubt, say N.
 endmenu
