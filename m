From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Oct 2007 11:00:01 +0000
Subject: [PATCH 1/1]: Test tree update  (was Re: [PATCH 3/10]: Dedicated auxiliary states to support passive-
Message-Id: <200710091200.01402@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: More informative state names

This realises a naming scheme due to Arnaldo Carvalho de Melo (many thanks), which
assigns more informative/declarative names to the auxiliary and intermediate states
PASSIVE_1/2i - which exist to facilitate passive-Close:

	s/PASSIVE_1/DCCP_PASSIVE_CLOSE/g;	/* any node receiving a Close */
	s/PASSIVE_2/DCCP_PASSIVE_CLOSEREQ/g;	/* when client receives CloseReq */

In addition, to better separate between sending and receiving a CloseReq,

   	s/CLOSEREQ/DCCP_ACTIVE_CLOSEREQ/g;	/* server sending a CloseReq */

However, for pretty-printing and system logs, the name of the last state remains
at `CLOSEREQ', for consistency.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   34 +++++++++++++++++-----------------
 net/dccp/input.c     |   13 ++++++-------
 net/dccp/proto.c     |   34 +++++++++++++++++-----------------
 3 files changed, 40 insertions(+), 41 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -246,33 +246,33 @@ enum dccp_state {
 	 *     (in this case, SOCK_DONE = 0).
 	 *  c. Server decides to hold TIMEWAIT state & performs an active-close.
 	 * To avoid erasing receive queues too early, the transitional states
-	 * PASSIVE_1 (from OPEN => CLOSED) and PASSIVE_2 (from (PART)OPEN to
-	 * CLOSING, corresponds to (b) above) are used.
+	 * PASSIVE_CLOSE (from OPEN => CLOSED) and PASSIVE_CLOSEREQ (from
+	 * (PART)OPEN to CLOSING, corresponds to (b) above) are used.
 	 */
-	DCCP_CLOSEREQ	= TCP_FIN_WAIT1,
-	DCCP_PASSIVE_1	= TCP_CLOSE_WAIT,	/* any node receiving a Close */
-	DCCP_CLOSING	= TCP_CLOSING,
-	DCCP_TIME_WAIT	= TCP_TIME_WAIT,
-	DCCP_CLOSED	= TCP_CLOSE,
+	DCCP_ACTIVE_CLOSEREQ	= TCP_FIN_WAIT1,
+	DCCP_PASSIVE_CLOSE	= TCP_CLOSE_WAIT,
+	DCCP_CLOSING		= TCP_CLOSING,
+	DCCP_TIME_WAIT		= TCP_TIME_WAIT,
+	DCCP_CLOSED		= TCP_CLOSE,
 	/* Everything below here is specific to DCCP only */
 	DCCP_INTRINSICS = TCP_MAX_STATES,
 	DCCP_PARTOPEN,
-	DCCP_PASSIVE_2,				/* client receiving CloseReq  */
+	DCCP_PASSIVE_CLOSEREQ,
 	DCCP_MAX_STATES
 };
 
 #define DCCP_STATE_MASK 0x1f
 
 enum {
-	DCCPF_OPEN	 = TCPF_ESTABLISHED,
-	DCCPF_REQUESTING = TCPF_SYN_SENT,
-	DCCPF_LISTEN	 = TCPF_LISTEN,
-	DCCPF_RESPOND	 = TCPF_SYN_RECV,
-	DCCPF_CLOSEREQ	 = TCPF_FIN_WAIT1,
-	DCCPF_CLOSING	 = TCPF_CLOSING,
-	DCCPF_TIME_WAIT	 = TCPF_TIME_WAIT,
-	DCCPF_CLOSED	 = TCPF_CLOSE,
-	DCCPF_PARTOPEN	 = (1 << (u8)DCCP_PARTOPEN),
+	DCCPF_OPEN	      = TCPF_ESTABLISHED,
+	DCCPF_REQUESTING      = TCPF_SYN_SENT,
+	DCCPF_LISTEN	      = TCPF_LISTEN,
+	DCCPF_RESPOND	      = TCPF_SYN_RECV,
+	DCCPF_ACTIVE_CLOSEREQ = TCPF_FIN_WAIT1,
+	DCCPF_CLOSING	      = TCPF_CLOSING,
+	DCCPF_TIME_WAIT	      = TCPF_TIME_WAIT,
+	DCCPF_CLOSED	      = TCPF_CLOSE,
+	DCCPF_PARTOPEN	      = (1 << (u8)DCCP_PARTOPEN),
 };
 
 static inline struct dccp_hdr *dccp_hdr(const struct sk_buff *skb)
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -31,8 +31,7 @@ static void dccp_fin(struct sock *sk, st
 
 static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
-	if (sk->sk_state = DCCP_CLOSEREQ) {
-		/* Server performed active close */
+	if (sk->sk_state = DCCP_ACTIVE_CLOSEREQ) {
 		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
 		dccp_done(sk);
 	} else {
@@ -42,9 +41,9 @@ static void dccp_rcv_close(struct sock *
 		 * application bug, the input queue may not be emptied at all.
 		 * In this case we wait until the peer sends the terminal Reset.
 		 */
-		if (sk->sk_state != DCCP_PASSIVE_1) {
+		if (sk->sk_state != DCCP_PASSIVE_CLOSE) {
 			dccp_fin(sk, skb);
-			dccp_set_state(sk, DCCP_PASSIVE_1);
+			dccp_set_state(sk, DCCP_PASSIVE_CLOSE);
 		}
 		sk_wake_async(sk, 1, POLL_HUP);
 	}
@@ -63,10 +62,10 @@ static void dccp_rcv_closereq(struct soc
 		return;
 	}
 
-	/* Do not enqueue CloseReq twice: see comments above for PASSIVE_1 */
-	if (sk->sk_state != DCCP_PASSIVE_2) {
+	/* Do not enqueue CloseReq twice: see comment above for PASSIVE_CLOSE */
+	if (sk->sk_state != DCCP_PASSIVE_CLOSEREQ) {
 		dccp_fin(sk, skb);
-		dccp_set_state(sk, DCCP_PASSIVE_2);
+		dccp_set_state(sk, DCCP_PASSIVE_CLOSEREQ);
 	}
 	sk_wake_async(sk, 1, POLL_HUP);
 }
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -75,7 +75,7 @@ void dccp_set_state(struct sock *sk, con
 
 	case DCCP_CLOSED:
 		if (oldstate = DCCP_CLOSING  ||
-		    oldstate = DCCP_CLOSEREQ || oldstate = DCCP_OPEN)
+		    oldstate = DCCP_ACTIVE_CLOSEREQ || oldstate = DCCP_OPEN)
 			DCCP_INC_STATS(DCCP_MIB_ESTABRESETS);
 
 		sk->sk_prot->unhash(sk);
@@ -137,17 +137,17 @@ EXPORT_SYMBOL_GPL(dccp_packet_name);
 const char *dccp_state_name(const int state)
 {
 	static char *dccp_state_names[] = {
-	[DCCP_OPEN]	  = "OPEN",
-	[DCCP_REQUESTING] = "REQUESTING",
-	[DCCP_PARTOPEN]	  = "PARTOPEN",
-	[DCCP_LISTEN]	  = "LISTEN",
-	[DCCP_RESPOND]	  = "RESPOND",
-	[DCCP_CLOSING]	  = "CLOSING",
-	[DCCP_CLOSEREQ]	  = "CLOSEREQ",
-	[DCCP_PASSIVE_1]  = "PASSIVE_1",
-	[DCCP_PASSIVE_2]  = "PASSIVE_2",
-	[DCCP_TIME_WAIT]  = "TIME_WAIT",
-	[DCCP_CLOSED]	  = "CLOSED",
+	[DCCP_OPEN]		= "OPEN",
+	[DCCP_REQUESTING]	= "REQUESTING",
+	[DCCP_PARTOPEN]		= "PARTOPEN",
+	[DCCP_LISTEN]		= "LISTEN",
+	[DCCP_RESPOND]		= "RESPOND",
+	[DCCP_CLOSING]		= "CLOSING",
+	[DCCP_ACTIVE_CLOSEREQ]	= "CLOSEREQ",
+	[DCCP_PASSIVE_CLOSE]	= "PASSIVE_CLOSE",
+	[DCCP_PASSIVE_CLOSEREQ]	= "PASSIVE_CLOSEREQ",
+	[DCCP_TIME_WAIT]	= "TIME_WAIT",
+	[DCCP_CLOSED]		= "CLOSED",
 	};
 
 	if (state >= DCCP_MAX_STATES)
@@ -850,12 +850,12 @@ EXPORT_SYMBOL_GPL(inet_dccp_listen);
 void dccp_handle_passive_close(struct sock *sk)
 {
 	switch (sk->sk_state) {
-	case DCCP_PASSIVE_1:
+	case DCCP_PASSIVE_CLOSE:
 		/* Node (client or server) has received Close packet. */
 		dccp_set_state(sk, DCCP_CLOSED);
 		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
 		break;
-	case DCCP_PASSIVE_2:
+	case DCCP_PASSIVE_CLOSEREQ:
 		/*
 		 * Client passive-close by receiving a CloseReq packet.
 		 * We need to set `active' when sending the Close, since 8.3 in
@@ -878,8 +878,8 @@ static void dccp_handle_close(struct soc
 	switch (sk->sk_state) {
 	case DCCP_CLOSED:
 		return;
-	case DCCP_PASSIVE_1:
-	case DCCP_PASSIVE_2:
+	case DCCP_PASSIVE_CLOSE:
+	case DCCP_PASSIVE_CLOSEREQ:
 		dccp_handle_passive_close(sk);
 		break;
 	case DCCP_PARTOPEN:
@@ -897,7 +897,7 @@ static void dccp_handle_close(struct soc
 		dccp_send_close(sk, 1);
 
 		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
-			next_state = DCCP_CLOSEREQ;
+			next_state = DCCP_ACTIVE_CLOSEREQ;
 		else
 			next_state = DCCP_CLOSING;
 		/* fall through */
