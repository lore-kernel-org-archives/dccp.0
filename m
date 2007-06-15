From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:25 +0000
Subject: [PATCH 2/9]: New RX History Step 1 - Integrate data structure into CCID3
Message-Id: <200706151531.25431@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 1 - Integrate data structure into CCID3

This is a `glue' patch to integrate the new RX history structure:
 -- the `ccid3hcrx_hist' field is now present in rx_sock, but not yet used;
 -- it obsoletes the {seqno,ccval}_nonloss fields (now in the history object);
 -- the remainder is clerical - variable renaming for `last_counter'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    6 +++---
 net/dccp/ccids/ccid3.h |   12 ++++--------
 2 files changed, 7 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -136,13 +136,11 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
  *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
- *  @ccid3hcrx_seqno_nonloss  -  Last received non-loss sequence number
- *  @ccid3hcrx_ccval_nonloss  -  Last received non-loss Window CCVal
- *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history
+ *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
@@ -152,9 +150,7 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
 #define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
 #define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
-	u64				ccid3hcrx_seqno_nonloss:48,
-					ccid3hcrx_ccval_nonloss:4,
-					ccid3hcrx_ccval_last_counter:4;
+	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_last_feedback;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -701,9 +701,9 @@ static void ccid3_hc_rx_send_feedback(st
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
 		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
-	hcrx->ccid3hcrx_last_feedback	   = now;
-	hcrx->ccid3hcrx_ccval_last_counter = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid3hcrx_bytes_recv	   = 0;
+	hcrx->ccid3hcrx_last_feedback = now;
+	hcrx->ccid3hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->ccid3hcrx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
