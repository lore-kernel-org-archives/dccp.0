From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 23 Mar 2007 03:07:30 +0000
Subject: [PATCH 9/9] DCCP: Rename slab
Message-Id: <200703231507.30710.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This alters the slabname to match module naming.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 7908a73..4427094 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -301,7 +301,7 @@ static __init int li_module_init(void)
 {
 	int rc = -ENOBUFS;
 
-	dccp_li_hist = dccp_li_hist_new("ccid3");
+	dccp_li_hist = dccp_li_hist_new("dccp_li");
 	if (dccp_li_hist = NULL)
 		return rc;
 	else
