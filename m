From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:16:47 +0000
Subject: [PATCH 19/29] Remove unused fields in packet history structure
Message-Id: <20070412211647.GT21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes two fields of the TX packet history structure which
are not referenced by the CCID 3 code and are not needed:

 * dccphtx_sent  -  is redundant since the fact that an entry is
   present in the TX history in itself is an indication that the
   packet has been sent (cf. dccp_write_xmit and ccid3_hc_tx_packet_sent);

 * dccphtx_rtt  -  is nowhere referenced and is not even required:
   the `Preventing Oscillations' mechanism in [RFC 3448, 4.5] uses a
   moving-average, but does not require to memorize past RTTs;
   the history field has no further use;

As a further benefit, the history entry size is reduced.

NB : Adding the newly created entry is now at the end of packet_sent - if it is
     in the history before being fully filled in, list corruption is possible.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c              |    4 +---
 net/dccp/ccids/lib/packet_history.h |   12 ++----------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 0029979..cd3565f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -408,13 +408,11 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 		DCCP_CRIT("packet history - out of memory!");
 		return;
 	}
-	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 
 	do_gettimeofday(&now);
 	packet->dccphtx_tstamp = now;
 	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
-	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
-	packet->dccphtx_sent   = 1;
+	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 6208188..78ef50f 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -54,9 +54,7 @@
  */
 struct dccp_tx_hist_entry {
 	struct list_head dccphtx_node;
-	u64		 dccphtx_seqno:48,
-			 dccphtx_sent:1;
-	u32		 dccphtx_rtt;
+	u64		 dccphtx_seqno;
 	struct timeval	 dccphtx_tstamp;
 };
 
@@ -71,13 +69,7 @@ static inline struct dccp_tx_hist_entry *
 			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
 					       const gfp_t prio)
 {
-	struct dccp_tx_hist_entry *entry = kmem_cache_alloc(hist->dccptxh_slab,
-							    prio);
-
-	if (entry != NULL)
-		entry->dccphtx_sent = 0;
-
-	return entry;
+	return kmem_cache_alloc(hist->dccptxh_slab, prio);
 }
 
 extern int dccp_tx_hist_get_send_time(struct dccp_tx_hist *, struct list_head *,
-- 
1.5.0.6

