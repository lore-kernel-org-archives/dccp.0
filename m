From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 21 Jul 2007 15:01:24 +0000
Subject: [PATCH 1/1][RFC]: Drop `accumulation of large send credits' patch
Message-Id: <200707211601.25016@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Drop `accumulation of large send credit patch'

This patch is provided for convenience for those people who migh have checked
out the test tree, to avoid having to pull again.

The `accumulation of large send credits' will be dropped from the test tree.

See http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/packet_scheduling/2.6.22-scheduler/
for reasons why.

Signed-off-by: Gerrit Renker

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -343,9 +343,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
-		/* Resynchronise t_nom when sender has been idle or slow */
-		if (delay + (s64)hctx->ccid3hctx_t_ipi  <  0)
-			hctx->ccid3hctx_t_nom = now;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -354,7 +351,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		else if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
