From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 08:46:09 +0000
Subject: [PATCH] net: dccp: Convert timers to use timer_setup()
Message-Id: <20171024084609.GA23862@beast>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Adds a pointer back to the sock.

Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: dccp@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/dccp/ccids/ccid2.c | 10 +++++-----
 net/dccp/ccids/ccid2.h |  1 +
 net/dccp/ccids/ccid3.c | 11 ++++++-----
 net/dccp/ccids/ccid3.h |  1 +
 net/dccp/timer.c       | 12 +++++++-----
 5 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index e1295d5f2c56..1c75cd1255f6 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,10 +126,10 @@ static void ccid2_change_l_seq_window(struct sock *sk, u64 val)
 						  DCCPF_SEQ_WMAX));
 }
 
-static void ccid2_hc_tx_rto_expire(unsigned long data)
+static void ccid2_hc_tx_rto_expire(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
-	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = from_timer(hc, t, tx_rtotimer);
+	struct sock *sk = hc->sk;
 	const bool sender_was_blocked = ccid2_cwnd_network_limited(hc);
 
 	bh_lock_sock(sk);
@@ -733,8 +733,8 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	hc->tx_rpdupack  = -1;
 	hc->tx_last_cong = hc->tx_lsndtime = hc->tx_cwnd_stamp = ccid2_jiffies32;
 	hc->tx_cwnd_used = 0;
-	setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
-			(unsigned long)sk);
+	hc->sk		 = sk;
+	timer_setup(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire, 0);
 	INIT_LIST_HEAD(&hc->tx_av_chunks);
 	return 0;
 }
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 6e50ef2898fb..1af0116dc6ce 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -85,6 +85,7 @@ struct ccid2_hc_tx_sock {
 				tx_rto;
 	u64			tx_rtt_seq:48;
 	struct timer_list	tx_rtotimer;
+	struct sock		*sk;
 
 	/* Congestion Window validation (optional, RFC 2861) */
 	u32			tx_cwnd_used,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 119c04317d48..8b5ba6dffac7 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -195,10 +195,10 @@ static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hc,
 	}
 }
 
-static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
+static void ccid3_hc_tx_no_feedback_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
-	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = from_timer(hc, t, tx_no_feedback_timer);
+	struct sock *sk = hc->sk;
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -505,8 +505,9 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 
 	hc->tx_state = TFRC_SSTATE_NO_SENT;
 	hc->tx_hist  = NULL;
-	setup_timer(&hc->tx_no_feedback_timer,
-			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
+	hc->sk	     = sk;
+	timer_setup(&hc->tx_no_feedback_timer,
+		    ccid3_hc_tx_no_feedback_timer, 0);
 	return 0;
 }
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 1a9933c29672..813d91c6e1e2 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -106,6 +106,7 @@ struct ccid3_hc_tx_sock {
 	u8				tx_last_win_count;
 	ktime_t				tx_t_last_win_count;
 	struct timer_list		tx_no_feedback_timer;
+	struct sock			*sk;
 	ktime_t				tx_t_ld;
 	ktime_t				tx_t_nom;
 	struct tfrc_tx_hist_entry	*tx_hist;
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 1e35526bf436..b50a8732ff43 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -234,10 +234,13 @@ static void dccp_write_xmitlet(unsigned long data)
 	bh_unlock_sock(sk);
 }
 
-static void dccp_write_xmit_timer(unsigned long data)
+static void dccp_write_xmit_timer(struct timer_list *t)
 {
-	dccp_write_xmitlet(data);
-	sock_put((struct sock *)data);
+	struct dccp_sock *dp = from_timer(dp, t, dccps_xmit_timer);
+	struct sock *sk = &dp->dccps_inet_connection.icsk_inet.sk;
+
+	dccp_write_xmitlet((unsigned long)sk);
+	sock_put(sk);
 }
 
 void dccp_init_xmit_timers(struct sock *sk)
@@ -245,8 +248,7 @@ void dccp_init_xmit_timers(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	tasklet_init(&dp->dccps_xmitlet, dccp_write_xmitlet, (unsigned long)sk);
-	setup_timer(&dp->dccps_xmit_timer, dccp_write_xmit_timer,
-							     (unsigned long)sk);
+	timer_setup(&dp->dccps_xmit_timer, dccp_write_xmit_timer, 0);
 	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
 				  &dccp_keepalive_timer);
 }
-- 
2.7.4


-- 
Kees Cook
Pixel Security
