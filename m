From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:36 +0000
Subject: [PATCH 4/14]: Integration of dynamic feature activation - part 3 (client side)
Message-Id: <200710031502.36443@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Integration of dynamic feature activation - part 3 (client side)

This integrates feature-activation in the client, the following details needed to be addressed:

1. When dccp_parse_options() fails, the reset code is already set, request_sent_state_process() 
   currently overrides this with `Packet Error', which is not intended - so changed to use the 
   reset code set in dccp_parse_options();

2. There was a FIXME to change the error code when dccp_ackvec_add() fails. I have looked this
   up and found that: 
   * the check whether ackno < ISN is already made earlier,
   * this Response is likely the first packet with an Ack number that the client gets,
   * so when dccp_ackvec_add() fails, the reason is likely not due to a packet error.

   There is another problem: when a connecting client sends a Reset in state REQUEST, the loop
   in dccp_sendmsg(), which waits in sk_stream_wait_connect() for the transition to PARTOPEN,
   does not (and will not) happen. The same problem also occurs if the feature negotiation 
   during connection setup fails. Thus I have lumped this case together with the following:

3. When feature negotiation fails, the socket should be marked as not usable, so that the
   application is notified that an error occurs. This is achieved by a new label, which uses
   an error code of `Aborted' and which sets the socket state to CLOSED, as well as sk_err.

Since this addresses congestion-control initialisation, a corresponding FIXME has been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -382,8 +382,13 @@ static int dccp_rcv_request_sent_state_p
 			goto out_invalid_packet;
 		}
 
+		/*
+		 * If option processing (Step 8) failed, return 1 here so that
+		 * dccp_v4_do_rcv() sends a Reset. The Reset code depends on
+		 * the option type and is set in dccp_parse_options().
+		 */
 		if (dccp_parse_options(sk, NULL, skb))
-			goto out_invalid_packet;
+			return 1;
 
 		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
 		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
@@ -394,7 +399,7 @@ static int dccp_rcv_request_sent_state_p
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 				    DCCP_SKB_CB(skb)->dccpd_seq,
 				    DCCP_ACKVEC_STATE_RECEIVED))
-			goto out_invalid_packet; /* FIXME: change error code */
+			goto unable_to_proceed;
 
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
@@ -456,6 +461,13 @@ static int dccp_rcv_request_sent_state_p
 			__kfree_skb(skb);
 			return 0;
 		}
+		/*
+		 * If feature negotiation throws an error, we can not proceed
+		 * (one or more feature values are undefined), so we send a
+		 * Reset. Otherwise, the Ack will clear any pending Confirms.
+		 */
+		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
+			goto unable_to_proceed;
 		dccp_send_ack(sk);
 		return -1;
 	}
@@ -464,6 +476,16 @@ out_invalid_packet:
 	/* dccp_v4_do_rcv will send a reset */
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_PACKET_ERROR;
 	return 1;
+
+unable_to_proceed:
+	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_ABORTED;
+	/*
+	 * We mark this socket as no longer usable, so that the loop in
+	 * dccp_sendmsg() terminates and the application gets notified.
+	 */
+	dccp_set_state(sk, DCCP_CLOSED);
+	sk->sk_err = ECOMM;
+	return 1;
 }
 
 static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
@@ -621,8 +643,6 @@ int dccp_rcv_state_process(struct sock *
 		return 1;
 
 	case DCCP_REQUESTING:
-		/* FIXME: do congestion control initialization */
-
 		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
 		if (queued >= 0)
 			return queued;
