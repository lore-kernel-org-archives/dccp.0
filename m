From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 30 Nov 2008 13:22:52 +0000
Subject: [PATCH 2/6] dccp: Integrate feature-negotiation insertion code
Message-Id: <1228051376-8174-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The patch implements insertion of feature negotiation at the server (listening
and request socket) and the client (connecting socket).

In dccp_insert_options(), several statements have been grouped together now
to achieve (it is hoped) better efficiency by reducing the number of tests
each packet has to go through:
 - Ack Vectors are sent if the packet is neither a Data or a Request packet;
 - a previous issue is corrected - feature negotiation options are allowed
   on DataAck packets (5.8).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/options.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -554,11 +554,25 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 	    dccp_insert_option_ndp(sk, skb))
 		return -1;
 
-	if (!dccp_packet_without_ack(skb)) {
-		if (dmsk->dccpms_send_ack_vector &&
-		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
-		    dccp_insert_option_ackvec(sk, skb))
+	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA) {
+
+		/* Feature Negotiation */
+		if (dccp_feat_insert_opts(dp, NULL, skb))
 			return -1;
+
+		if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST) {
+			/*
+			 * Obtain RTT sample from Request/Response exchange.
+			 * This is currently used in CCID 3 initialisation.
+			 */
+			if (dccp_insert_option_timestamp(sk, skb))
+				return -1;
+
+		} else if (dmsk->dccpms_send_ack_vector	&&
+			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
+			   dccp_insert_option_ackvec(sk, skb)) {
+				return -1;
+		}
 	}
 
 	if (dp->dccps_hc_rx_insert_options) {
@@ -567,14 +581,6 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 
-	/*
-	 * Obtain RTT sample from Request/Response exchange.
-	 * This is currently used in CCID 3 initialisation.
-	 */
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST &&
-	    dccp_insert_option_timestamp(sk, skb))
-		return -1;
-
 	if (dp->dccps_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(dp, NULL, skb))
 		return -1;
@@ -587,6 +593,9 @@ int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
 {
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
+	if (dccp_feat_insert_opts(NULL, dreq, skb))
+		return -1;
+
 	if (dreq->dreq_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(NULL, dreq, skb))
 		return -1;
