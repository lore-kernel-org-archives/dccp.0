From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:58:44 +0000
Subject: [PATCH 2/8] Improve the declaration of tfrc_option_receive struct
Message-Id: <200712201358.44916.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Improve the declaration of tfrc_option_receive struct.

It makes tfrcor_dropped_packets_idx a plain u16. tfrcor_loss_intervals_idx was part of a bitfield together with tfrcor_seqno because it is 48 bits and we wanted to use what is left in a 64. Adding the new DROPPED PACKET field this setup changed. Thus, making tfrcor_dropped_packets_idx a 16 bits entry in a 16 bits bitfield doesn't helps us here and likely produces bad code. Now we have just a 2 bytes hole.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -39,13 +39,13 @@ enum tfrc_options {
 };
 
 struct tfrc_options_received {
-	u64 tfrcor_seqno:48,
-	    tfrcor_loss_intervals_idx:16,
-	    tfrcor_dropped_packets_idx:16;
-	u16 tfrcor_loss_intervals_len,
-	    tfrcor_dropped_packets_len;
-	u32 tfrcor_loss_event_rate;
-	u32 tfrcor_receive_rate;
+	u64  tfrcor_seqno:48;
+	u64  tfrcor_loss_intervals_idx:16;
+	u16  tfrcor_dropped_packets_idx;
+	u16  tfrcor_loss_intervals_len;
+	u16  tfrcor_dropped_packets_len;
+	u32  tfrcor_loss_event_rate;
+	u32  tfrcor_receive_rate;
 };
 
 /* TFRC sender states */
