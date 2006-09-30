From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 30 Sep 2006 14:05:18 +0000
Subject: [PATCH][RFC] net/dccp: always log debug messages when CONFIG_DEBUG is set
Message-Id: <200609301505.19198@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This disables the integer (module) parameter dccp_debug which is
used to toggle debugging messages when configured with CONFIG_IP_DCCP_DEBUG.

Justification: Not possible to toggle debug mode when dccp is statically 
               compiled into the kernel; also when user forgets to explicitly
               load all modules and module loading is triggered by socket 
               create function, debug is off; in summary, it makes debugging
               much faster to use.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--

 ackvec.c |    3 ---
 dccp.h   |    9 +++------
 proto.c  |    8 --------
 3 files changed, 3 insertions(+), 17 deletions(-)


diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index c0cb709..01345df 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -322,9 +322,6 @@ out_duplicate:
 #ifdef CONFIG_IP_DCCP_DEBUG
 void dccp_ackvector_print(const u64 ackno, const unsigned char *vector, int len)
 {
-	if (!dccp_debug)
-		return;
-
 	printk("ACK vector len=%d, ackno=%llu |", len,
 	       (unsigned long long)ackno);
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9f00dd8..8aa2697 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -21,12 +21,9 @@ #include "ackvec.h"
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern int dccp_debug;
 
-#define dccp_pr_debug(format, a...) \
-	do { if (dccp_debug) \
-		printk(KERN_DEBUG "%s: " format, __FUNCTION__ , ##a); \
-	} while (0)
-#define dccp_pr_debug_cat(format, a...) do { if (dccp_debug) \
-					     printk(format, ##a); } while (0)
+#define dccp_pr_debug(format, a...)     do { printk(KERN_DEBUG "%s: " format,\
+					     __FUNCTION__ , ##a); } while (0)
+#define dccp_pr_debug_cat(format, a...) do { printk(format, ##a); } while (0)
 #else
 #define dccp_pr_debug(format, a...)
 #define dccp_pr_debug_cat(format, a...)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 2adfcd4..ffea66a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -949,14 +949,6 @@ static int thash_entries;
 module_param(thash_entries, int, 0444);
 MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
-#ifdef CONFIG_IP_DCCP_DEBUG
-int dccp_debug;
-module_param(dccp_debug, int, 0444);
-MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
-
-EXPORT_SYMBOL_GPL(dccp_debug);
-#endif
-
 static int __init dccp_init(void)
 {
 	unsigned long goal;
