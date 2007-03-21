From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:38 +0000
Subject: [PATCH 7/25]: Use skb timestamp for receiver side
Message-Id: <200703211844.38743@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Use skb timestamp for receiver side

 This patch replaces calls to do_gettimeofday at the receiver CCID 3
 with skb timestamps. The skb timestamps are computed earlier in the
 receive path, experimental measurements have shown that up to several
 hundred microseconds can lie between the skb receive timestamp and the
 timestamp taken when CCID 3 receives the packet. This difference has
 a negative impact on RTT estimation (reduced accuracy).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -151,7 +151,7 @@ static inline struct dccp_rx_hist_entry 
 		entry->dccphrx_ccval = dh->dccph_ccval;
 		entry->dccphrx_type  = dh->dccph_type;
 		entry->dccphrx_ndp   = ndp;
-		do_gettimeofday(&entry->dccphrx_tstamp);
+		skb_get_timestamp(skb, &entry->dccphrx_tstamp);
 	}
 
 	return entry;
