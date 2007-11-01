From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:40 +0000
Subject: [PATCH 14/25] Basic implementation for ccid-4 dropped packet option
Message-Id: <200710312131.40317.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Basic implementation for ccid-4 dropped packet option as per ccid-4 draft

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -36,12 +36,15 @@ enum tfrc_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
 	TFRC_OPT_RECEIVE_RATE	 = 194,
+	TFRC_OPT_DROPPED_PACKETS = 195, /* as per ccid-4 draft, section 8 */
 };
 
 struct tfrc_options_received {
 	u64 tfrcor_seqno:48,
-	    tfrcor_loss_intervals_idx:16;
-	u16 tfrcor_loss_intervals_len;
+	    tfrcor_loss_intervals_idx:16,
+	    tfrcor_dropped_packets_idx:16;
+	u16 tfrcor_loss_intervals_len,
+            tfrcor_dropped_packets_len;
 	u32 tfrcor_loss_event_rate;
 	u32 tfrcor_receive_rate;
 };
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -590,6 +590,9 @@ static int ccid4_hc_tx_parse_options(str
 				       opt_recv->tfrcor_receive_rate);
 		}
 		break;
+        case TFRC_OPT_DROPPED_PACKETS:
+                /* FIXME: Implement this sock option according to ccid-4 draft */
+                break;
 	}
 
 	return rc;
