From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Aug 2007 13:59:03 +0000
Subject: [PATCH 1/3]: Honour and make use of shutdown option set by user
Message-Id: <200708091459.03139@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Honour and make use of shutdown option set by user

This extends the DCCP socket API by honouring any shutdown(2) option set by the user.
The behaviour is, as much as possible, made consistent with the API for TCP's shutdown.

This patch exploits the information provided by the user via the socket API to reduce
processing costs:
 * if the read end is closed (SHUT_RD), it is not necessary to deliver to input CCID;
 * if the write end is closed (SHUT_WR), the same idea applies, but with a difference -
   as long as the TX queue has not been drained, we need to receive feedback to keep
   congestion-control rates up to date. Hence SHUT_WR is honoured only after the last
   packet (under congestion control) has been sent;
 * although SHUT_RDWR seems nonsensical, it is nevertheless supported in the same manner
   as for TCP (and agrees with test for SHUTDOWN_MASK in dccp_poll() in net/dccp/proto.c).

Furthermore, most of the code already honours the sk_shutdown flags (dccp_recvmsg() for 
instance sets the read length to 0 if SHUT_RD had been called); CCID handling is now added
to this by the present patch.

There will also no longer be any delivery when the socket is in the final stages, i.e. when
one of dccp_close(), dccp_fin(), or dccp_done() has been called - which is fine since at
that stage the connection is its final stages.

Motivation and background are on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/shutdown

A FIXME has been added to notify the other end if SHUT_RD has been set (RFC 4340, 11.7).


Note: There is a comment in inet_shutdown() in net/ipv4/af_inet.c which asks to "make
      sure the socket is a TCP socket". This should probably be extended to mean 
      `TCP or DCCP socket' (the code is also used by UDP and raw sockets).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 Documentation/networking/dccp.txt |    2 ++
 net/dccp/input.c                  |   27 ++++++++++++++++++++-------
 net/dccp/proto.c                  |    2 +-
 3 files changed, 23 insertions(+), 8 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -91,6 +91,21 @@ static void dccp_event_ack_recv(struct s
 					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
 
+static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+
+	/* Don't deliver to RX CCID when node has shut down read end. */
+	if (! (sk->sk_shutdown & RCV_SHUTDOWN))
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+	/*
+	 * Until the TX queue has been drained, we can not honour SHUT_WR, since
+	 * we need received feedback as input to adjust congestion control.
+	 */
+	if (sk->sk_write_queue.qlen > 0 || !(sk->sk_shutdown & SEND_SHUTDOWN))
+		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+}
+
 static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
@@ -195,8 +210,9 @@ static int __dccp_rcv_established(struct
 	case DCCP_PKT_DATAACK:
 	case DCCP_PKT_DATA:
 		/*
-		 * FIXME: check if sk_receive_queue is full, schedule DATA_DROPPED
-		 * option if it is.
+		 * FIXME: schedule DATA_DROPPED (RFC 4340, 11.7.2) if and when
+		 * - sk_shutdown = RCV_SHUTDOWN, use Code 1, "Not Listening"
+		 * - sk_receive_queue is full, use Code 2, "Receive Buffer"
 		 */
 		dccp_enqueue_skb(sk, skb);
 		return 0;
@@ -284,9 +300,7 @@ int dccp_rcv_established(struct sock *sk
 			    DCCP_SKB_CB(skb)->dccpd_seq,
 			    DCCP_ACKVEC_STATE_RECEIVED))
 		goto discard;
-
-	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	dccp_deliver_input_to_ccids(sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -532,8 +546,7 @@ int dccp_rcv_state_process(struct sock *
 				    DCCP_ACKVEC_STATE_RECEIVED))
 			goto discard;
 
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		dccp_deliver_input_to_ccids(sk, skb);
 	}
 
 	/*
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1006,7 +1006,7 @@ EXPORT_SYMBOL_GPL(dccp_close);
 
 void dccp_shutdown(struct sock *sk, int how)
 {
-	dccp_pr_debug("entry\n");
+	dccp_pr_debug("called shutdown(%x)\n", how);
 }
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -78,6 +78,8 @@ DCCP_SOCKOPT_CCID_TX_INFO
 	Returns a `struct tfrc_tx_info' in optval; the buffer for optval and
 	optlen must be set to at least sizeof(struct tfrc_tx_info).
 
+On unidirectional connections it is useful to close the unused half-connection
+via shutdown (SHUT_WR or SHUT_RD): this will reduce per-packet processing costs.
 
 Sysctl variables
 ========
