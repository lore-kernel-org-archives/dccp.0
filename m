From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:04:18 +0000
Subject: [PATCH 6/9] [CCID2]: Redundant debugging output
Message-Id: <200711031323.52814@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This reduces the amount of redundant debugging messages:

 * pipe/cwnd are printed in both tx_send_packet() and tx_packet_sent().
   Both functions are called immediately after one another, so one occurrence is sufficient.

 * Since tx_packet_sent() prints pipe/cwnd already, the second printk for pipe is redundant.

 * In tx_packet_sent() the check_sanity function is called twice (at the begin and at the end).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 96908df..176fef9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,9 +126,6 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_pr_debug("pipe=%d cwnd=%d\n", hctx->ccid2hctx_pipe,
-		       hctx->ccid2hctx_cwnd);
-
 	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd) {
 		/* OK we can send... make sure previous packet was sent off */
 		if (!hctx->ccid2hctx_sendwait) {
@@ -239,8 +236,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	struct ccid2_seq *next;
 	u64 seq;
 
-	ccid2_hc_tx_check_sanity(hctx);
-
 	BUG_ON(!hctx->ccid2hctx_sendwait);
 	hctx->ccid2hctx_sendwait = 0;
 	hctx->ccid2hctx_pipe++;
@@ -326,7 +321,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("Sent: seq=%llu\n", (unsigned long long)seq);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
-- 
1.5.2.2.238.g7cbf2f2-dirty

