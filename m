From: Baole Ni <baolex.ni@intel.com>
Date: Tue, 02 Aug 2016 12:16:10 +0000
Subject: [PATCH 1095/1285] Replace numeric parameter like 0444 with macro
Message-Id: <20160802121610.23133-1-baolex.ni@intel.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/dccp/proto.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 41e6580..dc0eb00 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1093,12 +1093,12 @@ static inline void dccp_mib_exit(void)
 }
 
 static int thash_entries;
-module_param(thash_entries, int, 0444);
+module_param(thash_entries, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 bool dccp_debug;
-module_param(dccp_debug, bool, 0644);
+module_param(dccp_debug, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
-- 
2.9.2

