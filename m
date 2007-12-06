From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 06 Dec 2007 07:59:15 +0000
Subject: CCID4 subtree updated
Message-Id: <20071206075915.GA6804@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have now updated the CCID4 subtree with regard to the latest changes in the
CCID3 module:
 * rx_update_s() becomes obsolete
 * instead, the `s' value is set to payload_size (first packet) or
 * set to tfrc_ewma() (all further data packets).

Furthermore (and this has been updated for CCID3 also) Arnaldo has introduced
a better handling of the conditional compilation in the dccp_tfrc_lib; this has
also been added. The interdiff is below.

I did some testing with these Kconfig options and the build process seems to work
exactly as expected: ie. if either CCID3=y or CCID4=y then TFRC_LIB=y; if either
CCID3_DEBUG=y or CCID4_DEBUG=y then TFRC_DEBUG=y.

Also as promised some sanity testing; results are in follow-up email.

-----------------> Inter-diff to previous version <-----------------------------

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -109,8 +109,8 @@ config IP_DCCP_CCID3_RTO
 
 config IP_DCCP_CCID4
 	tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"
-	depends on IP_DCCP
 	def_tristate IP_DCCP
+	select IP_DCCP_TFRC_LIB
 	---help---
 	  CCID-4 denotes Congestion Control Identifier 4, the Small-Packet
 	  variant of TCP-Friendly Rate Control (TFRC), in the Datagram
@@ -115,5 +189,5 @@ config IP_DCCP_TFRC_LIB
 config IP_DCCP_TFRC_DEBUG
 	bool
 	depends on IP_DCCP_TFRC_LIB
-	default y if IP_DCCP_CCID3_DEBUG
+	default y if (IP_DCCP_CCID3_DEBUG || IP_DCCP_CCID4_DEBUG)
--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -593,12 +593,6 @@ static void ccid4_hc_rx_set_state(struct sock *sk,
 	hcrx->tfrchcrx_state = state;
 }
 
-static inline void ccid4_hc_rx_update_s(struct tfrc_hc_rx_sock *hcrx, int len)
-{
-	if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
-		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, len, 9);
-}
-
 static void ccid4_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
 {
@@ -725,8 +719,8 @@ static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
+			hcrx->tfrchcrx_s = payload_size;
 			ccid4_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			ccid4_hc_rx_update_s(hcrx, payload_size);
 		}
 		goto update_records;
 	}
@@ -735,7 +729,10 @@ static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		goto done_receiving;
 
 	if (is_data_packet) {
-		ccid4_hc_rx_update_s(hcrx, payload_size);
+		/*
+		 * Update moving-average of s and the sum of received payload bytes
+		 */
+		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, payload_size, 9);
 		hcrx->tfrchcrx_bytes_recv += payload_size;
 	}
 


-- 
