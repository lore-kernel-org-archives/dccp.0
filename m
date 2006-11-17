From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:03:02 +0000
Subject: [PATCH 5/7]: Migration to DCCP_WARN_ON
Message-Id: <200611171803.02312@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Use DCCP_WARN_ON

This patch replaces the built-in WARN_ON with the more
informative DCCP_WARN_ON; same principle as preceding patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c      |    2 +-
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    4 ++--
 net/dccp/feat.c        |    3 ++-
 net/dccp/output.c      |    4 ++--
 net/dccp/proto.c       |    2 +-
 6 files changed, 9 insertions(+), 8 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -40,7 +40,7 @@ static void dccp_ackvec_record_delete(st
 	if (unlikely(avr = NULL))
 		return;
 	/* Check if deleting a linked record */
-	WARN_ON(!list_empty(&avr->dccpavr_node));
+	DCCP_WARN_ON(!list_empty(&avr->dccpavr_node));
 	kmem_cache_free(dccp_ackvec_record_slab, avr);
 }
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -177,7 +177,7 @@ static void ccid2_change_l_ack_ratio(str
 	}
 
 	ccid2_pr_debug("changing local ack ratio to %d\n", val);
-	WARN_ON(val <= 0);
+	DCCP_WARN_ON(val <= 0);
 	dp->dccps_l_ack_ratio = val;
 }
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -96,7 +96,7 @@ static void ccid3_hc_tx_set_state(struct
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
 		       ccid3_tx_state_name(state));
-	WARN_ON(state = oldstate);
+	DCCP_WARN_ON(state = oldstate);
 	hctx->ccid3hctx_state = state;
 }
 
@@ -692,7 +692,7 @@ static void ccid3_hc_rx_set_state(struct
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
 		       ccid3_rx_state_name(state));
-	WARN_ON(state = oldstate);
+	DCCP_WARN_ON(state = oldstate);
 	hcrx->ccid3hcrx_state = state;
 }
 
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -169,7 +169,8 @@ static int dccp_feat_reconcile(struct so
 			break;
 
 		default:
-			WARN_ON(1); /* XXX implement res */
+			DCCP_BUG("Fell through, feat=%d", opt->dccpop_feat);
+			/* XXX implement res */
 			return -EFAULT;
 		}
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -29,7 +29,7 @@ static inline void dccp_event_ack_sent(s
 static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	skb_set_owner_w(skb, sk);
-	WARN_ON(sk->sk_send_head);
+	DCCP_WARN_ON(sk->sk_send_head);
 	sk->sk_send_head = skb;
 }
 
@@ -76,7 +76,7 @@ static int dccp_transmit_skb(struct sock
 			 * Only data packets should come through with skb->sk
 			 * set.
 			 */
-			WARN_ON(skb->sk);
+			DCCP_WARN_ON(skb->sk);
 			skb_set_owner_w(skb, sk);
 			break;
 		}
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -62,7 +62,7 @@ void dccp_set_state(struct sock *sk, con
 	dccp_pr_debug("%s(%p) %-10.10s -> %s\n",
 		      dccp_role(sk), sk,
 		      dccp_state_name(oldstate), dccp_state_name(state));
-	WARN_ON(state = oldstate);
+	DCCP_WARN_ON(state = oldstate);
 
 	switch (state) {
 	case DCCP_OPEN:
