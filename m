From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Date: Tue, 10 Apr 2007 21:07:50 +0000
Subject: [PATCH 08/30] Use menuconfig objects - DCCP
Message-Id: <Pine.LNX.4.61.0704102305291.32056@yvahk01.tjqt.qr>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Use menuconfigs instead of menus, so the whole menu can be disabled at        
once instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

Index: linux-2.6.21-rc5/net/dccp/Kconfig
=================================--- linux-2.6.21-rc5.orig/net/dccp/Kconfig
+++ linux-2.6.21-rc5/net/dccp/Kconfig
@@ -1,8 +1,6 @@
-menu "DCCP Configuration (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
-
-config IP_DCCP
+menuconfig IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
+	depends on INET && EXPERIMENTAL
 	---help---
 	  Datagram Congestion Control Protocol (RFC 4340)
 
@@ -19,19 +17,20 @@ config IP_DCCP
 
 	  If in doubt, say N.
 
+if IP_DCCP
+
 config INET_DCCP_DIAG
-	depends on IP_DCCP && INET_DIAG
+	depends on INET_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
 config IP_DCCP_ACKVEC
-	depends on IP_DCCP
 	bool
 
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
-	depends on IP_DCCP && DEBUG_KERNEL=y
+	depends on DEBUG_KERNEL=y
 
 config IP_DCCP_DEBUG
 	bool "DCCP debug messages"
@@ -61,4 +60,4 @@ config NET_DCCPPROBE
 
 endmenu
 
-endmenu
+endif # IP_DDCP
#<EOF>
