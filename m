From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:57:56 +0000
Subject: [PATCH 1/6]: Avoid accumulation of large send credit
Message-Id: <200706091957.56966@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Avoid accumulation of large send credit

Backlogs of packets can accumulate in the CCID3 TX module when for instance
the application does not send for a longer time or sends slowly.
With regard to computing t_nom, this leads to an accumulation of send credits.
The present patch avoids large packet bursts that would result under these
conditions, by setting the backlog window of tardiness to one t_ipi unit.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -352,7 +352,9 @@ static int ccid3_hc_tx_send_packet(struc
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = ktime_delta(hctx->ccid3hctx_t_nom, now);
-		ccid3_pr_debug("delay=%ld\n", (long)delay);
+		/* Resynchronise t_nom when sender has been idle or slow */
+		if (delay + (s64)hctx->ccid3hctx_t_ipi  <  0)
+			hctx->ccid3hctx_t_nom = now;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -361,7 +363,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+		else if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
