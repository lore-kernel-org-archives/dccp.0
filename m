From: Baole Ni <baolex.ni@intel.com>
Date: Tue, 02 Aug 2016 12:15:59 +0000
Subject: [PATCH 1093/1285] Replace numeric parameter like 0444 with macro
Message-Id: <20160802121559.22998-1-baolex.ni@intel.com>
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
 net/dccp/ccids/ccid3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 119c043..f668e5b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -865,6 +865,6 @@ struct ccid_operations ccid3_ops = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-module_param(ccid3_debug, bool, 0644);
+module_param(ccid3_debug, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ccid3_debug, "Enable CCID-3 debug messages");
 #endif
-- 
2.9.2

