From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 08 Sep 2009 18:28:58 +0000
Subject: [PATCH 5/5] Updating documentation accordingly
Message-Id: <4AA6A26A.6080808@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
In-Reply-To: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Updating documentation accordingly

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales <ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>, <leandroal@gmail.com>

Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 10:42:37.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 11:03:15.000000000 -0300
@@ -1,4 +1,6 @@
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -105,6 +107,13 @@
 	ld->counter = 0;
 }
 
+/*
+ *  tfrc_sp_ld_prepare_data  -  updates arrays on tfrc_loss_data
+ *  				so they can be sent as options
+ *  @loss_count:	current loss count (packets after hole on transmission),
+ *			used to determine skip length for loss intervals option
+ *  @ld:		loss intervals data being updated
+ */
 void tfrc_sp_ld_prepare_data(u8 loss_count, struct tfrc_loss_data *ld)
 {
 	u8 *li_ofs, *d_ofs;
@@ -146,6 +155,16 @@
 	}
 }
 
+/*
+ *  tfrc_sp_update_li_data  -  Update tfrc_loss_data upon
+ *			       packet receiving or loss detection
+ *  @ld:			tfrc_loss_data being updated
+ *  @rh:			loss event record
+ *  @skb:			received packet
+ *  @new_loss:			dictates if new loss was detected
+ *				upon receiving current packet
+ *  @new_event:			...and if the loss starts new loss interval
+ */
 void tfrc_sp_update_li_data(struct tfrc_loss_data *ld,
 			    struct tfrc_rx_hist *rh,
 			    struct sk_buff *skb,
@@ -324,7 +343,7 @@
 }
 
 /*
- * tfrc_lh_update_i_mean  -  Update the `open' loss interval I_0
+ * tfrc_sp_lh_update_i_mean  -  Update the `open' loss interval I_0
  * This updates I_mean as the sequence numbers increase. As a consequence, the
  * open loss interval I_0 increases, hence p = W_tot/max(I_tot0, I_tot1)
  * decreases, and thus there is no need to send renewed feedback.
@@ -372,7 +391,8 @@
 	return cur->li_is_closed;
 }
 
-/* tfrc_lh_interval_add  -  Insert new record into the Loss Interval database
+/*
+ * tfrc_sp_lh_interval_add - Insert new record into the Loss Interval database
  * @lh:		   Loss Interval database
  * @rh:		   Receive history containing a fresh loss event
  * @calc_first_li: Caller-dependent routine to compute length of first interval
Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:42:37.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:55:15.000000000 -0300
@@ -1,6 +1,8 @@
 #ifndef _DCCP_LI_HIST_SP_
 #define _DCCP_LI_HIST_SP_
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
@@ -70,6 +72,15 @@
 struct tfrc_rx_hist;
 #endif
 
+/*
+ *  tfrc_loss_data_entry  -  Holds info about one loss interval
+ *  @next:		next entry on this linked list
+ *  @lossless_length:	length of lossless sequence
+ *  @ecn_nonce_sum:	ecn nonce sum for this interval
+ *  @loss_length:	length of lossy part
+ *  @data_length:	data length on lossless part
+ *  @drop_count:	count of dopped packets
+ */
 struct tfrc_loss_data_entry {
 	struct tfrc_loss_data_entry	*next;
 	u32				lossless_length:24;
@@ -79,13 +90,29 @@
 	u32				drop_count:24;
 };
 
+/* As defined at section 8.6.1. of RFC 4342 */
 #define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH	28
+/* Specified on section 8.7. of CCID4 draft */
 #define TFRC_DROP_OPT_MAX_LENGTH		84
 #define TFRC_LI_OPT_SZ	\
 	(2 + TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH*9)
 #define TFRC_DROPPED_OPT_SZ \
 	(1 + TFRC_DROP_OPT_MAX_LENGTH*3)
 
+/*
+ *  tfrc_loss_data  -  loss interval data
+ *  used by loss intervals and dropped packets options
+ *  @head:			linked list containing loss interval data
+ *  @counter:			number of entries
+ *  @loss_intervals_opts:	space necessary for writing temporary option
+ *				data for loss intervals option
+ *  @drop_opts:			same for dropped packets option
+ *  @last_loss_count:		last loss count (num. of packets
+ *				after hole on transmission) observed
+ *  @sto_ecn:			ecn's observed while waiting for hole
+ *				to be filled or accepted as missing
+ *  @sto_is_data:		flags about if packets saw were data packets
+ */
 struct tfrc_loss_data {
 	struct tfrc_loss_data_entry	*head;
 	u16				counter;
Index: dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:42:37.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:57:07.000000000 -0300
@@ -4,6 +4,14 @@
  *
  *  An implementation of the DCCP protocol
  *
+ *  Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab.
+ *  For further information please see http://embedded.ufcg.edu.br/
+ *  <ivocalado@embedded.ufcg.edu.br>,
+ *  <desadoc@gmail.com>, <leandroal@gmail.com>
+ *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
@@ -339,7 +347,7 @@
 }
 
 /*
- *  tfrc_rx_congestion_event  -  Loss detection and further processing
+ *  tfrc_sp_rx_congestion_event  -  Loss detection and further processing
  *  @h:		The non-empty RX history object
  *  @lh:	Loss Intervals database to update
  *  @skb:	Currently received packet
@@ -495,7 +503,7 @@
 }
 
 /*
- * tfrc_rx_hist_sample_rtt  -  Sample RTT from timestamp / CCVal
+ * tfrc_sp_rx_hist_sample_rtt  -  Sample RTT from timestamp / CCVal
  * Based on ideas presented in RFC 4342, 8.1. This function expects that no loss
  * is pending and uses the following history entries (via rtt_sample_prev):
  * - h->ring[0]  contains the most recent history entry prior to @skb;
Index: dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/packet_history_sp.h	2009-09-08 10:42:37.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.h	2009-09-08 10:57:36.000000000 -0300
@@ -1,6 +1,14 @@
 /*
  *  Packet RX/TX history data structures and routines for TFRC-based protocols.
  *
+ *  Copyright (c) 2009 Ivo Calado, Erivaldo Xavier, Leandro Sales
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab.
+ *  For further information please see http://embedded.ufcg.edu.br/
+ *  <ivocalado@embedded.ufcg.edu.br>,
+ *  <desadoc@gmail.com>, <leandroal@gmail.com>
+ *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_ccids_sp.c	2009-09-08 10:26:38.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.c	2009-09-08 11:00:12.000000000 -0300
@@ -1,4 +1,6 @@
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-09-08 10:42:37.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_ccids_sp.h	2009-09-08 11:00:31.000000000 -0300
@@ -1,4 +1,6 @@
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_equation_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_equation_sp.c	2009-09-08 10:26:38.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_equation_sp.c	2009-09-08 11:01:45.000000000 -0300
@@ -1,4 +1,6 @@
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -607,7 +609,7 @@
 }
 
 /*
- * tfrc_calc_x - Calculate the send rate as per section 3.1 of RFC3448
+ * tfrc_sp_calc_x - Calculate the send rate as per section 3.1 of RFC3448
  *
  *  @s: packet size          in bytes
  *  @R: RTT                  scaled by 1000000   (i.e., microseconds)
@@ -667,7 +669,7 @@
 }
 
 /*
- *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
+ *  tfrc_sp_calc_x_reverse_lookup  -  try to find p given f(p)
  *
  *  @fvalue: function value to match, scaled by 1000000
  *  Returns closest match for p, also scaled by 1000000
@@ -700,7 +702,7 @@
 }
 
 /*
- * tfrc_invert_loss_event_rate  -  Compute p so that 10^6 corresponds to 100%
+ * tfrc_sp_invert_loss_event_rate  -  Compute p so that 10^6 corresponds to 100%
  * When @loss_event_rate is large, there is a chance that p is truncated to 0.
  * To avoid re-entering slow-start in that case, we set p = TFRC_SMALLEST_P > 0.
  */
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_sp.c
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_sp.c	2009-09-08 10:26:38.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_sp.c	2009-09-08 11:02:15.000000000 -0300
@@ -1,6 +1,10 @@
 /*
  * TFRC library initialisation
  *
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
+ *	Almost copied from tfrc.c, only renamed symbols
+ *
  * Copyright (c) 2007 The University of Aberdeen, Scotland, UK
  * Copyright (c) 2007 Arnaldo Carvalho de Melo <acme@redhat.com>
  */
Index: dccp_tree_work5/net/dccp/ccids/lib/tfrc_sp.h
=================================--- dccp_tree_work5.orig/net/dccp/ccids/lib/tfrc_sp.h	2009-09-08 10:26:38.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/tfrc_sp.h	2009-09-08 11:02:31.000000000 -0300
@@ -1,6 +1,8 @@
 #ifndef _TFRC_SP_H_
 #define _TFRC_SP_H_
 /*
+ *  Copyright (c) 2009 Federal University of Campina Grande,
+ *	Embedded Systems and Pervasive Computing Lab
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>

