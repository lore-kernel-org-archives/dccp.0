From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:14:03 +0000
Subject: [PATCH 7/7] dccp ccid-3: Replace lazy BUG_ON with condition
Message-Id: <1217268843-19667-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The BUG_ON(w_tot = 0) only holds if there is no more than 1 loss interval in
the loss history. If there is only a single loss interval, the calc_i_mean()
routine need in fact not be called (RFC 3448, 6.3.1).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -67,7 +67,10 @@ static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
 	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
 
-	for (i=0; i <= k; i++) {
+	if (k <= 0)
+		return;
+
+	for (i = 0; i <= k; i++) {
 		i_i = tfrc_lh_get_interval(lh, i);
 
 		if (i < k) {
@@ -78,7 +81,6 @@ static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 			i_tot1 += i_i * tfrc_lh_weights[i-1];
 	}
 
-	BUG_ON(w_tot = 0);
 	lh->i_mean = max(i_tot0, i_tot1) / w_tot;
 }
 
