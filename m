From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Jan 2009 14:42:27 +0000
Subject: dccp test tree [RFC/RFT] [Patch 3/3] dccp: dccp_probe hook for
Message-Id: <20090105144227.GD3773@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Add dccp_probe support for CCID-2

This adds dccp_probe support for CCID-2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -248,6 +248,19 @@ static void ccid2_hc_tx_packet_sent(stru
 #endif
 }
 
+static size_t ccid2_hc_tx_probe(struct sock *sk, char *buf, const size_t maxlen)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	/* Specific field numbering:
+			5     6    7      8        9      10     11
+			rto   rtt  mdev   rttvar   cwnd   pipe   ssthresh  */
+	return snprintf(buf, maxlen, " %u %u %u %u %u %u %u", hctx->rto,
+			hctx->srtt >> 3, hctx->mdev >> 2, hctx->rttvar >> 2,
+			hctx->cwnd, hctx->pipe, hctx->ssthresh);
+
+}
+
 /**
  * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
  * This code is almost identical with TCP's tcp_rtt_estimator(), since
@@ -650,6 +663,7 @@ struct ccid_operations ccid2_ops = {
 	.ccid_hc_tx_exit	  = ccid2_hc_tx_exit,
 	.ccid_hc_tx_send_packet	  = ccid2_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	  = ccid2_hc_tx_packet_sent,
+	.ccid_hc_tx_probe	  = ccid2_hc_tx_probe,
 	.ccid_hc_tx_parse_options = ccid2_hc_tx_parse_options,
 	.ccid_hc_tx_packet_recv	  = ccid2_hc_tx_packet_recv,
 	.ccid_hc_rx_obj_size	  = sizeof(struct ccid2_hc_rx_sock),
