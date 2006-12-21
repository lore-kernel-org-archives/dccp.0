From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 20:44:42 +0000
Subject: [PATCH 1/1]: Fix packet tardiness bug in CCID 3
Message-Id: <200612212044.42230@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Fix packet tardiness BUG

 This fixes a bug introduced by myself. 

 A huge lot of thanks to Ian McDonald who identified this bug. 

Problem:
--------
 Due to packet scheduling in CCID 3, it can happen that the
 actual send time of a packet is later than t_now: in this case
 t_nom < t_now. 
 This case brings the entire packet scheduling out of sync, since
 the next packet is scheduled at t_nom + t_ipi, and t_nom is in
 the past.

Fix:
----
 Update t_nom to t_now whenever a packet is late due to scheduling
 (and then t_nom < t_now). This update takes place in ccid3_hc_tx_
 send_packet. In between calls to this function, it is irrelevant
 if t_nom < t_now (since it will be caught eventually). 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -349,7 +349,9 @@ static int ccid3_hc_tx_send_packet(struc
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
-		ccid3_pr_debug("delay=%ld\n", (long)delay);
+		/* handle packet tardiness: synchronise t_nom with send time */
+		if (delay < 0)
+			hctx->ccid3hctx_t_nom = now;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -358,7 +360,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
+		else if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
 			return delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, &now);
