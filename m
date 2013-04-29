From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 29 Apr 2013 03:06:01 +0000
Subject: [PATCH 1/1]
Message-Id: <20130428210601.70b8357c@liptov.cs.ualberta.ca>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ivo, Leandro, please check -- CCID-4 subtree has been updated with this patch

dccp ccid4: fix bug in handling the 2nd interval loss

This backports the fix developed by Samuel Jero for the CCID-3 code to CCID-4.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval_sp.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval_sp.c
+++ b/net/dccp/ccids/lib/loss_interval_sp.c
@@ -757,9 +757,21 @@ bool tfrc_sp_lh_interval_add(struct tfrc
 	cur->li_losses = rh->num_losses;
 	rh->num_losses = 0;
 
-	if (++lh->counter = 1)
+	if (++lh->counter = 1) {
 		lh->i_mean = cur->li_length = (*calc_first_li)(sk);
-	else {
+		cur->li_is_closed = true;
+		cur = tfrc_lh_demand_next(lh);
+		if (unlikely(cur = NULL)) {
+			DCCP_CRIT("Cannot allocate/add loss record.");
+			return false;
+		}
+		++lh->counter;
+		cur->li_seqno	  = cong_evt_seqno;
+		cur->li_ccval	  = cong_evt->tfrchrx_ccval;
+		cur->li_is_closed = false;
+		cur->li_length    = dccp_delta_seqno(cur->li_seqno,
+				 tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
+	} else {
 		/* RFC 5348, 5.3: length of the open loss interval I_0 */
 		cur->li_length = dccp_delta_seqno(cur->li_seqno,
 				 tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
