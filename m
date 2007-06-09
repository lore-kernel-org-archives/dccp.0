From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:32:38 +0000
Subject: [PATCH 2/3]: Sending time: update to ktime_t and bug-fix
Message-Id: <200706091932.38162@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Sending time: update to ktime_t and bug-fix

This updates the computation of t_nom and t_last_win_count to use the newer
gettimeofday interface.

The second point of this patch is to fix a bug in the send time processing:

  ccid3_hc_tx_send_packet currently returns 0 when the time difference
  between current time and t_nom is less than 1000 microseconds. 
  
  In this case the packet is sent immediately; but, unlike other packets
  that can be emitted on first attempt, it will not have its window
  counter updated and its options set as required. This is a bug.
  
Fix: Require the time difference to be at least 1000 microseconds. The
     algorithm then converges: time differences > 1000 microseconds trigger the
     timer in dccp_write_xmit; after timer expiry this function is tried again;
     when the time difference is less than 1000, the packet will have its options
     added and window counter updated as required.
  
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>  
---
 net/dccp/ccids/ccid3.c |   30 ++++++++++++------------------
 net/dccp/ccids/ccid3.h |    4 ++--
 2 files changed, 14 insertions(+), 20 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -108,10 +108,10 @@ struct ccid3_hc_tx_sock {
 	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	u8				ccid3hctx_idle;
-	struct timeval			ccid3hctx_t_last_win_count;
+	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
 	struct timeval			ccid3hctx_t_ld;
-	struct timeval			ccid3hctx_t_nom;
+	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
 	struct list_head		ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -194,25 +194,20 @@ static inline void ccid3_hc_tx_update_s(
  *	The algorithm is not applicable if RTT < 4 microseconds.
  */
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
-						struct timeval *now)
+						ktime_t now)
 {
-	suseconds_t delta;
 	u32 quarter_rtts;
 
 	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
 		return;
 
-	delta = timeval_delta(now, &hctx->ccid3hctx_t_last_win_count);
-	DCCP_BUG_ON(delta < 0);
-
-	quarter_rtts = (u32)delta / (hctx->ccid3hctx_rtt / 4);
+	quarter_rtts = ktime_delta(now, hctx->ccid3hctx_t_last_win_count);
+	quarter_rtts /= (hctx->ccid3hctx_rtt / 4);
 
 	if (quarter_rtts > 0) {
-		hctx->ccid3hctx_t_last_win_count = *now;
+		hctx->ccid3hctx_t_last_win_count = now;
 		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
 		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
-
-		ccid3_pr_debug("now at %#X\n", hctx->ccid3hctx_last_win_count);
 	}
 }
 
@@ -312,8 +307,8 @@ static int ccid3_hc_tx_send_packet(struc
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
-	suseconds_t delay;
+	ktime_t now = ktime_get_real();
+	s64 delay;
 
 	BUG_ON(hctx = NULL);
 
@@ -325,8 +320,6 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	dccp_timestamp(sk, &now);
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
@@ -361,7 +354,7 @@ static int ccid3_hc_tx_send_packet(struc
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		delay = ktime_delta(hctx->ccid3hctx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -371,10 +364,10 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
-			return delay / 1000L;
+		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+			return (u32)delay / 1000L;
 
-		ccid3_hc_tx_update_win_count(hctx, &now);
+		ccid3_hc_tx_update_win_count(hctx, now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -387,7 +380,8 @@ static int ccid3_hc_tx_send_packet(struc
 	hctx->ccid3hctx_idle = 0;
 
 	/* set the nominal send time for the next following packet */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+	hctx->ccid3hctx_t_nom = ktime_add_ns(hctx->ccid3hctx_t_nom,
+					     hctx->ccid3hctx_t_ipi * 1000);
 
 	return 0;
 }
