From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:50:54 +0000
Subject: [PATCH 5/8]:  Move debugging macro to header file
Message-Id: <200612151050.54101@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Move debugging macro to header file

This moves the ccid3_pr_debug macro into the header file,
so that it can be used from other files belonging to the
CCID3 framework as well. 

Thanks to Ian McDonald for the suggestion.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    8 +-------
 net/dccp/ccids/ccid3.h |    7 +++++++
 2 files changed, 8 insertions(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -41,13 +41,6 @@
 #include "lib/tfrc.h"
 #include "ccid3.h"
 
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static int ccid3_debug;
-#define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
-#else
-#define ccid3_pr_debug(format, a...)
-#endif
-
 static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
@@ -1227,6 +1220,7 @@ static struct ccid_operations ccid3 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+int ccid3_debug;
 module_param(ccid3_debug, int, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 #endif
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -61,6 +61,13 @@
 			rtt = CCID3_SANE_RTT_MAX;			   \
 		} 					} while (0)
 
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+extern int ccid3_debug;
+#define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
+#else
+#define ccid3_pr_debug(format, a...)
+#endif
+
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
