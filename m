From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Dec 2006 02:49:40 +0000
Subject: [PATCH 5/5]: DCCP Fix initial s
Message-Id: <200612201549.41083.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

If we set s to first packet size then s is way too low as this is not a
data packet. On my system this is 24 bytes (skb->len) and if sending
1400 byte packets you are sending at a rate over 50 x too much.

More conservative default is mss and follows general principle of being
conservative rather than aggressive.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1ae4f52..b40cad6 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -342,7 +342,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
 		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-		ccid3_hc_tx_update_s(hctx, skb->len);
+		ccid3_hc_tx_update_s(hctx, dp->dccps_mss_cache);
 		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
 		hctx->ccid3hctx_x <<= 6;
 
