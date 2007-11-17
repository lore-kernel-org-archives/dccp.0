From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:29 +0000
Subject: [PATCH 02/16] [CCID3]: Ignore trivial amounts of elapsed time
Message-Id: <1195291783668-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes a previously undiscovered issue; the problem is in computing
the elapsed time as the time between `receiving' the packet (i.e. skb enters
CCID module) and sending feedback:

     - there is no layer-processing, queueing, or delay involved,
     - hence the elapsed time is in the order of 1 function call
     - this is in the dimension of maximally 50..100usec
     - which renders the use of elapsed time almost entirely useless.

The fix is simply to ignore such trivial amounts of elapsed time.

As a further advantage, the now useless elapsed_time field can be removed from
the socket, which reduces the socket structure by another four bytes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   10 +---------
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 52b8e4c..e153366 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -747,11 +747,6 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
-	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	delta = ktime_us_delta(now, packet->dccphrx_tstamp);
-	DCCP_BUG_ON(delta < 0);
-	hcrx->ccid3hcrx_elapsed_time = delta / 10;
-
 	if (hcrx->ccid3hcrx_p = 0)
 		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
 	else if (hcrx->ccid3hcrx_p > 1000000) {
@@ -781,10 +776,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if ((hcrx->ccid3hcrx_elapsed_time != 0 &&
-	     dccp_insert_option_elapsed_time(sk, skb,
-					     hcrx->ccid3hcrx_elapsed_time)) ||
-	    dccp_insert_option_timestamp(sk, skb) ||
+	if (dccp_insert_option_timestamp(sk, skb) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 0cdc982..83467c3 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -147,7 +147,6 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
- *  @ccid3hcrx_elapsed_time  -  Time since packet reception
  */
 struct ccid3_hc_rx_sock {
 	struct tfrc_rx_info		ccid3hcrx_tfrc;
@@ -165,7 +164,6 @@ struct ccid3_hc_rx_sock {
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
-	u32				ccid3hcrx_elapsed_time;
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
-- 
1.5.2.2.238.g7cbf2f2-dirty

