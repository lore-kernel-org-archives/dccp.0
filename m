From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:18:55 +0000
Subject: [PATCHv2 2/4] Implement loss counting on TFRC-SP receiver
Message-Id: <4AD4B67F.8040208@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Implement loss counting on TFRC-SP receiver. Consider transmission's hole size as loss count.

Changes:
 - Adds field li_losses to tfrc_loss_interval to track loss count per interval
 - Adds field num_losses to tfrc_rx_hist, used to store loss count per loss event
 - Adds dccp_loss_count function to net/dccp/dccp.h, responsible for loss count using sequence numbers

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:54:16.819408361 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.c	2009-10-08 22:59:07.439908552 -0300
@@ -183,8 +183,11 @@
 		if (len <= 0)
 			return false;
 
-		if (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))
+		if (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval)) {
+			cur->li_losses += rh->num_losses;
+			rh->num_losses = 0;
 			return false;
+		}
 
 		/* RFC 5348, 5.3: length between subsequent intervals */
 		cur->li_length = len;
@@ -200,6 +203,8 @@
 	cur->li_seqno	  = cong_evt_seqno;
 	cur->li_ccval	  = cong_evt->tfrchrx_ccval;
 	cur->li_is_closed = false;
+	cur->li_losses    = rh->num_losses;
+	rh->num_losses = 0;
 
 	if (++lh->counter = 1)
 		lh->i_mean = cur->li_length = (*calc_first_li)(sk);
Index: dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:54:16.838907787 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/loss_interval_sp.h	2009-10-08 22:59:07.439908552 -0300
@@ -30,12 +30,14 @@
  *  @li_ccval:		The CCVal belonging to @li_seqno
  *  @li_is_closed:	Whether @li_seqno is older than 1 RTT
  *  @li_length:		Loss interval sequence length
+ *  @li_losses:        Number of losses counted on this interval
  */
 struct tfrc_loss_interval {
 	u64		 li_seqno:48,
 			 li_ccval:4,
 			 li_is_closed:1;
 	u32		 li_length;
+	u32              li_losses;
 };
 
 /**
Index: dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.h
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.h	2009-10-08 22:58:53.134907870 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.h	2009-10-08 22:59:07.439908552 -0300
@@ -104,6 +104,7 @@
  * @packet_size:	Packet size in bytes (as per RFC 3448, 3.1)
  * @bytes_recvd:	Number of bytes received since @bytes_start
  * @bytes_start:	Start time for counting @bytes_recvd
+ * @num_losses:		Number of losses detected
  */
 struct tfrc_rx_hist {
 	struct tfrc_rx_hist_entry *ring[TFRC_NDUPACK + 1];
@@ -116,6 +117,7 @@
 	u32			  packet_size,
 				  bytes_recvd;
 	ktime_t			  bytes_start;
+	u64			  num_losses;
 };
 
 /**
Index: dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c
=================================--- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:58:21.418908270 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:59:07.442411383 -0300
@@ -243,6 +243,7 @@
 {
 	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
 	    s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
+	    n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp,
 	    s2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_seqno,
 	    s3 = DCCP_SKB_CB(skb)->dccpd_seq;
 
@@ -250,6 +251,7 @@
 		h->loss_count = 3;
 		tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 3),
 					       skb, n3);
+		h->num_losses = dccp_loss_count(s0, s1, n1);
 		return 1;
 	}
 
@@ -263,6 +265,7 @@
 		tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 2),
 					       skb, n3);
 		h->loss_count = 3;
+		h->num_losses = dccp_loss_count(s0, s1, n1);
 		return 1;
 	}
 
@@ -299,6 +302,7 @@
 	h->loss_start = tfrc_rx_hist_index(h, 3);
 	tfrc_sp_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb, n3);
 	h->loss_count = 3;
+	h->num_losses = dccp_loss_count(s0, s3, n3);
 
 	return 1;
 }
Index: dccp_tree_work03/net/dccp/dccp.h
=================================--- dccp_tree_work03.orig/net/dccp/dccp.h	2009-10-08 22:54:16.858907920 -0300
+++ dccp_tree_work03/net/dccp/dccp.h	2009-10-08 22:59:07.442411383 -0300
@@ -154,6 +154,22 @@
 }
 
 /**
+ * dccp_loss_count - Approximate the number of data packets lost in a row
+ * @s1:   last known sequence number before the loss ('hole')
+ * @s2:   first sequence number seen after the 'hole'
+ * @ndp:  ndp count associated with packet having sequence number @s2
+ */
+static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 ndp)
+{
+       s64 delta = dccp_delta_seqno(s1, s2);
+
+       WARN_ON(delta < 0);
+       delta -= ndp + 1;
+
+       return delta > 0 ? delta : 0;
+}
+
+/**
  * dccp_loss_free  -  Evaluates condition for data loss from RFC 4340, 7.7.1
  * @s1:	 start sequence number
  * @s2:  end sequence number
@@ -162,10 +178,7 @@
  */
 static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
 {
-	s64 delta = dccp_delta_seqno(s1, s2);
-
-	WARN_ON(delta < 0);
-	return (u64)delta <= ndp + 1;
+       return dccp_loss_count(s1, s2, ndp) = 0;
 }
 
 enum {

