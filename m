From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:58:10 +0000
Subject: [PATCH 9/9] [DCCP] CCID3: Remove non-referenced variable
Message-Id: <20061120205810.GJ5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes a non-referenced variable.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 4eada51..fb21f2d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -965,7 +965,6 @@ static void ccid3_hc_rx_packet_recv(stru
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u8 win_count;
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
@@ -1017,8 +1016,6 @@ static void ccid3_hc_rx_packet_recv(stru
 		return;
 	}
 
-	win_count = packet->dccphrx_ccval;
-
 	loss = ccid3_hc_rx_detect_loss(sk, packet);
 
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
-- 
1.4.2.1.g3d5c

