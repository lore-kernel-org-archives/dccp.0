From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 09:02:53 +0000
Subject: [PATCH 1/6] dccp: Allow to distinguish original and retransmitted packets
Message-Id: <1216976578-17767-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch allows the sender to distinguish original and retransmitted packets.
That is in particular needed for the retransmission of Request packets, since
 * the first packet uses ISS (generated in net/dccp/ipv?.c), and sets GSS = ISS;
 * all retransmitted packets use GSS' = GSS + 1, so that the n-th retransmitted
   packet has sequence number ISS + n (mod 48).

To add this support, the patch reorganises existing code in such a manner that
 * icsk_retransmits = 0     for the original packet and
 * icsk_retransmits = n > 0  for the n-th retransmitted packet
at the time dccp_transmit_skb() is called via dccp_retransmit_skb().

This patch is thanks to Wei Yongjun, who pointed this problem out, and to
Arnaldo for further discussion.

Further changes:
----------------
 * exploits that, since sk_send_head always contains the original skb (enqueued
   by dccp_entail()), skb_cloned() never evaluated to true;
 * removed the `skb' argument from dccp_retransmit_skb(), since sk_send_head
   is used for all retransmissions (the exception is client-Acks in PARTOPEN
   state, but these are not put onto the sk_send_head);
 * updated documentation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    2 +-
 net/dccp/output.c |   20 ++++++++++++++++----
 net/dccp/timer.c  |   20 ++++----------------
 3 files changed, 21 insertions(+), 21 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -226,7 +226,7 @@ static inline void dccp_csum_outgoing(struct sk_buff *skb)
 
 extern void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
-extern int  dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb);
+extern int  dccp_retransmit_skb(struct sock *sk);
 
 extern void dccp_send_ack(struct sock *sk);
 extern void dccp_reqsk_send_ack(struct sk_buff *sk, struct request_sock *rsk);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -284,14 +284,26 @@ void dccp_write_xmit(struct sock *sk, int block)
 	}
 }
 
-int dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
+/**
+ * dccp_retransmit_skb  -  Retransmit Request, Close, or CloseReq packets
+ * There are only four retransmittable packet types in DCCP:
+ * - Request  in client-REQUEST  state (sec. 8.1.1),
+ * - CloseReq in server-CLOSEREQ state (sec. 8.3),
+ * - Close    in   node-CLOSING  state (sec. 8.3),
+ * - Acks in client-PARTOPEN state (sec. 8.1.5, handled by dccp_delack_timer()).
+ * This function expects sk->sk_send_head to contain the original skb.
+ */
+int dccp_retransmit_skb(struct sock *sk)
 {
+	BUG_TRAP(sk->sk_send_head != NULL);
+
 	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk) != 0)
 		return -EHOSTUNREACH; /* Routing failure or similar. */
 
-	return dccp_transmit_skb(sk, (skb_cloned(skb) ?
-				      pskb_copy(skb, GFP_ATOMIC):
-				      skb_clone(skb, GFP_ATOMIC)));
+	/* this count is used to distinguish original and retransmitted skb */
+	inet_csk(sk)->icsk_retransmits++;
+
+	return dccp_transmit_skb(sk, skb_clone(sk->sk_send_head, GFP_ATOMIC));
 }
 
 struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -99,21 +99,11 @@ static void dccp_retransmit_timer(struct sock *sk)
 	}
 
 	/*
-	 * sk->sk_send_head has to have one skb with
-	 * DCCP_SKB_CB(skb)->dccpd_type set to one of the retransmittable DCCP
-	 * packet types. The only packets eligible for retransmission are:
-	 *	-- Requests in client-REQUEST  state (sec. 8.1.1)
-	 *	-- Acks     in client-PARTOPEN state (sec. 8.1.5)
-	 *	-- CloseReq in server-CLOSEREQ state (sec. 8.3)
-	 *	-- Close    in   node-CLOSING  state (sec. 8.3)                */
-	BUG_TRAP(sk->sk_send_head != NULL);
-
-	/*
 	 * More than than 4MSL (8 minutes) has passed, a RESET(aborted) was
 	 * sent, no need to retransmit, this sock is dead.
 	 */
 	if (dccp_write_timeout(sk))
-		goto out;
+		return;
 
 	/*
 	 * We want to know the number of packets retransmitted, not the
@@ -122,30 +112,28 @@ static void dccp_retransmit_timer(struct sock *sk)
 	if (icsk->icsk_retransmits = 0)
 		DCCP_INC_STATS_BH(DCCP_MIB_TIMEOUTS);
 
-	if (dccp_retransmit_skb(sk, sk->sk_send_head) < 0) {
+	if (dccp_retransmit_skb(sk) != 0) {
 		/*
 		 * Retransmission failed because of local congestion,
 		 * do not backoff.
 		 */
-		if (icsk->icsk_retransmits = 0)
+		if (--icsk->icsk_retransmits = 0)
 			icsk->icsk_retransmits = 1;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  min(icsk->icsk_rto,
 					      TCP_RESOURCE_PROBE_INTERVAL),
 					  DCCP_RTO_MAX);
-		goto out;
+		return;
 	}
 
 backoff:
 	icsk->icsk_backoff++;
-	icsk->icsk_retransmits++;
 
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, DCCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
 				  DCCP_RTO_MAX);
 	if (icsk->icsk_retransmits > sysctl_dccp_retries1)
 		__sk_dst_reset(sk);
-out:;
 }
 
 static void dccp_write_timer(unsigned long data)
