From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:27:59 +0000
Subject: [PATCH 5/7]: Remove forward declarations in timer.c
Message-Id: <200611131328.00094@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove forward declarations in timer.c

This removes 3 forward declarations by reordering 2 functions.

No code change at all.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
---
 net/dccp/timer.c |  110 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 53 insertions(+), 57 deletions(-)

--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -20,16 +20,6 @@ int  sysctl_dccp_request_retries	__read_
 int  sysctl_dccp_retries1		__read_mostly = TCP_RETR1;
 int  sysctl_dccp_retries2		__read_mostly = TCP_RETR2;
 
-static void dccp_write_timer(unsigned long data);
-static void dccp_keepalive_timer(unsigned long data);
-static void dccp_delack_timer(unsigned long data);
-
-void dccp_init_xmit_timers(struct sock *sk)
-{
-	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
-				  &dccp_keepalive_timer);
-}
-
 static void dccp_write_err(struct sock *sk)
 {
 	sk->sk_err = sk->sk_err_soft ? : ETIMEDOUT;
@@ -90,53 +80,6 @@ static int dccp_write_timeout(struct soc
 	return 0;
 }
 
-/* This is the same as tcp_delack_timer, sans prequeue & mem_reclaim stuff */
-static void dccp_delack_timer(unsigned long data)
-{
-	struct sock *sk = (struct sock *)data;
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
-	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk)) {
-		/* Try again later. */
-		icsk->icsk_ack.blocked = 1;
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOCKED);
-		sk_reset_timer(sk, &icsk->icsk_delack_timer,
-			       jiffies + TCP_DELACK_MIN);
-		goto out;
-	}
-
-	if (sk->sk_state = DCCP_CLOSED ||
-	    !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
-		goto out;
-	if (time_after(icsk->icsk_ack.timeout, jiffies)) {
-		sk_reset_timer(sk, &icsk->icsk_delack_timer,
-			       icsk->icsk_ack.timeout);
-		goto out;
-	}
-
-	icsk->icsk_ack.pending &= ~ICSK_ACK_TIMER;
-
-	if (inet_csk_ack_scheduled(sk)) {
-		if (!icsk->icsk_ack.pingpong) {
-			/* Delayed ACK missed: inflate ATO. */
-			icsk->icsk_ack.ato = min(icsk->icsk_ack.ato << 1,
-						 icsk->icsk_rto);
-		} else {
-			/* Delayed ACK missed: leave pingpong mode and
-			 * deflate ATO.
-			 */
-			icsk->icsk_ack.pingpong = 0;
-			icsk->icsk_ack.ato = TCP_ATO_MIN;
-		}
-		dccp_send_ack(sk);
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKS);
-	}
-out:
-	bh_unlock_sock(sk);
-	sock_put(sk);
-}
-
 /*
  *	The DCCP retransmit timer.
  */
@@ -270,3 +213,56 @@ out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
+
+/* This is the same as tcp_delack_timer, sans prequeue & mem_reclaim stuff */
+static void dccp_delack_timer(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		/* Try again later. */
+		icsk->icsk_ack.blocked = 1;
+		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOCKED);
+		sk_reset_timer(sk, &icsk->icsk_delack_timer,
+			       jiffies + TCP_DELACK_MIN);
+		goto out;
+	}
+
+	if (sk->sk_state = DCCP_CLOSED ||
+	    !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
+		goto out;
+	if (time_after(icsk->icsk_ack.timeout, jiffies)) {
+		sk_reset_timer(sk, &icsk->icsk_delack_timer,
+			       icsk->icsk_ack.timeout);
+		goto out;
+	}
+
+	icsk->icsk_ack.pending &= ~ICSK_ACK_TIMER;
+
+	if (inet_csk_ack_scheduled(sk)) {
+		if (!icsk->icsk_ack.pingpong) {
+			/* Delayed ACK missed: inflate ATO. */
+			icsk->icsk_ack.ato = min(icsk->icsk_ack.ato << 1,
+						 icsk->icsk_rto);
+		} else {
+			/* Delayed ACK missed: leave pingpong mode and
+			 * deflate ATO.
+			 */
+			icsk->icsk_ack.pingpong = 0;
+			icsk->icsk_ack.ato = TCP_ATO_MIN;
+		}
+		dccp_send_ack(sk);
+		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKS);
+	}
+out:
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+void dccp_init_xmit_timers(struct sock *sk)
+{
+	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
+				  &dccp_keepalive_timer);
+}
