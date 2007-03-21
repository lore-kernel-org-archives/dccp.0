From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:45:25 +0000
Subject: [PATCH 16/25]: Preparation to fit TX list locking
Message-Id: <200703211845.25785@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Preparation to fit TX list locking

This patch prepares adding TX history locking by changing all 
functions which return a reference to a TX history object:

 1) removal of dccp_tx_hist_head  -  nowhere used in the code;
 2) change dccp_tx_hist_find_entry  -  the sole use is to look up a 
    timestamp for an Ack-ed packet; and then do garbage-collection.

The latter function is changed to return the desired timestamp instead of
a history object reference. 

Not returning object references is necessary, since otherwise lists could
not be garbage-collected (or would have to use atomic reference counts).

Furthermore, the garbage-collection is now integrated into (2), since it
requires first a read access and then a write access at the same place in 
the list: giving up the lock here would permit race condition.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   18 +++++++-----------
 net/dccp/ccids/lib/packet_history.c |   27 +++++++++++++++++++++------
 net/dccp/ccids/lib/packet_history.h |   16 ++--------------
 3 files changed, 30 insertions(+), 31 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -421,10 +421,9 @@ static void ccid3_hc_tx_packet_recv(stru
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
-	struct dccp_tx_hist_entry *packet;
-	struct timeval now;
+	struct timeval now, t_send;
 	unsigned long t_nfb;
-	u32 pinv, r_sample;
+	u32 pinv, r_sample, rc;
 
 	BUG_ON(hctx = NULL);
 
@@ -440,10 +439,10 @@ static void ccid3_hc_tx_packet_recv(stru
 	default:			return;
 	}
 
-	/* get packet from history to look up t_recvdata */
-	packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
-				         DCCP_SKB_CB(skb)->dccpd_ack_seq);
-	if (unlikely(packet = NULL)) {
+	/* look up t_recvdata in packet history */
+	rc = dccp_tx_hist_get_send_time(ccid3_tx_hist, &hctx->ccid3hctx_hist,
+				        DCCP_SKB_CB(skb)->dccpd_ack_seq, &t_send);
+	if (unlikely(!rc)) {
 		DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist in history!\n",
 			  dccp_role(sk), sk,
 		          (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
@@ -466,7 +465,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	 * R_sample  =  (t_now - t_recvdata) - t_elapsed
 	 */
 	skb_get_timestamp(skb, &now);
-	r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
+	r_sample = dccp_sample_rtt(sk, &now, &t_send);
 
 	/*
 	 * Update RTT estimate (honours RTT from SYN exchange):
@@ -523,9 +522,6 @@ done_computing_x:
 	/* unschedule no feedback timer */
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-	/* remove all packets older than the one acked from history */
-	dccp_tx_hist_purge_older(ccid3_tx_hist,
-				 &hctx->ccid3hctx_hist, packet);
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
 	 * that we now can send a packet, so wake up dccp_wait_for_ccid
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -85,21 +85,36 @@ void dccp_tx_hist_delete(struct dccp_tx_
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
 
-struct dccp_tx_hist_entry *
-	dccp_tx_hist_find_entry(const struct list_head *list, const u64 seq)
+/**
+ *  dccp_tx_hist_get_send_time  -  Retrieve timestamp of sent packet
+ *
+ *  @hist:   history slab associated with TX history
+ *  @list:   TX history list head
+ *  @seq:    48-bit sequence number of packet in question
+ *  @t_send: timestamp to be returned
+ *  Returns 1 on success and then garbage-collects all older entries.
+ */
+int dccp_tx_hist_get_send_time(struct dccp_tx_hist *hist,
+			       struct list_head *list, u64 seq,
+			       struct timeval *t_send)
 {
-	struct dccp_tx_hist_entry *packet = NULL, *entry;
+	struct dccp_tx_hist_entry *entry;
+	int found = 0;
 
 	list_for_each_entry(entry, list, dccphtx_node)
 		if (entry->dccphtx_seqno = seq) {
-			packet = entry;
+			found = 1;
+			*t_send = entry->dccphtx_tstamp;
 			break;
 		}
 
-	return packet;
+	if (found)
+		dccp_tx_hist_purge_older(hist, list, entry);
+
+	return found;
 }
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
+EXPORT_SYMBOL_GPL(dccp_tx_hist_get_send_time);
 
 void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
 {
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -80,20 +80,8 @@ static inline struct dccp_tx_hist_entry 
 	return entry;
 }
 
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
+extern int dccp_tx_hist_get_send_time(struct dccp_tx_hist *, struct list_head *,
+				      u64 seq, struct timeval *t_send);
 
 static inline void dccp_tx_hist_add_entry(struct list_head *list,
 					  struct dccp_tx_hist_entry *entry)
