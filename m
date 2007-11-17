From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:32 +0000
Subject: [PATCH 05/16] [TFRC]: Migrate TX history to singly-linked list
Message-Id: <11952917831070-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The patch set migrates TFRC TX history to a singly-linked list.

The details are:
 * use of a consistent naming scheme (all TFRC functions now begin with `tfrc_');
 * allocation and cleanup are taken care of internally;
 * provision of a lookup function, which is used by the CCID TX infrastructure
   to determine the time a packet was sent (in turn used for RTT sampling);
 * integration of the new interface with the present use in CCID3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c              |   53 ++++++-------------
 net/dccp/ccids/ccid3.h              |    3 +-
 net/dccp/ccids/lib/packet_history.c |  100 +++++++++++++++++++++++++++++++++-
 net/dccp/ccids/lib/packet_history.h |   42 ++++++++++++++-
 4 files changed, 155 insertions(+), 43 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index e07d817..51fd07b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,7 +49,7 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static struct dccp_tx_hist *ccid3_tx_hist;
+DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
 static struct dccp_rx_hist *ccid3_rx_hist;
 
 /*
@@ -389,29 +389,18 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 				    unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct dccp_tx_hist_entry *packet;
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	packet = dccp_tx_hist_entry_new(ccid3_tx_hist, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
+	if (tfrc_tx_hist_add(&hctx->ccid3hctx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
-		return;
-	}
-	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
-
-	packet->dccphtx_tstamp = ktime_get_real();
-	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
-	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
-	packet->dccphtx_sent   = 1;
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
-	struct dccp_tx_hist_entry *packet;
-	ktime_t now;
+	ktime_t t_send, now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
@@ -425,14 +414,12 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		/* get packet from history to look up t_recvdata */
-		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
-					      DCCP_SKB_CB(skb)->dccpd_ack_seq);
-		if (unlikely(packet = NULL)) {
-			DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist "
-				  "in history!\n",  dccp_role(sk), sk,
-			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+		/* estimate RTT from history if ACK number is valid */
+		if (! tfrc_tx_hist_when(&t_send, &hctx->ccid3hctx_hist,
+				        DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
+			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
+				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
+				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			return;
 		}
 
@@ -451,7 +438,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/*
 		 * Calculate new RTT sample and update moving average
 		 */
-		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->dccphtx_tstamp));
+		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, t_send));
 		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
@@ -493,9 +480,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* remove all packets older than the one acked from history */
-		dccp_tx_hist_purge_older(ccid3_tx_hist,
-					 &hctx->ccid3hctx_hist, packet);
 		/*
 		 * As we have calculated new ipi, delta, t_nom it is possible
 		 * that we now can send a packet, so wake up dccp_wait_for_ccid
@@ -598,7 +582,7 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
-	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
+	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
 
 	hctx->ccid3hctx_no_feedback_timer.function  				ccid3_hc_tx_no_feedback_timer;
@@ -616,7 +600,7 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
 	/* Empty packet history */
-	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
+	tfrc_tx_hist_cleanup(&hctx->ccid3hctx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1039,8 +1023,7 @@ static __init int ccid3_module_init(void)
 	if (ccid3_rx_hist = NULL)
 		goto out;
 
-	ccid3_tx_hist = dccp_tx_hist_new("ccid3");
-	if (ccid3_tx_hist = NULL)
+	if (tfrc_tx_cache_init(&ccid3_tx_hist, "ccid3"))
 		goto out_free_rx;
 
 	rc = ccid_register(&ccid3);
@@ -1050,8 +1033,7 @@ out:
 	return rc;
 
 out_free_tx:
-	dccp_tx_hist_delete(ccid3_tx_hist);
-	ccid3_tx_hist = NULL;
+	tfrc_tx_cache_cleanup(ccid3_tx_hist);
 out_free_rx:
 	dccp_rx_hist_delete(ccid3_rx_hist);
 	ccid3_rx_hist = NULL;
@@ -1063,10 +1045,9 @@ static __exit void ccid3_module_exit(void)
 {
 	ccid_unregister(&ccid3);
 
-	if (ccid3_tx_hist != NULL) {
-		dccp_tx_hist_delete(ccid3_tx_hist);
-		ccid3_tx_hist = NULL;
-	}
+	if (ccid3_tx_hist != NULL)
+		tfrc_tx_cache_cleanup(ccid3_tx_hist);
+
 	if (ccid3_rx_hist != NULL) {
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 36eca34..fd363f0 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -40,6 +40,7 @@
 #include <linux/list.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
+#include "lib/packet_history.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
@@ -111,7 +112,7 @@ struct ccid3_hc_tx_sock {
 	ktime_t				ccid3hctx_t_ld;
 	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
-	struct list_head		ccid3hctx_hist;
+	struct tfrc_tx_hist_head	ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 34c4f60..5651de4 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,7 +1,8 @@
 /*
  *  net/dccp/packet_history.c
  *
- *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
@@ -41,6 +42,37 @@
 /*
  * 	Transmitter History Routines
  */
+int tfrc_tx_cache_init(struct kmem_cache **cache, const char *name)
+{
+	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
+	char *slab_name;
+
+	slab_name = kmalloc(strlen(name) + sizeof(dccp_tx_hist_mask) - 1,
+			    GFP_ATOMIC);
+	if (slab_name = NULL)
+		goto fail;
+
+	sprintf(slab_name, dccp_tx_hist_mask, name);
+	*cache = kmem_cache_create(slab_name, sizeof(struct tfrc_tx_hist),
+					      0, SLAB_HWCACHE_ALIGN, NULL);
+	if (*cache != NULL)
+		return 0;
+
+	kfree(slab_name);
+fail:
+	return -ENOBUFS;
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_cache_init);
+
+void tfrc_tx_cache_cleanup(struct kmem_cache *cache)
+{
+	const char* name = kmem_cache_name(cache);
+
+	kmem_cache_destroy(cache);
+	kfree(name);
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_cache_cleanup);
+
 struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
 {
 	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
@@ -101,6 +133,69 @@ struct dccp_tx_hist_entry *
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
 
+int tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno)
+{
+	struct tfrc_tx_hist *new = kmem_cache_alloc(head->cache, gfp_any());
+
+	if (new = NULL)
+		return -ENOBUFS;
+	new->seqno = seqno;
+	new->stamp = ktime_get_real();
+	new->next  = head->first;
+
+	head->first = new;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_add);
+
+static void tfrc_tx_hist_remove_tail(struct tfrc_tx_hist **pptr,
+				     struct kmem_cache *cache)
+{
+	struct tfrc_tx_hist *ptr;
+
+	for (ptr = *pptr; ptr != NULL; ptr = *pptr) {
+		*pptr = ptr->next;
+		kmem_cache_free(cache, ptr);
+	}
+}
+
+void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head)
+{
+	tfrc_tx_hist_remove_tail(&head->first, head->cache);
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_cleanup);
+
+static struct tfrc_tx_hist
+	     *tfrc_tx_hist_lookup(struct tfrc_tx_hist_head *head, u64 seqno)
+{
+	struct tfrc_tx_hist *entry;
+
+	for (entry = head->first; entry != NULL; entry = entry->next)
+		if (entry->seqno = seqno)
+			return entry;
+	return NULL;
+}
+
+/**
+ *  tfrc_tx_hist_when  -  Retrieve send time of past packet
+ *  @stamp: send time to look up (returns value result)
+ *  @head:  TX history to search in
+ *  @ackno: ACK number which indicates the sent packet's sequence number
+ *  If successful, it garbage-collects older (irrelevant) entries and returns 1.
+ */
+int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
+{
+	struct tfrc_tx_hist *entry = tfrc_tx_hist_lookup(head, ackno);
+
+	if (entry != NULL) {
+		*stamp = entry->stamp;
+		tfrc_tx_hist_remove_tail(&entry->next, head->cache);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_when);
+
 void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
 {
 	struct dccp_tx_hist_entry *entry, *next;
@@ -147,8 +242,7 @@ struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
 	sprintf(slab_name, dccp_rx_hist_mask, name);
 	hist->dccprxh_slab = kmem_cache_create(slab_name,
 					     sizeof(struct dccp_rx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL);
+					     0, SLAB_HWCACHE_ALIGN, NULL);
 	if (hist->dccprxh_slab = NULL)
 		goto out_free_slab_name;
 out:
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 032bb61..bb253f1 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -1,10 +1,9 @@
 /*
- *  net/dccp/packet_history.h
+ *  Packet RX/TX history data structures and routines for TFRC-based protocols.
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
- *  An implementation of the DCCP protocol
- *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
@@ -52,6 +51,11 @@
 /*
  * 	Transmitter History data structures and declarations
  */
+#define DECLARE_TFRC_TX_CACHE(name)	static struct kmem_cache *(name);
+
+extern int  tfrc_tx_cache_init(struct kmem_cache **cache, const char *name);
+extern void tfrc_tx_cache_cleanup(struct kmem_cache *cache);
+
 struct dccp_tx_hist_entry {
 	struct list_head dccphtx_node;
 	u64		 dccphtx_seqno:48,
@@ -67,6 +71,35 @@ struct dccp_tx_hist {
 extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
 extern void 		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
 
+/**
+ *  tfrc_tx_hist  -  Simple singly-linked TX history list
+ *  @next:  next oldest entry (LIFO order)
+ *  @seqno: sequence number of this entry
+ *  @stamp: send time of packet with sequence number @seqno
+ */
+struct tfrc_tx_hist {
+	struct tfrc_tx_hist	*next;
+	u64			seqno;
+	ktime_t			stamp;
+};
+
+/**
+ *  tfrc_tx_hist_head  -  Head of TX history
+ *  @first: begin of the list
+ *  @cache: where list entries are allocated from
+ */
+struct tfrc_tx_hist_head {
+	struct tfrc_tx_hist	*first;
+	struct kmem_cache	*cache;
+};
+
+static inline void tfrc_tx_hist_init(struct tfrc_tx_hist_head *head,
+				     struct kmem_cache *cache)
+{
+	head->first = NULL;
+	head->cache = cache;
+}
+
 static inline struct dccp_tx_hist_entry *
 			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
 					       const gfp_t prio)
@@ -94,6 +127,9 @@ static inline struct dccp_tx_hist_entry *
 extern struct dccp_tx_hist_entry *
 			dccp_tx_hist_find_entry(const struct list_head *list,
 						const u64 seq);
+extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno);
+extern int  tfrc_tx_hist_when(ktime_t *, struct tfrc_tx_hist_head *, u64);
+extern void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head);
 
 static inline void dccp_tx_hist_add_entry(struct list_head *list,
 					  struct dccp_tx_hist_entry *entry)
-- 
1.5.2.2.238.g7cbf2f2-dirty

