From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:48 +0000
Subject: [PATCH 07/14] [ACKVEC]: Unnecessary to parse Ack Vectors when clearing HC-receiver state
Message-Id: <1198074355-18842-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes code clearing Ack Vector state when it is acknowledged via an
Ack Vector by the peer. That code is redundant, since
 * the receiver always puts the full acknowledgment window (groups 2,3 in 11.4.2)
   into the Ack Vectors it sends; hence the HC-receiver is only interested in the
   highest state that the HC-sender received;
 * this means that the acknowledgment number on the (Data)Ack from the HC-sender
   is sufficient; and work done in parsing earlier state is not necessary, since
   the later state subsumes the  earlier one (see also RFC 4340, A.4).

Other (minor) changes:
 * uses  the suggestion made in the code comment, to traverse from oldest record
   to youngest - allowing faster hits when the list is large;

 * removed the unused argument variable `sk' from check_rcv_ackno;

 * renamed check_rcv_ackno => clear_state, since then it is clearer
   what is done by the function (also same name as in A.3 of RFC 4340);

 * the variable `ackno' now becomes unused in options.c, and therefore
   is now used for other (space-saving) purposes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c  |  114 ++++++++++------------------------------------------
 net/dccp/ackvec.h  |   17 +-------
 net/dccp/input.c   |    4 +-
 net/dccp/options.c |   12 ++----
 4 files changed, 30 insertions(+), 117 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -102,13 +102,8 @@ extern void dccp_ackvec_free(struct dccp_ackvec *av);
 extern int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 			   const u64 ackno, const u8 state);
 
-extern void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
-					struct sock *sk, const u64 ackno);
-extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-			     u64 *ackno, const u8 opt,
-			     const u8 *value, const u8 len);
-
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
+extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
 
 static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
 {
@@ -139,18 +134,10 @@ static inline int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 	return -1;
 }
 
-static inline void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
-					       struct sock *sk, const u64 ackno)
+static inline void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
 {
 }
 
-static inline int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-				    const u64 *ackno, const u8 opt,
-				    const u8 *value, const u8 len)
-{
-	return -1;
-}
-
 static inline int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 nonce)
 {
 	return -1;
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -86,6 +86,24 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 	return 0;
 }
 
+static struct dccp_ackvec_record *dccp_ackvec_lookup(struct list_head *av_list,
+						     const u64 ackno)
+{
+	struct dccp_ackvec_record *avr;
+	/*
+	 * Exploit that records are inserted in descending order of sequence
+	 * number, start with the oldest record first. If @ackno is `before'
+	 * the earliest ack_ackno, the packet is too old (or is a duplicate).
+	 */
+	list_for_each_entry_reverse(avr, av_list, avr_node) {
+		if (avr->avr_ack_seqno = ackno)
+			return avr;
+		if (before48(ackno, avr->avr_ack_seqno))
+			break;
+	}
+	return NULL;
+}
+
 /*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
@@ -234,101 +252,13 @@ static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 	}
 }
 
-void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av, struct sock *sk,
-				 const u64 ackno)
-{
-	struct dccp_ackvec_record *avr;
-
-	/*
-	 * If we traverse backwards, it should be faster when we have large
-	 * windows. We will be receiving ACKs for stuff we sent a while back
-	 * -sorbo.
-	 */
-	list_for_each_entry_reverse(avr, &av->av_records, avr_node) {
-		if (ackno = avr->avr_ack_seqno) {
-			dccp_pr_debug("%s ACK packet 0, len=%d, ack_seqno=%llu, "
-				      "ack_ackno=%llu, ACKED!\n",
-				      dccp_role(sk), avr->avr_ack_runlen,
-				      (unsigned long long)avr->avr_ack_seqno,
-				      (unsigned long long)avr->avr_ack_ackno);
-			dccp_ackvec_throw_record(av, avr);
-			break;
-		} else if (avr->avr_ack_seqno > ackno)
-			break; /* old news */
-	}
-}
-
-static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
-					    struct sock *sk, u64 *ackno,
-					    const unsigned char len,
-					    const unsigned char *vector)
+void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
 {
-	unsigned char i;
 	struct dccp_ackvec_record *avr;
 
-	/* Check if we actually sent an ACK vector */
-	if (list_empty(&av->av_records))
-		return;
-
-	i = len;
-	/*
-	 * XXX
-	 * I think it might be more efficient to work backwards. See comment on
-	 * rcv_ackno. -sorbo.
-	 */
-	avr = list_entry(av->av_records.next, struct dccp_ackvec_record, avr_node);
-	while (i--) {
-		const u8 rl = dccp_ackvec_runlen(vector);
-		u64 ackno_end_rl;
-
-		dccp_set_seqno(&ackno_end_rl, *ackno - rl);
-
-		/*
-		 * If our AVR sequence number is greater than the ack, go
-		 * forward in the AVR list until it is not so.
-		 */
-		list_for_each_entry_from(avr, &av->av_records, avr_node) {
-			if (!after48(avr->avr_ack_seqno, *ackno))
-				goto found;
-		}
-		/* End of the av_records list, not found, exit */
-		break;
-found:
-		if (between48(avr->avr_ack_seqno, ackno_end_rl, *ackno)) {
-			if (dccp_ackvec_state(vector) !-					DCCP_ACKVEC_STATE_NOT_RECEIVED) {
-				dccp_pr_debug("%s ACK vector 0, len=%d, "
-					      "ack_seqno=%llu, ack_ackno=%llu, "
-					      "ACKED!\n",
-					      dccp_role(sk), len,
-					      (unsigned long long)
-					      avr->avr_ack_seqno,
-					      (unsigned long long)
-					      avr->avr_ack_ackno);
-				dccp_ackvec_throw_record(av, avr);
-				break;
-			}
-			/*
-			 * If it wasn't received, continue scanning... we might
-			 * find another one.
-			 */
-		}
-
-		dccp_set_seqno(ackno, ackno_end_rl - 1);
-		++vector;
-	}
-}
-
-int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-		      u64 *ackno, const u8 opt, const u8 *value, const u8 len)
-{
-	if (len > DCCP_SINGLE_OPT_MAXLEN)
-		return -1;
-
-	/* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
-	dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec, sk,
-					ackno, len, value);
-	return 0;
+	avr = dccp_ackvec_lookup(&av->av_records, ackno);
+	if (avr != NULL)
+		dccp_ackvec_throw_record(av, avr);
 }
 
 int __init dccp_ackvec_init(void)
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -164,8 +164,8 @@ static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	if (dp->dccps_hc_rx_ackvec != NULL)
-		dccp_ackvec_check_rcv_ackno(dp->dccps_hc_rx_ackvec, sk,
-					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
+		dccp_ackvec_clear_state(dp->dccps_hc_rx_ackvec,
+					DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
 
 static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -138,9 +138,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_ACK_VECTOR_1:
 			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
-			if (dp->dccps_hc_rx_ackvec != NULL &&
-			    dccp_ackvec_parse(sk, skb, &ackno, opt, value, len))
-				goto out_invalid_option;
+			dccp_pr_debug("%s Ack Vector (len=%u)\n", dccp_role(sk),
+				      len);
 			break;
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
@@ -166,8 +165,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			}
 			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
 				      dccp_role(sk), ntohl(opt_val),
-				      (unsigned long long)
-				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
+				      (unsigned long long)ackno);
 			/* schedule an Ack in case this sender is quiescent */
 			dccp_schedule_ack(sk);
 			break;
@@ -181,9 +179,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
 				      "ackno=%llu", dccp_role(sk),
 				      opt_recv->dccpor_timestamp_echo,
-				      len + 2,
-				      (unsigned long long)
-				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
+				      len + 2, (unsigned long long)ackno);
 
 			value += 4;
 
-- 
1.5.3.GIT

