From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:21:30 +0000
Subject: [PATCH 11/11]: Disable setting timers for feature negotiation
Message-Id: <200709271521.30742@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Disable setting timers for feature negotiation

As a byproduct of restricting feature negotiation to connection setup, the feature-negotiation
retransmit timer is no longer required. All retransmission is now mapped onto the protocol-level
retransmission. To avoid interactions with the old code, this patch removes timer handling already.

Implementation details indicating why timers are no longer needed can be found on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c    |    6 ------
 net/dccp/options.c |   18 ------------------
 net/dccp/timer.c   |   12 ------------
 3 files changed, 36 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -737,12 +737,6 @@ int dccp_feat_confirm_recv(struct sock *
 			all_confirmed = 0;
 	}
 
-	/* fix re-transmit timer */
-	if (all_confirmed) {
-		dccp_pr_debug("clear feat negotiation timer %p\n", sk);
-		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
-	}
-
 	if (!found)
 		dccp_pr_debug("%s(%d, ...) never requested\n",
 			      dccp_feat_typename(type), feature);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -468,7 +468,6 @@ static int dccp_insert_feat_opt(struct s
 
 static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt, *next;
 	int change = 0;
@@ -509,23 +508,6 @@ static int dccp_insert_options_feat(stru
 		}
 	}
 
-	/* Retransmit timer.
-	 * If this is the master listening sock, we don't set a timer on it.  It
-	 * should be fine because if the dude doesn't receive our RESPONSE
-	 * [which will contain the CHANGE] he will send another REQUEST which
-	 * will "retrnasmit" the change.
-	 */
-	if (change && dp->dccps_role != DCCP_ROLE_LISTEN) {
-		dccp_pr_debug("reset feat negotiation timer %p\n", sk);
-
-		/* XXX don't reset the timer on re-transmissions.  I.e. reset it
-		 * only when sending new stuff i guess.  Currently the timer
-		 * never backs off because on re-transmission it just resets it!
-		 */
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
-	}
-
 	return 0;
 }
 
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -82,17 +82,6 @@ static void dccp_retransmit_timer(struct
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	/* retransmit timer is used for feature negotiation throughout
-	 * connection.  In this case, no packet is re-transmitted, but rather an
-	 * ack is generated and pending changes are placed into its options.
-	 */
-	if (sk->sk_send_head = NULL) {
-		dccp_pr_debug("feat negotiation retransmit timeout %p\n", sk);
-		if (sk->sk_state = DCCP_OPEN)
-			dccp_send_ack(sk);
-		goto backoff;
-	}
-
 	/*
 	 * sk->sk_send_head has to have one skb with
 	 * DCCP_SKB_CB(skb)->dccpd_type set to one of the retransmittable DCCP
@@ -131,7 +120,6 @@ static void dccp_retransmit_timer(struct
 		goto out;
 	}
 
-backoff:
 	icsk->icsk_backoff++;
 	icsk->icsk_retransmits++;
 
