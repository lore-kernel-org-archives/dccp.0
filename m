From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 18 May 2008 16:44:31 +0000
Subject: [DCCP] [RFT/Bug-Fix] [Patch 1/1]: Special case for client-PARTOPEN
Message-Id: <20080518164431.GA24987@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

     (This is an update for the test-tree, not meant for mainline now)

--------------------------> Patch <-------------------------------------
[DCCP]: Special case for client-PARTOPEN with DataAcks

There are two conflicting goals: providing a large room for options and allowing
the client to send DataAcks in the "half-open" PARTOPEN state. 

To increase robustness, it is necessary to resend Confirm feature-negotiation
options, even though the RFC does not mandate it. But feature negotiation
options can take (much) more room than the options on common DataAck packets.

Instead of reducing the MPS always for a case which only applies to the three
messages send during initial handshake, this patch devises a special case:
if the payload length of the DataAck in PARTOPEN is too large, an Ack is sent
to carry the options, and the feature-negotiation list is then flushed.

This means that the server gets two Acks for one Response. If both Acks get
lost, it is probably better to restart the connection anyway and devising yet
another special-case does not seem worth the extra complexity.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.h   |    3 +++
 net/dccp/output.c |   16 +++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -23,6 +23,9 @@
 #define DCCPF_SEQ_WMIN		32
 #define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
 
+/* Feature-negotiation overhead in multiples of 4-byte words */
+#define DCCP_FEATNEG_OVERHEAD_FACTOR	32
+
 enum dccp_feat_type {
 	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
 	FEAT_AT_TX   = 2,	/* located at TX side of half-connection  */
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -245,7 +245,21 @@ static void dccp_xmit_packet(struct sock
 	len = skb->len;
 
 	if (sk->sk_state = DCCP_PARTOPEN) {
-		/* See 8.1.5.  Handshake Completion */
+		const u32 overhead = DCCP_FEATNEG_OVERHEAD_FACTOR << 2;
+		/*
+		 * See 8.1.5 - Handshake Completion.
+		 * For robustness we resend Confirm options until the client has
+		 * entered OPEN. Unfortunately, the "copious space for options"
+		 * (RFC 4340, 4.6) means that there is less space for payload.
+		 * For overly large payloads, send second Ack to carry options.
+		 */
+		if (!list_empty(&dp->dccps_featneg) &&
+		    len + overhead >= dp->dccps_mss_cache) {
+			DCCP_WARN("Payload too large (%d) for featneg.\n", len);
+			dccp_send_ack(sk);
+			dccp_feat_list_purge(&dp->dccps_featneg);
+		}
+
 		inet_csk_schedule_ack(sk);
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 					      inet_csk(sk)->icsk_rto,
