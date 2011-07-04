From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:15 +0000
Subject: [PATCH 2/6] dccp: combine the functionality of enqeueing and cloning
Message-Id: <1309806079-21604-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Realising the following call pattern,
 * first dccp_entail() is called to enqueue a new skb and
 * then skb_clone() is called to transmit a clone of that skb,
this patch integrates both into the same function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -27,11 +27,13 @@ static inline void dccp_event_ack_sent(struct sock *sk)
 	inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 }
 
-static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
+/* enqueue @skb on sk_send_head for retransmission, return clone to send now */
+static struct sk_buff *dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	skb_set_owner_w(skb, sk);
 	WARN_ON(sk->sk_send_head);
 	sk->sk_send_head = skb;
+	return skb_clone(sk->sk_send_head, gfp_any());
 }
 
 /*
@@ -552,8 +554,7 @@ int dccp_connect(struct sock *sk)
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 
-	dccp_skb_entail(sk, skb);
-	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
+	dccp_transmit_skb(sk, dccp_skb_entail(sk, skb));
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
@@ -678,8 +679,7 @@ void dccp_send_close(struct sock *sk, const int active)
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSE;
 
 	if (active) {
-		dccp_skb_entail(sk, skb);
-		dccp_transmit_skb(sk, skb_clone(skb, prio));
+		skb = dccp_skb_entail(sk, skb);
 		/*
 		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
 		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
@@ -692,6 +692,6 @@ void dccp_send_close(struct sock *sk, const int active)
 		 */
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
-	} else
-		dccp_transmit_skb(sk, skb);
+	}
+	dccp_transmit_skb(sk, skb);
 }
