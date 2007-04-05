From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:37:18 +0000
Subject: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy applications
Message-Id: <200704051637.18198@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Protect against Reset/Sync floods due to buggy applications

This patch protects against Reset/Sync floods which happens as a result
of either buggy or crashing client applications. The Reset/Sync flood
is triggered as follows:

 1. Client establishes connection to listening server;
 2. before server can write data to client, client crashes;
 3. crashing client removes connection state at client host;
 4. server still thinks client is alive and sends data;
 5. client responds to server packet with Reset packet Code 3, 
    "No Connection", with seqno=0 - as per RFC 4340, 8.3.1;
 6. server thinks that seqno=0 is out of synch (step 6), sends Sync;
 7. goto (6).

The result is a drastic flood of packets: In one occasion I counted
345549 Reset/Sync packets, before the server finally killed itself.

Fix:
----
Since this condition is peculiar and can be distinguished from other
sequence-invalid packets, a special case has been added. The Reset
is accepted if
 * it has Reset Code 3, "No Connection" AND
 * it has sequence number 0 as described in RFC 4340, 8.3.1.

If both conditions are satisfied, the Reset is enqueued in the receive queue
as usual, and will very soon terminate the crashed connection.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -155,6 +155,22 @@ static int dccp_check_seqno(struct sock 
 		    (DCCP_SKB_CB(skb)->dccpd_ack_seq ! 		     DCCP_PKT_WITHOUT_ACK_SEQ))
 			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
+
+	} else if (dh->dccph_type = DCCP_PKT_RESET  &&
+		   dccp_hdr_reset(skb)->dccph_reset_code =
+		   DCCP_RESET_CODE_NO_CONNECTION &&
+		   DCCP_SKB_CB(skb)->dccpd_seq = 0) {
+		/*
+		 * This happens when connection is established and client app
+		 * crashes before server can send data. The crashing client
+		 * removes connection state, so the server gets a Code 3 Reset
+		 * packet with seqno 0 (RFC 4340, 8.3.1). Responding here with
+		 * a Sync leads to a Reset-Storm which will flood the network
+		 * until the server gives up on this connection or is killed.
+		 * We let this case pass so that the Reset gets enqueued and
+		 * will terminate the erratic connection.
+		 */
+		DCCP_WARN("DCCP: Peer sent RESET with seqno 0\n");
 	} else {
 		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
@@ -168,6 +184,7 @@ static int dccp_check_seqno(struct sock 
 			  (unsigned long long) lawl,
 			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			  (unsigned long long) dp->dccps_awh);
+		/* FIXME: Rate-limit DCCP-Sync packets as per RFC 4340, 7.5.4 */
 		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
 		return -1;
 	}
