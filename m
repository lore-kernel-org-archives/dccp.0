From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 08 Dec 2007 18:52:12 +0000
Subject: [PATCH 2/3] [TFRC]: The function tfrc_rx_hist_entry_delete() is not used anymore
Message-Id: <1197139933-11609-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/packet_history.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 54cd23e..af44082 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -151,11 +151,6 @@ void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-static inline void tfrc_rx_hist_entry_delete(struct tfrc_rx_hist_entry *entry)
-{
-	kmem_cache_free(tfrc_rx_hist_slab, entry);
-}
-
 /**
  * tfrc_rx_hist_entry - return the n-th history entry after loss_start
  */
-- 
1.5.3.4

