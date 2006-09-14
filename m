From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:14:33 +0000
Subject: [PATCH 10/10]: [DCCP] CCID2: Add helper functions for changing important CCID2 state
Message-Id: <20060914171433.GL20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Introduce methods which manipulate interesting congestion control state such as
pipe and rtt estimate.  This is useful for people wishing to monitor the
variables of CCID and instrument the code [perhaps using Kprobes].  Personally,
I am a fan of encapsulation---that justifies this change =D.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |   31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 4fcd858..5c294ee 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -199,6 +199,17 @@ static void ccid2_change_cwnd(struct cci
 	hctx->ccid2hctx_cwnd = val;
 }
 
+static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
+{
+	ccid2_pr_debug("change SRTT to %ld\n", val);
+	hctx->ccid2hctx_srtt = val;
+}
+ 
+static void ccid2_change_pipe(struct ccid2_hc_tx_sock *hctx, long val)
+{
+	hctx->ccid2hctx_pipe = val;
+}
+
 static void ccid2_start_rto_timer(struct sock *sk);
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -228,7 +239,7 @@ static void ccid2_hc_tx_rto_expire(unsig
 	ccid2_start_rto_timer(sk);
 
 	/* adjust pipe, cwnd etc */
-	hctx->ccid2hctx_pipe = 0;
+	ccid2_change_pipe(hctx, 0);
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
@@ -274,7 +285,7 @@ static void ccid2_hc_tx_packet_sent(stru
 
 	BUG_ON(!hctx->ccid2hctx_sendwait);
 	hctx->ccid2hctx_sendwait = 0;
-	hctx->ccid2hctx_pipe++;
+	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe + 1);
 	BUG_ON(hctx->ccid2hctx_pipe < 0);
 
 	/* There is an issue.  What if another packet is sent between
@@ -470,11 +481,13 @@ static inline void ccid2_new_ack(struct 
 		if (hctx->ccid2hctx_srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
 			       	       r, jiffies, seqp->ccid2s_seq);
-			hctx->ccid2hctx_srtt = r;
+			ccid2_change_srtt(hctx, r);
 			hctx->ccid2hctx_rttvar = r >> 1;
 		} else {
 			/* RTTVAR */
 			long tmp = hctx->ccid2hctx_srtt - r;
+			long srtt;
+
 			if (tmp < 0)
 				tmp *= -1;
 
@@ -484,10 +497,12 @@ static inline void ccid2_new_ack(struct 
 			hctx->ccid2hctx_rttvar += tmp;
 
 			/* SRTT */
-			hctx->ccid2hctx_srtt *= 7;
-			hctx->ccid2hctx_srtt >>= 3;
+			srtt = hctx->ccid2hctx_srtt;
+			srtt *= 7;
+			srtt >>= 3;
 			tmp = r >> 3;
-			hctx->ccid2hctx_srtt += tmp;
+			srtt += tmp;
+			ccid2_change_srtt(hctx, srtt);
 		}
 		s = hctx->ccid2hctx_rttvar << 2;
 		/* clock granularity is 1 when based on jiffies */
@@ -523,7 +538,7 @@ static void ccid2_hc_tx_dec_pipe(struct 
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	hctx->ccid2hctx_pipe--;
+	ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe-1);
 	BUG_ON(hctx->ccid2hctx_pipe < 0);
 
 	if (hctx->ccid2hctx_pipe = 0)
@@ -749,7 +764,7 @@ static int ccid2_hc_tx_init(struct ccid 
 
 	hctx->ccid2hctx_sent	 = 0;
 	hctx->ccid2hctx_rto	 = 3 * HZ;
-	hctx->ccid2hctx_srtt	 = -1;
+	ccid2_change_srtt(hctx, -1);
 	hctx->ccid2hctx_rttvar	 = -1;
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
