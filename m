From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 28 Nov 2007 15:23:51 +0000
Subject: [PATCH 4/5] [DCCP]: Integrate state transitions for passive-close
Message-Id: <1196263432-17390-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This adds the necessary state transitions for the two forms of passive-close

 * PASSIVE_CLOSE    - which is entered when a host   receives a Close;
 * PASSIVE_CLOSEREQ - which is entered when a client receives a CloseReq.

Here is a detailed account of what the patch does in each state.

1) Receiving CloseReq

  The pseudo-code in 8.5 says:

     Step 13: Process CloseReq
          If P.type = CloseReq and S.state < CLOSEREQ,
              Generate Close
              S.state := CLOSING
              Set CLOSING timer.

  This means we need to address what to do in CLOSED, LISTEN, REQUEST, RESPOND, PARTOPEN, and OPEN.

   * CLOSED:         silently ignore - it may be a late or duplicate CloseReq;
   * LISTEN/RESPOND: will not appear, since Step 7 is performed first (we know we are the client);
   * REQUEST:        perform Step 13 directly (no need to enqueue packet);
   * OPEN/PARTOPEN:  enter PASSIVE_CLOSEREQ so that the application has a chance to process unread data.

  When already in PASSIVE_CLOSEREQ, no second CloseReq is enqueued. In any other state, the CloseReq is ignored.
  I think that this offers some robustness against rare and pathological cases: e.g. a simultaneous close where
  the client sends a Close and the server a CloseReq. The client will then be retransmitting its Close until it
  gets the Reset, so ignoring the CloseReq while in state CLOSING is sane.

2) Receiving Close

  The code below from 8.5 is unconditional.

     Step 14: Process Close
          If P.type = Close,
              Generate Reset(Closed)
              Tear down connection
              Drop packet and return

  Thus we need to consider all states:
   * CLOSED:           silently ignore, since this can happen when a retransmitted or late Close arrives;
   * LISTEN:           dccp_rcv_state_process() will generate a Reset ("No Connection");
   * REQUEST:          perform Step 14 directly (no need to enqueue packet);
   * RESPOND:          dccp_check_req() will generate a Reset ("Packet Error") -- left it at that;
   * OPEN/PARTOPEN:    enter PASSIVE_CLOSE so that application has a chance to process unread data;
   * CLOSEREQ:         server performed active-close -- perform Step 14;
   * CLOSING:          simultaneous-close: use a tie-breaker to avoid message ping-pong (see comment);
   * PASSIVE_CLOSEREQ: ignore - the peer has a bug (sending first a CloseReq and now a Close);
   * TIMEWAIT:         packet is ignored.

   Note that the condition of receiving a packet in state CLOSED here is different from the condition "there
   is no socket for such a connection": the socket still exists, but its state indicates it is unusable.

   Last, dccp_finish_passive_close sets either DCCP_CLOSED or DCCP_CLOSING = TCP_CLOSING, so that
   sk_stream_wait_close() will wait for the final Reset (which will trigger CLOSING => CLOSED).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/dccp.h |    1 -
 net/dccp/input.c     |   88 +++++++++++++++++++++++++++++++++++++++++--------
 net/dccp/proto.c     |   88 +++++++++++++++++++++++++++++++++-----------------
 3 files changed, 131 insertions(+), 46 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 8b3f9ad..312b989 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -260,7 +260,6 @@ enum dccp_state {
 };
 
 #define DCCP_STATE_MASK 0x1f
-#define DCCP_ACTION_FIN (1<<7)
 
 enum {
 	DCCPF_OPEN	      = TCPF_ESTABLISHED,
diff --git a/net/dccp/input.c b/net/dccp/input.c
index ef299fb..fe4b0fb 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -32,16 +32,56 @@ static void dccp_fin(struct sock *sk, struct sk_buff *skb)
 	sk->sk_data_ready(sk, 0);
 }
 
-static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
+static int dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
-	dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
-	dccp_fin(sk, skb);
-	dccp_set_state(sk, DCCP_CLOSED);
-	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
+	int queued = 0;
+
+	switch (sk->sk_state) {
+	/*
+	 * We ignore Close when received in one of the following states:
+	 *  - CLOSED		(may be a late or duplicate packet)
+	 *  - PASSIVE_CLOSEREQ	(the peer has sent a CloseReq earlier)
+	 *  - RESPOND		(already handled by dccp_check_req)
+	 */
+	case DCCP_CLOSING:
+		/*
+		 * Simultaneous-close: receiving a Close after sending one. This
+		 * can happen if both client and server perform active-close and
+		 * will result in an endless ping-pong of crossing and retrans-
+		 * mitted Close packets, which only terminates when one of the
+		 * nodes times out (min. 64 seconds). Quicker convergence can be
+		 * achieved when one of the nodes acts as tie-breaker.
+		 * This is ok as both ends are done with data transfer and each
+		 * end is just waiting for the other to acknowledge termination.
+		 */
+		if (dccp_sk(sk)->dccps_role != DCCP_ROLE_CLIENT)
+			break;
+		/* fall through */
+	case DCCP_REQUESTING:
+	case DCCP_ACTIVE_CLOSEREQ:
+		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
+		dccp_done(sk);
+		break;
+	case DCCP_OPEN:
+	case DCCP_PARTOPEN:
+		/* Give waiting application a chance to read pending data */
+		queued = 1;
+		dccp_fin(sk, skb);
+		dccp_set_state(sk, DCCP_PASSIVE_CLOSE);
+		/* fall through */
+	case DCCP_PASSIVE_CLOSE:
+		/*
+		 * Retransmitted Close: we have already enqueued the first one.
+		 */
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
+	}
+	return queued;
 }
 
-static void dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
+static int dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
 {
+	int queued = 0;
+
 	/*
 	 *   Step 7: Check for unexpected packet types
 	 *      If (S.is_server and P.type = CloseReq)
@@ -50,12 +90,26 @@ static void dccp_rcv_closereq(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (dccp_sk(sk)->dccps_role != DCCP_ROLE_CLIENT) {
 		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
-		return;
+		return queued;
 	}
 
-	if (sk->sk_state != DCCP_CLOSING)
+	/* Step 13: process relevant Client states < CLOSEREQ */
+	switch (sk->sk_state) {
+	case DCCP_REQUESTING:
+		dccp_send_close(sk, 0);
 		dccp_set_state(sk, DCCP_CLOSING);
-	dccp_send_close(sk, 0);
+		break;
+	case DCCP_OPEN:
+	case DCCP_PARTOPEN:
+		/* Give waiting application a chance to read pending data */
+		queued = 1;
+		dccp_fin(sk, skb);
+		dccp_set_state(sk, DCCP_PASSIVE_CLOSEREQ);
+		/* fall through */
+	case DCCP_PASSIVE_CLOSEREQ:
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
+	}
+	return queued;
 }
 
 static u8 dccp_reset_code_convert(const u8 code)
@@ -247,11 +301,13 @@ static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 		dccp_rcv_reset(sk, skb);
 		return 0;
 	case DCCP_PKT_CLOSEREQ:
-		dccp_rcv_closereq(sk, skb);
+		if (dccp_rcv_closereq(sk, skb))
+			return 0;
 		goto discard;
 	case DCCP_PKT_CLOSE:
-		dccp_rcv_close(sk, skb);
-		return 0;
+		if (dccp_rcv_close(sk, skb))
+			return 0;
+		goto discard;
 	case DCCP_PKT_REQUEST:
 		/* Step 7
 		 *   or (S.is_server and P.type = Response)
@@ -590,11 +646,13 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNC);
 		goto discard;
 	} else if (dh->dccph_type = DCCP_PKT_CLOSEREQ) {
-		dccp_rcv_closereq(sk, skb);
+		if (dccp_rcv_closereq(sk, skb))
+			return 0;
 		goto discard;
 	} else if (dh->dccph_type = DCCP_PKT_CLOSE) {
-		dccp_rcv_close(sk, skb);
-		return 0;
+		if (dccp_rcv_close(sk, skb))
+			return 0;
+		goto discard;
 	}
 
 	switch (sk->sk_state) {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 3489d3f..60f40ec 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -71,7 +71,8 @@ void dccp_set_state(struct sock *sk, const int state)
 		break;
 
 	case DCCP_CLOSED:
-		if (oldstate = DCCP_CLOSING || oldstate = DCCP_OPEN)
+		if (oldstate = DCCP_OPEN || oldstate = DCCP_ACTIVE_CLOSEREQ ||
+		    oldstate = DCCP_CLOSING)
 			DCCP_INC_STATS(DCCP_MIB_ESTABRESETS);
 
 		sk->sk_prot->unhash(sk);
@@ -92,6 +93,24 @@ void dccp_set_state(struct sock *sk, const int state)
 
 EXPORT_SYMBOL_GPL(dccp_set_state);
 
+static void dccp_finish_passive_close(struct sock *sk)
+{
+	switch (sk->sk_state) {
+	case DCCP_PASSIVE_CLOSE:
+		/* Node (client or server) has received Close packet. */
+		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
+		dccp_set_state(sk, DCCP_CLOSED);
+		break;
+	case DCCP_PASSIVE_CLOSEREQ:
+		/*
+		 * Client received CloseReq. We set the `active' flag so that
+		 * dccp_send_close() retransmits the Close as per RFC 4340, 8.3.
+		 */
+		dccp_send_close(sk, 1);
+		dccp_set_state(sk, DCCP_CLOSING);
+	}
+}
+
 void dccp_done(struct sock *sk)
 {
 	dccp_set_state(sk, DCCP_CLOSED);
@@ -762,19 +781,26 @@ int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
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
+				dccp_finish_passive_close(sk);
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
@@ -876,28 +902,30 @@ out:
 
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
+static void dccp_terminate_connection(struct sock *sk)
 {
-	const int next = dccp_new_state[sk->sk_state];
-	const int ns = next & DCCP_STATE_MASK;
+	u8 next_state = DCCP_CLOSED;
 
-	if (ns != sk->sk_state)
-		dccp_set_state(sk, ns);
+	switch (sk->sk_state) {
+	case DCCP_PASSIVE_CLOSE:
+	case DCCP_PASSIVE_CLOSEREQ:
+		dccp_finish_passive_close(sk);
+		break;
+	case DCCP_PARTOPEN:
+		dccp_pr_debug("Stop PARTOPEN timer (%p)\n", sk);
+		inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
+		/* fall through */
+	case DCCP_OPEN:
+		dccp_send_close(sk, 1);
 
-	return next & DCCP_ACTION_FIN;
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+			next_state = DCCP_ACTIVE_CLOSEREQ;
+		else
+			next_state = DCCP_CLOSING;
+		/* fall through */
+	default:
+		dccp_set_state(sk, next_state);
+	}
 }
 
 void dccp_close(struct sock *sk, long timeout)
@@ -940,8 +968,8 @@ void dccp_close(struct sock *sk, long timeout)
 	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
-	} else if (dccp_close_state(sk)) {
-		dccp_send_close(sk, 1);
+	} else if (sk->sk_state != DCCP_CLOSED) {
+		dccp_terminate_connection(sk);
 	}
 
 	sk_stream_wait_close(sk, timeout);
-- 
1.5.3.4

