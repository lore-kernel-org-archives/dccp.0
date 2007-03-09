From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 Mar 2007 13:16:07 +0000
Subject: [PATCH 1/1][DCCP] [BUG-FIX]: timer bug
Message-Id: <200703091316.07792@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes the reported timer bug. Have added it as 
     00_DCCP_CCID-Timer-on-Passive-Socket.diff          on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog
Tested to work. Best regards, Gerrit.

---------------------------> Patch v0 <-----------------------------------------
[DCCP]: Initialise write_xmit_timer also on passive sockets

The TX CCID needs the write_xmit_timer for delaying packet sends. Previously
this timer was only activated on active (connecting) sockets.

This patch initialises the write_xmit_timer in sync with the other timers, i.e.
the timer will be ready on any socket. This is used by applications with a
listening socket which start to stream after receiving an initiation by the
client.  The write_xmit_timer is stopped when the application closes, as before.

Was tested to work and to remove the timer bug reported on dccp@vger.

Also moved timer initialisation into timer.c (static). 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    1 +
 net/dccp/output.c |   16 ----------------
 net/dccp/timer.c  |   25 +++++++++++++++++++++++++
 3 files changed, 26 insertions(+), 16 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -191,6 +191,7 @@ extern void dccp_send_sync(struct sock *
 			   const enum dccp_pkt_type pkt_type);
 
 extern void dccp_write_xmit(struct sock *sk, int block);
+extern void dccp_write_xmit_timer(unsigned long data);
 extern void dccp_write_space(struct sock *sk);
 
 extern void dccp_init_xmit_timers(struct sock *sk);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -213,19 +213,6 @@ do_interrupted:
 	goto out;
 }
 
-static void dccp_write_xmit_timer(unsigned long data) {
-	struct sock *sk = (struct sock *)data;
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk))
-		sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies+1);
-	else
-		dccp_write_xmit(sk, 0);
-	bh_unlock_sock(sk);
-	sock_put(sk);
-}
-
 void dccp_write_xmit(struct sock *sk, int block)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -434,9 +421,6 @@ static inline void dccp_connect_init(str
 	dp->dccps_gar = dp->dccps_iss;
 
 	icsk->icsk_retransmits = 0;
-	init_timer(&dp->dccps_xmit_timer);
-	dp->dccps_xmit_timer.data = (unsigned long)sk;
-	dp->dccps_xmit_timer.function = dccp_write_xmit_timer;
 }
 
 int dccp_connect(struct sock *sk)
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -261,8 +261,33 @@ out:
 	sock_put(sk);
 }
 
+/* Transmit-delay timer: used by the CCIDs to delay actual send time */
+void dccp_write_xmit_timer(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk))
+		sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies+1);
+	else
+		dccp_write_xmit(sk, 0);
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+static void dccp_init_write_xmit_timer(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	init_timer(&dp->dccps_xmit_timer);
+	dp->dccps_xmit_timer.data = (unsigned long)sk;
+	dp->dccps_xmit_timer.function = dccp_write_xmit_timer;
+}
+
 void dccp_init_xmit_timers(struct sock *sk)
 {
+	dccp_init_write_xmit_timer(sk);
 	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
 				  &dccp_keepalive_timer);
 }
