From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jan 2008 10:16:13 +0000
Subject: [PATCH 3/6] [DCCP]: Bug-Fix - AWL was never updated
Message-Id: <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch was triggered by finding the  following message in the syslog:
 "kernel: dccp_check_seqno: DCCP: Step 6 failed for DATAACK packet, [...]
   P.ackno exists or LAWL(82947089) <= P.ackno(82948208)
	                            <= S.AWH(82948728), sending SYNC..."

Note the difference between AWH and AWL: it is 1639 packets (while Sequence
Window was actually at 100). A closer look at the trace showed that
LAWL = AWL = 82947089 equalled the ISS on the Response.

The cause of the bug was that AWL was only ever set on the first packet - the
DCCP-Request sent by dccp_v{4,6}_connect().

The fix is to continually update AWL/AWH with each new packet (as GSS=AWH).

In addition, AWL/AWH are now updated to enforce more stringent checks on the
initial sequence numbers when connecting:
 * AWL is initialised to ISS and remains at this value;
 * AWH is always set to GSS (via dccp_update_gss());
 * so on the first Request: AWL =      AWH = ISS,
   and on the n-th Request: AWL = ISS, AWH = ISS+n.

As a consequence, only Response packets that refer to Requests sent by this
host will pass, all others are discarded. This is the intention and in effect
implements the initial adjustments for AWL as specified in RFC 4340, 7.5.1.

Note: A problem that remains is that ISS can potentially be under-run even after
      the initial handshake; this is addressed a subsequent patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   34 +++++++++++++++-------------------
 1 files changed, 15 insertions(+), 19 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -53,8 +53,11 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 					  dccp_packet_hdr_len(dcb->dccpd_type);
 		int err, set_ack = 1;
 		u64 ackno = dp->dccps_gsr;
-
-		dccp_inc_seqno(&dp->dccps_gss);
+		/*
+		 * Increment GSS here already in case the option code needs it.
+		 * Update GSS for real only if option processing below succeeds.
+		 */
+		dcb->dccpd_seq = ADD48(dp->dccps_gss, 1);
 
 		switch (dcb->dccpd_type) {
 		case DCCP_PKT_DATA:
@@ -66,6 +69,9 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		case DCCP_PKT_REQUEST:
 			set_ack = 0;
+			/* Use ISS on the first (non-retransmitted) Request. */
+			if (icsk->icsk_retransmits = 0)
+				dcb->dccpd_seq = dp->dccps_iss;
 			/* fall through */
 
 		case DCCP_PKT_SYNC:
@@ -84,14 +90,11 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
-		dcb->dccpd_seq = dp->dccps_gss;
-
 		if (dccp_insert_options(sk, skb)) {
 			kfree_skb(skb);
 			return -EPROTO;
 		}
 
-
 		/* Build DCCP header and checksum it. */
 		dh = dccp_zeroed_hdr(skb, dccp_header_size);
 		dh->dccph_type	= dcb->dccpd_type;
@@ -103,7 +106,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 		/* XXX For now we're using only 48 bits sequence numbers */
 		dh->dccph_x	= 1;
 
-		dp->dccps_awh = dp->dccps_gss;
+		dccp_update_gss(sk, dcb->dccpd_seq);
 		dccp_hdr_set_seq(dh, dp->dccps_gss);
 		if (set_ack)
 			dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), ackno);
@@ -112,6 +115,11 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 		case DCCP_PKT_REQUEST:
 			dccp_hdr_request(skb)->dccph_req_service  							dp->dccps_service;
+			/*
+			 * Limit Ack window to ISS <= P.ackno <= GSS, so that
+			 * only Responses to Requests we sent are considered.
+			 */
+			dp->dccps_awl = dp->dccps_iss;
 			break;
 		case DCCP_PKT_RESET:
 			dccp_hdr_reset(skb)->dccph_reset_code @@ -447,19 +455,7 @@ static inline void dccp_connect_init(struct sock *sk)
 
 	dccp_sync_mss(sk, dst_mtu(dst));
 
-	/*
-	 * SWL and AWL are initially adjusted so that they are not less than
-	 * the initial Sequence Numbers received and sent, respectively:
-	 *	SWL := max(GSR + 1 - floor(W/4), ISR),
-	 *	AWL := max(GSS - W' + 1, ISS).
-	 * These adjustments MUST be applied only at the beginning of the
-	 * connection.
-	 */
-	dccp_update_gss(sk, dp->dccps_iss);
-	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
-
-	/* S.GAR - greatest valid acknowledgement number received on a non-Sync;
-	 *         initialized to S.ISS (sec. 8.5)                            */
+	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
 	dp->dccps_gar = dp->dccps_iss;
 
 	icsk->icsk_retransmits = 0;
