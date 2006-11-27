From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 27 Nov 2006 14:46:12 +0000
Subject: [PATCH 5/8] [DCCP] ccid3: Avoid congestion control on zero-sized data packets
Message-Id: <20061127144612.GP11605@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This resolves an `XXX' in ccid3_hc_tx_send_packet().

The function is only called on Data and DataAck packets and returns a negative
result on zero-sized messages. This is a reasonable policy since CCID 3 is a
congestion-control module and congestion control on zero-sized Data(Ack)
packets is in a way pathological.

The patch uses a more suitable error code for this case, it returns the Posix.1
code `EBADMSG' ("Not a data message") instead of `ENOTCONN'.

As a result of ignoring zero-sized packets, a the condition for a warning
"First packet is data" in ccid3_hc_tx_packet_sent is always satisfied; this
message has been removed since it will always be printed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2745d83..62c3042 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -264,13 +264,13 @@ static int ccid3_hc_tx_send_packet(struc
 
 	BUG_ON(hctx = NULL);
 
-	/* Check if pure ACK or Terminating*/
 	/*
-	 * XXX: We only call this function for DATA and DATAACK, on, these
-	 * packets can have zero length, but why the comment about "pure ACK"?
+	 * This function is called only for Data and DataAck packets. Sending
+	 * zero-sized Data(Ack)s is theoretically possible, but for congestion
+	 * control this case is pathological - ignore it.
 	 */
 	if (unlikely(len = 0))
-		return -ENOTCONN;
+		return -EBADMSG;
 
 	/* See if last packet allocated was not sent */
 	new_packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
@@ -387,11 +387,7 @@ static void ccid3_hc_tx_packet_sent(stru
 
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
-		/* if first wasn't pure ack */
-		if (len != 0)
-			DCCP_CRIT("%s, First packet sent is noted "
-				  "as a data packet",  dccp_role(sk));
-		return;
+		/* fall through */
 	case TFRC_SSTATE_NO_FBACK:
 		/* t_nom, t_ipi, delta do not change until feedback arrives */
 		return;
-- 
1.4.2.1.g3d5c

