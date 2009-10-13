From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:19:02 +0000
Subject: [PATCHv2 3/4] Implement TFRC-SP calc of mean length of loss intervals,
Message-Id: <4AD4B686.4090309@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Implement TFRC-SP calc of mean length of loss intervals accordingly to section 3 of RFC 4828

Changes:
 - Modify tfrc_sp_lh_calc_i_mean header, now receiving the current ccval, so it can determine
  if a loss interval is too recent
 - Consider number of losses in each loss interval
 - Only consider open loss interval if it is at least 2 rtt old
 - Changes function signatures as necessary

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:07.439908552 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:14.214408089 -0300
@@ -29,13 +29,15 @@
  *  @li_seqno:		Highest received seqno before the start of loss
  *  @li_ccval:		The CCVal belonging to @li_seqno
  *  @li_is_closed:	Whether @li_seqno is older than 1 RTT
+ *  @li_is_short:	Whether this interval is no longer that 2 RTT
  *  @li_length:		Loss interval sequence length
  *  @li_losses:        Number of losses counted on this interval
  */
 struct tfrc_loss_interval {
 	u64		 li_seqno:48,
 			 li_ccval:4,
-			 li_is_closed:1;
+			 li_is_closed:1,
+			 li_is_short:1;
 	u32		 li_length;
 	u32              li_losses;
 };
Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:07.439908552 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:14.214408089 -0300
@@ -36,6 +36,27 @@
 	return lh->ring[LIH_INDEX(lh->counter - i - 1)]->li_length;
 }
 
+static inline u32
+tfrc_lh_loss_interval_losses(struct tfrc_loss_hist *lh, const u8 i)
+{
+	BUG_ON(i >= lh->counter);
+	return lh->ring[LIH_INDEX(lh->counter - i - 1)]->li_losses;
+}
+
+static inline u8
+tfrc_lh_interval_is_short(struct tfrc_loss_hist *lh, const u8 i)
+{
+	BUG_ON(i >= lh->counter);
+	return lh->ring[LIH_INDEX(lh->counter - i - 1)]->li_is_short;
+}
+
+static inline u8
+tfrc_lh_loss_interval_ccval(struct tfrc_loss_hist *lh, const u8 i)
+{
+	BUG_ON(i >= lh->counter);
+	return lh->ring[LIH_INDEX(lh->counter - i - 1)]->li_ccval;
+}
+
 /*
  *	On-demand allocation and de-allocation of entries
  */
@@ -61,10 +82,11 @@
 		}
 }
 
-static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_ccval)
 {
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
 	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
+	u32 losses;
 
 	if (k <= 0)
 		return;
@@ -72,6 +94,14 @@
 	for (i = 0; i <= k; i++) {
 		i_i = tfrc_lh_get_interval(lh, i);
 
+		if (tfrc_lh_interval_is_short(lh, i)) {
+
+			losses = tfrc_lh_loss_interval_losses(lh, i);
+
+			if (losses > 0)
+				i_i = DIV_ROUND_UP(i_i, losses);
+		}
+
 		if (i < k) {
 			i_tot0 += i_i * tfrc_lh_weights[i];
 			w_tot  += tfrc_lh_weights[i];
@@ -81,6 +111,11 @@
 	}
 
 	lh->i_mean = max(i_tot0, i_tot1) / w_tot;
+	BUG_ON(w_tot = 0);
+	if (SUB16(curr_ccval, tfrc_lh_loss_interval_ccval(lh, 0) > 8))
+		lh->i_mean = max(i_tot0, i_tot1) / w_tot;
+	else
+		lh->i_mean = i_tot1 / w_tot;
 }
 
 /**
@@ -121,7 +156,7 @@
 		return;
 
 	cur->li_length = len;
-	tfrc_sp_lh_calc_i_mean(lh);
+	tfrc_sp_lh_calc_i_mean(lh, dccp_hdr(skb)->dccph_ccval);
 }
 
 /* RFC 4342, 10.2: test for the existence of packet with sequence number S */
@@ -191,6 +226,9 @@
 
 		/* RFC 5348, 5.3: length between subsequent intervals */
 		cur->li_length = len;
+
+		if (SUB16(cong_evt->tfrchrx_ccval, cur->li_ccval) <= 8)
+			cur->li_is_short = 1;
 	}
 
 	/* Make the new interval the current one */
@@ -203,6 +241,7 @@
 	cur->li_seqno	  = cong_evt_seqno;
 	cur->li_ccval	  = cong_evt->tfrchrx_ccval;
 	cur->li_is_closed = false;
+	cur->li_is_short  = 0;
 	cur->li_losses    = rh->num_losses;
 	rh->num_losses = 0;
 
@@ -216,7 +255,7 @@
 		if (lh->counter > (2*LIH_SIZE))
 			lh->counter -= LIH_SIZE;
 
-		tfrc_sp_lh_calc_i_mean(lh);
+		tfrc_sp_lh_calc_i_mean(lh, cong_evt->tfrchrx_ccval);
 	}
 	return true;
 }

