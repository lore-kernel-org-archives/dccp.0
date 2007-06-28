From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Jun 2007 14:10:41 +0000
Subject: [PATCH 2/4]: Make all `debug' parameters bool
Message-Id: <200706281510.41649@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make all `debug' parameters bool

This just sets the parameter to bool, since debugging messages
are either on or off.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 net/dccp/proto.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -835,7 +835,7 @@ static struct ccid_operations ccid2 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-module_param(ccid2_debug, int, 0444);
+module_param(ccid2_debug, bool, 0444);
 MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -953,7 +953,7 @@ static struct ccid_operations ccid3 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-module_param(ccid3_debug, int, 0444);
+module_param(ccid3_debug, bool, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -993,7 +993,7 @@ MODULE_PARM_DESC(thash_entries, "Number 
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 int dccp_debug;
-module_param(dccp_debug, int, 0444);
+module_param(dccp_debug, bool, 0444);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
