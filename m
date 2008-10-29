From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 29 Oct 2008 05:33:43 +0000
Subject: dccp test-tree [RFC/RFT] [Patch 1/1] dccp ccid-2: Use u32
Message-Id: <20081029053342.GA26455@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update of the dccp test tree at

	git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree `dccp']

It is part of an ongoing effort to improve and align the code with 
existing code.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp ccid-2: Use u32 timestamps uniformly

CCID-2 is de facto a mini implementation of TCP. Thus it makes sense to share
as much code as possible. 

This patch therefore aligns CCID-2 timestamping with TCP timestamping, which
also halves the space consumption (on 64-bit systems).

The necessary include file <net/tcp.h> is already included by way of
net/dccp.h.  Redundant include files are also removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   14 ++++++--------
 net/dccp/ccids/ccid2.h |   15 ++++++++++-----
 2 files changed, 16 insertions(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -20,18 +20,23 @@
 #ifndef _DCCP_CCID2_H_
 #define _DCCP_CCID2_H_
 
-#include <linux/dccp.h>
 #include <linux/timer.h>
 #include <linux/types.h>
 #include "../ccid.h"
+#include "../dccp.h"
+
+/*
+ * CCID-2 timestamping faces the same issues as TCP timestamping.
+ * Hence we reuse/share as much of the code as possible.
+ */
+#define ccid2_time_stamp	tcp_time_stamp
+
 /* NUMDUPACK parameter from RFC 4341, p. 6 */
 #define NUMDUPACK	3
 
-struct sock;
-
 struct ccid2_seq {
 	u64			ccid2s_seq;
-	unsigned long		ccid2s_sent;
+	u32			ccid2s_sent;
 	int			ccid2s_acked;
 	struct ccid2_seq	*ccid2s_prev;
 	struct ccid2_seq	*ccid2s_next;
@@ -73,7 +78,7 @@ struct ccid2_hc_tx_sock {
 	struct timer_list	rtotimer;
 	u64			rpseq;
 	int			rpdupack;
-	unsigned long		last_cong;
+	u32			last_cong;
 	u64			high_ack;
 	struct list_head	av_chunks;
 };
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -26,8 +26,6 @@
  * This implementation should follow RFC 4341
  */
 #include "../feat.h"
-#include "../ccid.h"
-#include "../dccp.h"
 #include "ccid2.h"
 
 
@@ -177,7 +175,7 @@ static void ccid2_hc_tx_packet_sent(stru
 
 	hctx->seqh->ccid2s_seq   = dp->dccps_gss;
 	hctx->seqh->ccid2s_acked = 0;
-	hctx->seqh->ccid2s_sent  = jiffies;
+	hctx->seqh->ccid2s_sent  = ccid2_time_stamp;
 
 	next = hctx->seqh->ccid2s_next;
 	/* check if we need to alloc more space */
@@ -252,7 +250,7 @@ static void ccid2_hc_tx_packet_sent(stru
 		struct ccid2_seq *seqp = hctx->seqt;
 
 		while (seqp != hctx->seqh) {
-			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
+			ccid2_pr_debug("out seq=%llu acked=%d time=%u\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
@@ -372,19 +370,19 @@ static void ccid2_new_ack(struct sock *s
 	 * The cleanest solution is to not use the ccid2s_sent field at all
 	 * and instead use DCCP timestamps - need to be resolved at some time.
 	 */
-	ccid2_rtt_estimator(sk, jiffies - seqp->ccid2s_sent);
+	ccid2_rtt_estimator(sk, ccid2_time_stamp - seqp->ccid2s_sent);
 }
 
 static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (time_before(seqp->ccid2s_sent, hctx->last_cong)) {
+	if ((s32)(seqp->ccid2s_sent - hctx->last_cong) < 0) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
 	}
 
-	hctx->last_cong = jiffies;
+	hctx->last_cong = ccid2_time_stamp;
 
 	hctx->cwnd     = hctx->cwnd / 2 ? : 1U;
 	hctx->ssthresh = max(hctx->cwnd, 2U);
@@ -634,7 +632,7 @@ static int ccid2_hc_tx_init(struct ccid 
 
 	hctx->rto	= DCCP_TIMEOUT_INIT;
 	hctx->rpdupack  = -1;
-	hctx->last_cong = jiffies;
+	hctx->last_cong = ccid2_time_stamp;
 	setup_timer(&hctx->rtotimer, ccid2_hc_tx_rto_expire, (unsigned long)sk);
 	INIT_LIST_HEAD(&hctx->av_chunks);
 	return 0;
-- 
