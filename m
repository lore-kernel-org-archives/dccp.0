From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:13:21 +0000
Subject: [Patch 9/12]: Perform history operations only after packet has been sent
Message-Id: <200612072113.21700@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Perform history operations only after packet has been sent

 This migrates all packet history operations into the routine
 ccid3_hc_tx_packet_sent, thereby removing synchronization problems
 that occur when, as before, the operations are spread over multiple
 routines.
 The following minor simplifications are also applied:
  * several simplifications now follow from this change - several tests 
    are now no longer required
  * removal of one unnecessary variable (dp)

Justification:
--------------
 Currently packet history operations span two different routines, 
 one of which is likely to pass through several iterations of sleeping
 and awakening. 
 The first routine, ccid3_hc_tx_send_packet, allocates an entry and
 sets a few fields. The remaining fields are filled in when the second
 routine (which is not within a sleeping context), ccid3_hc_tx_packet_sent,
 is called. This has several strong drawbacks:
  * it is not necessary to split history operations - all fields can be
    filled in by the second routine
  * the first routine is called multiple times, until a packet can be sent,
    and sleeps meanwhile - this causes a lot of difficulties with regard to
    keeping the list consistent
  * since both routines do not have a producer-consumer like synchronization,
    it is very difficult to maintain data across calls to these routines
  * the fact that the routines are called in different contexts (sleeping, not
    sleeping) adds further problems		  

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   38 +++++++++-----------------------------
 1 file changed, 9 insertions(+), 29 deletions(-)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -296,7 +296,6 @@ static int ccid3_hc_tx_send_packet(struc
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct dccp_tx_hist_entry *new_packet;
 	struct timeval now;
 	suseconds_t delay;
 
@@ -310,21 +309,6 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	/* See if last packet allocated was not sent */
-	new_packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
-	if (new_packet = NULL || new_packet->dccphtx_sent) {
-		new_packet = dccp_tx_hist_entry_new(ccid3_tx_hist,
-						    SLAB_ATOMIC);
-
-		if (unlikely(new_packet = NULL)) {
-			DCCP_WARN("%s, sk=%p, not enough mem to add to history,"
-				  "send refused\n", dccp_role(sk), sk);
-			return -ENOBUFS;
-		}
-
-		dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, new_packet);
-	}
-
 	dccp_timestamp(sk, &now);
 
 	switch (hctx->ccid3hctx_state) {
@@ -380,31 +364,27 @@ static int ccid3_hc_tx_send_packet(struc
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
 	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
 
-	dccp_timestamp(sk, &now);
-
 	ccid3_hc_tx_update_s(hctx, len);
 
-	packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
+	packet = dccp_tx_hist_entry_new(ccid3_tx_hist, SLAB_ATOMIC);
 	if (unlikely(packet = NULL)) {
-		DCCP_WARN("packet doesn't exist in history!\n");
-		return;
-	}
-	if (unlikely(packet->dccphtx_sent)) {
-		DCCP_WARN("no unsent packet in history!\n");
+		DCCP_CRIT("packet history - out of memory!");
 		return;
 	}
+	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
+
+	dccp_timestamp(sk, &now);
 	packet->dccphtx_tstamp = now;
-	packet->dccphtx_seqno  = dp->dccps_gss;
-	hctx->ccid3hctx_idle = 0;
-	packet->dccphtx_rtt  = hctx->ccid3hctx_rtt;
-	packet->dccphtx_sent = 1;
+	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
+	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
+	packet->dccphtx_sent   = 1;
+	hctx->ccid3hctx_idle   = 0;
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
