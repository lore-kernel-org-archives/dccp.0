From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:06:07 +0000
Subject: [PATCH 7/7]: Add annotations for socket structures
Message-Id: <200611171806.07871@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Add annotations for socket structures

This adds documentation to the CCID 3 rx/tx socket fields.
Plus some minor re-formatting.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |   90 +++++++++++++++++++++++++++++--------------------
 1 file changed, 55 insertions(+), 35 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -81,26 +81,28 @@ enum ccid3_hc_tx_states {
 	TFRC_SSTATE_TERM,
 };
 
-/** struct ccid3_hc_tx_sock - CCID3 sender half connection sock
+/** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
-  * @ccid3hctx_state - Sender state
-  * @ccid3hctx_x - Current sending rate
-  * @ccid3hctx_x_recv - Receive rate
-  * @ccid3hctx_x_calc - Calculated send (?) rate
-  * @ccid3hctx_s - Packet size
-  * @ccid3hctx_rtt - Estimate of current round trip time in usecs
-  * @@ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
-  * @ccid3hctx_last_win_count - Last window counter sent
-  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
-  * 				  with last_win_count value sent
-  * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
-  * @ccid3hctx_idle - FIXME
-  * @ccid3hctx_t_ld - Time last doubled during slow start
-  * @ccid3hctx_t_nom - Nominal send time of next packet
-  * @ccid3hctx_t_ipi - Interpacket (send) interval
-  * @ccid3hctx_delta - Send timer delta
-  * @ccid3hctx_hist - Packet history
-  */
+ * @ccid3hctx_x - Current sending rate
+ * @ccid3hctx_x_recv - Receive rate
+ * @ccid3hctx_x_calc - Calculated send rate (RFC 3448, 3.1)
+ * @ccid3hctx_rtt - Estimate of current round trip time in usecs
+ * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
+ * @ccid3hctx_s - Packet size
+ * @ccid3hctx_t_rto - Retransmission Timeout (RFC 3448, 3.1)
+ * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6)
+ * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
+ * @ccid3hctx_last_win_count - Last window counter sent
+ * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
+ * 				 with last_win_count value sent
+ * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
+ * @ccid3hctx_idle - Flag indicating that sender is idling
+ * @ccid3hctx_t_ld - Time last doubled during slow start
+ * @ccid3hctx_t_nom - Nominal send time of next packet
+ * @ccid3hctx_delta - Send timer delta
+ * @ccid3hctx_hist - Packet history
+ * @ccid3hctx_options_received - Parsed set of retrieved options
+ */
 struct ccid3_hc_tx_sock {
 	struct tfrc_tx_info		ccid3hctx_tfrc;
 #define ccid3hctx_x			ccid3hctx_tfrc.tfrctx_x
@@ -130,23 +132,41 @@ enum ccid3_hc_rx_states {
 	TFRC_RSTATE_TERM    = 127,
 };
 
+/** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
+ *
+ *  @ccid3hcrx_x_recv  -  receiver estimate of send rate (RFC 3448 4.3)
+ *  @ccid3hcrx_rtt  -  receiver estimate of rtt ??? FIXME
+ *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
+ *  @ccid3hcrx_seqno_nonloss  -  FIXME
+ *  @ccid3hcrx_ccval_nonloss  -  FIXME
+ *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @ccid3hcrx_tstamp_last_feedback  -  FIXME
+ *  @ccid3hcrx_tstamp_last_ack  -  FIXME
+ *  @ccid3hcrx_hist  -  Packet history
+ *  @ccid3hcrx_li_hist  -  FIXME
+ *  @ccid3hcrx_s  -  Received packet size
+ *  @ccid3hcrx_pinv  -  1/p
+ *  @ccid3hcrx_elapsed_time  -  Time since packet reception
+ */
 struct ccid3_hc_rx_sock {
-	struct tfrc_rx_info	ccid3hcrx_tfrc;
-#define ccid3hcrx_x_recv	ccid3hcrx_tfrc.tfrcrx_x_recv
-#define ccid3hcrx_rtt		ccid3hcrx_tfrc.tfrcrx_rtt
-#define ccid3hcrx_p		ccid3hcrx_tfrc.tfrcrx_p
-  	u64			ccid3hcrx_seqno_nonloss:48,
-				ccid3hcrx_ccval_nonloss:4,
-				ccid3hcrx_ccval_last_counter:4;
-	enum ccid3_hc_rx_states	ccid3hcrx_state:8;
-  	u32			ccid3hcrx_bytes_recv;
-  	struct timeval		ccid3hcrx_tstamp_last_feedback;
-  	struct timeval		ccid3hcrx_tstamp_last_ack;
-	struct list_head	ccid3hcrx_hist;
-	struct list_head	ccid3hcrx_li_hist;
-  	u16			ccid3hcrx_s;
-  	u32			ccid3hcrx_pinv;
-  	u32			ccid3hcrx_elapsed_time;
+	struct tfrc_rx_info		ccid3hcrx_tfrc;
+#define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
+#define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
+#define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
+  	u64				ccid3hcrx_seqno_nonloss:48,
+					ccid3hcrx_ccval_nonloss:4,
+					ccid3hcrx_ccval_last_counter:4;
+	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
+  	u32				ccid3hcrx_bytes_recv;
+  	struct timeval			ccid3hcrx_tstamp_last_feedback;
+  	struct timeval			ccid3hcrx_tstamp_last_ack;
+	struct list_head		ccid3hcrx_hist;
+	struct list_head		ccid3hcrx_li_hist;
+  	u16				ccid3hcrx_s;
+  	u32				ccid3hcrx_pinv;
+  	u32				ccid3hcrx_elapsed_time;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
