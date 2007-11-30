From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 30 Nov 2007 01:58:12 +0000
Subject: [PATCH 1/1][TFRC]: Hide tx history details from the CCIDs
Message-Id: <20071130015812.GP12069@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Herbert,

	Please consider pulling from:

	master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Thanks a lot!

- Arnaldo

commit f1ff09e7955a2cffa3dfdda8a63a1ce991f11a7b
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Thu Nov 29 22:47:15 2007 -0200

    [TFRC]: Hide tx history details from the CCIDs
    
    Based on a previous patch by Gerrit Renker.
    
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2668de8..5dea690 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -399,7 +399,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
-	struct tfrc_tx_hist_entry *packet;
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
@@ -414,19 +413,17 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
+		now = ktime_get_real();
+
 		/* estimate RTT from history if ACK number is valid */
-		packet = tfrc_tx_hist_find_entry(hctx->ccid3hctx_hist,
-						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
-		if (packet = NULL) {
+		r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
+					    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
+		if (r_sample = 0) {
 			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
 				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
 				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			return;
 		}
-		/*
-		 * Garbage-collect older (irrelevant) entries
-		 */
-		tfrc_tx_hist_purge(&packet->next);
 
 		/* Update receive rate in units of 64 * bytes/second */
 		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
@@ -438,12 +435,10 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_p = 0;
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
-
-		now = ktime_get_real();
 		/*
-		 * Calculate new RTT sample and update moving average
+		 * Validate new RTT sample and update moving average
 		 */
-		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->stamp));
+		r_sample = dccp_sample_rtt(sk, r_sample);
 		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 1397360..4805de9 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -39,12 +39,24 @@
 #include <linux/string.h>
 #include "packet_history.h"
 
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
 /*
  * Transmitter History Routines
  */
 static struct kmem_cache *tfrc_tx_hist;
 
-struct tfrc_tx_hist_entry *
+static struct tfrc_tx_hist_entry *
 	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
 {
 	while (head != NULL && head->seqno != seqno)
@@ -52,7 +64,6 @@ struct tfrc_tx_hist_entry *
 
 	return head;
 }
-EXPORT_SYMBOL_GPL(tfrc_tx_hist_find_entry);
 
 int tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno)
 {
@@ -83,6 +94,24 @@ void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp)
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_purge);
 
+u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno,
+		     const ktime_t now)
+{
+	u32 rtt = 0;
+	struct tfrc_tx_hist_entry *packet = tfrc_tx_hist_find_entry(head, seqno);
+
+	if (packet != NULL) {
+		rtt = ktime_us_delta(now, packet->stamp);
+		/*
+		 * Garbage-collect older (irrelevant) entries:
+		 */
+		tfrc_tx_hist_purge(&packet->next);
+	}
+
+	return rtt;
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
+
 /*
  * 	Receiver History Routines
  */
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 5c07182..0670f46 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -48,23 +48,12 @@
 #define TFRC_WIN_COUNT_PER_RTT	 4
 #define TFRC_WIN_COUNT_LIMIT	16
 
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
+struct tfrc_tx_hist_entry;
 
 extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
 extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
-
-extern struct tfrc_tx_hist_entry *
-	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 ackno);
+extern u32  tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head,
+			     const u64 seqno, const ktime_t now);
 
 /*
  * 	Receiver History data structures and declarations
