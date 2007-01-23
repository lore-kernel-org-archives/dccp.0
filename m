From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:41:16 +0000
Subject: [PATCH 7/7]: Use initial RTT sample from SYN exchange
Message-Id: <200701231541.16360@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Use initial RTT sample from SYN exchange

The patch follows the following recommendation made in an erratum to RFC 4342:

  "Senders MAY additionally make use of other available RTT measurements, 
   including those from the initial Request-Response packet exchange."

It implements larger initial windows with regard to this inital RTT measurement,
using the mechanism suggested in draft-ietf-dccp-rfc3448bis, section 4.2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -337,15 +337,24 @@ static int ccid3_hc_tx_send_packet(struc
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
-		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
 		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
-		hctx->ccid3hctx_x <<= 6;
 
-		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
-		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
-		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
-		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
+		/*
+		 * Use initial RTT sample when available: recommended by erratum
+		 * to RFC 4342. This implements the initialisation procedure of
+		 * draft-ietf-dccp-rfc3448bis, section 4.2. X is scaled by 2^6.
+		 */
+		if (dp->dccps_syn_rtt) {
+			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
+			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+			hctx->ccid3hctx_t_ld = now;
+		} else {
+			/* Fall back to RFC 3448: set X/s initially to 1pps */
+			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+			hctx->ccid3hctx_x <<= 6;
+		}
+		ccid3_update_send_interval(hctx);
 
 		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
