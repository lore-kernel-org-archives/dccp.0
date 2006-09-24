From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 24 Sep 2006 21:19:30 +0000
Subject: [PATCH 3/4][DCCP]: Use constants for CCIDs
Message-Id: <20060924211929.GD6263@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

With constants for CCID numbers this now uses them in some places.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
-- 
1.4.2.1.g3d5c

