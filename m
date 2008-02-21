From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:19 +0000
Subject: [PATCH 01/10] [ACKVEC]: Need to ignore Ack Vectors on request sockets
Message-Id: <1203584968-8957-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes an oversight from an earlier patch.

The issue is that Ack Vectors must not be parsed on request sockets, since
the Ack Vector feature depends on the selection of the (TX) CCID. During the
initial handshake the CCIDs are undefined, and so RFC 4340, 10.3 applies:

 "Using CCID-specific options and feature options during a negotiation
  for the corresponding CCID feature is NOT RECOMMENDED [...]"

Worse, it is not even possible: when the server receives the Request from the
client, the CCID and Ack vector features are undefined; when the Ack finalising
the 3-way hanshake arrives, the request socket has not been cloned yet into a
full socket. (This order is necessary, since otherwise the newly created socket
would have to be destroyed whenever an option error occurred - a malicious
hacker could simply send garbage options and exploit this.)

As a result, it is not feasible to parse Ack Vectors on request sockets, since
their sink (the CCIDs interested in using Ack Vector information) is undefined.

Hence disabled by this patch.

Two further, minor changes:
 * replaced magic numbers for CCID-specific options with symbolic constants;
 * replaced local variables `idx' with computation in argument list (btw,
   these indices are nowhere used -- are they really still needed???).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    6 ++++--
 net/dccp/options.c   |   19 +++++++------------
 2 files changed, 11 insertions(+), 14 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -165,8 +165,10 @@ enum {
 	DCCPO_TIMESTAMP_ECHO = 42,
 	DCCPO_ELAPSED_TIME = 43,
 	DCCPO_MAX = 45,
-	DCCPO_MIN_CCID_SPECIFIC = 128,
-	DCCPO_MAX_CCID_SPECIFIC = 255,
+	DCCPO_MIN_RX_CCID_SPECIFIC = 128,	/* from sender to receiver */
+	DCCPO_MAX_RX_CCID_SPECIFIC = 191,
+	DCCPO_MIN_TX_CCID_SPECIFIC = 192,	/* from receiver to sender */
+	DCCPO_MAX_TX_CCID_SPECIFIC = 255,
 };
 
 /* DCCP CCIDS */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -104,9 +104,10 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		 *
 		 * CCID-specific options are ignored during connection setup, as
 		 * negotiation may still be in progress (see RFC 4340, 10.3).
-		 *
+		 * The same applies to Ack Vectors, as these depend on the CCID.
 		 */
-		if (dreq != NULL && opt >= 128)
+		if (dreq != NULL && (opt >= DCCPO_MIN_RX_CCID_SPECIFIC ||
+		    opt = DCCPO_ACK_VECTOR_0 || opt = DCCPO_ACK_VECTOR_1))
 			goto ignore_option;
 
 		switch (opt) {
@@ -226,23 +227,17 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			dccp_pr_debug("%s rx opt: ELAPSED_TIME=%d\n",
 				      dccp_role(sk), elapsed_time);
 			break;
-		case 128 ... 191: {
-			const u16 idx = value - options;
-
+		case DCCPO_MIN_RX_CCID_SPECIFIC ... DCCPO_MAX_RX_CCID_SPECIFIC:
 			if (ccid_hc_rx_parse_options(dp->dccps_hc_rx_ccid, sk,
-						     opt, len, idx,
+						     opt, len, value - options,
 						     value) != 0)
 				goto out_invalid_option;
-		}
 			break;
-		case 192 ... 255: {
-			const u16 idx = value - options;
-
+		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
-						     opt, len, idx,
+						     opt, len, value - options,
 						     value) != 0)
 				goto out_invalid_option;
-		}
 			break;
 		default:
 			DCCP_CRIT("DCCP(%p): option %d(len=%d) not "
