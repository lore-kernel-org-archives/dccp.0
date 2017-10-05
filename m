From: Kees Cook <keescook@chromium.org>
Date: Thu, 05 Oct 2017 00:52:26 +0000
Subject: [PATCH] inet/connection_sock: Convert timers to use
Message-Id: <20171005005226.GA23598@beast>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: netdev@vger.kernel.org
Cc: dccp@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 include/net/inet_connection_sock.h |  6 +++---
 net/dccp/timer.c                   | 18 ++++++++++--------
 net/ipv4/inet_connection_sock.c    | 14 ++++++--------
 net/ipv4/tcp_timer.c               | 18 +++++++++++-------
 4 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 13e4c89a8231..0358745ea059 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -169,9 +169,9 @@ enum inet_csk_ack_state_t {
 };
 
 void inet_csk_init_xmit_timers(struct sock *sk,
-			       void (*retransmit_handler)(unsigned long),
-			       void (*delack_handler)(unsigned long),
-			       void (*keepalive_handler)(unsigned long));
+			       void (*retransmit_handler)(struct timer_list *),
+			       void (*delack_handler)(struct timer_list *),
+			       void (*keepalive_handler)(struct timer_list *));
 void inet_csk_clear_xmit_timers(struct sock *sk);
 
 static inline void inet_csk_schedule_ack(struct sock *sk)
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 3a2c34027758..1e35526bf436 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -125,10 +125,11 @@ static void dccp_retransmit_timer(struct sock *sk)
 		__sk_dst_reset(sk);
 }
 
-static void dccp_write_timer(unsigned long data)
+static void dccp_write_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
-	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_connection_sock *icsk +			from_timer(icsk, t, icsk_retransmit_timer);
+	struct sock *sk = &icsk->icsk_inet.sk;
 	int event = 0;
 
 	bh_lock_sock(sk);
@@ -161,19 +162,20 @@ static void dccp_write_timer(unsigned long data)
 	sock_put(sk);
 }
 
-static void dccp_keepalive_timer(unsigned long data)
+static void dccp_keepalive_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 
 	pr_err("dccp should not use a keepalive timer !\n");
 	sock_put(sk);
 }
 
 /* This is the same as tcp_delack_timer, sans prequeue & mem_reclaim stuff */
-static void dccp_delack_timer(unsigned long data)
+static void dccp_delack_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
-	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_connection_sock *icsk +			from_timer(icsk, t, icsk_delack_timer);
+	struct sock *sk = &icsk->icsk_inet.sk;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c039c937ba90..c838988eee04 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -494,17 +494,15 @@ EXPORT_SYMBOL(inet_csk_accept);
  * to optimize.
  */
 void inet_csk_init_xmit_timers(struct sock *sk,
-			       void (*retransmit_handler)(unsigned long),
-			       void (*delack_handler)(unsigned long),
-			       void (*keepalive_handler)(unsigned long))
+			       void (*retransmit_handler)(struct timer_list *t),
+			       void (*delack_handler)(struct timer_list *t),
+			       void (*keepalive_handler)(struct timer_list *t))
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	setup_timer(&icsk->icsk_retransmit_timer, retransmit_handler,
-			(unsigned long)sk);
-	setup_timer(&icsk->icsk_delack_timer, delack_handler,
-			(unsigned long)sk);
-	setup_timer(&sk->sk_timer, keepalive_handler, (unsigned long)sk);
+	timer_setup(&icsk->icsk_retransmit_timer, retransmit_handler, 0);
+	timer_setup(&icsk->icsk_delack_timer, delack_handler, 0);
+	timer_setup(&sk->sk_timer, keepalive_handler, 0);
 	icsk->icsk_pending = icsk->icsk_ack.pending = 0;
 }
 EXPORT_SYMBOL(inet_csk_init_xmit_timers);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 655dd8d7f064..d24c29f73146 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -283,15 +283,17 @@ void tcp_delack_timer_handler(struct sock *sk)
  *
  *  Returns: Nothing (void)
  */
-static void tcp_delack_timer(unsigned long data)
+static void tcp_delack_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
+	struct inet_connection_sock *icsk +			from_timer(icsk, t, icsk_delack_timer);
+	struct sock *sk = &icsk->icsk_inet.sk;
 
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk)) {
 		tcp_delack_timer_handler(sk);
 	} else {
-		inet_csk(sk)->icsk_ack.blocked = 1;
+		icsk->icsk_ack.blocked = 1;
 		__NET_INC_STATS(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		/* deleguate our work to tcp_release_cb() */
 		if (!test_and_set_bit(TCP_DELACK_TIMER_DEFERRED, &sk->sk_tsq_flags))
@@ -570,9 +572,11 @@ void tcp_write_timer_handler(struct sock *sk)
 	sk_mem_reclaim(sk);
 }
 
-static void tcp_write_timer(unsigned long data)
+static void tcp_write_timer(struct timer_list *t)
 {
-	struct sock *sk = (struct sock *)data;
+	struct inet_connection_sock *icsk +			from_timer(icsk, t, icsk_retransmit_timer);
+	struct sock *sk = &icsk->icsk_inet.sk;
 
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk)) {
@@ -607,9 +611,9 @@ void tcp_set_keepalive(struct sock *sk, int val)
 EXPORT_SYMBOL_GPL(tcp_set_keepalive);
 
 
-static void tcp_keepalive_timer (unsigned long data)
+static void tcp_keepalive_timer (struct timer_list *t)
 {
-	struct sock *sk = (struct sock *) data;
+	struct sock *sk = from_timer(sk, t, sk_timer);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 elapsed;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
