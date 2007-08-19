From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:51:05 +0000
Subject: [PATCH 08/15] [CCID3]: Stop using dccp_timestamp
Message-Id: <20070819235105.GL24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now to convert the ackvec code to ktime_t so that we can get rid of
dccp_timestamp and the epoch thing in dccp_sock.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 3524328..6b12e9f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -388,7 +388,6 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 				    unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
 	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
@@ -402,8 +401,7 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 	}
 	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 
-	dccp_timestamp(sk, &now);
-	packet->dccphtx_tstamp = now;
+	packet->dccphtx_tstamp = ktime_to_timeval(ktime_get_real());
 	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
 	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
 	packet->dccphtx_sent   = 1;
@@ -729,8 +727,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_rx_hist_entry *packet;
-	struct timeval tnow;
-	ktime_t now;
+	ktime_t now, t_hist;
 	suseconds_t delta;
 
 	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
@@ -765,8 +762,8 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	tnow = ktime_to_timeval(now);
-	delta = timeval_delta(&tnow, &packet->dccphrx_tstamp);
+	t_hist = timeval_to_ktime(packet->dccphrx_tstamp);
+	delta = ktime_us_delta(now, t_hist);
 	DCCP_BUG_ON(delta < 0);
 	hcrx->ccid3hcrx_elapsed_time = delta / 10;
 
-- 
1.5.2.2

