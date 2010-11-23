From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Nov 2010 12:44:14 +0000
Subject: dccp-test-tree [RFC][Patch 1/1] dccp: requesting comments re	updating ARP/neighbour table state
Message-Id: <20101123124414.GC3915@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I noted that DCCP apparently does not update the neighbour tables in the same
way as TCP (or UDP with MSG_CONFIRM). 

This patch adds the missing calls to dst_update(). I would appreciate review
and comments in case I missed something.

DCCP does not have the equivalent of tcp_init_metrics()/tcp_update_metrics().
It seems that this functionality would be more in the CCIDs than in the main
DCCP module (for instance, CCID-3 does not understand ssthresh/cwnd and uses
a different RTT sampling algorithm).

This patch is meant for RFC, not currently for submission. It is in the DCCP
test tree, on 
     
     git://eden-feed.erg.abdn.ac.uk/dccp_exp    [subtree 'dccp']


>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: indicate forward progress of connection to lower layer

This patch implements three cases of indicating forward progress:

 1. Peer acknowledging receipt of connection initiation.
    This corresponds to the cases where tcp_init_metrics() is called:
    * receiving Syn-Ack in response to Syn (tcp_rcv_synsent_state_process),
    * receiving Ack to finish the handshake (TCP_SYN_RECV -> TCP_ESTABLISHED);
    which in DCCP corresponds to
    * receiving Response after Request (dccp_rcv_request_sent_state_process),
    * moving from RESPOND/PARTOPEN to OPEN when receiving an Ack/DataAck
      (RESPOND) or non-Sync/Reset (PARTOPEN).
    The latter does no extra rebuild_header() as in tcp_rcv_state_process(),
    since in DCCP an active (client) socket can not become a passive one later,
    and since dccp_v{4,6}_request_recv_sock() already talk to the routing
    system.

 2. Peer advancing GAR (greatest acknowledgment number received).
    This is comparable to making forward progress in tcp_ack().

 3. Peer acknowledging request to terminate the connection.
    This corresponds to TCP teardown -
    * receiving Ack-of-Fin in FIN_WAIT1/LAST_ACK (tcp_rcv_state_process),
    * entering TIME_WAIT (tcp_time_wait),
    and is realized in DCCP when receiving
    * a Reset packet with code "Closed" (in response to DCCP-Close),
    * a Close packet after sending a CloseReq,
    * a Close packet after sending a Close (simultaneous close).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -71,6 +71,7 @@ static int dccp_rcv_close(struct sock *s
 		/* fall through */
 	case DCCP_REQUESTING:
 	case DCCP_ACTIVE_CLOSEREQ:
+		dst_confirm(__sk_dst_get(sk));
 		dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
 		dccp_done(sk);
 		break;
@@ -155,6 +156,8 @@ static void dccp_rcv_reset(struct sock *
 	/* Queue the equivalent of TCP fin so that dccp_recvmsg exits the loop */
 	dccp_fin(sk, skb);
 
+	if (dccp_hdr_reset(skb)->dccph_reset_code = DCCP_RESET_CODE_CLOSED)
+		dst_confirm(__sk_dst_get(sk));
 	if (err && !sock_flag(sk, SOCK_DEAD))
 		sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
 	dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
@@ -242,8 +245,10 @@ static int dccp_check_seqno(struct sock 
 
 		if (dh->dccph_type != DCCP_PKT_SYNC &&
 		    ackno != DCCP_PKT_WITHOUT_ACK_SEQ &&
-		    after48(ackno, dp->dccps_gar))
+		    after48(ackno, dp->dccps_gar)) {
+			dst_confirm(__sk_dst_get(sk));
 			dp->dccps_gar = ackno;
+		}
 	} else {
 		unsigned long now = jiffies;
 		/*
@@ -475,6 +480,8 @@ static int dccp_rcv_request_sent_state_p
 		/* Make sure socket is routed, for correct metrics. */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
+		dst_confirm(__sk_dst_get(sk));
+
 		if (!sock_flag(sk, SOCK_DEAD)) {
 			sk->sk_state_change(sk);
 			sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
@@ -556,6 +563,8 @@ static int dccp_rcv_respond_partopen_sta
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * delta);
 		}
 
+		dst_confirm(__sk_dst_get(sk));
+
 		dp->dccps_osr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_set_state(sk, DCCP_OPEN);
 
