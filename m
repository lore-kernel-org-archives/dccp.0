From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 21 Jan 2008 08:57:58 +0000
Subject: [Announce]: Test tree updates
Message-Id: <20080121085758.GE4606@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is to announce that the test tree 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		{dccp,ccid4}

has been updated with regards to two fixes: the first corrects an error, the other removes
a redundant piece of code - the changes are in this order with the summary line at the top.

==============================================[DCCP]: Integration of dynamic feature activation - part 3 (client side)

=> CHANGE: 1) moved the feature activation upwards, since if there is a pending
               write, the skb is deleted and the function returns before the features
	       are activated (stupid error).
	    2) restored Ack Vector jump label (see subsequent change at bottom of message).

--- b/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -444,7 +444,7 @@
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 				    DCCP_SKB_CB(skb)->dccpd_seq,
 				    DCCP_ACKVEC_STATE_RECEIVED))
-			goto unable_to_proceed;
+			goto out_invalid_packet; /* FIXME: change error code */
 
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
@@ -480,6 +480,15 @@
 		 */
 		dccp_set_state(sk, DCCP_PARTOPEN);
 
+		/*
+		 * If feature negotiation was successful, activate features now;
+		 * an activation failure means that this host could not activate
+		 * one ore more features (e.g. insufficient memory) which leaves
+		 * at least one feature in an undefined state.
+		 */
+		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
+			goto unable_to_proceed;
+
 		/* Make sure socket is routed, for correct metrics. */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
@@ -506,13 +515,6 @@
 			__kfree_skb(skb);
 			return 0;
 		}
-		/*
-		 * If feature negotiation throws an error, we can not proceed
-		 * (one or more feature values are undefined), so we send a
-		 * Reset. Otherwise, the Ack will clear any pending Confirms.
-		 */
-		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
-			goto unable_to_proceed;
 		dccp_send_ack(sk);
 		return -1;
 	}
==============================================[ACKVEC]: Phase out the use of boolean flag for Ack Vectors

=> CHANGE: Removed adding the received Response to the Ack vector. The reason is that
            1) it is not necessary to record the Response as received (if it weren't 
	       received, the connection would have failed altogether);
	    2) the CCIDs only look at data packets received in the (PART)OPEN state, so the
	       Response would always be ignored; recording it would not help to detect holes
	       (since only the packets received after a hole can act as pseudo-dupacks).

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -440,12 +440,6 @@ static int dccp_rcv_request_sent_state_p
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
 			    dp->dccps_options_received.dccpor_timestamp_echo));
 
-		if (dccp_msk(sk)->dccpms_send_ack_vector &&
-		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
-			goto out_invalid_packet; /* FIXME: change error code */
-
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
 		/*
-- 
