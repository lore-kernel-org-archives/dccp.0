From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 Mar 2007 11:39:35 +0000
Subject: [PATCH v2]: 5f: Specification changed while patch was in the queue
Message-Id: <200703131139.35994@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While at it, I noted that the spec now says "MSS/second" instead of "1 packet/second"
in draft rfc3448bis Rev01 (which came out a week ago). Better to change that now, 
interdiff to previous patch below. Have checked other patches so that the references
are up-to-date with draft rfc3448bis-01.

INTERDIFF v1 .. v2:
 @@ -342,7 +342,7 @@
                /*
                 * Use initial RTT sample when available: recommended by erratum
                 * to RFC 4342. This implements the initialisation procedure of
 -                * draft rfc3448bis, section 4.2. Remember, X is scaled by 2^6.
 +                * draft-ietf-dccp-rfc3448bis, section 4.2. X is scaled by 2^6.
                 */
                if (dp->dccps_syn_rtt) {
                        ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
 @@ -350,8 +350,8 @@
                        hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
                        hctx->ccid3hctx_t_ld = now;
                } else {
 -                       /* Sender does not have RTT sample: X = MSS/second */
 -                       hctx->ccid3hctx_x = dp->dccps_mss_cache;
 +                       /* Fall back to RFC 3448: set X/s initially to 1pps */
 +                       hctx->ccid3hctx_x = hctx->ccid3hctx_s;
                        hctx->ccid3hctx_x <<= 6;
                

==============> Patch v2 <=========================
[CCID 3]: Use initial RTT sample from SYN exchange

The patch follows the following recommendation made in an erratum to RFC 4342:

  "Senders MAY additionally make use of other available RTT measurements, 
   including those from the initial Request-Response packet exchange."

It implements larger initial windows with regard to this inital RTT measurement,
using the mechanism suggested in draft-ietf-dccp-rfc3448bis, section 4.2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -333,19 +333,30 @@ static int ccid3_hc_tx_send_packet(struc
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
 		hctx->ccid3hctx_last_win_count	 = 0;
 		hctx->ccid3hctx_t_last_win_count = now;
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-
-		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-		hctx->ccid3hctx_x  =  hctx->ccid3hctx_s  =  skb->len;
-		hctx->ccid3hctx_x <<= 6;
-
-		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
-		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
-		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
-		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
 
 		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
+
+		hctx->ccid3hctx_s = skb->len;
+
+		/*
+		 * Use initial RTT sample when available: recommended by erratum
+		 * to RFC 4342. This implements the initialisation procedure of
+		 * draft rfc3448bis, section 4.2. Remember, X is scaled by 2^6.
+		 */
+		if (dp->dccps_syn_rtt) {
+			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
+			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+			hctx->ccid3hctx_t_ld = now;
+		} else {
+			/* Sender does not have RTT sample: X = MSS/second */
+			hctx->ccid3hctx_x = dp->dccps_mss_cache;
+			hctx->ccid3hctx_x <<= 6;
+		}
+		ccid3_update_send_interval(hctx);
+
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
