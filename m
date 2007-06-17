From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:54:48 +0000
Subject: [PATCH 9/9]: Interface CCID3 code with newer TFRC LI database
Message-Id: <200706171354.48119@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID]: Interface CCID3 code with newer TFRC LI database

This hooks up the TFRC Loss Interval database with CCID 3 packet reception.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -795,12 +795,11 @@ static void ccid3_hc_rx_packet_recv(stru
 	/*
 	 *	Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist)) {
-		/*
-		 * Loss Handling
-		 *
-		 * XXX: part of subsequent patch
-		 */
+	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
+				&hcrx->ccid3hcrx_li_hist,
+				skb, ndp, ccid3_first_li, sk) ) {
+		do_feedback = 1;
 		goto done_receiving;
 	}
 
@@ -813,14 +812,23 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
-
+	if (! tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
+		/*
+		 * Empty loss history: no loss so far, hence p stays 0.
+		 * Sample RTT values, since an RTT estimate is required for the
+		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
+		 */
 		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
 		if (sample != 0)
 			hcrx->ccid3hcrx_rtt  				tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
 
-	}
+	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb))
+		/*
+		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
+		 * has decreased (resp. p has increased), send feedback now.
+		 */
+		do_feedback = 1;
 
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
