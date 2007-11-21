From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:28 +0000
Subject: [PATCH 06/11] [DCCP]: Honour and make use of shutdown option set by user
Message-Id: <1195658913-24840-7-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

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
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |    2 ++
 net/dccp/input.c                  |   27 ++++++++++++++++++++-------
 net/dccp/proto.c                  |    2 +-
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index afb66f9..f771034 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -72,6 +72,8 @@ DCCP_SOCKOPT_CCID_TX_INFO
 	Returns a `struct tfrc_tx_info' in optval; the buffer for optval and
 	optlen must be set to at least sizeof(struct tfrc_tx_info).
 
+On unidirectional connections it is useful to close the unused half-connection
+via shutdown (SHUT_WR or SHUT_RD): this will reduce per-packet processing costs.
 
 Sysctl variables
 ========
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 1ce1010..df0fb2c 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -103,6 +103,21 @@ static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
 
+static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+
+	/* Don't deliver to RX CCID when node has shut down read end. */
+	if (!(sk->sk_shutdown & RCV_SHUTDOWN))
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
@@ -209,8 +224,9 @@ static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	case DCCP_PKT_DATAACK:
 	case DCCP_PKT_DATA:
 		/*
-		 * FIXME: check if sk_receive_queue is full, schedule DATA_DROPPED
-		 * option if it is.
+		 * FIXME: schedule DATA_DROPPED (RFC 4340, 11.7.2) if and when
+		 * - sk_shutdown = RCV_SHUTDOWN, use Code 1, "Not Listening"
+		 * - sk_receive_queue is full, use Code 2, "Receive Buffer"
 		 */
 		__skb_pull(skb, dh->dccph_doff * 4);
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
@@ -300,9 +316,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			    DCCP_SKB_CB(skb)->dccpd_seq,
 			    DCCP_ACKVEC_STATE_RECEIVED))
 		goto discard;
-
-	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	dccp_deliver_input_to_ccids(sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -543,8 +557,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				    DCCP_ACKVEC_STATE_RECEIVED))
 			goto discard;
 
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		dccp_deliver_input_to_ccids(sk, skb);
 	}
 
 	/*
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7a3bea9..0aec735 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -981,7 +981,7 @@ EXPORT_SYMBOL_GPL(dccp_close);
 
 void dccp_shutdown(struct sock *sk, int how)
 {
-	dccp_pr_debug("entry\n");
+	dccp_pr_debug("called shutdown(%x)\n", how);
 }
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
-- 
1.5.3.4

