From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Feb 2012 02:05:54 +0000
Subject: [PATCH 1/1] dccp ccid-3: replace incorrect BUG_ON
Message-Id: <20120227020554.GB14246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp ccid-3: replace incorrect BUG_ON

This replaces an unjustified BUG_ON(), which could get triggered under normal
conditions: X_calc can be 0 when p > 0. X would in this case be set to the
minimum, s/t_mbi. Its replacement avoids t_ipi = 0 (unbounded sending rate).

Thanks to Jordi, Victor and Xavier who reported this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -98,6 +98,7 @@ static void ccid3_update_send_interval(s
 {
 	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 
+	DCCP_BUG_ON(hc->tx_t_ipi = 0);
 	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hc->tx_t_ipi,
 		       hc->tx_s, (unsigned)(hc->tx_x >> 6));
 }
@@ -236,8 +237,6 @@ static void ccid3_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hc->tx_p && !hc->tx_x_calc);
-
 		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
 			hc->tx_x_recv  				max(hc->tx_x_recv / 2,
