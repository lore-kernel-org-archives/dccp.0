From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 07:38:02 +0000
Subject: [PATCH 1/4] [CCID3]: Remove ugly RTT-sampling history lookup
Message-Id: <1210059485-691-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the RTT-sampling function tfrc_tx_hist_rtt(), since

 1. it suffered from complex passing of return values (the return value both
    indicated successful lookup and at the same time doubled as RTT sample);

 2. when for some odd reason the sample value equalled 0, this triggered a bug
    warning about "bogus Ack", due to the ambiguity of the return value;

 3. on a passive host which has not sent anything the TX history is empty and
    thus will lead to unwanted "bogus Ack" warnings such as
    ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-28197148
    ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-26641606.

So this patch makes everything explicit that previously was implicit.

Furthermore, the "bogus Ack" warning has been removed, since it can actually be
triggered due to several reasons (network reordering, old packet, (3) above),
hence it is not very useful.

The format of this code is thanks to a suggestion by Arnaldo doing an earlier
discussion -- which is in fact the clearer variant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   34 ++++++++++++++++-------------
 net/dccp/ccids/lib/packet_history.c |   40 -----------------------------------
 net/dccp/ccids/lib/packet_history.h |   22 ++++++++++++++++--
 3 files changed, 38 insertions(+), 58 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -367,6 +367,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv = &hctx->options_received;
+	struct tfrc_tx_hist_entry *acked;
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -380,17 +381,24 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	    hctx->state != TFRC_SSTATE_NO_FBACK)
 		return;
 
-	now = ktime_get_real();
-
-	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->hist,
-				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
-	if (r_sample = 0) {
-		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
-			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
-			  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	/*
+	 * Locate the acknowledged packet in the TX history.
+	 *
+	 * Returning "entry not found" here can for instance happen when
+	 *  - the host has not sent out anything (e.g. a passive server),
+	 *  - the Ack is outdated (packet with higher Ack number was received),
+	 *  - it is a bogus Ack (for a packet not sent on this connection).
+	 */
+	acked = tfrc_tx_hist_find_entry(hctx->hist, dccp_hdr_ack_seq(skb));
+	if (acked = NULL)
 		return;
-	}
+	/* For the sake of RTT sampling, ignore/remove all older entries */
+	tfrc_tx_hist_purge(&acked->next);
+
+	/* Update the moving average for the RTT estimate (RFC 3448, 4.3) */
+	now	  = ktime_get_real();
+	r_sample  = dccp_sample_rtt(sk, ktime_us_delta(now, acked->stamp));
+	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
 
 	/* Update receive rate in units of 64 * bytes/second */
 	hctx->x_recv = opt_recv->ccid3or_receive_rate;
@@ -402,11 +410,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hctx->p = 0;
 	else				       /* can not exceed 100% */
 		hctx->p = scaled_div(1, pinv);
-	/*
-	 * Validate new RTT sample and update moving average
-	 */
-	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
+
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -40,12 +40,28 @@
 #include <linux/slab.h>
 #include "tfrc.h"
 
-struct tfrc_tx_hist_entry;
+/**
+ *  tfrc_tx_hist_entry  -  Simple singly-linked TX history list
+ *  @next:  next oldest entry (LIFO order)
+ *  @seqno: sequence number of this entry
+ *  @stamp: send time of packet with sequence number @seqno
+ */
+struct tfrc_tx_hist_entry {
+	struct tfrc_tx_hist_entry *next;
+	u64			  seqno;
+	ktime_t			  stamp;
+};
+
+static inline struct tfrc_tx_hist_entry *
+	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
+{
+	while (head != NULL && head->seqno != seqno)
+		head = head->next;
+	return head;
+}
 
 extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
 extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
-extern u32  tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head,
-			     const u64 seqno, const ktime_t now);
 
 /* Subtraction a-b modulo-16, respects circular wrap-around */
 #define SUB16(a, b) (((a) + 16 - (b)) & 0xF)
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -40,18 +40,6 @@
 #include "packet_history.h"
 #include "../../dccp.h"
 
-/**
- *  tfrc_tx_hist_entry  -  Simple singly-linked TX history list
- *  @next:  next oldest entry (LIFO order)
- *  @seqno: sequence number of this entry
- *  @stamp: send time of packet with sequence number @seqno
- */
-struct tfrc_tx_hist_entry {
-	struct tfrc_tx_hist_entry *next;
-	u64			  seqno;
-	ktime_t			  stamp;
-};
-
 /*
  * Transmitter History Routines
  */
@@ -73,15 +61,6 @@ void tfrc_tx_packet_history_exit(void)
 	}
 }
 
-static struct tfrc_tx_hist_entry *
-	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
-{
-	while (head != NULL && head->seqno != seqno)
-		head = head->next;
-
-	return head;
-}
-
 int tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno)
 {
 	struct tfrc_tx_hist_entry *entry = kmem_cache_alloc(tfrc_tx_hist_slab, gfp_any());
@@ -111,25 +90,6 @@ void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp)
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_purge);
 
-u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno,
-		     const ktime_t now)
-{
-	u32 rtt = 0;
-	struct tfrc_tx_hist_entry *packet = tfrc_tx_hist_find_entry(head, seqno);
-
-	if (packet != NULL) {
-		rtt = ktime_us_delta(now, packet->stamp);
-		/*
-		 * Garbage-collect older (irrelevant) entries:
-		 */
-		tfrc_tx_hist_purge(&packet->next);
-	}
-
-	return rtt;
-}
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
-
-
 /*
  * 	Receiver History Routines
  */


The University of Aberdeen is a charity registered in Scotland, No SC013683.

