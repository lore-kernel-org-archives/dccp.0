From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:36:59 +0000
Subject: [PATCH 36/43]: Shift the retransmit timer for active-close into output.c
Message-Id: <200704051636.59765@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Shift the retransmit timer for active-close into output.c

When performing active close, RFC 4340, 8.3. requires to retransmit the
Close/CloseReq with a backoff-retransmit timer starting at intially 2 RTTs.

This patch shifts the existing code for active-close retransmit timer
into output.c, so that the retransmit timer is started when the first
Close/CloseReq is sent. Previously, the timer was started when, after
releasing the socket in dccp_close(), the actively-closing side had not yet
reached the CLOSED/TIMEWAIT state.

The patch further reduces the initial timeout from 3 seconds to the required
2 RTTs, where - in absence of a known RTT - the fallback value specified in
RFC 4340, 3.4 is used.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   12 +++++++++++-
 net/dccp/proto.c  |   18 ------------------
 2 files changed, 11 insertions(+), 19 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -967,24 +967,6 @@ adjudge_to_death:
 	if (state != DCCP_CLOSED && sk->sk_state = DCCP_CLOSED)
 		goto out;
 
-	/*
-	 * The last release_sock may have processed the CLOSE or RESET
-	 * packet moving sock to CLOSED state, if not we have to fire
-	 * the CLOSE/CLOSEREQ retransmission timer, see "8.3. Termination"
-	 * in draft-ietf-dccp-spec-11. -acme
-	 */
-	if (sk->sk_state = DCCP_CLOSING) {
-		/* FIXME: should start at 2 * RTT */
-		/* Timer for repeating the CLOSE/CLOSEREQ until an answer. */
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto,
-					  DCCP_RTO_MAX);
-#if 0
-		/* Yeah, we should use sk->sk_prot->orphan_count, etc */
-		dccp_set_state(sk, DCCP_CLOSED);
-#endif
-	}
-
 	if (sk->sk_state = DCCP_CLOSED)
 		inet_csk_destroy_sock(sk);
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -566,7 +566,17 @@ void dccp_send_close(struct sock *sk, co
 		dccp_write_xmit(sk, 1);
 		dccp_skb_entail(sk, skb);
 		dccp_transmit_skb(sk, skb_clone(skb, prio));
-		/* FIXME do we need a retransmit timer here? */
+		/*
+		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
+		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
+		 * state can be left. The initial timeout is 2 RTTs.
+		 * Since we do not always have a CCID with RTT measurements, we
+		 * use the fallback RTT from [RFC 4340, 3.4] (200ms).
+		 */
+		inet_csk(sk)->icsk_rto +				2 * usecs_to_jiffies(DCCP_FALLBACK_RTT);
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
 	} else
 		dccp_transmit_skb(sk, skb);
 }
