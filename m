From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:41:11 +0000
Subject: [PATCH 6/7]: Sample RTT from SYN exchange
Message-Id: <200701231541.11648@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Sample RTT from SYN exchange

Function:
---------
 This patch acquires the RTT of the initial SYN (Request/Response) exchange
 and stores it in an unused field of dccp_sock. 

Purpose:
--------
 The purpose is primarily to provide an initial RTT sample for CCIDs. CCID 3
 in particular benefits from such a sample; using the RTT of the SYN exchange
 is recommended in an erratum to RFC 4342, and in draft-ietf-dccp-rfc3448bis.

Implementation note: 
--------------------
 Double use is made of the `icsk_ack.lrcvtime' field by #defining an alias for it.
 This is justified (1) by exploiting that Acks are only meaningful when the client
 has reached the OPEN state and the alias is used before reaching this state and
 (2) since there is currently no other use for this field in the entire DCCP code.
 (NB: Since the RTT sample is currently used only by CCID 3, it could be wrapped in
  Kconfig #ifdef options, but this clutters code and so has not been done.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 include/linux/dccp.h |    2 ++
 net/dccp/input.c     |    8 ++++++++
 net/dccp/options.c   |    8 ++++++++
 3 files changed, 18 insertions(+)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -476,10 +476,12 @@ struct dccp_ackvec;
  * @dccps_hc_rx_insert_options -
  * @dccps_hc_tx_insert_options -
  * @dccps_xmit_timer - timer for when CCID is not ready to send
+ * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
 struct dccp_sock {
 	/* inet_connection_sock has to be the first member of dccp_sock */
 	struct inet_connection_sock	dccps_inet_connection;
+#define dccps_syn_rtt			dccps_inet_connection.icsk_ack.lrcvtime
 	__u64				dccps_swl;
 	__u64				dccps_swh;
 	__u64				dccps_awl;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -565,6 +565,14 @@ int dccp_insert_options(struct sock *sk,
 	    dccp_insert_options_feat(sk, skb))
 		return -1;
 
+	/*
+	 * Obtain RTT sample from Request/Response exchange.
+	 * This is currently used in CCID 3 initialisation.
+	 */
+	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST &&
+	    dccp_insert_option_timestamp(sk, skb))
+		return -1;
+
 	/* XXX: insert other options when appropriate */
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -353,6 +353,14 @@ static int dccp_rcv_request_sent_state_p
 		/* Make sure socket is routed, for correct metrics. */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
+		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
+		if (dp->dccps_options_received.dccpor_timestamp_echo) {
+			struct timeval now;
+
+			do_gettimeofday(&now);
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
+		}
+
 		if (!sock_flag(sk, SOCK_DEAD)) {
 			sk->sk_state_change(sk);
 			sk_wake_async(sk, 0, POLL_OUT);
