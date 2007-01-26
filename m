From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 26 Jan 2007 03:29:00 +0000
Subject: [PATCH 2/2] DCCP: Fix up concurrent loss
Message-Id: <200701261629.01214.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a first attempt at starting to get towards RFC4342 section 5.2.

In this first patch we make sure that consecutive losses aren't treated as
individual losses.

Note that no attempt is made to ensure that they are within the same rtt
so it is not compliant with the RFC but it's closer and better than what we
currently have which must be a "good thing".

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 0de594e..c58da72 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -390,6 +390,7 @@ void dccp_li_update_li(struct sock *sk, struct sk_buff *skb)
 		head->dccplih_interval = dccp_li_calc_first_li(sk, skb);
 		head->dccplih_seqno     = seq_nonloss;
 		head->dccplih_win_count = win_nonloss;
+		head->dccplih_loss_size = 1;
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
@@ -403,6 +404,22 @@ void dccp_li_update_li(struct sock *sk, struct sk_buff *skb)
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_nonloss);
+
+		/* checking if consecutive lost packets. If so just add to
+		 * loss size.
+		 *
+		 * FIXME we should be checking win count here also
+		 */
+		if (seq_temp = head->dccplih_loss_size) {
+			head->dccplih_loss_size++;
+			dccp_pr_debug("consecutive loss li_seqno=%llu, "
+			  "new_seqno = %llu, loss_size=%u\n",
+			  (u64)head->dccplih_seqno, seq_nonloss,
+			  head->dccplih_loss_size);
+			return;
+		}
+
+			
 		entry = dccp_li_hist_entry_new();
 
 		if (entry = NULL) {
@@ -420,6 +437,7 @@ void dccp_li_update_li(struct sock *sk, struct sk_buff *skb)
 		entry->dccplih_seqno = seq_nonloss;
 		entry->dccplih_interval = seq_temp;
 		entry->dccplih_win_count = win_nonloss;
+		entry->dccplih_loss_size = 1;
 		dccp_pr_debug("adding node seqno=%llu, interval=%u\n",
 		   (u64)entry->dccplih_seqno, entry->dccplih_interval);
 	}
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 5c847a4..1a41ead 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -34,6 +34,7 @@ struct dccp_li_hist_entry {
 	u64		 dccplih_seqno:48,
 			 dccplih_win_count:4;
 	u32		 dccplih_interval;
+	u32		 dccplih_loss_size;
 };
 
 extern void dccp_li_hist_purge(struct list_head *list);
