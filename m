From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:13:14 +0000
Subject: [Patch 8/12]: TX history - remove unused field
Message-Id: <200612072113.14871@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: TX history - remove unused field

This removes the `dccphtx_ccval' field since it is nowhere
used in the code and in fact not necessary for the accounting.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    5 +++--
 net/dccp/ccids/lib/packet_history.h |    1 -
 2 files changed, 3 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -370,8 +370,9 @@ static int ccid3_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	new_packet->dccphtx_ccval = DCCP_SKB_CB(skb)->dccpd_ccval -				    hctx->ccid3hctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+
+	/* set the nominal send time for the next following packet */
 	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
 	return 0;
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -52,7 +52,6 @@
 struct dccp_tx_hist_entry {
 	struct list_head dccphtx_node;
 	u64		 dccphtx_seqno:48,
-			 dccphtx_ccval:4,
 			 dccphtx_sent:1;
 	u32		 dccphtx_rtt;
 	struct timeval	 dccphtx_tstamp;
