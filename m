From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:36:42 +0000
Subject: [PATCH 33/43]: Basic support for passive-close
Message-Id: <200704051636.42765@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Basic support for passive-close

This implements necessary state transitions for the two forms of passive-close

 * PASSIVE_1, which is entered when a host receives Close;
 * PASSIVE_2, which is entered when a client receives CloseReq.

The handling is such that these passive connection-termination requests are
enqueued as `fin' packets so that dccp_recvmsg() can later detect them. The
only thing I am not entirely sure about is the wake_async in dccp_rcv_closereq();
this has been copied from dccp_rcv_close() (but looks ok from the principle).

The completed state transition diagram is on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/closing_states/

NB: Regrettably, it is no longer easily possible to use a table-based transition as
    before. The reason is that the role of the host (server or client) also plays a
    `role' in the state transition. Therefore DCCP_ACTION_FIN has also been removed.
    Another difference is that the transition into DCCP_CLOSED is now after sending
    the Close/CloseReq.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    1 
 net/dccp/input.c     |   34 +++++++++++-----
 net/dccp/proto.c     |  108 ++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 102 insertions(+), 41 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -55,6 +55,9 @@ EXPORT_SYMBOL_GPL(dccp_hashinfo);
 /* the maximum queue length for tx in packets. 0 is no limit */
 int sysctl_dccp_tx_qlen __read_mostly = 5;
 
+/* Forward Declarations. */
+static void dccp_handle_passive_close(struct sock *sk);
+
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
@@ -71,7 +74,8 @@ void dccp_set_state(struct sock *sk, con
 		break;
 
 	case DCCP_CLOSED:
-		if (oldstate = DCCP_CLOSING || oldstate = DCCP_OPEN)
+		if (oldstate = DCCP_CLOSING  ||
+		    oldstate = DCCP_CLOSEREQ || oldstate = DCCP_OPEN)
 			DCCP_INC_STATS(DCCP_MIB_ESTABRESETS);
 
 		sk->sk_prot->unhash(sk);
@@ -721,19 +725,26 @@ int dccp_recvmsg(struct kiocb *iocb, str
 
 		dh = dccp_hdr(skb);
 
-		if (dh->dccph_type = DCCP_PKT_DATA ||
-		    dh->dccph_type = DCCP_PKT_DATAACK)
+		switch (dh->dccph_type) {
+		case DCCP_PKT_DATA:
+		case DCCP_PKT_DATAACK:
 			goto found_ok_skb;
 
-		if (dh->dccph_type = DCCP_PKT_RESET ||
-		    dh->dccph_type = DCCP_PKT_CLOSE) {
-			dccp_pr_debug("found fin ok!\n");
+		case DCCP_PKT_CLOSE:
+		case DCCP_PKT_CLOSEREQ:
+			if (!(flags & MSG_PEEK))
+				dccp_handle_passive_close(sk);
+			/* fall through */
+		case DCCP_PKT_RESET:
+			dccp_pr_debug("found fin (%s) ok!\n",
+				      dccp_packet_name(dh->dccph_type));
 			len = 0;
 			goto found_fin_ok;
+		default:
+			dccp_pr_debug("packet_type=%s\n",
+				      dccp_packet_name(dh->dccph_type));
+			sk_eat_skb(sk, skb, 0);
 		}
-		dccp_pr_debug("packet_type=%s\n",
-			      dccp_packet_name(dh->dccph_type));
-		sk_eat_skb(sk, skb, 0);
 verify_sock_status:
 		if (sock_flag(sk, SOCK_DONE)) {
 			len = 0;
@@ -835,28 +846,64 @@ out:
 
 EXPORT_SYMBOL_GPL(inet_dccp_listen);
 
-static const unsigned char dccp_new_state[] = {
-	/* current state:   new state:      action:	*/
-	[0]		  = DCCP_CLOSED,
-	[DCCP_OPEN]	  = DCCP_CLOSING | DCCP_ACTION_FIN,
-	[DCCP_REQUESTING] = DCCP_CLOSED,
-	[DCCP_PARTOPEN]	  = DCCP_CLOSING | DCCP_ACTION_FIN,
-	[DCCP_LISTEN]	  = DCCP_CLOSED,
-	[DCCP_RESPOND]	  = DCCP_CLOSED,
-	[DCCP_CLOSING]	  = DCCP_CLOSED,
-	[DCCP_TIME_WAIT]  = DCCP_CLOSED,
-	[DCCP_CLOSED]	  = DCCP_CLOSED,
-};
-
-static int dccp_close_state(struct sock *sk)
+void dccp_handle_passive_close(struct sock *sk)
 {
-	const int next = dccp_new_state[sk->sk_state];
-	const int ns = next & DCCP_STATE_MASK;
+	switch (sk->sk_state) {
+	case DCCP_PASSIVE_1:
+		/* Node (client or server) has received Close packet. */
+		dccp_set_state(sk, DCCP_CLOSED);
+		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
+		break;
+	case DCCP_PASSIVE_2:
+		/*
+		 * Client passive-close by receiving a CloseReq packet.
+		 * We need to set `active' when sending the Close, since 8.3 in
+		 * RFC 4340 requires nodes in the CLOSING state to retransmit
+		 * the Close/CloseReq packets. A conforming peer implementation
+		 * will in turn retransmit its CloseReq packets as well.
+		 */
+		dccp_set_state(sk, DCCP_CLOSING);
+		dccp_send_close(sk, 1);
+		break;
+	default:
+		return;
+	}
+}
 
-	if (ns != sk->sk_state)
-		dccp_set_state(sk, ns);
+static void dccp_handle_close(struct sock *sk)
+{
+	u8 next_state = DCCP_CLOSED;
 
-	return next & DCCP_ACTION_FIN;
+	switch (sk->sk_state) {
+	case DCCP_CLOSED:
+		return;
+	case DCCP_PASSIVE_1:
+	case DCCP_PASSIVE_2:
+		dccp_handle_passive_close(sk);
+		break;
+	case DCCP_PARTOPEN:
+		/*
+		 * Clear PARTOPEN timer [RFC 4340, 8.1.5]; we will be sending a
+		 * Close presently, which will be (re-)transmitted anyhow (8.3).
+		 */
+		dccp_pr_debug("Stop PARTOPEN timer (%p)\n", sk);
+		inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
+		/* fall through */
+	case DCCP_OPEN:
+		/*
+		 * An active close need only be sent in these two states
+		 */
+		dccp_send_close(sk, 1);
+
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+			next_state = DCCP_CLOSEREQ;
+		else
+			next_state = DCCP_CLOSING;
+		/* fall through */
+	default:
+		dccp_set_state(sk, next_state);
+		break;
+	}
 }
 
 void dccp_close(struct sock *sk, long timeout)
@@ -893,9 +940,8 @@ void dccp_close(struct sock *sk, long ti
 	if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
-	} else if (dccp_close_state(sk)) {
-		dccp_send_close(sk, 1);
-	}
+	} else	/* Passive/active close after all data has been read. */
+		dccp_handle_close(sk);
 
 	sk_stream_wait_close(sk, timeout);
 
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -31,10 +31,23 @@ static void dccp_fin(struct sock *sk, st
 
 static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
-	dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
-	dccp_fin(sk, skb);
-	dccp_set_state(sk, DCCP_CLOSED);
-	sk_wake_async(sk, 1, POLL_HUP);
+	if (sk->sk_state = DCCP_CLOSEREQ) {
+		/* Server performed active close */
+		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
+		dccp_done(sk);
+	} else {
+		/*
+		 * Passive-close: Only the first Close is enqueued, there is no
+		 * point in putting several Closes on the queue - in case of an
+		 * application bug, the input queue may not be emptied at all.
+		 * In this case we wait until the peer sends the terminal Reset.
+		 */
+		if (sk->sk_state != DCCP_PASSIVE_1) {
+			dccp_fin(sk, skb);
+			dccp_set_state(sk, DCCP_PASSIVE_1);
+		}
+		sk_wake_async(sk, 1, POLL_HUP);
+	}
 }
 
 static void dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
@@ -50,9 +63,12 @@ static void dccp_rcv_closereq(struct soc
 		return;
 	}
 
-	if (sk->sk_state != DCCP_CLOSING)
-		dccp_set_state(sk, DCCP_CLOSING);
-	dccp_send_close(sk, 0);
+	/* Do not enqueue CloseReq twice: see comments above for PASSIVE_1 */
+	if (sk->sk_state != DCCP_PASSIVE_2) {
+		dccp_fin(sk, skb);
+		dccp_set_state(sk, DCCP_PASSIVE_2);
+	}
+	sk_wake_async(sk, 1, POLL_HUP);
 }
 
 static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
@@ -181,7 +197,7 @@ static int __dccp_rcv_established(struct
 		return 0;
 	case DCCP_PKT_CLOSEREQ:
 		dccp_rcv_closereq(sk, skb);
-		goto discard;
+		return 0;
 	case DCCP_PKT_CLOSE:
 		dccp_rcv_close(sk, skb);
 		return 0;
@@ -534,7 +550,7 @@ int dccp_rcv_state_process(struct sock *
 		goto discard;
 	} else if (dh->dccph_type = DCCP_PKT_CLOSEREQ) {
 		dccp_rcv_closereq(sk, skb);
-		goto discard;
+		return 0;
 	} else if (dh->dccph_type = DCCP_PKT_CLOSE) {
 		dccp_rcv_close(sk, skb);
 		return 0;
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -259,7 +259,6 @@ enum dccp_state {
 };
 
 #define DCCP_STATE_MASK 0x1f
-#define DCCP_ACTION_FIN (1<<7)
 
 enum {
 	DCCPF_OPEN	 = TCPF_ESTABLISHED,
