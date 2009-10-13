From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:27:34 +0000
Subject: [PATCH 4/4] Implement loss intervals option
Message-Id: <4AD4B886.5080804@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Implement loss intervals option. Similar to dropped packets option implementation, reference it.

Changes:
 - Adds tfrc_sp_parse_loss_intervals_opt, that parses loss intervals option received data

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:38.114908156 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:43.986408220 -0300
@@ -550,6 +550,46 @@
 	li_data->dropped_packets_data[0] = optlen/3;
 }
 
+/*
+ * tfrc_sp_parse_loss_intervals_opt  -  parses loss interval option
+ * li_data:		used to store parsed data
+ * optval:		option data
+ * optlen:		option length
+ */
+void tfrc_sp_parse_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
+				      u8 *optval, u8 optlen)
+{
+	u8 pos;
+	u32 length;
+
+	if ((optlen%9) != 1) {
+		li_data->loss_interval_data[0] = 0;
+		return;
+	}
+
+	pos = 1;
+	optval++;
+
+	while (pos < optlen) {
+		length = ntohl(((*((u32 *)optval)) & 0xFFFFFF00) >> 8);
+		pos += 3;
+		optval += 3;
+
+		length += ntohl(((*((u32 *)optval))&0x7FFFFF00) >> 8);
+		pos += 6;
+		optval += 6;
+
+		li_data->loss_interval_data[(pos-1)%9] = length;
+
+		if ((pos/9) = 9) {
+			li_data->loss_interval_data[0] = 9;
+			return;
+		}
+	}
+
+	li_data->loss_interval_data[0] = (optlen-1)/9;
+}
+
 static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_ccval)
 {
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:38.114908156 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:43.986408220 -0300
@@ -177,6 +177,8 @@
 					     u8 curr_ccval, u64 seqno);
 extern void tfrc_sp_parse_dropped_packets_opt(struct tfrc_tx_li_data *li_data,
 					      u8 *optval, u8 optlen);
+extern void tfrc_sp_parse_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
+					      u8 *optval, u8 optlen);
 extern void tfrc_sp_tx_ld_cleanup(struct tfrc_ecn_echo_sum_entry **);
 
 #endif /* _DCCP_LI_HIST_SP_ */

