From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:17 +0000
Subject: [PATCH 03/13] [DCCP]: Make all `debug' parameters bool
Message-Id: <20070929153817.GH23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This just sets the parameter to bool, since debugging messages
are either on or off.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 net/dccp/proto.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index d29b88f..c199f34 100644
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
index a409939..25772c3 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1046,7 +1046,7 @@ static struct ccid_operations ccid3 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-module_param(ccid3_debug, int, 0444);
+module_param(ccid3_debug, bool, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 #endif
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index c0b685e..cc9bf1c 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -992,7 +992,7 @@ MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 int dccp_debug;
-module_param(dccp_debug, int, 0444);
+module_param(dccp_debug, bool, 0444);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
-- 
1.5.2.2

