From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 16:00:16 +0000
Subject: [PATCH 3/7]: Introduce a consisten BUG/WARN message scheme
Message-Id: <200611171600.16291@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Introduce a consistent BUG/WARN message scheme

This refines the existing set of DCCP messages so that 
	* BUG(), BUG_ON(), WARN_ON() have meaningful DCCP-specific
	  counterparts
	* DCCP_CRIT (for severe warnings) is not rate-limited
	* DCCP_WARN() is introduced as rate-limited wrapper

Using these allows a faster and cleaner transition to their original 
counterparts once the code has matured into a full DCCP implementation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 net/dccp/dccp.h |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -18,13 +18,19 @@
 #include <net/tcp.h>
 #include "ackvec.h"
 
-#define DCCP_CRIT(fmt, a...) LIMIT_NETDEBUG(KERN_CRIT fmt " at %s:%d/%s()\n",  \
- 					 ##a, __FILE__, __LINE__, __FUNCTION__)
-#define DCCP_BUG(fmt, a...)  do { DCCP_CRIT(fmt, ##a); dump_stack(); } while (0)
-#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) = 0))                   \
-					DCCP_BUG("BUG: condition \"%s\" fails",\
-						 __stringify((cond)));	       \
+/*
+ * 	DCCP - specific warning and debugging macros.
+ */
+#define DCCP_WARN(fmt, a...) LIMIT_NETDEBUG(KERN_WARNING "%s: " fmt,       \
+						        __FUNCTION__, ##a)
+#define DCCP_CRIT(fmt, a...) printk(KERN_CRIT fmt " at %s:%d/%s()\n", ##a, \
+					 __FILE__, __LINE__, __FUNCTION__)
+#define DCCP_BUG(a...)       do { DCCP_CRIT("BUG: " a); dump_stack(); } while(0)
+#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) != 0))		   \
+				     DCCP_BUG("\"%s\" holds (exception!)", \
+					      __stringify(cond));          \
 			     } while (0)
+#define DCCP_WARN_ON(cond)   DCCP_BUG_ON((cond))
 
 #ifdef MODULE
 #define DCCP_PRINTK(enable, fmt, args...)	do { if (enable)	     \
