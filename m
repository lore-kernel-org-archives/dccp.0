From: Baole Ni <baolex.ni@intel.com>
Date: Tue, 02 Aug 2016 12:16:05 +0000
Subject: [PATCH 1094/1285] Replace numeric parameter like 0444 with macro
Message-Id: <20160802121605.23066-1-baolex.ni@intel.com>
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
 net/dccp/ccids/lib/tfrc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ccids/lib/tfrc.c b/net/dccp/ccids/lib/tfrc.c
index 62b5828..9cf730c 100644
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -9,7 +9,7 @@
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
 bool tfrc_debug;
-module_param(tfrc_debug, bool, 0644);
+module_param(tfrc_debug, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(tfrc_debug, "Enable TFRC debug messages");
 #endif
 
-- 
2.9.2

