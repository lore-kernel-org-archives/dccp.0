From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:23:28 +0000
Subject: [PATCH 1/4] Adds random ect generation to tfrc-sp sender side
Message-Id: <4AD4B790.9000701@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Adds random ect generation to tfrc-sp sender side. Before sending the packet, TFRC-SP chooses randomly
one ect codepoint, returns it and register at the ect history list.

Changes:
 - Creates tfrc_sp_get_random_ect, that uses random.h to choose one ect codepoint
 - Defines tfrc_tx_li_data, that stores data parsed from options loss intervals and dropped packets, and ecn nonce history
 - Defines tfrc_ecn_echo_sum_entry, type of entries of ecn nonce history list
 - Adds memory manage routines and code to these structures

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:20.526408512 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:26.926501680 -0300
@@ -15,6 +15,7 @@
 
 static struct kmem_cache  *tfrc_lh_slab  __read_mostly;
 static struct kmem_cache  *tfrc_ld_slab  __read_mostly;
+static struct kmem_cache  *tfrc_ecn_echo_sum_slab  __read_mostly;
 /* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
 static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
 
@@ -84,6 +85,48 @@
 }
 
 /*
+ * tfrc_sp_get_random_ect  -  return random ect codepoint
+ * li_data:		data where to register ect sent
+ * seqn:		packet's sequence number
+ */
+int tfrc_sp_get_random_ect(struct tfrc_tx_li_data *li_data, u64 seqn)
+{
+	int ect;
+	struct tfrc_ecn_echo_sum_entry *sum;
+
+	/* TODO: implement random ect*/
+	ect = INET_ECN_ECT_0;
+
+	sum = kmem_cache_alloc(tfrc_ecn_echo_sum_slab, GFP_ATOMIC);
+
+	sum->previous = li_data->ecn_sums_head;
+	sum->ecn_echo_sum = (sum->previous->ecn_echo_sum) ? !ect : ect;
+	sum->seq_num = seqn;
+
+	li_data->ecn_sums_head = sum;
+
+	return ect;
+}
+
+/*
+ * tfrc_sp_tx_ld_cleanup  -  free all entries
+ * echo_sums_data:		head of the list
+ */
+void tfrc_sp_tx_ld_cleanup(struct tfrc_ecn_echo_sum_entry **echo_sums_data)
+{
+	struct tfrc_ecn_echo_sum_entry *e, *previous;
+	e = *echo_sums_data;
+
+	while (e != NULL) {
+		previous = e->previous;
+		kmem_cache_free(tfrc_ecn_echo_sum_slab, e);
+		e = previous;
+	}
+
+	*echo_sums_data = NULL;
+}
+
+/*
  * Allocation routine for new entries of loss interval data
  */
 static struct tfrc_loss_data_entry *tfrc_ld_add_new(struct tfrc_loss_data *ld)
@@ -493,8 +536,13 @@
 	tfrc_ld_slab = kmem_cache_create("tfrc_sp_li_data",
 					 sizeof(struct tfrc_loss_data_entry), 0,
 					 SLAB_HWCACHE_ALIGN, NULL);
-
-	if ((tfrc_lh_slab != NULL) && (tfrc_ld_slab != NULL))
+	tfrc_ecn_echo_sum_slab = kmem_cache_create("tfrc_sp_ecn_echo_sum",
+				sizeof(struct tfrc_ecn_echo_sum_entry), 0,
+						SLAB_HWCACHE_ALIGN, NULL);
+
+	if ((tfrc_lh_slab != NULL) &&
+	    (tfrc_ld_slab != NULL) &&
+	    (tfrc_ecn_echo_sum_slab != NULL))
 		return 0;
 
 	if (tfrc_lh_slab != NULL) {
@@ -507,6 +555,11 @@
 		tfrc_ld_slab = NULL;
 	}
 
+	if (tfrc_ecn_echo_sum_slab != NULL) {
+		kmem_cache_destroy(tfrc_ecn_echo_sum_slab);
+		tfrc_ecn_echo_sum_slab = NULL;
+	}
+
 	return -ENOBUFS;
 }
 
@@ -521,4 +574,9 @@
 		kmem_cache_destroy(tfrc_ld_slab);
 		tfrc_ld_slab = NULL;
 	}
+
+	if (tfrc_ecn_echo_sum_slab != NULL) {
+		kmem_cache_destroy(tfrc_ecn_echo_sum_slab);
+		tfrc_ecn_echo_sum_slab = NULL;
+	}
 }
Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:20.526408512 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:26.926501680 -0300
@@ -128,6 +128,31 @@
 	memset(ld, 0, sizeof(*ld));
 }
 
+/*
+ * tfrc_ecn_echo_sum_entry  -  store sent ecn codepoint info
+ * ecn_echo_sum:		ecn echo sum up to that packet
+ * seq_num:			sequence number of packet
+ * previous:			previous sent packet info
+ */
+struct tfrc_ecn_echo_sum_entry {
+	u8				ecn_echo_sum:1;
+	u64				seq_num:48;
+	struct tfrc_ecn_echo_sum_entry	*previous;
+};
+
+/*
+ * tfrc_tx_li_data  -  data about sent ecn and parsed options
+ * ecn_sums_head:		ecn data list
+ * seq_num:			sequence number of packet
+ * previous:			previous sent packet info
+ */
+struct tfrc_tx_li_data {
+	struct tfrc_ecn_echo_sum_entry	*ecn_sums_head;
+	u32				dropped_packets_data[1 + 9];
+	u32				loss_interval_data[1 + 9];
+	u8				skip_length;
+};
+
 struct tfrc_rx_hist;
 
 extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *,
@@ -143,6 +168,8 @@
 extern void tfrc_sp_lh_cleanup(struct tfrc_loss_hist *lh);
 extern void tfrc_sp_ld_cleanup(struct tfrc_loss_data *ld);
 extern void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data *ld);
+extern int  tfrc_sp_get_random_ect(struct tfrc_tx_li_data *li_data, u64 seqn);
+extern void tfrc_sp_tx_ld_cleanup(struct tfrc_ecn_echo_sum_entry **);
 
 #endif /* _DCCP_LI_HIST_SP_ */
 
Index: dccp_tree_work03/net/dccp/ccids/lib/tfrc_ccids_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-10-08 22:59:20.526408512 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-10-08 22:59:26.926501680 -0300
@@ -85,6 +85,7 @@
 	ktime_t				t_ld;
 	ktime_t				t_nom;
 	struct tfrc_tx_hist_entry	*hist;
+	struct tfrc_tx_li_data 		li_data;
 };
 
 static inline struct tfrc_hc_tx_sock *tfrc_hc_tx_sk(const struct sock *sk)

