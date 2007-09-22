From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 21:10:33 +0000
Subject: [PATCH 6/6] [DCCP]: Parameter renaming
Message-Id: <20070922211033.GK4887@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The parameter `seq' of dccp_send_sync() is in fact an acknowledgement number
and not a sequence number - thus renamed by this patch into `ackno'.

Secondly, a `critical' warning is added when a Sync/SyncAck could not be sent.

Sanity: I have checked all other functions that are called in dccp_transmit_skb,
        there are no clashes with the use of dccpd_ack_seq; no other function is
        using this slot at the same time.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/output.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index c8d843e..6e23d5b 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -69,7 +69,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		case DCCP_PKT_SYNC:
 		case DCCP_PKT_SYNCACK:
-			ackno = dcb->dccpd_seq;
+			ackno = dcb->dccpd_ack_seq;
 			/* fall through */
 		default:
 			/*
@@ -507,7 +507,7 @@ void dccp_send_delayed_ack(struct sock *sk)
 	sk_reset_timer(sk, &icsk->icsk_delack_timer, timeout);
 }
 
-void dccp_send_sync(struct sock *sk, const u64 seq,
+void dccp_send_sync(struct sock *sk, const u64 ackno,
 		    const enum dccp_pkt_type pkt_type)
 {
 	/*
@@ -517,14 +517,16 @@ void dccp_send_sync(struct sock *sk, const u64 seq,
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
-- 
1.5.3.1

