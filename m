From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:26:44 +0000
Subject: [PATCH 2/7] [DCCP]: Use constants for CCIDs
Message-Id: <200609221426.45216.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With constants for CCID numbers this now uses them in some places.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 457dd3d..2efb505 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -808,7 +808,7 @@ static void ccid2_hc_rx_packet_recv(stru
 }
 
 static struct ccid_operations ccid2 = {
-	.ccid_id		= 2,
+	.ccid_id		= DCCPC_CCID2,
 	.ccid_name		= "ccid2",
 	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 195aa95..67d2dc0 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1240,7 +1240,7 @@ static int ccid3_hc_tx_getsockopt(struct
 }
 
 static struct ccid_operations ccid3 = {
-	.ccid_id		   = 3,
+	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "ccid3",
 	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
