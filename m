From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Feb 2008 09:52:01 +0000
Subject: [PATCH 1/2] [DCCP]: Leave headroom for options when calculating the MPS
Message-Id: <1203933122-27140-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The Maximum Packet Size (MPS) is of interest for applications which want
to transfer data, so it is only relevant to the data transfer phase of a
connection (unless one wants to send data on the DCCP-Request, but that is
not considered here).

The strategy chosen to deal with this requirement is to leave room for only 
such options that may appear on data packets.

A special consideration applies to Ack Vectors: this is purely guesswork,
since these can have any length between 3 and 1020 bytes. The strategy
chosen here is to subtract a configurable minimum, the value of 16 bytes
(2 bytes for type/length plus 14 Ack Vector cells) has been found by 
experimentatation. If people experience this as too much or too little,
this could later be turned into a Kconfig option.	

There are currently no CCID-specific header options which may appear on data
packets, hence it is not necessary to define a corresponding CCID field.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ackvec.h |    3 +++
 net/dccp/output.c |   22 ++++++++++++++--------
 2 files changed, 17 insertions(+), 8 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -21,6 +21,9 @@
 /* We can spread an ack vector across multiple options */
 #define DCCP_MAX_ACKVEC_LEN (DCCP_SINGLE_OPT_MAXLEN * 2)
 
+/* Estimated minimum average Ack Vector length - used for updating MPS */
+#define DCCPAV_MIN_OPTLEN	16
+
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
 #define DCCP_ACKVEC_STATE_NOT_RECEIVED	(3 << 6)
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -153,21 +153,27 @@ unsigned int dccp_sync_mss(struct sock *
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	u32 ccmps = dccp_determine_ccmps(dp);
-	int cur_mps = ccmps ? min(pmtu, ccmps) : pmtu;
+	u32 cur_mps = ccmps ? min(pmtu, ccmps) : pmtu;
 
 	/* Account for header lengths and IPv4/v6 option overhead */
 	cur_mps -= (icsk->icsk_af_ops->net_header_len + icsk->icsk_ext_hdr_len +
 		    sizeof(struct dccp_hdr) + sizeof(struct dccp_hdr_ext));
 
 	/*
-	 * FIXME: this should come from the CCID infrastructure, where, say,
-	 * TFRC will say it wants TIMESTAMPS, ELAPSED time, etc, for now lets
-	 * put a rough estimate for NDP + TIMESTAMP + TIMESTAMP_ECHO + ELAPSED
-	 * TIME + TFRC_OPT_LOSS_EVENT_RATE + TFRC_OPT_RECEIVE_RATE + padding to
-	 * make it a multiple of 4
+	 * Leave enough headroom for common DCCP header options.
+	 * This only considers options which may appear on DCCP-Data packets, as
+	 * per table 3 in RFC 4340, 5.8. When running out of space for other
+	 * options (eg. Ack Vector which can take up to 255 bytes), it is better
+	 * to schedule a separate Ack. Thus we leave headroom for the following:
+	 *  - 1 byte for Slow Receiver (11.6)
+	 *  - 6 bytes for Timestamp (13.1)
+	 *  - 10 bytes for Timestamp Echo (13.3)
+	 *  - 8 bytes for NDP count (7.7, when activated)
+	 *  - 6 bytes for Data Checksum (9.3)
+	 *  - %DCCPAV_MIN_OPTLEN bytes for Ack Vector size (11.4, when enabled)
 	 */
-
-	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
+	cur_mps -= roundup(1 + 6 + 10 + dp->dccps_send_ndp_count * 8 + 6 +
+			   (dp->dccps_hc_rx_ackvec ? DCCPAV_MIN_OPTLEN : 0), 4);
 
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie = pmtu;
