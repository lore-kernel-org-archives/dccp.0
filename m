From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jun 2007 09:05:25 +0000
Subject: [PATCH 5/5]: Provide central source file and debug facility
Message-Id: <200706141005.25979@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Provide central source file and debug facility

This patch changes the tfrc_lib module in the following manner:

 (1) a dedicated tfrc_module source file  (this is later populated 
     with TX/RX hist and LI Database routines);
 (2) a dedicated tfrc_pr_debug macro with toggle switch `tfrc_debug'.

The first serves to make the source code structure clearer, since module
initialisation and module parameter statements are currently spread over
loss_interval.c and packet_history.c (which are part of the tfrc_lib).

There is no functional change in this patch: but subsequent patches will
contribute module initialisation/cleanup routines (left open for now).

Point (2) provides a functionality which is available in all other DCCP
modules already: module debugging is enabled via a Kconfig option, in the
running code, debugging output can be toggled via the module parameter
`tfrc_debug'.  So far, one had to resort to dccp_pr_debug for this, but it
is not a good idea since it destroys the logical module separation and makes
tfrc_lib debugging dependent on dccp main-module debugging flags.

NB: TFRC debugging is enabled via Kconfig dependency on CCID3 debug,
    since CCID3 is currently the only `customer' of the TFRC library.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig              |   12 ++++++++----
 net/dccp/ccids/lib/Makefile         |    3 ++-
 net/dccp/ccids/lib/packet_history.c |    7 -------
 net/dccp/ccids/lib/packet_history.h |    3 +--
 net/dccp/ccids/lib/tfrc.h           |    8 ++++++++
 net/dccp/ccids/lib/tfrc_module.c    |   31 +++++++++++++++++++++++++++++++
 6 files changed, 50 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -15,6 +15,14 @@
  */
 #include <linux/types.h>
 #include <asm/div64.h>
+#include "../../dccp.h"
+
+#ifdef CONFIG_IP_DCCP_TFRC_DEBUG
+extern int tfrc_debug;
+#define tfrc_pr_debug(format, a...)	DCCP_PR_DEBUG(tfrc_debug, format, ##a)
+#else
+#define tfrc_pr_debug(format, a...)
+#endif
 
 /* integer-arithmetic divisions of type (a * 1000000)/b */
 static inline u64 scaled_div(u64 a, u32 b)
--- a/net/dccp/ccids/lib/Makefile
+++ b/net/dccp/ccids/lib/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
 
-dccp_tfrc_lib-y := loss_interval.o packet_history.o tfrc_equation.o
+dccp_tfrc_lib-y := tfrc_module.o    tfrc_equation.o \
+                   packet_history.o loss_interval.o
--- /dev/null
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -0,0 +1,31 @@
+/*
+ * TFRC: main module holding the pieces of the TFRC library together
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include "tfrc.h"
+
+static int __init tfrc_module_init(void)
+{
+	int rc = 0;
+
+	return rc;
+}
+
+static void __exit tfrc_module_exit(void)
+{
+}
+
+module_init(tfrc_module_init);
+module_exit(tfrc_module_exit);
+
+#ifdef CONFIG_IP_DCCP_TFRC_DEBUG
+int tfrc_debug;
+module_param(tfrc_debug, bool, 0444);
+MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
+#endif
+
+MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
+	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
+MODULE_DESCRIPTION("DCCP TFRC library");
+MODULE_LICENSE("GPL");
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -34,7 +34,6 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-#include <linux/module.h>
 #include <linux/string.h>
 #include "packet_history.h"
 
@@ -296,9 +295,3 @@ void dccp_rx_hist_purge(struct dccp_rx_h
 }
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
-
-
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
-MODULE_DESCRIPTION("DCCP TFRC library");
-MODULE_LICENSE("GPL");
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -40,8 +40,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/time.h>
-
-#include "../../dccp.h"
+#include "tfrc.h"
 
 /* Number of later packets received before one is considered lost */
 #define TFRC_RECV_NUM_LATE_LOSS	 3
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -74,10 +74,6 @@ config IP_DCCP_CCID3
 
 	  If in doubt, say M.
 
-config IP_DCCP_TFRC_LIB
-	depends on IP_DCCP_CCID3
-	def_tristate IP_DCCP_CCID3
-
 config IP_DCCP_CCID3_DEBUG
 	  bool "CCID3 debugging messages"
 	  depends on IP_DCCP_CCID3
@@ -121,5 +117,13 @@ config IP_DCCP_CCID3_RTO
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.
 
+# The TFRC Library: currently only has CCID 3 as customer
+config IP_DCCP_TFRC_LIB
+	depends on IP_DCCP_CCID3
+	def_tristate IP_DCCP_CCID3
+
+config IP_DCCP_TFRC_DEBUG
+	bool
+	default y if IP_DCCP_CCID3_DEBUG
 
 endmenu
