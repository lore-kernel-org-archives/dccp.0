From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Thu, 22 Nov 2007 20:30:15 +0000
Subject: TX history patches was: Re: Test tree patch inventory - update
Message-Id: <20071122203015.GE17441@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
> 	[TFRC]: Migrate TX history to singly-linked list
> 	[TFRC]: Remove old (doubly-linked list) TX history 

Hi Gerrit,

	I reworked these two patches into this one below, please take a
look. I'll go thru the RX and loss events soon.

- Arnaldo

commit 866e2bc985b99a11622e8ed6ffd2bf2d161bed06
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Thu Nov 22 17:49:59 2007 -0200

    [TFRC]: Migrate TX history to singly-linked lis
    
    This patch was based on another made by Gerrit Renker, his changelog was:
    
        ------------------------------------------------------
    The patch set migrates TFRC TX history to a singly-linked list.
    
    The details are:
     * use of a consistent naming scheme (all TFRC functions now begin with `tfrc_');
     * allocation and cleanup are taken care of internally;
     * provision of a lookup function, which is used by the CCID TX infrastructure
       to determine the time a packet was sent (in turn used for RTT sampling);
     * integration of the new interface with the present use in CCID3.
        ------------------------------------------------------
    
    Simplifications I did:
    
    . removing the tfrc_tx_hist_head that had a pointer to the list head and
      another for the slabcache.
    . No need for creating a slabcache for each CCID that wants to use the TFRC
      tx history routines, create a single slabcache when the dccp_tfrc_lib module
      init routine is called.
    
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 964ec91..2668de8 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,7 +49,6 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
 
 /*
@@ -389,28 +388,18 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
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
+	struct tfrc_tx_hist_entry *packet;
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -425,16 +414,19 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
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
+		packet = tfrc_tx_hist_find_entry(hctx->ccid3hctx_hist,
+						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
+		if (packet = NULL) {
+			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
+				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
+				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			return;
 		}
+		/*
+		 * Garbage-collect older (irrelevant) entries
+		 */
+		tfrc_tx_hist_purge(&packet->next);
 
 		/* Update receive rate in units of 64 * bytes/second */
 		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
@@ -451,7 +443,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/*
 		 * Calculate new RTT sample and update moving average
 		 */
-		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->dccphtx_tstamp));
+		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->stamp));
 		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
@@ -493,9 +485,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* remove all packets older than the one acked from history */
-		dccp_tx_hist_purge_older(ccid3_tx_hist,
-					 &hctx->ccid3hctx_hist, packet);
 		/*
 		 * As we have calculated new ipi, delta, t_nom it is possible
 		 * that we now can send a packet, so wake up dccp_wait_for_ccid
@@ -598,7 +587,7 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
-	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
+	hctx->ccid3hctx_hist = NULL;
 	setup_timer(&hctx->ccid3hctx_no_feedback_timer,
 			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
 
@@ -612,8 +601,7 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-	/* Empty packet history */
-	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
+	tfrc_tx_hist_purge(&hctx->ccid3hctx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1036,19 +1024,12 @@ static __init int ccid3_module_init(void)
 	if (ccid3_rx_hist = NULL)
 		goto out;
 
-	ccid3_tx_hist = dccp_tx_hist_new("ccid3");
-	if (ccid3_tx_hist = NULL)
-		goto out_free_rx;
-
 	rc = ccid_register(&ccid3);
 	if (rc != 0)
-		goto out_free_tx;
+		goto out_free_rx;
 out:
 	return rc;
 
-out_free_tx:
-	dccp_tx_hist_delete(ccid3_tx_hist);
-	ccid3_tx_hist = NULL;
 out_free_rx:
 	dccp_rx_hist_delete(ccid3_rx_hist);
 	ccid3_rx_hist = NULL;
@@ -1060,10 +1041,6 @@ static __exit void ccid3_module_exit(void)
 {
 	ccid_unregister(&ccid3);
 
-	if (ccid3_tx_hist != NULL) {
-		dccp_tx_hist_delete(ccid3_tx_hist);
-		ccid3_tx_hist = NULL;
-	}
 	if (ccid3_rx_hist != NULL) {
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 36eca34..b842a7d 100644
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
+	struct tfrc_tx_hist_entry	*ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 40ad428..ccd04a6 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -277,7 +277,7 @@ void dccp_li_update_li(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_li_update_li);
 
-static __init int dccp_li_init(void)
+int __init dccp_li_init(void)
 {
 	dccp_li_cachep = kmem_cache_create("dccp_li_hist",
 					   sizeof(struct dccp_li_hist_entry),
@@ -285,10 +285,10 @@ static __init int dccp_li_init(void)
 	return dccp_li_cachep = NULL ? -ENOBUFS : 0;
 }
 
-static __exit void dccp_li_exit(void)
+void dccp_li_exit(void)
 {
-	kmem_cache_destroy(dccp_li_cachep);
+	if (dccp_li_cachep != NULL) {
+		kmem_cache_destroy(dccp_li_cachep);
+		dccp_li_cachep = NULL;
+	}
 }
-
-module_init(dccp_li_init);
-module_exit(dccp_li_exit);
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 34c4f60..1397360 100644
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
@@ -39,93 +40,48 @@
 #include "packet_history.h"
 
 /*
- * 	Transmitter History Routines
+ * Transmitter History Routines
  */
-struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
-{
-	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
-	char *slab_name;
+static struct kmem_cache *tfrc_tx_hist;
 
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_tx_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_tx_hist_mask, name);
-	hist->dccptxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_tx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL);
-	if (hist->dccptxh_slab = NULL)
-		goto out_free_slab_name;
-out:
-	return hist;
-out_free_slab_name:
-	kfree(slab_name);
-out_free_hist:
-	kfree(hist);
-	hist = NULL;
-	goto out;
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_new);
-
-void dccp_tx_hist_delete(struct dccp_tx_hist *hist)
+struct tfrc_tx_hist_entry *
+	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
 {
-	const char* name = kmem_cache_name(hist->dccptxh_slab);
+	while (head != NULL && head->seqno != seqno)
+		head = head->next;
 
-	kmem_cache_destroy(hist->dccptxh_slab);
-	kfree(name);
-	kfree(hist);
+	return head;
 }
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_find_entry);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
-
-struct dccp_tx_hist_entry *
-	dccp_tx_hist_find_entry(const struct list_head *list, const u64 seq)
+int tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno)
 {
-	struct dccp_tx_hist_entry *packet = NULL, *entry;
-
-	list_for_each_entry(entry, list, dccphtx_node)
-		if (entry->dccphtx_seqno = seq) {
-			packet = entry;
-			break;
-		}
-
-	return packet;
+	struct tfrc_tx_hist_entry *entry = kmem_cache_alloc(tfrc_tx_hist, gfp_any());
+
+	if (entry = NULL)
+		return -ENOBUFS;
+	entry->seqno = seqno;
+	entry->stamp = ktime_get_real();
+	entry->next  = *headp;
+	*headp	     = entry;
+	return 0;
 }
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_add);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
-
-void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
+void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp)
 {
-	struct dccp_tx_hist_entry *entry, *next;
+	struct tfrc_tx_hist_entry *head = *headp;
 
-	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
-		list_del_init(&entry->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, entry);
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
+	while (head != NULL) {
+		struct tfrc_tx_hist_entry *next = head->next;
 
-void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-			      struct list_head *list,
-			      struct dccp_tx_hist_entry *packet)
-{
-	struct dccp_tx_hist_entry *next;
-
-	list_for_each_entry_safe_continue(packet, next, list, dccphtx_node) {
-		list_del_init(&packet->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, packet);
+		kmem_cache_free(tfrc_tx_hist, head);
+		head = next;
 	}
-}
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
+	*headp = NULL;
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_purge);
 
 /*
  * 	Receiver History Routines
@@ -147,8 +103,7 @@ struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
 	sprintf(slab_name, dccp_rx_hist_mask, name);
 	hist->dccprxh_slab = kmem_cache_create(slab_name,
 					     sizeof(struct dccp_rx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL);
+					     0, SLAB_HWCACHE_ALIGN, NULL);
 	if (hist->dccprxh_slab = NULL)
 		goto out_free_slab_name;
 out:
@@ -293,6 +248,37 @@ void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
 
+extern int __init dccp_li_init(void);
+extern void dccp_li_exit(void);
+
+static __init int packet_history_init(void)
+{
+	if (dccp_li_init() != 0)
+		goto out;
+
+	tfrc_tx_hist = kmem_cache_create("tfrc_tx_hist",
+					 sizeof(struct tfrc_tx_hist_entry), 0,
+					 SLAB_HWCACHE_ALIGN, NULL);
+	if (tfrc_tx_hist = NULL)
+		goto out_li_exit;
+
+	return 0;
+out_li_exit:
+	dccp_li_exit();
+out:
+	return -ENOBUFS;
+}
+module_init(packet_history_init);
+
+static __exit void packet_history_exit(void)
+{
+	if (tfrc_tx_hist != NULL) {
+		kmem_cache_destroy(tfrc_tx_hist);
+		tfrc_tx_hist = NULL;
+	}
+	dccp_li_exit();
+}
+module_exit(packet_history_exit);
 
 MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
 	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 032bb61..5c07182 100644
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
@@ -49,71 +48,23 @@
 #define TFRC_WIN_COUNT_PER_RTT	 4
 #define TFRC_WIN_COUNT_LIMIT	16
 
-/*
- * 	Transmitter History data structures and declarations
+/**
+ *  tfrc_tx_hist_entry  -  Simple singly-linked TX history list
+ *  @next:  next oldest entry (LIFO order)
+ *  @seqno: sequence number of this entry
+ *  @stamp: send time of packet with sequence number @seqno
  */
-struct dccp_tx_hist_entry {
-	struct list_head dccphtx_node;
-	u64		 dccphtx_seqno:48,
-			 dccphtx_sent:1;
-	u32		 dccphtx_rtt;
-	ktime_t		 dccphtx_tstamp;
-};
-
-struct dccp_tx_hist {
-	struct kmem_cache *dccptxh_slab;
+struct tfrc_tx_hist_entry {
+	struct tfrc_tx_hist_entry *next;
+	u64			  seqno;
+	ktime_t			  stamp;
 };
 
-extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
-extern void 		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
-
-static inline struct dccp_tx_hist_entry *
-			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
-					       const gfp_t prio)
-{
-	struct dccp_tx_hist_entry *entry = kmem_cache_alloc(hist->dccptxh_slab,
-							    prio);
-
-	if (entry != NULL)
-		entry->dccphtx_sent = 0;
-
-	return entry;
-}
-
-static inline struct dccp_tx_hist_entry *
-			dccp_tx_hist_head(struct list_head *list)
-{
-	struct dccp_tx_hist_entry *head = NULL;
-
-	if (!list_empty(list))
-		head = list_entry(list->next, struct dccp_tx_hist_entry,
-				  dccphtx_node);
-	return head;
-}
-
-extern struct dccp_tx_hist_entry *
-			dccp_tx_hist_find_entry(const struct list_head *list,
-						const u64 seq);
-
-static inline void dccp_tx_hist_add_entry(struct list_head *list,
-					  struct dccp_tx_hist_entry *entry)
-{
-	list_add(&entry->dccphtx_node, list);
-}
-
-static inline void dccp_tx_hist_entry_delete(struct dccp_tx_hist *hist,
-					     struct dccp_tx_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccptxh_slab, entry);
-}
-
-extern void dccp_tx_hist_purge(struct dccp_tx_hist *hist,
-			       struct list_head *list);
+extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
+extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
 
-extern void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-				     struct list_head *list,
-				     struct dccp_tx_hist_entry *next);
+extern struct tfrc_tx_hist_entry *
+	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 ackno);
 
 /*
  * 	Receiver History data structures and declarations
