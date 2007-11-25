From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 25 Nov 2007 17:30:11 +0000
Subject: [PATCH v2 1/1]
Message-Id: <20071125173011.GA11950@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After further experiments I am resubmitting this patch, using a higher RTT estimate
for the Close/CloseReq retransmission timer. 

The problem with the fallback RTT of 200ms is that it is lower than several link
types. I have experimented on (emulated) satellite links which have an RTT of ~600ms.
What then happens is that the retransmission of the Close happens too early: the
second Close(Req) is sent before the reply from the peer arrives; when the peer gets
the retransmitted Close(Req), it has already torn down its end and replies with a
Reset ("No Connection").

This leads to a lot of noise on the wire, depending on the actual link RTT there may be
several retranmissions with subsequent Resets ("No Connection"). Furthermore, several
technologies have link RTTs greater than 200ms: WiMax for instance (~700ms) or GPRS.

The patch now uses 3 seconds, which coincides with the usec value of DCCP_SANE_RTT_MAX
and the TCP initial RTO.

I think that this is a better solution: in the normal case we have no packet loss and
hence the timer will be killed before it expires. When packet loss occurs we have the
retranmission to ensure that the connection is eventually taken down.

Will be uploaded to the test tree early next week.

INTER-DIFF:
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -578,13 +578,14 @@ void dccp_send_close(struct sock *sk, co
 		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
 		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
 		 * state can be left. The initial timeout is 2 RTTs.
-		 * Since we do not always have a CCID with RTT measurements, we
-		 * use the fallback RTT from [RFC 4340, 3.4] (200ms).
+		 * Since RTT measurement is done by the CCIDs, there is no easy
+		 * way to get an RTT sample. The fallback RTT from RFC 4340, 3.4
+		 * is too low (200ms); we use a high value to avoid unnecessary
+		 * retransmissions when the link RTT is > 0.2 seconds.
+		 * FIXME: Let main module sample RTTs and use that instead.
 		 */
-		inet_csk(sk)->icsk_rto -				2 * usecs_to_jiffies(DCCP_FALLBACK_RTT);
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
+					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
 	} else
 		dccp_transmit_skb(sk, skb);
 }

-----------------------------> Patch v2 <--------------------------------------------
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
 net/dccp/output.c |   13 ++++++++++++-
 net/dccp/proto.c  |   18 ------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -985,24 +985,6 @@ adjudge_to_death:
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
@@ -574,7 +574,18 @@ void dccp_send_close(struct sock *sk, co
 		dccp_write_xmit(sk, 1);
 		dccp_skb_entail(sk, skb);
 		dccp_transmit_skb(sk, skb_clone(skb, prio));
-		/* FIXME do we need a retransmit timer here? */
+		/*
+		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
+		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
+		 * state can be left. The initial timeout is 2 RTTs.
+		 * Since RTT measurement is done by the CCIDs, there is no easy
+		 * way to get an RTT sample. The fallback RTT from RFC 4340, 3.4
+		 * is too low (200ms); we use a high value to avoid unnecessary
+		 * retransmissions when the link RTT is > 0.2 seconds.
+		 * FIXME: Let main module sample RTTs and use that instead.
+		 */
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
 	} else
 		dccp_transmit_skb(sk, skb);
 }
