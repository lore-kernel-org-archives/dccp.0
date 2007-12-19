From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:45 +0000
Subject: [PATCH 04/14] [ACKVEC]: Inlines for run length and state
Message-Id: <1198074355-18842-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides inlines for Ack Vector run length and state, which allow to wrap
several instances of the same code into function calls.

The unused function dccp_ackvec_print() (which also relied on the older
constants), has been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c      |   71 +++++++++++-------------------------------------
 net/dccp/ackvec.h      |   13 +++++++-
 net/dccp/ccids/ccid2.c |    7 ++---
 3 files changed, 30 insertions(+), 61 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -30,8 +30,17 @@
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
 #define DCCP_ACKVEC_STATE_NOT_RECEIVED	(3 << 6)
 
-#define DCCP_ACKVEC_STATE_MASK		0xC0 /* 11000000 */
-#define DCCP_ACKVEC_LEN_MASK		0x3F /* 00111111 */
+#define DCCPAV_MAX_RUNLEN	0x3F
+
+static inline u8 dccp_ackvec_runlen(const u8 *cell)
+{
+	return *cell & DCCPAV_MAX_RUNLEN;
+}
+
+static inline u8 dccp_ackvec_state(const u8 *cell)
+{
+	return *cell & ~DCCPAV_MAX_RUNLEN;
+}
 
 /** struct dccp_ackvec - Ack Vector main data structure
  *
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -135,7 +135,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	avr->avr_ack_ptr    = av->av_buf_head;
 	avr->avr_ack_ackno  = av->av_buf_ackno;
 	avr->avr_ack_nonce  = nonce;
-	avr->avr_ack_runlen = av->av_buf[av->av_buf_head] & DCCP_ACKVEC_LEN_MASK;
+	avr->avr_ack_runlen = dccp_ackvec_runlen(av->av_buf + av->av_buf_head);
 
 	dccp_ackvec_insert_avr(av, avr);
 
@@ -178,18 +178,6 @@ void dccp_ackvec_free(struct dccp_ackvec *av)
 	kmem_cache_free(dccp_ackvec_slab, av);
 }
 
-static inline u8 dccp_ackvec_state(const struct dccp_ackvec *av,
-				   const u32 index)
-{
-	return av->av_buf[index] & DCCP_ACKVEC_STATE_MASK;
-}
-
-static inline u8 dccp_ackvec_len(const struct dccp_ackvec *av,
-				 const u32 index)
-{
-	return av->av_buf[index] & DCCP_ACKVEC_LEN_MASK;
-}
-
 /*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
@@ -234,6 +222,8 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		    const u64 ackno, const u8 state)
 {
+	u8 *cur_head = av->av_buf + av->av_buf_head,
+	   *buf_end  = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 	/*
 	 * Check at the right places if the buffer is full, if it is, tell the
 	 * caller to start dropping packets till the HC-Sender acks our ACK
@@ -258,7 +248,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 
 	/* See if this is the first ackno being inserted */
 	if (av->av_vec_len = 0) {
-		av->av_buf[av->av_buf_head] = state;
+		*cur_head = state;
 		av->av_vec_len = 1;
 	} else if (after48(ackno, av->av_buf_ackno)) {
 		const u64 delta = dccp_delta_seqno(av->av_buf_ackno, ackno);
@@ -267,10 +257,9 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		 * Look if the state of this packet is the same as the
 		 * previous ackno and if so if we can bump the head len.
 		 */
-		if (delta = 1 &&
-		    dccp_ackvec_state(av, av->av_buf_head) = state &&
-		    dccp_ackvec_len(av, av->av_buf_head) < DCCP_ACKVEC_LEN_MASK)
-			av->av_buf[av->av_buf_head]++;
+		if (delta = 1 && dccp_ackvec_state(cur_head) = state &&
+		    dccp_ackvec_runlen(cur_head) < DCCPAV_MAX_RUNLEN)
+			*cur_head += 1;
 		else if (dccp_ackvec_set_buf_head_state(av, delta, state))
 			return -ENOBUFS;
 	} else {
@@ -283,21 +272,18 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->av_buf_ackno);
-		u32 index = av->av_buf_head;
 
 		while (1) {
-			const u8 len = dccp_ackvec_len(av, index);
-			const u8 state = dccp_ackvec_state(av, index);
+			const u8 len = dccp_ackvec_runlen(cur_head);
 			/*
 			 * valid packets not yet in av_buf have a reserved
 			 * entry, with a len equal to 0.
 			 */
-			if (state = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
-			    len = 0 && delta = 0) { /* Found our
-							 reserved seat! */
+			if (*cur_head = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
+			    delta = 0) {
 				dccp_pr_debug("Found %llu reserved seat!\n",
 					      (unsigned long long)ackno);
-				av->av_buf[index] = state;
+				*cur_head = state;
 				goto out;
 			}
 			/* len = 0 means one packet */
@@ -305,8 +291,8 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 				goto out_duplicate;
 
 			delta -= len + 1;
-			if (++index = DCCPAV_MAX_ACKVEC_LEN)
-				index = 0;
+			if (++cur_head = buf_end)
+				cur_head = av->av_buf;
 		}
 	}
 
@@ -321,31 +307,6 @@ out_duplicate:
 	return -EILSEQ;
 }
 
-#ifdef CONFIG_IP_DCCP_DEBUG
-void dccp_ackvector_print(const u64 ackno, const unsigned char *vector, int len)
-{
-	dccp_pr_debug_cat("ACK vector len=%d, ackno=%llu |", len,
-			 (unsigned long long)ackno);
-
-	while (len--) {
-		const u8 state = (*vector & DCCP_ACKVEC_STATE_MASK) >> 6;
-		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-
-		dccp_pr_debug_cat("%d,%d|", state, rl);
-		++vector;
-	}
-
-	dccp_pr_debug_cat("\n");
-}
-
-void dccp_ackvec_print(const struct dccp_ackvec *av)
-{
-	dccp_ackvector_print(av->av_buf_ackno,
-			     av->av_buf + av->av_buf_head,
-			     av->av_vec_len);
-}
-#endif
-
 static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 				     struct dccp_ackvec_record *avr)
 {
@@ -409,7 +370,7 @@ static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
 	 */
 	avr = list_entry(av->av_records.next, struct dccp_ackvec_record, avr_node);
 	while (i--) {
-		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
+		const u8 rl = dccp_ackvec_runlen(vector);
 		u64 ackno_end_rl;
 
 		dccp_set_seqno(&ackno_end_rl, *ackno - rl);
@@ -426,8 +387,8 @@ static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
 		break;
 found:
 		if (between48(avr->avr_ack_seqno, ackno_end_rl, *ackno)) {
-			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
-			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
+			if (dccp_ackvec_state(vector) !+					DCCP_ACKVEC_STATE_NOT_RECEIVED) {
 				dccp_pr_debug("%s ACK vector 0, len=%d, "
 					      "ack_seqno=%llu, ack_ackno=%llu, "
 					      "ACKED!\n",
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -578,8 +578,8 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 					 &vector, &veclen)) != -1) {
 		/* go through this ack vector */
 		while (veclen--) {
-			const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-			u64 ackno_end_rl = SUB48(ackno, rl);
+			u64 ackno_end_rl = SUB48(ackno,
+						 dccp_ackvec_runlen(vector));
 
 			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
 				       (unsigned long long)ackno,
@@ -602,8 +602,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = *vector &
-						 DCCP_ACKVEC_STATE_MASK;
+				const u8 state = dccp_ackvec_state(vector);
 
 				/* new packet received or marked */
 				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
-- 
1.5.3.GIT

