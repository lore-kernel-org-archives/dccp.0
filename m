From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Feb 2008 14:23:05 +0000
Subject: [PATCH 1/4] [CCID2]: Remove redundant sanity tests
Message-Id: <1204122188-9984-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the ccid2_hc_tx_check_sanity function: it is redundant.

Details:
====
The tx_check_sanity function performs three tests:
 1) it checks that the circular TX list is sorted
    - in ascending order of sequence number (ccid2s_seq)
    - and time (ccid2s_sent),
    - in the direction from `tail' (hctx_seqt) to `head' (hctx_seqh);
 2) it ensures that the entire list has the length seqbufc * CCID2_SEQBUF_LEN;
 3) it ensures that ccid2hctx_pipe equals the number of packets that were not
    marked `acked' (ccid2s_acked) between `tail' and `head'.

The following argues that each of these tests is redundant, this can be verified
by going through the code.

(1) is not necessary, since both time and GSS increase from one packet to the
next, so that subsequent insertions in tx_packet_sent (which advance the `head'
pointer) will be in ascending order of time and sequence number.

In (2), the length of the list is always equal to seqbufc times CCID2_SEQBUF_LEN
(set to 1024) unless allocation caused an earlier failure, because:
 * at initialisation (tx_init), there is one chunk of size 1024 and seqbufc=1;
 * subsequent calls to tx_alloc_seq take place whenever head->next = tail in
   tx_packet_sent; then a new chunk of size 1024 is inserted between head and
   tail, and seqbufc is incremented by one.

To show that (3) is redundant requires looking at two cases.

The `pipe' variable of the TX socket is incremented only in tx_packet_sent, and
decremented in tx_packet_recv.  When head = tail (TX history empty) then pipe
should be 0, which is the case directly after initialisation and after a
retransmission timeout has occurred (ccid2_hc_tx_rto_expire).

The first case involves parsing Ack Vectors for packets recorded in the live
portion of the buffer, between tail and head. For each packet marked by the
receiver as received (state 0) or ECN-marked (state 1), pipe is decremented by
one, so for all such packets the BUG_ON in tx_check_sanity will not trigger.

The second case is the loss detection in the second half of tx_packet_recv,
below the comment "Check for NUMDUPACK".

The first while-loop here ensures that the sequence number of `seqp' is either
above or equal to `high_ack', or otherwise equal to the highest sequence number
sent so far (of the entry head->prev, as head points to the next unsent entry).
The next while-loop ("while (1)") counts the number of acked packets starting
from that position of seqp, going backwards in the direction from head->prev to
tail. If NUMDUPACK=3 such packets were counted within this loop, `seqp' points
to the last acknowledged packet of these, and the "if (done = NUMDUPACK)" block
is entered next.
The while-loop contained within that block in turn traverses the list backwards,
from head to tail; the position of `seqp' is saved in the variable `last_acked'.
For each packet not marked as `acked', a congestion event is triggered within
the loop, and pipe is decremented. The loop terminates when `seqp' has reached
`tail', whereupon tail is set to the position previously stored in `last_acked'.
Thus, between `last_acked' and the previous position of `tail',
 - pipe has been decremented earlier if the packet was marked as state 0 or 1;
 - pipe was decremented if the packet was not marked as acked.
That is, pipe has been decremented by the number of packets between `last_acked'
and the previous position of `tail'. As a consequence, pipe now again reflects
the number of packets which have not (yet) been acked between the new position
of tail (at `last_acked') and head->prev, or 0 if head=tail. The result is that
the BUG_ON condition in check_sanity will also not be triggered, hence the test
(3) is also redundant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   51 ------------------------------------------------
 1 files changed, 0 insertions(+), 51 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -34,51 +34,8 @@
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 static int ccid2_debug;
 #define ccid2_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid2_debug, format, ##a)
-
-static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
-{
-	int len = 0;
-	int pipe = 0;
-	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
-
-	/* there is data in the chain */
-	if (seqp != hctx->ccid2hctx_seqt) {
-		seqp = seqp->ccid2s_prev;
-		len++;
-		if (!seqp->ccid2s_acked)
-			pipe++;
-
-		while (seqp != hctx->ccid2hctx_seqt) {
-			struct ccid2_seq *prev = seqp->ccid2s_prev;
-
-			len++;
-			if (!prev->ccid2s_acked)
-				pipe++;
-
-			/* packets are sent sequentially */
-			BUG_ON(dccp_delta_seqno(seqp->ccid2s_seq,
-						prev->ccid2s_seq ) >= 0);
-			BUG_ON(time_before(seqp->ccid2s_sent,
-					   prev->ccid2s_sent));
-
-			seqp = prev;
-		}
-	}
-
-	BUG_ON(pipe != hctx->ccid2hctx_pipe);
-	ccid2_pr_debug("len of chain=%d\n", len);
-
-	do {
-		seqp = seqp->ccid2s_prev;
-		len++;
-	} while (seqp != hctx->ccid2hctx_seqh);
-
-	ccid2_pr_debug("total len=%d\n", len);
-	BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
-}
 #else
 #define ccid2_pr_debug(format, a...)
-#define ccid2_hc_tx_check_sanity(hctx)
 #endif
 
 static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
@@ -178,8 +135,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 
 	ccid2_pr_debug("RTO_EXPIRE\n");
 
-	ccid2_hc_tx_check_sanity(hctx);
-
 	/* back-off timer */
 	hctx->ccid2hctx_rto <<= 1;
 
@@ -202,7 +157,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hctx->ccid2hctx_rpseq	 = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
-	ccid2_hc_tx_check_sanity(hctx);
 
 	/* if we were blocked before, we may now send cwnd=1 packet */
 	if (sender_was_blocked)
@@ -317,7 +271,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 		}
 	} while (0);
 	ccid2_pr_debug("=====\n");
-	ccid2_hc_tx_check_sanity(hctx);
 #endif
 }
 
@@ -467,7 +420,6 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	int done = 0;
 	unsigned int maxincr = 0;
 
-	ccid2_hc_tx_check_sanity(hctx);
 	/* check reverse path congestion */
 	seqno = DCCP_SKB_CB(skb)->dccpd_seq;
 
@@ -644,7 +596,6 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
 	}
 
-	ccid2_hc_tx_check_sanity(hctx);
 done:
 	/* check if incoming Acks allow pending packets to be sent */
 	if (sender_was_blocked && !ccid2_cwnd_network_limited(hctx))
@@ -685,8 +636,6 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
 	INIT_LIST_HEAD(&hctx->ccid2hctx_av_chunks);
-
-	ccid2_hc_tx_check_sanity(hctx);
 	return 0;
 }
 
