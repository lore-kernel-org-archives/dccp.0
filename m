From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:36:19 +0000
Subject: [PATCH 29/43]: Shorten struct-member name
Message-Id: <200704051636.19746@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Shorten struct-member name

To better cope with limited line length of 80 chars, the `last feedback'
field name is made shorted.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 ++++++-------
 net/dccp/ccids/ccid3.h |    4 ++--
 2 files changed, 8 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -149,7 +149,7 @@ enum ccid3_fback_type {
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of RTT (RFC 4342, 8.1)
  *  @ccid3hcrx_pinv  -  Reciprocal of Loss Event Rate p (RFC 4342, sec. 8.5)
- *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
+ *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
@@ -162,7 +162,7 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_x_recv;
 	u32				ccid3hcrx_rtt;
 #define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
-	struct timeval			ccid3hcrx_tstamp_last_feedback;
+	struct timeval			ccid3hcrx_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u32				ccid3hcrx_elapsed_time;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -753,8 +753,7 @@ static void ccid3_hc_rx_send_feedback(st
 			break;
 		/* fall through */
 	case FBACK_PERIODIC:
-		delta = timeval_delta(&now,
-				      &hcrx->ccid3hcrx_tstamp_last_feedback);
+		delta = timeval_delta(&now, &hcrx->ccid3hcrx_last_feedback);
 		DCCP_BUG_ON(delta < 0);
 		hcrx->ccid3hcrx_x_recv  			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
@@ -770,10 +769,10 @@ static void ccid3_hc_rx_send_feedback(st
 	delta = timeval_delta(&now, &t_recv);
 	DCCP_BUG_ON(delta < 0);
 
-	hcrx->ccid3hcrx_elapsed_time	     = delta / 10;
-	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_last_counter	     = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid3hcrx_bytes_recv	     = 0;
+	hcrx->ccid3hcrx_elapsed_time  = delta / 10;
+	hcrx->ccid3hcrx_last_feedback = now;
+	hcrx->ccid3hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->ccid3hcrx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -829,7 +828,7 @@ static u32 ccid3_first_li(struct sock *s
 	}
 
 	do_gettimeofday(&tstamp);
-	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
+	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_last_feedback);
 	DCCP_BUG_ON(delta <= 0);
 
 	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
