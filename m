From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sat, 28 Oct 2017 20:48:47 +0000
Subject: [PATCH] net: dccp: ccids: lib: packet_history: use swap macro in tfrc_rx_hist_swap
Message-Id: <20171028204847.GA12655@embeddedor.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/dccp/ccids/lib/packet_history.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 08df7a3..876e185 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -149,10 +149,8 @@ static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
 {
 	const u8 idx_a = tfrc_rx_hist_index(h, a),
 		 idx_b = tfrc_rx_hist_index(h, b);
-	struct tfrc_rx_hist_entry *tmp = h->ring[idx_a];
 
-	h->ring[idx_a] = h->ring[idx_b];
-	h->ring[idx_b] = tmp;
+	swap(h->ring[idx_a], h->ring[idx_b]);
 }
 
 /*
-- 
2.7.4

