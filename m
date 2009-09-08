From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 08 Sep 2009 18:28:55 +0000
Subject: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to receiver
Message-Id: <4AA6A267.7080500@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
In-Reply-To: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Adds options DROPPED PACKETS and LOSS INTERVALS to receiver. In this patch is added the
mechanism of gathering information about loss intervals and storing it, for later
construction of these two options.

Changes:
 - Adds tfrc_loss_data and tfrc_loss_data_entry, structures that register loss intervals info
 - Adds dccp_skb_is_ecn_ect0 and dccp_skb_is_ecn_ect1 as necessary, so ecn can be verified and
   used in loss intervals option, that reports ecn nonce sum
 - Adds tfrc_sp_update_li_data that updates information about loss intervals
 - Adds tfrc_sp_ld_prepare_data, that fills fields on tfrc_loss_data with current options values
 - And adds a field of type struct tfrc_loss_data to struct tfrc_hc_rx_sock

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales <ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>, <leandroal@gmail.com>

Index: dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:42:37.000000000 -0300
@@ -233,7 +233,9 @@
 }
 
 /* return 1 if a new loss event has been identified */
-static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
+static int __two_after_loss(struct tfrc_rx_hist *h,
+			    struct sk_buff *skb, u32 n3,
+			    bool *new_loss)
 {
 	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
 	    s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
@@ -245,6 +247,7 @@
 		tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 3),
 					       skb, n3);
 		h->num_losses = dccp_loss_count(s2, s3, n3);
+		*new_loss = 1;
 		return 1;
 	}
 
@@ -259,6 +262,7 @@
 					       skb, n3);
 		h->loss_count = 3;
 		h->num_losses = dccp_loss_count(s1, s3, n3);
+		*new_loss = 1;
 		return 1;
 	}
 
@@ -284,6 +288,7 @@
 			tfrc_sp_rx_hist_entry_from_skb(
 					tfrc_rx_hist_loss_prev(h), skb, n3);
 
+		*new_loss = 0;
 		return 0;
 	}
 
@@ -297,6 +302,7 @@
 	h->loss_count = 3;
 	h->num_losses = dccp_loss_count(s0, s3, n3);
 
+	*new_loss = 1;
 	return 1;
 }
 
@@ -348,11 +354,14 @@
  *  operations when loss_count is greater than 0 after calling this function.
  */
 bool tfrc_sp_rx_congestion_event(struct tfrc_rx_hist *h,
-			      struct tfrc_loss_hist *lh,
-	 struct sk_buff *skb, const u64 ndp,
-  u32 (*first_li)(struct sock *), struct sock *sk)
+				 struct tfrc_loss_hist *lh,
+				 struct tfrc_loss_data *ld,
+				 struct sk_buff *skb, const u64 ndp,
+				 u32 (*first_li)(struct sock *),
+				 struct sock *sk)
 {
 	bool new_event = false;
+	bool new_loss = false;
 
 	if (tfrc_sp_rx_hist_duplicate(h, skb))
 		return 0;
@@ -365,12 +374,13 @@
 		__one_after_loss(h, skb, ndp);
 	} else if (h->loss_count != 2) {
 		DCCP_BUG("invalid loss_count %d", h->loss_count);
-	} else if (__two_after_loss(h, skb, ndp)) {
+	} else if (__two_after_loss(h, skb, ndp, &new_loss)) {
 		/*
 		* Update Loss Interval database and recycle RX records
 		*/
 		new_event = tfrc_sp_lh_interval_add(lh, h, first_li, sk,
 						dccp_hdr(skb)->dccph_ccval);
+		tfrc_sp_update_li_data(ld, h, skb, new_loss, new_event);
 		__three_after_loss(h);
 
 	} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(skb)) {
@@ -396,6 +406,8 @@
 		}
 	}
 
+	tfrc_sp_update_li_data(ld, h, skb, new_loss, new_event);
+
 	/*
 	* Update moving-average of `s' and the sum of received payload bytes.
 	*/
Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 10:42:37.000000000 -0300
@@ -14,6 +14,7 @@
 #include "tfrc_sp.h"
 
 static struct kmem_cache  *tfrc_lh_slab  __read_mostly;
+static struct kmem_cache  *tfrc_ld_slab  __read_mostly;
 /* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
 static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
 
@@ -67,6 +68,224 @@
 		}
 }
 
+/*
+ * Allocation routine for new entries of loss interval data
+ */
+static struct tfrc_loss_data_entry *tfrc_ld_add_new(struct tfrc_loss_data *ld)
+{
+	struct tfrc_loss_data_entry *new +			kmem_cache_alloc(tfrc_ld_slab, GFP_ATOMIC);
+
+	if (new = NULL)
+		return NULL;
+
+	memset(new, 0, sizeof(struct tfrc_loss_data_entry));
+
+	new->next = ld->head;
+	ld->head = new;
+	ld->counter++;
+
+	return new;
+}
+
+void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld)
+{
+	struct tfrc_loss_data_entry *next, *h = ld->head;
+
+	if (!h)
+		return;
+
+	while (h) {
+		next = h->next;
+		kmem_cache_free(tfrc_ld_slab, h);
+		h = next;
+	}
+
+	ld->head = NULL;
+	ld->counter = 0;
+}
+
+void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data *ld)
+{
+	u8 *li_ofs, *d_ofs;
+	struct tfrc_loss_data_entry *e;
+	u16 count;
+
+	li_ofs = &ld->loss_intervals_opts[0];
+	d_ofs = &ld->drop_opts[0];
+
+	count = 0;
+	e = ld->head;
+
+	*li_ofs = loss_count + 1;
+	li_ofs++;
+
+	while (e != NULL) {
+
+		if (count < TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH) {
+			*li_ofs = ((htonl(e->lossless_length) & 0x00FFFFFF)<<8);
+			li_ofs += 3;
+			*li_ofs = ((e->ecn_nonce_sum&0x1) << 31) &
+				  (htonl((e->loss_length & 0x00FFFFFF))<<8);
+			li_ofs += 3;
+			*li_ofs = ((htonl(e->data_length) & 0x00FFFFFF)<<8);
+			li_ofs += 3;
+		}
+
+		if (count < TFRC_DROP_OPT_MAX_LENGTH) {
+			*d_ofs = (htonl(e->drop_count) & 0x00FFFFFF)<<8;
+			d_ofs += 3;
+		}
+
+		if ((count >= TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH) &&
+		    (count >= TFRC_DROP_OPT_MAX_LENGTH))
+			break;
+
+		count++;
+		e = e->next;
+	}
+}
+
+void tfrc_sp_update_li_data(struct tfrc_loss_data *ld,
+			    struct tfrc_rx_hist *rh,
+			    struct sk_buff *skb,
+			    bool new_loss, bool new_event)
+{
+	struct tfrc_loss_data_entry *new, *h;
+
+	if (!dccp_data_packet(skb))
+		return;
+
+	if (ld->head = NULL) {
+		new = tfrc_ld_add_new(ld);
+		if (unlikely(new = NULL)) {
+			DCCP_CRIT("Cannot allocate new loss data registry.");
+			return;
+		}
+
+		if (new_loss) {
+			new->drop_count = rh->num_losses;
+			new->lossless_length = 1;
+			new->loss_length = rh->num_losses;
+
+			if (dccp_data_packet(skb))
+				new->data_length = 1;
+
+			if (dccp_data_packet(skb) && dccp_skb_is_ecn_ect1(skb))
+				new->ecn_nonce_sum = 1;
+			else
+				new->ecn_nonce_sum = 0;
+		} else {
+			new->drop_count = 0;
+			new->lossless_length = 1;
+			new->loss_length = 0;
+
+			if (dccp_data_packet(skb))
+				new->data_length = 1;
+
+			if (dccp_data_packet(skb) && dccp_skb_is_ecn_ect1(skb))
+				new->ecn_nonce_sum = 1;
+			else
+				new->ecn_nonce_sum = 0;
+		}
+
+		return;
+	}
+
+	if (new_event) {
+		new = tfrc_ld_add_new(ld);
+		if (unlikely(new = NULL)) {
+			DCCP_CRIT("Cannot allocate new loss data registry. \
+					Cleaning up.");
+			tfrc_sp_ld_cleanup(ld);
+			return;
+		}
+
+		new->drop_count = rh->num_losses;
+		new->lossless_length = (ld->last_loss_count - rh->loss_count);
+		new->loss_length = rh->num_losses;
+
+		new->ecn_nonce_sum = 0;
+		new->data_length = 0;
+
+		while (ld->last_loss_count > rh->loss_count) {
+			ld->last_loss_count--;
+
+			if (ld->sto_is_data & (1 << (ld->last_loss_count))) {
+				new->data_length++;
+
+				if (ld->sto_ecn & (1 << (ld->last_loss_count)))
+					new->ecn_nonce_sum +						!new->ecn_nonce_sum;
+			}
+		}
+
+		return;
+	}
+
+	h = ld->head;
+
+	if (rh->loss_count > ld->last_loss_count) {
+		ld->last_loss_count = rh->loss_count;
+
+		if (dccp_data_packet(skb))
+			ld->sto_is_data |= (1 << (ld->last_loss_count - 1));
+
+		if (dccp_skb_is_ecn_ect1(skb))
+			ld->sto_ecn |= (1 << (ld->last_loss_count - 1));
+
+		return;
+	}
+
+	if (new_loss) {
+		h->drop_count += rh->num_losses;
+		h->lossless_length = (ld->last_loss_count - rh->loss_count);
+		h->loss_length += h->lossless_length + rh->num_losses;
+
+		h->ecn_nonce_sum = 0;
+		h->data_length = 0;
+
+		while (ld->last_loss_count > rh->loss_count) {
+			ld->last_loss_count--;
+
+			if (ld->sto_is_data&(1 << (ld->last_loss_count))) {
+				h->data_length++;
+
+				if (ld->sto_ecn & (1 << (ld->last_loss_count)))
+					h->ecn_nonce_sum = !h->ecn_nonce_sum;
+			}
+		}
+
+		return;
+	}
+
+	if (ld->last_loss_count > rh->loss_count) {
+		while (ld->last_loss_count > rh->loss_count) {
+			ld->last_loss_count--;
+
+			h->lossless_length++;
+
+			if (ld->sto_is_data & (1 << (ld->last_loss_count))) {
+				h->data_length++;
+
+				if (ld->sto_ecn & (1 << (ld->last_loss_count)))
+					h->ecn_nonce_sum = !h->ecn_nonce_sum;
+			}
+		}
+
+		return;
+	}
+
+	h->lossless_length++;
+
+	if (dccp_data_packet(skb)) {
+		h->data_length++;
+
+		if (dccp_skb_is_ecn_ect1(skb))
+			h->ecn_nonce_sum = !h->ecn_nonce_sum;
+	}
+}
+
 static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_ccval)
 {
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
@@ -244,8 +463,11 @@
 	tfrc_lh_slab = kmem_cache_create("tfrc_sp_li_hist",
 					 sizeof(struct tfrc_loss_interval), 0,
 					 SLAB_HWCACHE_ALIGN, NULL);
+	tfrc_ld_slab = kmem_cache_create("tfrc_sp_li_data",
+					 sizeof(struct tfrc_loss_data_entry), 0,
+					 SLAB_HWCACHE_ALIGN, NULL);
 
-	if ((tfrc_lh_slab != NULL))
+	if ((tfrc_lh_slab != NULL) || (tfrc_ld_slab != NULL))
 		return 0;
 
 	if (tfrc_lh_slab != NULL) {
@@ -253,6 +475,11 @@
 		tfrc_lh_slab = NULL;
 	}
 
+	if (tfrc_ld_slab != NULL) {
+		kmem_cache_destroy(tfrc_ld_slab);
+		tfrc_ld_slab = NULL;
+	}
+
 	return -ENOBUFS;
 }
 
@@ -262,4 +489,9 @@
 		kmem_cache_destroy(tfrc_lh_slab);
 		tfrc_lh_slab = NULL;
 	}
+
+	if (tfrc_ld_slab != NULL) {
+		kmem_cache_destroy(tfrc_ld_slab);
+		tfrc_ld_slab = NULL;
+	}
 }
Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:42:37.000000000 -0300
@@ -70,13 +70,52 @@
 struct tfrc_rx_hist;
 #endif
 
+struct tfrc_loss_data_entry {
+	struct tfrc_loss_data_entry	*next;
+	u32				lossless_length:24;
+	u8				ecn_nonce_sum:1;
+	u32				loss_length:24;
+	u32				data_length:24;
+	u32				drop_count:24;
+};
+
+#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH	28
+#define TFRC_DROP_OPT_MAX_LENGTH		84
+#define TFRC_LI_OPT_SZ	\
+	(2 + TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH*9)
+#define TFRC_DROPPED_OPT_SZ \
+	(1 + TFRC_DROP_OPT_MAX_LENGTH*3)
+
+struct tfrc_loss_data {
+	struct tfrc_loss_data_entry	*head;
+	u16				counter;
+	u8				loss_intervals_opts[TFRC_LI_OPT_SZ];
+	u8				drop_opts[TFRC_DROPPED_OPT_SZ];
+	u8				last_loss_count;
+	u8				sto_ecn;
+	u8				sto_is_data;
+};
+
+static inline void tfrc_ld_init(struct tfrc_loss_data *ld)
+{
+	memset(ld, 0, sizeof(struct tfrc_loss_data));
+}
+
+struct tfrc_rx_hist;
+
 extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *,
 				    struct tfrc_rx_hist *,
 				    u32 (*first_li)(struct sock *),
 				    struct sock *,
 				    __u8 ccval);
+extern void tfrc_sp_update_li_data(struct tfrc_loss_data *,
+				   struct tfrc_rx_hist *,
+				   struct sk_buff *,
+				   bool new_loss, bool new_event);
 extern void tfrc_sp_lh_update_i_mean(struct tfrc_loss_hist *lh,
 				     struct sk_buff *);
 extern void tfrc_sp_lh_cleanup(struct tfrc_loss_hist *lh);
+extern void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld);
+extern void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data *ld);
 
 #endif /* _DCCP_LI_HIST_SP_ */
Index: dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/packet_history_sp.h	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.h	2009-09-08 10:42:37.000000000 -0300
@@ -203,6 +203,7 @@
 
 extern bool tfrc_sp_rx_congestion_event(struct tfrc_rx_hist *h,
 				     struct tfrc_loss_hist *lh,
+				     struct tfrc_loss_data *ld,
 				     struct sk_buff *skb, const u64 ndp,
 				     u32 (*first_li)(struct sock *sk),
 				     struct sock *sk);
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-09-08 10:42:37.000000000 -0300
@@ -129,6 +129,7 @@
  *  @tstamp_last_feedback  -  Time at which last feedback was sent
  *  @hist  -  Packet history (loss detection + RTT sampling)
  *  @li_hist  -  Loss Interval database
+ *  @li_data  -  Loss Interval data for options
  *  @p_inverse  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct tfrc_hc_rx_sock {
@@ -138,6 +139,7 @@
 	ktime_t				tstamp_last_feedback;
 	struct tfrc_rx_hist		hist;
 	struct tfrc_loss_hist		li_hist;
+	struct tfrc_loss_data		li_data;
 #define p_inverse			li_hist.i_mean
 };
 
Index: dccp_tree_work5/net/dccp/dccp.h
=================================--- dccp_tree_work5.orig/net/dccp/dccp.h	2009-09-08 10:42:30.000000000 -0300
+++ dccp_tree_work5/net/dccp/dccp.h	2009-09-08 10:42:37.000000000 -0300
@@ -403,6 +403,16 @@
 	return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) = INET_ECN_CE;
 }
 
+static inline bool dccp_skb_is_ecn_ect0(const struct sk_buff *skb)
+{
+	return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) = INET_ECN_ECT_0;
+}
+
+static inline bool dccp_skb_is_ecn_ect1(const struct sk_buff *skb)
+{
+	return (DCCP_SKB_CB(skb)->dccpd_ecn & INET_ECN_MASK) = INET_ECN_ECT_0;
+}
+
 /* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {


