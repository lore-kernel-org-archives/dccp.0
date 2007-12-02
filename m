From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 02 Dec 2007 21:36:54 +0000
Subject: [PATCH 5/7] [TFRC]: Rename dccp_rx_ to tfrc_rx_
Message-Id: <1196631416-17778-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is in preparation for merging the new rx history code written by Gerrit Renker.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c              |   32 ++++++------
 net/dccp/ccids/lib/loss_interval.c  |   14 +++---
 net/dccp/ccids/lib/packet_history.c |   90 +++++++++++++++++-----------------
 net/dccp/ccids/lib/packet_history.h |   48 +++++++++---------
 4 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 07920bb..c95dca8 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -677,7 +677,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_rx_hist_entry *packet;
+	struct tfrc_rx_hist_entry *packet;
 	ktime_t now;
 	suseconds_t delta;
 
@@ -701,7 +701,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 		return;
 	}
 
-	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
+	packet = tfrc_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("%s(%p), no data packet in history!\n",
 			  dccp_role(sk), sk);
@@ -709,7 +709,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	}
 
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
+	hcrx->ccid3hcrx_ccval_last_counter   = packet->tfrchrx_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	if (hcrx->ccid3hcrx_p = 0)
@@ -752,12 +752,12 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 }
 
 static int ccid3_hc_rx_detect_loss(struct sock *sk,
-				    struct dccp_rx_hist_entry *packet)
+				    struct tfrc_rx_hist_entry *packet)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *rx_hist -				dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
-	u64 seqno = packet->dccphrx_seqno;
+	struct tfrc_rx_hist_entry *rx_hist +				tfrc_rx_hist_head(&hcrx->ccid3hcrx_hist);
+	u64 seqno = packet->tfrchrx_seqno;
 	u64 tmp_seqno;
 	int loss = 0;
 	u8 ccval;
@@ -766,9 +766,9 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 
 	if (!rx_hist ||
-	   follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
+	   follows48(packet->tfrchrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
 		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
+		hcrx->ccid3hcrx_ccval_nonloss = packet->tfrchrx_ccval;
 		goto detect_out;
 	}
 
@@ -789,7 +789,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
 		dccp_inc_seqno(&tmp_seqno);
-		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
+		while (tfrc_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
 		   tmp_seqno, &ccval)) {
 			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
 			hcrx->ccid3hcrx_ccval_nonloss = ccval;
@@ -799,13 +799,13 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 
 	/* FIXME - this code could be simplified with above while */
 	/* but works at moment */
-	if (follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
+	if (follows48(packet->tfrchrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
 		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
+		hcrx->ccid3hcrx_ccval_nonloss = packet->tfrchrx_ccval;
 	}
 
 detect_out:
-	dccp_rx_hist_add_packet(&hcrx->ccid3hcrx_hist,
+	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist,
 				&hcrx->ccid3hcrx_li_hist, packet,
 				hcrx->ccid3hcrx_seqno_nonloss);
 	return loss;
@@ -815,7 +815,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	const struct dccp_options_received *opt_recv;
-	struct dccp_rx_hist_entry *packet;
+	struct tfrc_rx_hist_entry *packet;
 	u32 p_prev, r_sample, rtt_prev;
 	int loss, payload_size;
 	ktime_t now;
@@ -850,7 +850,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	packet = dccp_rx_hist_entry_new(opt_recv->dccpor_ndp, skb, GFP_ATOMIC);
+	packet = tfrc_rx_hist_entry_new(opt_recv->dccpor_ndp, skb, GFP_ATOMIC);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
 			  "to history, consider it lost!\n", dccp_role(sk), sk);
@@ -933,7 +933,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	/* Empty packet history */
-	dccp_rx_hist_purge(&hcrx->ccid3hcrx_hist);
+	tfrc_rx_hist_purge(&hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index f2ca4eb..a5f59af 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -129,7 +129,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 				 u16 s, u32 bytes_recv,
 				 u32 previous_x_recv)
 {
-	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
+	struct tfrc_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
 	ktime_t tstamp = ktime_set(0, 0);
@@ -138,18 +138,18 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 	int step = 0;
 	u64 fval;
 
-	list_for_each_entry_safe(entry, next, hist_list, dccphrx_node) {
-		if (dccp_rx_hist_entry_data_packet(entry)) {
+	list_for_each_entry_safe(entry, next, hist_list, tfrchrx_node) {
+		if (tfrc_rx_hist_entry_data_packet(entry)) {
 			tail = entry;
 
 			switch (step) {
 			case 0:
-				tstamp	  = entry->dccphrx_tstamp;
-				win_count = entry->dccphrx_ccval;
+				tstamp	  = entry->tfrchrx_tstamp;
+				win_count = entry->tfrchrx_ccval;
 				step = 1;
 				break;
 			case 1:
-				interval = win_count - entry->dccphrx_ccval;
+				interval = win_count - entry->tfrchrx_ccval;
 				if (interval < 0)
 					interval += TFRC_WIN_COUNT_LIMIT;
 				if (interval > 4)
@@ -176,7 +176,7 @@ found:
 		return ~0;
 	}
 
-	delta = ktime_us_delta(tstamp, tail->dccphrx_tstamp);
+	delta = ktime_us_delta(tstamp, tail->tfrchrx_tstamp);
 	DCCP_BUG_ON(delta < 0);
 
 	rtt = delta * 4 / interval;
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index e1ab853..255cca1 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -116,58 +116,58 @@ EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
  */
 static struct kmem_cache *tfrc_rx_hist_slab;
 
-struct dccp_rx_hist_entry *dccp_rx_hist_entry_new(const u32 ndp,
+struct tfrc_rx_hist_entry *tfrc_rx_hist_entry_new(const u32 ndp,
 						  const struct sk_buff *skb,
 						  const gfp_t prio)
 {
-	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(tfrc_rx_hist_slab,
+	struct tfrc_rx_hist_entry *entry = kmem_cache_alloc(tfrc_rx_hist_slab,
 							    prio);
 
 	if (entry != NULL) {
 		const struct dccp_hdr *dh = dccp_hdr(skb);
 
-		entry->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-		entry->dccphrx_ccval = dh->dccph_ccval;
-		entry->dccphrx_type  = dh->dccph_type;
-		entry->dccphrx_ndp   = ndp;
-		entry->dccphrx_tstamp = ktime_get_real();
+		entry->tfrchrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+		entry->tfrchrx_ccval = dh->dccph_ccval;
+		entry->tfrchrx_type  = dh->dccph_type;
+		entry->tfrchrx_ndp   = ndp;
+		entry->tfrchrx_tstamp = ktime_get_real();
 	}
 
 	return entry;
 }
-EXPORT_SYMBOL_GPL(dccp_rx_hist_entry_new);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_entry_new);
 
-static inline void dccp_rx_hist_entry_delete(struct dccp_rx_hist_entry *entry)
+static inline void tfrc_rx_hist_entry_delete(struct tfrc_rx_hist_entry *entry)
 {
 	kmem_cache_free(tfrc_rx_hist_slab, entry);
 }
 
-int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
+int tfrc_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 			    u8 *ccval)
 {
-	struct dccp_rx_hist_entry *packet = NULL, *entry;
+	struct tfrc_rx_hist_entry *packet = NULL, *entry;
 
-	list_for_each_entry(entry, list, dccphrx_node)
-		if (entry->dccphrx_seqno = seq) {
+	list_for_each_entry(entry, list, tfrchrx_node)
+		if (entry->tfrchrx_seqno = seq) {
 			packet = entry;
 			break;
 		}
 
 	if (packet)
-		*ccval = packet->dccphrx_ccval;
+		*ccval = packet->tfrchrx_ccval;
 
 	return packet != NULL;
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_find_entry);
-struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list)
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_find_entry);
+struct tfrc_rx_hist_entry *
+		tfrc_rx_hist_find_data_packet(const struct list_head *list)
 {
-	struct dccp_rx_hist_entry *entry, *packet = NULL;
+	struct tfrc_rx_hist_entry *entry, *packet = NULL;
 
-	list_for_each_entry(entry, list, dccphrx_node)
-		if (entry->dccphrx_type = DCCP_PKT_DATA ||
-		    entry->dccphrx_type = DCCP_PKT_DATAACK) {
+	list_for_each_entry(entry, list, tfrchrx_node)
+		if (entry->tfrchrx_type = DCCP_PKT_DATA ||
+		    entry->tfrchrx_type = DCCP_PKT_DATAACK) {
 			packet = entry;
 			break;
 		}
@@ -175,29 +175,29 @@ struct dccp_rx_hist_entry *
 	return packet;
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_find_data_packet);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_find_data_packet);
 
-void dccp_rx_hist_add_packet(struct list_head *rx_list,
+void tfrc_rx_hist_add_packet(struct list_head *rx_list,
 			     struct list_head *li_list,
-			     struct dccp_rx_hist_entry *packet,
+			     struct tfrc_rx_hist_entry *packet,
 			     u64 nonloss_seqno)
 {
-	struct dccp_rx_hist_entry *entry, *next;
+	struct tfrc_rx_hist_entry *entry, *next;
 	u8 num_later = 0;
 
-	list_add(&packet->dccphrx_node, rx_list);
+	list_add(&packet->tfrchrx_node, rx_list);
 
 	num_later = TFRC_RECV_NUM_LATE_LOSS + 1;
 
 	if (!list_empty(li_list)) {
-		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
+		list_for_each_entry_safe(entry, next, rx_list, tfrchrx_node) {
 			if (num_later = 0) {
 				if (after48(nonloss_seqno,
-				   entry->dccphrx_seqno)) {
-					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(entry);
+				   entry->tfrchrx_seqno)) {
+					list_del_init(&entry->tfrchrx_node);
+					tfrc_rx_hist_entry_delete(entry);
 				}
-			} else if (dccp_rx_hist_entry_data_packet(entry))
+			} else if (tfrc_rx_hist_entry_data_packet(entry))
 				--num_later;
 		}
 	} else {
@@ -208,7 +208,7 @@ void dccp_rx_hist_add_packet(struct list_head *rx_list,
 		 * We have no loss interval history so we need at least one
 		 * rtt:s of data packets to approximate rtt.
 		 */
-		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
+		list_for_each_entry_safe(entry, next, rx_list, tfrchrx_node) {
 			if (num_later = 0) {
 				switch (step) {
 				case 0:
@@ -220,10 +220,10 @@ void dccp_rx_hist_add_packet(struct list_head *rx_list,
 					step = 2;
 					/* OK, find next data packet */
 					num_later = 1;
-					win_count = entry->dccphrx_ccval;
+					win_count = entry->tfrchrx_ccval;
 					break;
 				case 2:
-					tmp = win_count - entry->dccphrx_ccval;
+					tmp = win_count - entry->tfrchrx_ccval;
 					if (tmp < 0)
 						tmp += TFRC_WIN_COUNT_LIMIT;
 					if (tmp > TFRC_WIN_COUNT_PER_RTT + 1) {
@@ -236,29 +236,29 @@ void dccp_rx_hist_add_packet(struct list_head *rx_list,
 						num_later = 1;
 					break;
 				case 3:
-					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(entry);
+					list_del_init(&entry->tfrchrx_node);
+					tfrc_rx_hist_entry_delete(entry);
 					break;
 				}
-			} else if (dccp_rx_hist_entry_data_packet(entry))
+			} else if (tfrc_rx_hist_entry_data_packet(entry))
 				--num_later;
 		}
 	}
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-void dccp_rx_hist_purge(struct list_head *list)
+void tfrc_rx_hist_purge(struct list_head *list)
 {
-	struct dccp_rx_hist_entry *entry, *next;
+	struct tfrc_rx_hist_entry *entry, *next;
 
-	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
-		list_del_init(&entry->dccphrx_node);
-		dccp_rx_hist_entry_delete(entry);
+	list_for_each_entry_safe(entry, next, list, tfrchrx_node) {
+		list_del_init(&entry->tfrchrx_node);
+		tfrc_rx_hist_entry_delete(entry);
 	}
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_purge);
 
 __init int packet_history_init(void)
 {
@@ -269,7 +269,7 @@ __init int packet_history_init(void)
 		goto out_err;
 
 	tfrc_rx_hist_slab = kmem_cache_create("tfrc_rx_hist",
-					      sizeof(struct dccp_rx_hist_entry), 0,
+					      sizeof(struct tfrc_rx_hist_entry), 0,
 					      SLAB_HWCACHE_ALIGN, NULL);
 	if (tfrc_rx_hist_slab = NULL)
 		goto out_free_tx;
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 34b180b..5b0b983 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -57,51 +57,51 @@ extern u32  tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head,
 /*
  * 	Receiver History data structures and declarations
  */
-struct dccp_rx_hist_entry {
-	struct list_head dccphrx_node;
-	u64		 dccphrx_seqno:48,
-			 dccphrx_ccval:4,
-			 dccphrx_type:4;
-	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
-	ktime_t		 dccphrx_tstamp;
+struct tfrc_rx_hist_entry {
+	struct list_head tfrchrx_node;
+	u64		 tfrchrx_seqno:48,
+			 tfrchrx_ccval:4,
+			 tfrchrx_type:4;
+	u32		 tfrchrx_ndp; /* In fact it is from 8 to 24 bits */
+	ktime_t		 tfrchrx_tstamp;
 };
 
-extern struct dccp_rx_hist_entry *
-			dccp_rx_hist_entry_new(const u32 ndp,
+extern struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_entry_new(const u32 ndp,
 					       const struct sk_buff *skb,
 					       const gfp_t prio);
 
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_head(struct list_head *list)
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_head(struct list_head *list)
 {
-	struct dccp_rx_hist_entry *head = NULL;
+	struct tfrc_rx_hist_entry *head = NULL;
 
 	if (!list_empty(list))
-		head = list_entry(list->next, struct dccp_rx_hist_entry,
-				  dccphrx_node);
+		head = list_entry(list->next, struct tfrc_rx_hist_entry,
+				  tfrchrx_node);
 	return head;
 }
 
-extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
+extern int tfrc_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 				   u8 *ccval);
-extern struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list);
+extern struct tfrc_rx_hist_entry *
+		tfrc_rx_hist_find_data_packet(const struct list_head *list);
 
-extern void dccp_rx_hist_add_packet(struct list_head *rx_list,
+extern void tfrc_rx_hist_add_packet(struct list_head *rx_list,
 				    struct list_head *li_list,
-				    struct dccp_rx_hist_entry *packet,
+				    struct tfrc_rx_hist_entry *packet,
 				    u64 nonloss_seqno);
 
-extern void dccp_rx_hist_purge(struct list_head *list);
+extern void tfrc_rx_hist_purge(struct list_head *list);
 
 static inline int
-	dccp_rx_hist_entry_data_packet(const struct dccp_rx_hist_entry *entry)
+	tfrc_rx_hist_entry_data_packet(const struct tfrc_rx_hist_entry *entry)
 {
-	return entry->dccphrx_type = DCCP_PKT_DATA ||
-	       entry->dccphrx_type = DCCP_PKT_DATAACK;
+	return entry->tfrchrx_type = DCCP_PKT_DATA ||
+	       entry->tfrchrx_type = DCCP_PKT_DATAACK;
 }
 
-extern u64 dccp_rx_hist_detect_loss(struct list_head *rx_list,
+extern u64 tfrc_rx_hist_detect_loss(struct list_head *rx_list,
 				    struct list_head *li_list, u8 *win_loss);
 
 #endif /* _DCCP_PKT_HIST_ */
-- 
1.5.3.4

