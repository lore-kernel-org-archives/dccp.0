From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:02:48 +0000
Subject: [PATCH 14/22] [DCCP] ccid3: Initialise RTT values
Message-Id: <20061210030248.GP17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 7017d84..7618d51 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -617,6 +617,7 @@ static int ccid3_hc_tx_init(struct ccid 
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->ccid3hctx_s     = 0;
+	hctx->ccid3hctx_rtt   = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
@@ -1093,7 +1094,7 @@ static int ccid3_hc_rx_init(struct ccid 
 	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_s   = 0;
-	hcrx->ccid3hcrx_rtt = 5000; /* XXX 5ms for now... */
+	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
 }
 
-- 
1.4.2.1.g3d5c

