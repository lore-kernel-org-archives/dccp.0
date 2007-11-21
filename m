From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:25 +0000
Subject: [PATCH 03/11] [CCID3]: Accurately determine idle & application-limited periods
Message-Id: <1195658913-24840-4-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This fixes/updates the handling of idle and application-limited periods in CCID3,
which currently is broken: there is no detection as to how long a sender has been
idle - there is only one flag which is toggled in between function calls.

Being obsolete now, the `idle' flag is removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   18 ++++++++++--------
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 6680c80..a6111e5 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -119,6 +119,13 @@ static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 
 }
 
+static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
+{
+	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
+
+	return delta / hctx->ccid3hctx_rtt;
+}
+
 /**
  * ccid3_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
@@ -139,10 +146,11 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
-	 * when idling [RFC 4342, 5.1]. See also draft-ietf-dccp-rfc3448bis.
+	 * when idling [RFC 4342, 5.1]. Definition of idling is from rfc3448bis:
+	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (unlikely(hctx->ccid3hctx_idle)) {
+	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
 		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
 	}
@@ -228,8 +236,6 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
-	hctx->ccid3hctx_idle = 1;
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
@@ -372,7 +378,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
-	hctx->ccid3hctx_idle = 0;
 
 	/* set the nominal send time for the next following packet */
 	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
@@ -531,9 +536,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 				   jiffies + usecs_to_jiffies(t_nfb));
-
-		/* set idle flag */
-		hctx->ccid3hctx_idle = 1;
 		break;
 	case TFRC_SSTATE_NO_SENT:	/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 83467c3..36eca34 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -88,7 +88,6 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
  *				 with last_win_count value sent
  * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
- * @ccid3hctx_idle - Flag indicating that sender is idling
  * @ccid3hctx_t_ld - Time last doubled during slow start
  * @ccid3hctx_t_nom - Nominal send time of next packet
  * @ccid3hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
@@ -107,7 +106,6 @@ struct ccid3_hc_tx_sock {
 	u16				ccid3hctx_s;
 	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
-	u8				ccid3hctx_idle;
 	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
 	ktime_t				ccid3hctx_t_ld;
-- 
1.5.3.4

