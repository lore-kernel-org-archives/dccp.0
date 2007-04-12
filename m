From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:14:54 +0000
Subject: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <20070412211454.GH21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 This patch replaces calls to do_gettimeofday at the receiver CCID 3
 with skb timestamps. The skb timestamps are computed earlier in the
 receive path, experimental measurements have shown that up to several
 hundred microseconds can lie between the skb receive timestamp and the
 timestamp taken when CCID 3 receives the packet. This difference has
 a negative impact on RTT estimation (reduced accuracy).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/lib/packet_history.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index b40b9f9..330b58f 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -151,7 +151,7 @@ static inline struct dccp_rx_hist_entry *
 		entry->dccphrx_ccval = dh->dccph_ccval;
 		entry->dccphrx_type  = dh->dccph_type;
 		entry->dccphrx_ndp   = ndp;
-		do_gettimeofday(&entry->dccphrx_tstamp);
+		skb_get_timestamp(skb, &entry->dccphrx_tstamp);
 	}
 
 	return entry;
-- 
1.5.0.6

