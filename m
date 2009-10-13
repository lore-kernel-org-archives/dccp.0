From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:25:33 +0000
Subject: [PATCH 3/4] Implement dropped packets option
Message-Id: <4AD4B80D.8090207@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Implement dropped packets option. First we parse the received option and store the data, then we check the ecn sum along
the intervals described. The last step calcs 'p' from the option data and only suceeds if loss interval data was parsed before
and is ready to be consumed.

Changes:
 - Adds tfrc_sp_check_ecn_sum, that checks ecn in the received option
 - Adds tfrc_sp_p_from_loss_intervals_opt, do 'p' calc from parsed and stored option data
 - Adds tfrc_sp_parse_dropped_packets_opt, that do the parsing of received option, storing data

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:26.926501680 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:38.114908156 -0300
@@ -350,6 +350,206 @@
 		h->ecn_nonce_sum = !h->ecn_nonce_sum;
 }
 
+/*
+ * tfrc_sp_check_ecn_sum  -  check received ecn sum parsed from
+ *			     loss interval option
+ * li_data:		data parsed from options
+ * optval:		data from option
+ * optlen:		option data length
+ * skb:		last received packet
+ */
+bool tfrc_sp_check_ecn_sum(struct tfrc_tx_li_data *li_data, u8 *optval,
+			   u8 optlen, struct sk_buff *skb)
+{
+	u8 skip_length;
+	u32 data_length;
+	u8 sum0, sum1, li_sum;
+	struct tfrc_ecn_echo_sum_entry *entry;
+	u64 seqn;
+
+	if ((optlen < 10) || ((optlen - 1)%3 != 0))
+		return false;
+
+	if (li_data = NULL)
+		return true;
+
+	entry = li_data->ecn_sums_head;
+
+	if (entry = NULL)
+		return true;
+
+	seqn = dccp_hdr_ack_seq(skb);
+
+	while (entry->seq_num != seqn) {
+		entry = entry->previous;
+
+		if (entry = NULL)
+			return true;
+	}
+
+	skip_length = *optval;
+	optval++;
+	optlen--;
+
+	while (skip_length--) {
+		entry = entry->previous;
+
+		if (entry = NULL)
+			return false;
+	}
+
+	optval += 3;
+	optlen -= 3;
+
+	do {
+		sum0 = entry->ecn_echo_sum;
+
+		li_sum = (*((u32 *)optval)&0x80000000) ? 1 : 0;
+
+		optval += 3;
+		optlen -= 3;
+
+		data_length = ntohl((*((u32 *)optval) & 0xFFFFFF00) >> 8);
+
+		while (--data_length) {
+			entry = entry->previous;
+
+			if (entry = NULL)
+				return true;
+		}
+
+		sum1 = entry->ecn_echo_sum;
+
+		if (((sum0+sum1) & 0x1) != li_sum)
+			return false;
+
+		optval += 6;
+		optlen -= 6;
+
+	} while (optlen >= 9);
+
+	if (entry != NULL)
+		tfrc_sp_tx_ld_cleanup(&entry->previous);
+
+	return true;
+}
+
+static struct tfrc_tx_hist_entry*
+	tfrc_sp_seek_tx_entry(struct tfrc_tx_hist_entry *head,
+			      u64 seqno, u32 backward)
+{
+	if (head = NULL)
+		return NULL;
+
+	while (head->seqno != seqno) {
+		head = head->next;
+
+		if (head = NULL)
+			return NULL;
+	}
+
+	while (backward-- > 0) {
+		head = head->next;
+
+		if (head = NULL)
+			return NULL;
+	}
+
+	return head;
+}
+
+/*
+ * tfrc_sp_p_from_loss_intervals_opt  -  calcs p from loss interval option
+ * li_data:		data parsed from options
+ * head:		contains ccval info
+ * curr_ccval:		current ccval
+ * seqno:		last acked seqno
+ */
+u32 tfrc_sp_p_from_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
+				      struct tfrc_tx_hist_entry *head,
+				      u8 curr_ccval, u64 seqno)
+{
+	int i, k;
+	u8 ccval;
+	u32 i_i, i_tot0, i_tot1, w_tot, i_totl, losses, mean;
+	i_tot0 = i_tot1 = w_tot = i_totl = 0;
+
+	if (li_data->loss_interval_data[0] = 0)
+		return 0;
+
+	if (li_data->loss_interval_data[0] < li_data->dropped_packets_data[0])
+		return 0;
+
+	k = li_data->loss_interval_data[0];
+
+	for (i = 1; i <= k; i++) {
+		i_i = li_data->loss_interval_data[i];
+		i_totl += i_i;
+		ccval = tfrc_sp_seek_tx_entry(head, seqno, i_totl - 1)->ccval;
+
+		if (SUB16(curr_ccval, ccval) <= 8) {
+			losses = li_data->dropped_packets_data[i];
+
+			if (losses > 0)
+				i_i = div64_u64(i_i, losses);
+		}
+
+		if (i != k) {
+			i_tot0 += i_i * tfrc_lh_weights[i-1];
+			w_tot  += tfrc_lh_weights[i-1];
+		}
+
+		if (i > 1)
+			i_tot1 += i_i * tfrc_lh_weights[i-2];
+	}
+
+	ccval = tfrc_sp_seek_tx_entry(head, seqno,
+			li_data->loss_interval_data[1] - 1)->ccval;
+
+	if (SUB16(curr_ccval, ccval) > 8)
+		mean = max(i_tot0, i_tot1) / w_tot;
+	else
+		mean = i_tot1 / w_tot;
+
+	return tfrc_sp_invert_loss_event_rate(mean);
+
+	return 0;
+}
+
+/*
+ * tfrc_sp_parse_dropped_packets_opt  -  parses received dropped packets option
+ * li_data:		used to store parsed data
+ * optval:		option data
+ * optlen:		option length
+ */
+void tfrc_sp_parse_dropped_packets_opt(struct tfrc_tx_li_data *li_data,
+				       u8 *optval, u8 optlen)
+{
+	u8 pos;
+	u32 dropped;
+
+	if ((optlen%3) != 0) {
+		li_data->dropped_packets_data[0] = 0;
+		return;
+	}
+
+	pos = 0;
+
+	while (pos < optlen) {
+		dropped = ntohl(((*((u32 *)(optval + pos))) & 0xFFFFFF00) >> 8);
+		li_data->dropped_packets_data[1 + (pos/3)] = dropped;
+
+		if ((pos/3) = 9) {
+			li_data->dropped_packets_data[0] = 9;
+			return;
+		}
+
+		pos += 3;
+	}
+
+	li_data->dropped_packets_data[0] = optlen/3;
+}
+
 static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_ccval)
 {
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
@@ -400,7 +600,10 @@
 	if (cur = NULL)			/* not initialised */
 		return;
 
-	/* FIXME: should probably also count non-data packets (RFC 4342, 6.1) */
+	/*
+	 * FIXME: should probably also count non-data packets
+	 * (RFC 4342, 6.1)
+	 */
 	if (!dccp_data_packet(skb))
 		return;
 
Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:26.926501680 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:38.114908156 -0300
@@ -169,6 +169,14 @@
 extern void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld);
 extern void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data *ld);
 extern int  tfrc_sp_get_random_ect(struct tfrc_tx_li_data *li_data, u64 seqn);
+extern bool tfrc_sp_check_ecn_sum(struct tfrc_tx_li_data *li_data, u8 *optval,
+				  u8 optlen, struct sk_buff *skb);
+struct tfrc_tx_hist_entry;
+extern u32 tfrc_sp_p_from_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
+					     struct tfrc_tx_hist_entry *head,
+					     u8 curr_ccval, u64 seqno);
+extern void tfrc_sp_parse_dropped_packets_opt(struct tfrc_tx_li_data *li_data,
+					      u8 *optval, u8 optlen);
 extern void tfrc_sp_tx_ld_cleanup(struct tfrc_ecn_echo_sum_entry **);
 
 #endif /* _DCCP_LI_HIST_SP_ */

