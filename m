From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:14:46 +0000
Subject: [PATCH 06/29] Use skb timestamp for TX side
Message-Id: <20070412211446.GG21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 This patch uses skb timestamps (and provides the necessary enable/disable
 mechanism) instead of layer-4 timestamping. This affords a more accurate
 RTT estimation.

Background:

 The sender currently computes the timestamp of received (Ack) packets when
 the packet is delivered to layer 4. The skb timestamp is taken earlier, and
 the differences are notable: dDuring test runs under different load conditions,
 the layer-4 timestamp was observed to be on average up to 100 microseconds,
 in the extreme up to a millisecond, later than the skb timestamp.
 This has a negative impact on the RTT estimation (reduced accuracy).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index b756e95..a20b636 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -469,7 +469,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		do_gettimeofday(&now);
+		skb_get_timestamp(skb, &now);
 
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
@@ -645,6 +645,7 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 				ccid3_hc_tx_no_feedback_timer;
 	hctx->ccid3hctx_no_feedback_timer.data     = (unsigned long)sk;
 	init_timer(&hctx->ccid3hctx_no_feedback_timer);
+	net_enable_timestamp();
 
 	return 0;
 }
@@ -657,6 +658,7 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	net_disable_timestamp();
 
 	/* Empty packet history */
 	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
-- 
1.5.0.6

