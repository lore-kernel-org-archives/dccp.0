From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:33 +0000
Subject: [PATCH 6/25]: Use skb timestamp for TX side
Message-Id: <200703211844.33539@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Use skb timestamp for TX side

 This patch uses skb timestamps (and provides the necessary enable/disable
 mechanism) instead of layer-4 timestamping. This affords a more accurate
 RTT estimation.

Background:
-----------
 The sender currently computes the timestamp of received (Ack) packets when 
 the packet is delivered to layer 4. The skb timestamp is taken earlier, and
 the differences are notable: dDuring test runs under different load conditions,
 the layer-4 timestamp was observed to be on average up to 100 microseconds, 
 in the extreme up to a millisecond, later than the skb timestamp. 
 This has a negative impact on the RTT estimation (reduced accuracy).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -469,7 +469,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		do_gettimeofday(&now);
+		skb_get_timestamp(skb, &now);
 
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
@@ -645,6 +645,7 @@ static int ccid3_hc_tx_init(struct ccid 
 				ccid3_hc_tx_no_feedback_timer;
 	hctx->ccid3hctx_no_feedback_timer.data     = (unsigned long)sk;
 	init_timer(&hctx->ccid3hctx_no_feedback_timer);
+	net_enable_timestamp();
 
 	return 0;
 }
@@ -657,6 +658,7 @@ static void ccid3_hc_tx_exit(struct sock
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	net_disable_timestamp();
 
 	/* Empty packet history */
 	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
