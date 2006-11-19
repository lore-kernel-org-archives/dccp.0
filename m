From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 19 Nov 2006 02:52:39 +0000
Subject: [PATCH 3/3] DCCP: Remove unneeded variable
Message-Id: <200611191552.40380.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2fa0c6d..55b972b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -982,7 +982,6 @@ static void ccid3_hc_rx_packet_recv(stru
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u8 win_count;
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
@@ -1038,8 +1037,6 @@ static void ccid3_hc_rx_packet_recv(stru
 		return;
 	}
 
-	win_count = packet->dccphrx_ccval;
-
 	loss = ccid3_hc_rx_detect_loss(sk, packet);
 
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
