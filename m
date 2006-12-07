From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:12:53 +0000
Subject: [Patch 5/12]: Initialise RTT values
Message-Id: <200612072112.53347@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Initialise RTT values

In both the sender and the receiver it is possible that the stored
RTT value is accessed before an actual RTT estimate has been computed.

This patch
 * initialises the sender RTT to 0 
     - the sender always accesses the RTT in ccid3_hc_tx_packet_sent
     - the RTT is further needed for the window counter algorithm

 * replaces the receiver initialisation of 5msec with 0 
     - which has the same effect and removes an `XXX'
     - the RTT value is needed in ccid3_hc_rx_packet_recv as rtt_prev

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -622,6 +622,7 @@ static int ccid3_hc_tx_init(struct ccid 
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->ccid3hctx_s     = 0;
+	hctx->ccid3hctx_rtt   = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
@@ -1011,6 +1012,7 @@ static void ccid3_hc_rx_packet_recv(stru
 			hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
 					      r_sample / 10;
 
+
 		if (rtt_prev != hcrx->ccid3hcrx_rtt)
 			ccid3_pr_debug("%s, New RTT=%uus, elapsed time=%u\n",
 				       dccp_role(sk), hcrx->ccid3hcrx_rtt,
@@ -1098,7 +1100,7 @@ static int ccid3_hc_rx_init(struct ccid 
 	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_s   = 0;
-	hcrx->ccid3hcrx_rtt = 5000; /* XXX 5ms for now... */
+	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
 }
 
