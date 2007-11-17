From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:34 +0000
Subject: [PATCH 07/16] [TFRC]: Provide central source file and debug facility
Message-Id: <11952917831286-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch changes the tfrc_lib module in the following manner:

 (1) a dedicated tfrc_module source file  (this is later populated
     with TX/RX hist and LI Database routines);
 (2) a dedicated tfrc_pr_debug macro with toggle switch `tfrc_debug'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/Kconfig              |   12 +++++++---
 net/dccp/ccids/lib/Makefile         |    3 +-
 net/dccp/ccids/lib/loss_interval.c  |    7 +----
 net/dccp/ccids/lib/packet_history.c |    7 ------
 net/dccp/ccids/lib/packet_history.h |    3 +-
 net/dccp/ccids/lib/tfrc.h           |   17 ++++++++++++---
 net/dccp/ccids/lib/tfrc_module.c    |   38 +++++++++++++++++++++++++++++++++++
 7 files changed, 64 insertions(+), 23 deletions(-)
 create mode 100644 net/dccp/ccids/lib/tfrc_module.c

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 80f4698..c00b655 100644
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
diff --git a/net/dccp/ccids/lib/Makefile b/net/dccp/ccids/lib/Makefile
index 5f940a6..1295635 100644
--- a/net/dccp/ccids/lib/Makefile
+++ b/net/dccp/ccids/lib/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
 
-dccp_tfrc_lib-y := loss_interval.o packet_history.o tfrc_equation.o
+dccp_tfrc_lib-y := tfrc_module.o    tfrc_equation.o \
+                   packet_history.o loss_interval.o
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 40ad428..e8a9d09 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -277,7 +277,7 @@ void dccp_li_update_li(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_li_update_li);
 
-static __init int dccp_li_init(void)
+int dccp_li_init(void)
 {
 	dccp_li_cachep = kmem_cache_create("dccp_li_hist",
 					   sizeof(struct dccp_li_hist_entry),
@@ -285,10 +285,7 @@ static __init int dccp_li_init(void)
 	return dccp_li_cachep = NULL ? -ENOBUFS : 0;
 }
 
-static __exit void dccp_li_exit(void)
+void dccp_li_exit(void)
 {
 	kmem_cache_destroy(dccp_li_cachep);
 }
-
-module_init(dccp_li_init);
-module_exit(dccp_li_exit);
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 1955f13..5a61b1b 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -35,7 +35,6 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-#include <linux/module.h>
 #include <linux/string.h>
 #include "packet_history.h"
 
@@ -301,9 +300,3 @@ void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 }
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
-
-
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
-MODULE_DESCRIPTION("DCCP TFRC library");
-MODULE_LICENSE("GPL");
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 3c39bc3..137b33c 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -39,8 +39,7 @@
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-
-#include "../../dccp.h"
+#include "tfrc.h"
 
 /* Number of later packets received before one is considered lost */
 #define TFRC_RECV_NUM_LATE_LOSS	 3
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index 5a0ba86..ab8848c 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -3,10 +3,11 @@
 /*
  *  net/dccp/ccids/lib/tfrc.h
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
- *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *  Copyright (c) 2005   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *  Copyright (c) 2003   Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -15,6 +16,14 @@
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
diff --git a/net/dccp/ccids/lib/tfrc_module.c b/net/dccp/ccids/lib/tfrc_module.c
new file mode 100644
index 0000000..5a4b055
--- /dev/null
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -0,0 +1,38 @@
+/*
+ * TFRC: main module holding the pieces of the TFRC library together
+ *
+ * Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include "tfrc.h"
+
+extern int  dccp_li_init(void);
+extern void dccp_li_exit(void);
+
+static int __init tfrc_module_init(void)
+{
+	int rc = dccp_li_init();
+
+	return rc;
+}
+
+static void __exit tfrc_module_exit(void)
+{
+	dccp_li_exit();
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
+MODULE_AUTHOR("Gerrit Renker <gerrit@erg.abdn.ac.uk>, "
+	      "Ian McDonald <ian.mcdonald@jandi.co.nz>, "
+	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
+MODULE_DESCRIPTION("DCCP TFRC library");
+MODULE_LICENSE("GPL");
-- 
1.5.2.2.238.g7cbf2f2-dirty

