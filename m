From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Jul 2008 14:51:50 +0000
Subject: [PATCH 4/4] dccp ccid-3: Length of loss intervals
Message-Id: <1215874310-10534-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This corrects an error in the computation of the open loss interval I_0:
  * the interval length is (highest_seqno - start_seqno) + 1
  * and not (highest_seqno - start_seqno).

This condition was not fully clear in RFC 3448, but reflects the current
revision state of rfc3448bis and is also consistent with RFC 4340, 6.1.1.

Further changes:
----------------
 * variable renamed due to line length constraints;
 * explicit typecast to `s64' to avoid implicit signed/unsigned casting.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -90,14 +90,14 @@ u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 {
 	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh);
 	u32 old_i_mean = lh->i_mean;
-	s64 length;
+	s64 len;
 
 	if (cur = NULL)			/* not initialised */
 		return 0;
 
-	length = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq);
+	len = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq) + 1;
 
-	if (length - cur->li_length <= 0)	/* duplicate or reordered */
+	if (len - (s64)cur->li_length <= 0)	/* duplicate or reordered */
 		return 0;
 
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, cur->li_ccval) > 4)
@@ -114,7 +114,7 @@ u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 	if (tfrc_lh_length(lh) = 1)		/* due to RFC 3448, 6.3.1 */
 		return 0;
 
-	cur->li_length = length;
+	cur->li_length = len;
 	tfrc_lh_calc_i_mean(lh);
 
 	return (lh->i_mean < old_i_mean);
@@ -159,7 +159,7 @@ int tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
 	else {
 		cur->li_length = dccp_delta_seqno(cur->li_seqno, new->li_seqno);
 		new->li_length = dccp_delta_seqno(new->li_seqno,
-				  tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno);
+				  tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
 		if (lh->counter > (2*LIH_SIZE))
 			lh->counter -= LIH_SIZE;
 
