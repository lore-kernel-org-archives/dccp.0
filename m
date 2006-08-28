From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 28 Aug 2006 04:36:37 +0000
Subject: [PATCH 1/1] [DCCP]: Tidyup CCID3 list handling
Message-Id: <200608281636.38517.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As Arnaldo Carvalho de Melo points out I should be using list_entry in case
the structure changes in future. Current code functions but is reliant
on position and requires type cast.

Noticed when doing this that I have one more variable than I needed so
removing that also.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 090bc39..195aa95 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -900,7 +900,7 @@ found:
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_li_hist_entry *next, *head;
+	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
@@ -908,15 +908,15 @@ static void ccid3_hc_rx_update_li(struct
 		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
 			return;
 
-		next = (struct dccp_li_hist_entry *)
-		   hcrx->ccid3hcrx_li_hist.next;
-		next->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
+		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
 
-		head = (struct dccp_li_hist_entry *)
-		   hcrx->ccid3hcrx_li_hist.next;
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
 		/* FIXME win count check removed as was wrong */
 		/* should make this check with receive history */
 		/* and compare there as per section 10.2 of RFC4342 */
