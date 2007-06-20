From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:55:56 +0000
Subject: [PATCH 3/5]: Parameter renaming
Message-Id: <200706201055.56699@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Parameter renaming

The parameter `seq' of dccp_send_sync() is in fact an acknowledgement number 
and not a sequence number - thus renamed by this patch into `ackno'.

Secondly, a `critical' warning is added when a Sync/SyncAck could not be sent.

Sanity: I have checked all other functions that are called in dccp_transmit_skb,
        there are no clashes with the use of dccpd_ack_seq; no other function is
        using this slot at the same time.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -69,7 +69,7 @@ static int dccp_transmit_skb(struct sock
 
 		case DCCP_PKT_SYNC:
 		case DCCP_PKT_SYNCACK:
-			ackno = dcb->dccpd_seq;
+			ackno = dcb->dccpd_ack_seq;
 			/* fall through */
 		default:
 			/*
@@ -507,7 +507,7 @@ void dccp_send_delayed_ack(struct sock *
 	sk_reset_timer(sk, &icsk->icsk_delack_timer, timeout);
 }
 
-void dccp_send_sync(struct sock *sk, const u64 seq,
+void dccp_send_sync(struct sock *sk, const u64 ackno,
 		    const enum dccp_pkt_type pkt_type)
 {
 	/*
@@ -517,14 +517,16 @@ void dccp_send_sync(struct sock *sk, con
 	 */
 	struct sk_buff *skb = alloc_skb(sk->sk_prot->max_header, GFP_ATOMIC);
 
-	if (skb = NULL)
+	if (skb = NULL) {
 		/* FIXME: how to make sure the sync is sent? */
+		DCCP_CRIT("could not send %s", dccp_packet_name(pkt_type));
 		return;
+	}
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, sk->sk_prot->max_header);
 	DCCP_SKB_CB(skb)->dccpd_type = pkt_type;
-	DCCP_SKB_CB(skb)->dccpd_seq = seq;
+	DCCP_SKB_CB(skb)->dccpd_ack_seq = ackno;
 
 	dccp_transmit_skb(sk, skb);
 }
