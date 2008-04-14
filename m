From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Apr 2008 09:36:19 +0000
Subject: [PATCH net-2.6.26][DCCP]: Fix comment about control sockets.
Message-Id: <48032593.3080409@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These sockets now have a bit other names and are no longer global.

Shame on me, I haven't provided a good comment for this when
sending DCCP netnsization patches.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |    2 +-
 net/dccp/ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b997466..d0ed87d 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -32,7 +32,7 @@
 #include "feat.h"
 
 /*
- * The dccp_ctl_sk is the global socket data structure used for responding to
+ * The per-net dccp.v4_ctl_sk socket is used for responding to
  * the Out-of-the-blue (OOTB) packets. A control sock will be created
  * for this socket at the initialization time.
  */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 94e0c94..f8371c7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -33,7 +33,7 @@
 #include "ipv6.h"
 #include "feat.h"
 
-/* dccp_v6_ctl_sk is used for sending RSTs and ACKs */
+/* The per-net dccp.v6_ctl_sk is used for sending RSTs and ACKs */
 
 static struct inet_connection_sock_af_ops dccp_ipv6_mapped;
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
-- 
1.5.3.4

