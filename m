From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:17:12 +0000
Subject: [PATCH 22/29] Make all `debug' parameters bool
Message-Id: <20070412211712.GW21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This just sets the parameter to bool, since debugging messages
are either on or off.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 net/dccp/proto.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 248d20f..67a3d23 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -835,7 +835,7 @@ static struct ccid_operations ccid2 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-module_param(ccid2_debug, int, 0444);
+module_param(ccid2_debug, bool, 0444);
 MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
 #endif
 
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index cd3565f..590c002 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1215,7 +1215,7 @@ static struct ccid_operations ccid3 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-module_param(ccid3_debug, int, 0444);
+module_param(ccid3_debug, bool, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 #endif
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e00359d..a93bb3d 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -991,7 +991,7 @@ MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 int dccp_debug;
-module_param(dccp_debug, int, 0444);
+module_param(dccp_debug, bool, 0444);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
-- 
1.5.0.6

