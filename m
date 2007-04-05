From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:40 +0000
Subject: [PATCH 7/43]: New RX History Step 1 - Integrate new history structure
Message-Id: <200704051633.40937@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 1 - Integrate new history structure

This is a `glue' patch to integrate the new RX history structure:
 * fields are now present in rx_sock, but not yet used;
 * updated initialisation / clean-up routines accordingly;
 * each `#if 0' ... `#endif' refers to one subsequent patch, as previously
   discussed, it is better to introduce changes gradually rather than in one
   huge batch;
 * the remainder of the patch is clerical: re-ordering and #includes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   11 ++++++++---
 net/dccp/ccids/ccid3.h |   15 ++++++---------
 2 files changed, 14 insertions(+), 12 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -33,9 +33,7 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include "../ccid.h"
 #include "../dccp.h"
-#include "lib/packet_history.h"
 #include "lib/loss_interval.h"
 #include "lib/tfrc.h"
 #include "ccid3.h"
@@ -780,7 +778,7 @@ static void ccid3_hc_rx_send_feedback(st
 
 	hcrx->ccid3hcrx_elapsed_time	     = delta / 10;
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = dccp_hdr(skb)->dccph_ccval;
+	hcrx->ccid3hcrx_last_counter	     = dccp_hdr(skb)->dccph_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
@@ -832,6 +830,7 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	int step = 0;
 	u64 fval;
 
+#if 0		/* XXX resolved in subsequent patch */
 	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
 				 dccphrx_node) {
 		if (dccp_rx_hist_entry_data_packet(entry)) {
@@ -913,6 +912,8 @@ found:
 		return ~0;
 	else
 		return 1000000 / p;
+#endif
+	return ~0;
 }
 
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
@@ -962,6 +963,7 @@ static void ccid3_hc_rx_update_li(struct
 	}
 }
 
+#if 0	/* XXX obsoleted by subsequent patch */
 static int ccid3_hc_rx_detect_loss(struct sock *sk,
 				    struct dccp_rx_hist_entry *packet)
 {
@@ -1014,6 +1016,7 @@ detect_out:
 		   hcrx->ccid3hcrx_seqno_nonloss);
 	return loss;
 }
+#endif
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -1056,6 +1059,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		return;
 	}
 
+#if 0	/* XXX resolved by subsequent patch */
 	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
 					skb, GFP_ATOMIC);
 	if (unlikely(packet = NULL)) {
@@ -1066,6 +1070,7 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	loss = ccid3_hc_rx_detect_loss(sk, packet);
 
+#endif
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
 
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -41,6 +41,7 @@
 #include <linux/types.h>
 #include <linux/tfrc.h>
 #include <asm/unaligned.h>
+#include "lib/packet_history.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
@@ -127,10 +128,8 @@ enum ccid3_hc_rx_states {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @ccid3hcrx_seqno_nonloss  -  Last received non-loss sequence number
- *  @ccid3hcrx_ccval_nonloss  -  Last received non-loss Window CCVal
- *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
@@ -138,14 +137,12 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_pinv  -  Reciprocal of Loss Event Rate p (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history
+ *  @ccid3hcrx_hist  -  Packet history exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
  */
 struct ccid3_hc_rx_sock {
-	u64				ccid3hcrx_seqno_nonloss:48,
-					ccid3hcrx_ccval_nonloss:4,
-					ccid3hcrx_ccval_last_counter:4;
+	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_bytes_recv;
@@ -154,7 +151,7 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_pinv;
 	struct timeval			ccid3hcrx_tstamp_last_feedback;
 	struct timeval			ccid3hcrx_tstamp_last_ack;
-	struct list_head		ccid3hcrx_hist;
+	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u32				ccid3hcrx_elapsed_time;
 };
