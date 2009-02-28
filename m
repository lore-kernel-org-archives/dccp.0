From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 28 Feb 2009 08:38:29 +0000
Subject: [PATCH 2/2] dccp: Do not let initial option overhead shrink the MPS
Message-Id: <1235810309-10256-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a problem caused by the overlap of the connection-setup and
established-state phases of DCCP connections.

During connection setup, the client retransmits Confirm Feature-Negotiation
options until a response from the server signals that it can move from the
half-established PARTOPEN into the OPEN state, whereupon the connection is
fully established on both ends (RFC 4340, 8.1.5).

However, since the client may already send data while it is in the PARTOPEN
state, consequences arise for the Maximum Packet Size: the problem is that the
initial option overhead is much higher than for the subsequent established
phase, as it involves potentially many variable-length list-type options
(server-priority options, RFC 4340, 6.4).

Applying the standard MPS is insufficient here: especially with larger
payloads this can lead to annoying, counter-intuitive EMSGSIZE errors.

On the other hand, reducing the MPS available for the established phase by
the added initial overhead is highly wasteful and inefficient.

The solution chosen therefore is a two-phase strategy:

   If the payload length of the DataAck in PARTOPEN is too large, an Ack is sent
   to carry the options, and the feature-negotiation list is then flushed.

   This means that the server gets two Acks for one Response. If both Acks get
   lost, it is probably better to restart the connection anyway and devising yet
   another special-case does not seem worth the extra complexity.

The result is a higher utilisation of the available packet space for the data
transmission phase (established state) of a connection.

The patch (over-)estimates the initial overhead to be 32*4 bytes -- commonly
seen values were around 90 bytes for initial feature-negotiation options.

It uses sizeof(u32) to mean "aligned units of 4 bytes".
For consistency, another use of 4-byte alignment is adapted.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    5 ++++-
 net/dccp/output.c |   15 ++++++++++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -63,11 +63,14 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
  *    - DCCP-Reset    with ACK Subheader and 4 bytes of Reset Code fields
  *  Hence a safe upper bound for the maximum option length is 1020-28 = 992
  */
-#define MAX_DCCP_SPECIFIC_HEADER (255 * sizeof(int))
+#define MAX_DCCP_SPECIFIC_HEADER (255 * sizeof(uint32_t))
 #define DCCP_MAX_PACKET_HDR 28
 #define DCCP_MAX_OPT_LEN (MAX_DCCP_SPECIFIC_HEADER - DCCP_MAX_PACKET_HDR)
 #define MAX_DCCP_HEADER (MAX_DCCP_SPECIFIC_HEADER + MAX_HEADER)
 
+/* Upper bound for initial feature-negotiation overhead (padded to 32 bits) */
+#define DCCP_FEATNEG_OVERHEAD	 (32 * sizeof(uint32_t))
+
 #define DCCP_TIMEWAIT_LEN (60 * HZ) /* how long to wait to destroy TIME-WAIT
 				     * state, about 60 seconds */
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -276,7 +276,20 @@ void dccp_write_xmit(struct sock *sk, int block)
 			const int len = skb->len;
 
 			if (sk->sk_state = DCCP_PARTOPEN) {
-				/* See 8.1.5.  Handshake Completion */
+				const u32 cur_mps = dp->dccps_mss_cache - DCCP_FEATNEG_OVERHEAD;
+				/*
+				 * See 8.1.5 - Handshake Completion.
+				 *
+				 * For robustness we resend Confirm options until the client has
+				 * entered OPEN. During the initial feature negotiation, the MPS
+				 * is smaller than usual, reduced by the Change/Confirm options.
+				 */
+				if (!list_empty(&dp->dccps_featneg) && len > cur_mps) {
+					DCCP_WARN("Payload too large (%d) for featneg.\n", len);
+					dccp_send_ack(sk);
+					dccp_feat_list_purge(&dp->dccps_featneg);
+				}
+
 				inet_csk_schedule_ack(sk);
 				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  inet_csk(sk)->icsk_rto,
