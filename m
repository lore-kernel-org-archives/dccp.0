From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Mar 2007 04:16:35 +0000
Subject: [PATCH 8/9] DCCP: Refactor loss initialisation
Message-Id: <200703221616.35515.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_li_hist_interval_new doesn't need the last two parameters as the logic
doesn't belong there and makes dccp_li_update_li more confusing as to where
the structure values come from.

And of course it never hurts to reduce stack usage.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 9e7fbed..2001dd7 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -150,8 +150,6 @@ static int dccp_li_hist_interval_new(struct list_head *list,
 		list_add(&entry->dccplih_node, list);
 	}
 
-	entry->dccplih_seqno     = seq_nonloss;
-	entry->dccplih_win_count = win_nonloss;
 	return 1;
 }
 
@@ -272,6 +270,8 @@ void dccp_li_update_li(struct sock *sk)
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
 		head->dccplih_interval = dccp_li_calc_first_li(sk);
+		head->dccplih_seqno     = seq_nonloss;
+		head->dccplih_win_count = win_nonloss;
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
