From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:04:08 +0000
Subject: [PATCH 3/9] [CCID2]: Replace read-only variable with constant
Message-Id: <200711031323.43503@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This replaces the field member `numdupack', which was used as a read-only
constant in the code, with a #define.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    8 +++-----
 net/dccp/ccids/ccid2.h |    3 ++-
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 722d481..e32f766 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -586,8 +586,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid2hctx_rpdupack++;
 
 			/* check if we got enough dupacks */
-			if (hctx->ccid2hctx_rpdupack >-			    hctx->ccid2hctx_numdupack) {
+			if (hctx->ccid2hctx_rpdupack >= NUMDUPACK) {
 				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
 				hctx->ccid2hctx_rpseq = 0;
 
@@ -708,7 +707,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	while (1) {
 		if (seqp->ccid2s_acked) {
 			done++;
-			if (done = hctx->ccid2hctx_numdupack)
+			if (done = NUMDUPACK)
 				break;
 		}
 		if (seqp = hctx->ccid2hctx_seqt)
@@ -719,7 +718,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/* If there are at least 3 acknowledgements, anything unacknowledged
 	 * below the last sequence number is considered lost
 	 */
-	if (done = hctx->ccid2hctx_numdupack) {
+	if (done = NUMDUPACK) {
 		struct ccid2_seq *last_acked = seqp;
 
 		/* check for lost packets */
@@ -761,7 +760,6 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
 	hctx->ccid2hctx_ssthresh  = ~0;
-	hctx->ccid2hctx_numdupack = 3;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 6d0b4e3..443f08a 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -24,6 +24,8 @@
 #include <linux/timer.h>
 #include <linux/types.h>
 #include "../ccid.h"
+/* NUMDUPACK parameter from RFC 4341, p. 6 */
+#define NUMDUPACK	3
 
 struct sock;
 
@@ -52,7 +54,6 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_acks;
 	unsigned int		ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
-	int			ccid2hctx_numdupack;
 	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
 	int			ccid2hctx_seqbufc;
 	struct ccid2_seq	*ccid2hctx_seqh;
-- 
1.5.2.2.238.g7cbf2f2-dirty

