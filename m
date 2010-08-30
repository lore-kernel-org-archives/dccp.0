From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 05:23:10 +0000
Subject: [PATCH 1/5] dccp ccid-2: Use u32 timestamps uniformly
Message-Id: <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since CCID-2 is de facto a mini implementation of TCP, it makes sense to share
as much code as possible.

Hence this patch aligns CCID-2 timestamping with TCP timestamping.
This also halves the space consumption (on 64-bit systems).

The necessary include file <net/tcp.h> is already included by way of
net/dccp.h. Redundant includes have been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.h |   15 ++++++++++-----
 net/dccp/ccids/ccid2.c |   14 ++++++--------
 2 files changed, 16 insertions(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -18,18 +18,23 @@
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
@@ -72,7 +77,7 @@ struct ccid2_hc_tx_sock {
 
 	u64			tx_rpseq;
 	int			tx_rpdupack;
-	unsigned long		tx_last_cong;
+	u32			tx_last_cong;
 	u64			tx_high_ack;
 };
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -25,8 +25,6 @@
  */
 #include <linux/slab.h>
 #include "../feat.h"
-#include "../ccid.h"
-#include "../dccp.h"
 #include "ccid2.h"
 
 
@@ -175,7 +173,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 
 	hc->tx_seqh->ccid2s_seq   = dp->dccps_gss;
 	hc->tx_seqh->ccid2s_acked = 0;
-	hc->tx_seqh->ccid2s_sent  = jiffies;
+	hc->tx_seqh->ccid2s_sent  = ccid2_time_stamp;
 
 	next = hc->tx_seqh->ccid2s_next;
 	/* check if we need to alloc more space */
@@ -250,7 +248,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		struct ccid2_seq *seqp = hc->tx_seqt;
 
 		while (seqp != hc->tx_seqh) {
-			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
+			ccid2_pr_debug("out seq=%llu acked=%d time=%u\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
@@ -431,19 +429,19 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
 	 * The cleanest solution is to not use the ccid2s_sent field at all
 	 * and instead use DCCP timestamps: requires changes in other places.
 	 */
-	ccid2_rtt_estimator(sk, jiffies - seqp->ccid2s_sent);
+	ccid2_rtt_estimator(sk, ccid2_time_stamp - seqp->ccid2s_sent);
 }
 
 static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	if (time_before(seqp->ccid2s_sent, hc->tx_last_cong)) {
+	if ((s32)(seqp->ccid2s_sent - hc->tx_last_cong) < 0) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
 	}
 
-	hc->tx_last_cong = jiffies;
+	hc->tx_last_cong = ccid2_time_stamp;
 
 	hc->tx_cwnd      = hc->tx_cwnd / 2 ? : 1U;
 	hc->tx_ssthresh  = max(hc->tx_cwnd, 2U);
@@ -683,7 +681,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 
 	hc->tx_rto	 = DCCP_TIMEOUT_INIT;
 	hc->tx_rpdupack  = -1;
-	hc->tx_last_cong = jiffies;
+	hc->tx_last_cong = ccid2_time_stamp;
 	setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
 	return 0;
