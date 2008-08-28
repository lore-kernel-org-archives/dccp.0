From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:03 +0000
Subject: [PATCH 28/37] dccp: Integration of dynamic feature activation - part 3 (client side)
Message-Id: <1219945512-7723-29-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This integrates feature-activation in the client, with these details:

 1. When dccp_parse_options() fails, the reset code is already set, request_sent
    _state_process() currently overrides this with `Packet Error', which is not
    intended - so changed to use the reset code set in dccp_parse_options();

 2. There was a FIXME to change the error code when dccp_ackvec_add() fails.
    I have looked this up and found that:
    * the check whether ackno < ISN is already made earlier,
    * this Response is likely the 1st packet with an Ackno that the client gets,
    * so when dccp_ackvec_add() fails, the reason is likely not a packet error.

 3. When feature negotiation fails, the socket should be marked as not usable,
    so that the application is notified that an error occurs. This is achieved
    by a new label, which uses an error code of `Aborted' and which sets the
    socket state to CLOSED, as well as sk_err.

 4. Avoids parsing the Ack twice in Respond state by not doing option processing
    again in dccp_rcv_respond_partopen_state_process (as option processing has
    already been done on the request_sock in dccp_check_req).

Since this addresses congestion-control initialisation, a corresponding
FIXME has been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/input.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -421,8 +421,13 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
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
@@ -475,6 +480,15 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		 */
 		dccp_set_state(sk, DCCP_PARTOPEN);
 
+		/*
+		 * If feature negotiation was successful, activate features now;
+		 * an activation failure means that this host could not activate
+		 * one ore more features (e.g. insufficient memory), which would
+		 * leave at least one feature in an undefined state.
+		 */
+		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
+			goto unable_to_proceed;
+
 		/* Make sure socket is routed, for correct metrics. */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
@@ -509,6 +523,16 @@ out_invalid_packet:
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
@@ -600,7 +624,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (sk->sk_state != DCCP_REQUESTING) {
+	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
 		if (dccp_check_seqno(sk, skb))
 			goto discard;
 
@@ -665,8 +689,6 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		return 1;
 
 	case DCCP_REQUESTING:
-		/* FIXME: do congestion control initialization */
-
 		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
 		if (queued >= 0)
 			return queued;
-- 
1.6.0.rc2

