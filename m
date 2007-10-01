From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:26 +0000
Subject: [PATCH 7/11]: Integrate feature-negotiation insertion code
Message-Id: <200710011518.26652@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Integrate feature-negotiation insertion code

The patch implements insertion of feature negotiation at the server (listening and
request socket) and the client (connecting socket).

In dccp_insert_options(), several statements have been grouped together now to achieve
(I hope) better efficiency by reducing the number of tests each packet has to go through:
 - Ack Vectors are, as before, sent if the packet is neither a Data or a Request packet;
 - a previous issue is corrected - feature negotiation options are allowed on DataAck
   packets (5.8).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -528,11 +528,23 @@ int dccp_insert_options(struct sock *sk,
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
+		} else if (dmsk->dccpms_send_ack_vector &&
+			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
+			   dccp_insert_option_ackvec(sk, skb))
+				return -1;
 	}
 
 	if (dp->dccps_hc_rx_insert_options) {
@@ -541,21 +553,6 @@ int dccp_insert_options(struct sock *sk,
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 
-	/* Feature negotiation */
-	/* Data packets can't do feat negotiation */
-	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA &&
-	    DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATAACK &&
-	    dccp_insert_options_feat(sk, skb))
-		return -1;
-
-	/*
-	 * Obtain RTT sample from Request/Response exchange.
-	 * This is currently used in CCID 3 initialisation.
-	 */
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST &&
-	    dccp_insert_option_timestamp(sk, skb))
-		return -1;
-
 	if (dp->dccps_tstamp != NULL &&
 	    dccp_insert_option_timestamp_echo(&dp->dccps_tstamp, skb))
 		return -1;
@@ -572,6 +569,9 @@ int dccp_insert_options_rsk(struct dccp_
 {
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
+	if (dccp_feat_insert_opts(NULL, dreq, skb))
+		return -1;
+
 	if (dreq->dreq_tstamp != NULL &&
 	    dccp_insert_option_timestamp_echo(&dreq->dreq_tstamp, skb))
 		return -1;
