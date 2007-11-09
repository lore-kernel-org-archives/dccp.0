From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 Nov 2007 15:13:14 +0000
Subject: Re: [RFC]: Removal of spinlocks/rw_locks in ccid3.c / packet_history.c
Message-Id: <20071109151314.GA27536@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200711031350.20405@strip-the-willow>
In-Reply-To: <200711031350.20405@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Following the earlier RFC and Arnaldo's comments, the unnecessary spinlocks and 
reader/writer locks used so far for the TFRC RX and TX history structures have
been removed. 

It has taken some time since it involved testing as well; I think it is 
correct now. Below is the changelog of the updated tree. I have not yet
put it online, first due to testing, and I think that the CCID4 subtree
also needs an update; to be done.


The patch set has so far not been combined into larger units, but this will
be done when this change is through.

The changelog below records the changes made to individual patches. The
`interdiff' between the old test tree (online) and the new test tree
(not yet online) is at the end of this message: it is small.


                           TX History Changes
                           ------------------
[TFRC]: Migrate TX history to singly-linked list
 - removed global declaration of reader/writer lock in packet_history.c (DEFINE_RWLOCK)

[TFRC]: History allocation / deallocation routines
  - removed the locks in tx_hist_add() and tx_hist_cleanup()
  - revised the algorithm which "cuts off" the tail of the singly-linked list
  - this lead to much shorter functions

[TFRC]: Add history query/lookup function

                           RX History Changes
                           ------------------
[TFRC]: New receiver history data structure
 - removed the @lock field member of struct tfrc_rx_hist


[TFRC]: New RX History Step 2 - Initialisation and cleanup
 - removed lock initialisation from tfrc_rx_hist_init()

[CCID 3]: New RX History Step 4/5 - Integrate Receiver RTT sampling (part 3 of 3)
 - removed the use of locks in ccid3_hc_rx_packet_recv()

All other patches not mentioned have been ajdusted (but not changed in
content) to match the above update.

          -----------------------------------------------------
          Interdiff from previous test tree ..... test tree now
          -----------------------------------------------------

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -112,14 +112,12 @@ struct tfrc_rx_hist_entry {
  *   @loss_count:	Number of entries in circular history
  *   @loss_start:	Movable index (for loss detection)
  *   @rtt_sample_prev:  Used during RTT sampling, points to candidate entry
- *   @lock:		Serialize concurrent access
  */
 struct tfrc_rx_hist {
 	struct tfrc_rx_hist_entry	*ring[NDUPACK + 1];
 	u8				loss_count:2,
 					loss_start:2;
 #define rtt_sample_prev			loss_start
-	spinlock_t			lock;
 };
 
 /*
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -782,8 +782,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
 
-	spin_lock(&hcrx->ccid3hcrx_hist.lock);
-
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
@@ -847,8 +845,6 @@ update_records:
 	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
 
 done_receiving:
-	spin_unlock(&hcrx->ccid3hcrx_hist.lock);
-
 	if (do_feedback)
 		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
 }
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -40,8 +40,6 @@
 /*
  * 	Transmitter History Routines
  */
-DEFINE_RWLOCK(tfrc_tx_hist_lock);
-
 int tfrc_tx_cache_init(struct kmem_cache **cache, const char *name)
 {
 	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
@@ -79,31 +77,43 @@ int tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno)
 
 	if (new = NULL)
 		return -ENOBUFS;
-
 	new->seqno = seqno;
 	new->stamp = ktime_get_real();
+	new->next  = head->first;
 
-	write_lock_bh(&tfrc_tx_hist_lock);
-	new->next = head->first;
 	head->first = new;
-	write_unlock_bh(&tfrc_tx_hist_lock);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_add);
 
-static void __tfrc_tx_hist_remove_tail(struct tfrc_tx_hist *ptr,
-				       struct kmem_cache *cache)
- {
-	struct tfrc_tx_hist *old;
+static void tfrc_tx_hist_remove_tail(struct tfrc_tx_hist **pptr,
+				     struct kmem_cache *cache)
+{
+	struct tfrc_tx_hist *ptr;
 
-	while (ptr != NULL) {
-		old = ptr;
-		ptr = ptr->next;
-		kmem_cache_free(cache, old);
+	for (ptr = *pptr; ptr != NULL; ptr = *pptr) {
+		*pptr = ptr->next;
+		kmem_cache_free(cache, ptr);
 	}
 }
 
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
 /**
  *  tfrc_tx_hist_when  -  Retrieve send time of past packet
  *  @stamp: send time to look up (returns value result)
@@ -113,38 +123,17 @@ static void __tfrc_tx_hist_remove_tail(struct tfrc_tx_hist *ptr,
  */
 int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
 {
-	struct tfrc_tx_hist *cur, *tail = NULL;
-
-	write_lock_bh(&tfrc_tx_hist_lock);
-	for (cur = head->first; cur != NULL; cur = cur->next)
-		if (cur->seqno = ackno) {
-			*stamp = cur->stamp;
-			tail = cur->next;
-			cur->next = NULL;
-			break;
-		}
-	write_unlock_bh(&tfrc_tx_hist_lock);
-
-	if (tail)
-		__tfrc_tx_hist_remove_tail(tail, head->cache);
+	struct tfrc_tx_hist *entry = tfrc_tx_hist_lookup(head, ackno);
 
-	return (cur != NULL);
+	if (entry != NULL) {
+		*stamp = entry->stamp;
+		tfrc_tx_hist_remove_tail(&entry->next, head->cache);
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_when);
 
-void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head)
-{
-	struct tfrc_tx_hist *free_this;
-
-	write_lock_bh(&tfrc_tx_hist_lock);
-	free_this = head->first;
-	head->first = NULL;
-	write_unlock_bh(&tfrc_tx_hist_lock);
-
-	__tfrc_tx_hist_remove_tail(free_this, head->cache);
-}
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_cleanup);
-
 
 /*
  * 	Receiver History Routines
@@ -160,7 +149,6 @@ int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
 		if (h->ring[i] = NULL)
 			return 1;
 	}
-	spin_lock_init(&h->lock);
 	h->loss_count = 0;
 	h->loss_start = 0;
 	return 0;
