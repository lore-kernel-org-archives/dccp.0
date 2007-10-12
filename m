From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Oct 2007 09:51:57 +0000
Subject: [PATCH 4/5]: Leave headroom for options when calculating the MPS
Message-Id: <200710121051.57905@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Leave headroom for options when calculating the MPS

The Maximum Packet Size (MPS) is of interest for applications which want
to transfer data, so it is only relevant to the data transfer phase of a
connection (unless one wants to send data on the DCCP-Request, but that is
not considered here).

The strategy chosen to deal with this requirement is to leave room for only 
such options that may appear on data packets.

This excludes in particular variable-length options such as Ack Vector:
as detailed in section 11.2 of RFC 4340, such options can use a separate
Ack if a current DataAck packet does not have sufficient room left.

There are currently no CCID-specific header options which may appear on data
packets, hence it is not necessary to define a corresponding CCID field.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -160,14 +160,18 @@ unsigned int dccp_sync_mss(struct sock *
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
 	 */
-
-	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
+	cur_mps -= roundup(1 + 6 + 10 + dp->dccps_send_ndp_count * 8 + 6, 4);
 
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie = pmtu;
