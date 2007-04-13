From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 17:57:29 +0000
Subject: [PATCHv2 08/29] Honour initial RTT estimate
Message-Id: <200704131857.29383@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am resubmitting this patch since David pulled it out
this morning and had issues with it - this is to show
that there is no more reliance on skb_get_timestamp.

There is a related issue, for which an update will also be provided.

------------------> Patch v2 <--------------------------
[CCID 3]: Honour initial RTT estimate

This is a small optimisation which improves the accuracy of TX
RTT sampling when an initial RTT sample (e.g. from the intial
Request/Response exchange) is available.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -469,28 +469,29 @@ static void ccid3_hc_tx_packet_recv(stru
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		dccp_timestamp(sk, &now);
-
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
 		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
+		dccp_timestamp(sk, &now);
 		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
 
 		/*
-		 * Update RTT estimate by
-		 * If (No feedback recv)
+		 * Update RTT estimate (honours RTT from SYN exchange):
+		 * If (No RTT sample so far)
 		 *    R = R_sample;
 		 * Else
 		 *    R = q * R + (1 - q) * R_sample;
 		 *
 		 * q is a constant, RFC 3448 recomments 0.9
 		 */
+		hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
+				    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
+
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 */
-			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 
@@ -504,8 +505,6 @@ static void ccid3_hc_tx_packet_recv(stru
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
-			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
-						   r_sample) / 10;
 
 			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 			if (hctx->ccid3hctx_p > 0)
