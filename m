From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 19 May 2007 05:21:21 +0000
Subject: [PATCH 7/7] DCCP: Alter slab name
Message-Id: <200705191721.22026.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This alters the slabname to match module naming. In future this code will
be used for CCID4 and so we should lose the current name.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 16ced5f..b19f89c 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -299,7 +299,7 @@ EXPORT_SYMBOL(dccp_li_update_li);
 
 static __init int li_module_init(void)
 {
-	dccp_li_hist = dccp_li_hist_new("ccid3");
+	dccp_li_hist = dccp_li_hist_new("dccp_li");
 	return dccp_li_hist = NULL ? -ENOBUFS : 0;
 }
 module_init(li_module_init);
