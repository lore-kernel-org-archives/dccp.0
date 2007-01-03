From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:57:46 +0000
Subject: [PATCH 1/4][NEW]: Always use debug-toggle parameters
Message-Id: <200701031357.46525@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Always use debug-toggle parameters

Currently debugging output (when configured) is automatically enabled when
DCCP modules are compiled into the kernel rather than built as loadable modules.  
This is not necessary, since the module parameters in this case become kernel 
commandline parameters, e.g. DCCP or CCID3 debug output can be enabled for a 
static build by appending the following at the boot prompt:

	dccp.dccp_debug=1 	dccp_ccid3.ccid3_debug=1

This patch therefore does away with the more complicated way of always enabling
debug output for static builds

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    4 ----
 1 file changed, 4 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -31,13 +31,9 @@
 					      __stringify(cond));          \
 			     } while (0)
 
-#ifdef MODULE
 #define DCCP_PRINTK(enable, fmt, args...)	do { if (enable)	     \
 							printk(fmt, ##args); \
 					 	} while(0)
-#else
-#define DCCP_PRINTK(enable, fmt, args...)	printk(fmt, ##args)
-#endif
 #define DCCP_PR_DEBUG(enable, fmt, a...)	DCCP_PRINTK(enable, KERN_DEBUG \
 						  "%s: " fmt, __FUNCTION__, ##a)
 
