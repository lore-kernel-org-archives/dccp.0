From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:14 +0000
Subject: [PATCH 1/6] dccp: Clean up slow-path input processing
Message-Id: <1309806079-21604-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch rearranges the order of statements of the slow-path input processing
(i.e. any other state than OPEN), to resolve the following issues.

 1. Dependencies: the order of statements now better matches RFC 4340, 8.5, i.e.
    step 7 is before step 9 (previously 9 was before 7), and parsing options in
    step 8 (which may consume resources) now comes after step 7.
 2. Sequence number checks are omitted if in state LISTEN/REQUEST, due to the
    note underneath the table in RFC 4340, 7.5.3.
    As a result, CCID processing is now indeed confined to OPEN/PARTOPEN states,
    i.e. congestion control is performed only on the flow of data packets. This
    avoids pathological cases of doing congestion control on those messages
    which set up and terminate the connection.
 3. Packets are now passed on to Ack Vector / CCID processing only after
    - step 7  (receive unexpected packets),
    - step 9  (receive Reset),
    - step 13 (receive CloseReq),
    - step 14 (receive Close)
    and only if the state is PARTOPEN. This simplifies CCID processing:
    - in LISTEN/CLOSED the CCIDs are non-existent;
    - in RESPOND/REQUEST the CCIDs have not yet been negotiated;
    - in CLOSEREQ and active-CLOSING the node has already closed this socket;
    - in passive-CLOSING the client is waiting for its Reset.
    In the last case, RFC 4340, 8.3 leaves it open to ignore further incoming
    data, which is the approach taken here.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   61 ++++++++++++++++++++++++++---------------------------
 1 files changed, 30 insertions(+), 31 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -619,20 +619,31 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		return 1;
 	}
 
-	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
-		if (dccp_check_seqno(sk, skb))
-			goto discard;
-
-		/*
-		 * Step 8: Process options and mark acknowledgeable
-		 */
-		if (dccp_parse_options(sk, NULL, skb))
-			return 1;
+	/* Step 6: Check sequence numbers (omitted in LISTEN/REQUEST state) */
+	if (sk->sk_state != DCCP_REQUESTING && dccp_check_seqno(sk, skb))
+		goto discard;
 
-		dccp_handle_ackvec_processing(sk, skb);
-		dccp_deliver_input_to_ccids(sk, skb);
+	/*
+	 *   Step 7: Check for unexpected packet types
+	 *      If (S.is_server and P.type = Response)
+	 *	    or (S.is_client and P.type = Request)
+	 *	    or (S.state = RESPOND and P.type = Data),
+	 *	  Send Sync packet acknowledging P.seqno
+	 *	  Drop packet and return
+	 */
+	if ((dp->dccps_role != DCCP_ROLE_CLIENT &&
+	     dh->dccph_type = DCCP_PKT_RESPONSE) ||
+	    (dp->dccps_role = DCCP_ROLE_CLIENT &&
+	     dh->dccph_type = DCCP_PKT_REQUEST) ||
+	    (sk->sk_state = DCCP_RESPOND && dh->dccph_type = DCCP_PKT_DATA)) {
+		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNC);
+		goto discard;
 	}
 
+	/*  Step 8: Process options */
+	if (dccp_parse_options(sk, NULL, skb))
+		return 1;
+
 	/*
 	 *  Step 9: Process Reset
 	 *	If P.type = Reset,
@@ -640,31 +651,15 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	 *		S.state := TIMEWAIT
 	 *		Set TIMEWAIT timer
 	 *		Drop packet and return
-	*/
+	 */
 	if (dh->dccph_type = DCCP_PKT_RESET) {
 		dccp_rcv_reset(sk, skb);
 		return 0;
-		/*
-		 *   Step 7: Check for unexpected packet types
-		 *      If (S.is_server and P.type = Response)
-		 *	    or (S.is_client and P.type = Request)
-		 *	    or (S.state = RESPOND and P.type = Data),
-		 *	  Send Sync packet acknowledging P.seqno
-		 *	  Drop packet and return
-		 */
-	} else if ((dp->dccps_role != DCCP_ROLE_CLIENT &&
-		    dh->dccph_type = DCCP_PKT_RESPONSE) ||
-		    (dp->dccps_role = DCCP_ROLE_CLIENT &&
-		     dh->dccph_type = DCCP_PKT_REQUEST) ||
-		    (sk->sk_state = DCCP_RESPOND &&
-		     dh->dccph_type = DCCP_PKT_DATA)) {
-		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNC);
-		goto discard;
-	} else if (dh->dccph_type = DCCP_PKT_CLOSEREQ) {
+	} else if (dh->dccph_type = DCCP_PKT_CLOSEREQ) {	/* Step 13 */
 		if (dccp_rcv_closereq(sk, skb))
 			return 0;
 		goto discard;
-	} else if (dh->dccph_type = DCCP_PKT_CLOSE) {
+	} else if (dh->dccph_type = DCCP_PKT_CLOSE) {		/* Step 14 */
 		if (dccp_rcv_close(sk, skb))
 			return 0;
 		goto discard;
@@ -679,8 +674,12 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		__kfree_skb(skb);
 		return 0;
 
-	case DCCP_RESPOND:
 	case DCCP_PARTOPEN:
+		/* Step 8: if using Ack Vectors, mark packet acknowledgeable */
+		dccp_handle_ackvec_processing(sk, skb);
+		dccp_deliver_input_to_ccids(sk, skb);
+		/* fall through */
+	case DCCP_RESPOND:
 		queued = dccp_rcv_respond_partopen_state_process(sk, skb,
 								 dh, len);
 		break;
