From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 16:52:11 +0000
Subject: [RFC][PATCH 1/12][NETNS]: Add an empty netns_dccp structure on struct
Message-Id: <47FBA826.9040402@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

According to the overall struct net design, it will be
filled with DCCP-related members.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/net_namespace.h |    4 ++++
 include/net/netns/dccp.h    |    7 +++++++
 2 files changed, 11 insertions(+), 0 deletions(-)
 create mode 100644 include/net/netns/dccp.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0ab62ed..e2aee26 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -13,6 +13,7 @@
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
 #include <net/netns/ipv6.h>
+#include <net/netns/dccp.h>
 #include <net/netns/x_tables.h>
 
 struct proc_dir_entry;
@@ -54,6 +55,9 @@ struct net {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netns_ipv6	ipv6;
 #endif
+#if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
+	struct netns_dccp	dccp;
+#endif
 #ifdef CONFIG_NETFILTER
 	struct netns_xt		xt;
 #endif
diff --git a/include/net/netns/dccp.h b/include/net/netns/dccp.h
new file mode 100644
index 0000000..056e6ad
--- /dev/null
+++ b/include/net/netns/dccp.h
@@ -0,0 +1,7 @@
+#ifndef __NETNS_DCCP_H__
+#define __NETNS_DCCP_H__
+
+struct netns_dccp {
+};
+
+#endif
-- 
1.5.3.4

