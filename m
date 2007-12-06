From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 06 Dec 2007 21:02:48 +0000
Subject: [PATCH 1/7] [TFRC]: Provide central source file and debug facility
Message-Id: <1196974974-31531-2-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-2-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-2-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This patch changes the tfrc_lib module in the following manner:

 (1) a dedicated tfrc source file to call the packet history &
     loss interval init/exit functions.
 (2) a dedicated tfrc_pr_debug macro with toggle switch `tfrc_debug'.

Commiter note: renamed tfrc_module.c to tfrc.c, and made CONFIG_IP_DCCP_CCID3
select IP_DCCP_TFRC_LIB.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/Kconfig              |   13 ++++++---
 net/dccp/ccids/lib/Makefile         |    2 +-
 net/dccp/ccids/lib/packet_history.c |   27 ++-----------------
 net/dccp/ccids/lib/packet_history.h |    3 +-
 net/dccp/ccids/lib/tfrc.c           |   48 +++++++++++++++++++++++++++++++++++
 net/dccp/ccids/lib/tfrc.h           |   17 +++++++++---
 6 files changed, 75 insertions(+), 35 deletions(-)
 create mode 100644 net/dccp/ccids/lib/tfrc.c

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 3d7d867..1227594 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -38,6 +38,7 @@ config IP_DCCP_CCID2_DEBUG
 config IP_DCCP_CCID3
 	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
 	def_tristate IP_DCCP
+	select IP_DCCP_TFRC_LIB
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
@@ -63,10 +64,6 @@ config IP_DCCP_CCID3
 
 	  If in doubt, say M.
 
-config IP_DCCP_TFRC_LIB
-	depends on IP_DCCP_CCID3
-	def_tristate IP_DCCP_CCID3
-
 config IP_DCCP_CCID3_DEBUG
 	  bool "CCID3 debugging messages"
 	  depends on IP_DCCP_CCID3
@@ -110,5 +107,13 @@ config IP_DCCP_CCID3_RTO
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.
 
+config IP_DCCP_TFRC_LIB
+	tristate
+	default n
+
+config IP_DCCP_TFRC_DEBUG
+	bool
+	depends on IP_DCCP_TFRC_LIB
+	default y if IP_DCCP_CCID3_DEBUG
 
 endmenu
diff --git a/net/dccp/ccids/lib/Makefile b/net/dccp/ccids/lib/Makefile
index 5f940a6..68c93e3 100644
--- a/net/dccp/ccids/lib/Makefile
+++ b/net/dccp/ccids/lib/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
 
-dccp_tfrc_lib-y := loss_interval.o packet_history.o tfrc_equation.o
+dccp_tfrc_lib-y := tfrc.o tfrc_equation.o packet_history.o loss_interval.o
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 4805de9..1d4d6ee 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -35,7 +35,6 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-#include <linux/module.h>
 #include <linux/string.h>
 #include "packet_history.h"
 
@@ -277,39 +276,19 @@ void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
 
-extern int __init dccp_li_init(void);
-extern void dccp_li_exit(void);
-
-static __init int packet_history_init(void)
+__init int packet_history_init(void)
 {
-	if (dccp_li_init() != 0)
-		goto out;
-
 	tfrc_tx_hist = kmem_cache_create("tfrc_tx_hist",
 					 sizeof(struct tfrc_tx_hist_entry), 0,
 					 SLAB_HWCACHE_ALIGN, NULL);
-	if (tfrc_tx_hist = NULL)
-		goto out_li_exit;
 
-	return 0;
-out_li_exit:
-	dccp_li_exit();
-out:
-	return -ENOBUFS;
+	return tfrc_tx_hist = NULL ? -ENOBUFS : 0;
 }
-module_init(packet_history_init);
 
-static __exit void packet_history_exit(void)
+void packet_history_exit(void)
 {
 	if (tfrc_tx_hist != NULL) {
 		kmem_cache_destroy(tfrc_tx_hist);
 		tfrc_tx_hist = NULL;
 	}
-	dccp_li_exit();
 }
-module_exit(packet_history_exit);
-
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
-MODULE_DESCRIPTION("DCCP TFRC library");
-MODULE_LICENSE("GPL");
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 0670f46..9a2642e 100644
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
diff --git a/net/dccp/ccids/lib/tfrc.c b/net/dccp/ccids/lib/tfrc.c
new file mode 100644
index 0000000..3a7a183
--- /dev/null
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -0,0 +1,48 @@
+/*
+ * TFRC: main module holding the pieces of the TFRC library together
+ *
+ * Copyright (c) 2007 The University of Aberdeen, Scotland, UK
+ * Copyright (c) 2007 Arnaldo Carvalho de Melo <acme@redhat.com>
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include "tfrc.h"
+
+#ifdef CONFIG_IP_DCCP_TFRC_DEBUG
+int tfrc_debug;
+module_param(tfrc_debug, bool, 0444);
+MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
+#endif
+
+extern int  dccp_li_init(void);
+extern void dccp_li_exit(void);
+extern int packet_history_init(void);
+extern void packet_history_exit(void);
+
+static int __init tfrc_module_init(void)
+{
+	int rc = dccp_li_init();
+
+	if (rc = 0) {
+		rc = packet_history_init();
+		if (rc != 0)
+			dccp_li_exit();
+	}
+
+	return rc;
+}
+
+static void __exit tfrc_module_exit(void)
+{
+	packet_history_exit();
+	dccp_li_exit();
+}
+
+module_init(tfrc_module_init);
+module_exit(tfrc_module_exit);
+
+MODULE_AUTHOR("Gerrit Renker <gerrit@erg.abdn.ac.uk>, "
+	      "Ian McDonald <ian.mcdonald@jandi.co.nz>, "
+	      "Arnaldo Carvalho de Melo <acme@redhat.com>");
+MODULE_DESCRIPTION("DCCP TFRC library");
+MODULE_LICENSE("GPL");
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
-- 
1.5.3.4

