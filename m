From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:05:55 +0000
Subject: [PATCH 02/12] [DCCP]: Shift the retransmit timer for active-close into output.c
Message-Id: <1197558365-31134-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

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
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/output.c |   13 ++++++++++++-
 net/dccp/proto.c  |   18 ------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index 7caa7f5..e97584a 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -574,7 +574,18 @@ void dccp_send_close(struct sock *sk, const int active)
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
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 60f40ec..8a73c8f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -996,24 +996,6 @@ adjudge_to_death:
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
 
-- 
1.5.3.4

