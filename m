From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:43 +0000
Subject: [PATCH 02/14] [ACKVEC]: Update Ack Vector fields
Message-Id: <1198074355-18842-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch updates the fields used by the Ack Vector structures:

 * buf_tail was missing and has been added as struct member (support for
   updating this field follows in subsequent patches);

 * the buf_nonce is now an array, each element covering up to 253 bytes of
   buffer state - this simplifies computing the ECN nonce for large Ack Vectors.

In particular, there are the following changes:

 * since buf_nonce and buffer size use the same number, introduced a constant to
   set the maximum number of Ack Vectors in the buffer (tried Kconfig, but with
   low Ack Ratio rates, a size of 1 is fully sufficient, 2 seems to work for a
   wide range of cases; Kconfig remains an option for later);

 * removed the field dccpav_ack_nonce from struct dccp_ackvec, since this is
   already redundantly stored in the `dccpavr_ack_nonce' (Ack Vector record);

 * replaced semantics of dccpavr_sent_len with dccpavr_ack_runlen, since the
   code needs to be able to remember the old run length;

 * also updated the documentation on sending Ack Vectors, it was outdated
   (ack_runlen was not considered);

 * all sequence numbers now truncated to 48 bits (the assignment of 2^48 to
   buf_ackno in dccp_ackvec_alloc() has been removed, since dccp_ackvec_add()
   overrides this value each time a new packet is added to the buffer).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   48 ++++++++++++++++----------------
 net/dccp/ackvec.h |   77 +++++++++++++++++++++++++++--------------------------
 2 files changed, 63 insertions(+), 62 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -18,8 +18,14 @@
 
 /* maximum size of a single TLV-encoded option (sans type/len bytes) */
 #define DCCP_SINGLE_OPT_MAXLEN  253
-/* We can spread an ack vector across multiple options */
-#define DCCP_MAX_ACKVEC_LEN (DCCP_SINGLE_OPT_MAXLEN * 2)
+/*
+ * Ack Vector buffer space is static, in multiples of %DCCP_SINGLE_OPT_MAXLEN,
+ * the maximum size of a single Ack Vector. Setting %DCCPAV_NUM_ACKVECS to 1
+ * will be sufficient for most cases of low Ack Ratios, using a value of 2 gives
+ * more headroom if Ack Ratio is higher or when the sender acknowledges slowly.
+ */
+#define DCCPAV_NUM_ACKVECS	2
+#define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
@@ -28,58 +34,53 @@
 #define DCCP_ACKVEC_STATE_MASK		0xC0 /* 11000000 */
 #define DCCP_ACKVEC_LEN_MASK		0x3F /* 00111111 */
 
-/** struct dccp_ackvec - ack vector
- *
- * This data structure is the one defined in RFC 4340, Appendix A.
- *
- * @av_buf_head - circular buffer head
- * @av_buf_tail - circular buffer tail
- * @av_buf_ackno - ack # of the most recent packet acknowledgeable in the
- *		       buffer (i.e. %av_buf_head)
- * @av_buf_nonce - the one-bit sum of the ECN Nonces on all packets acked
- * 		       by the buffer with State 0
+/** struct dccp_ackvec - Ack Vector main data structure
  *
- * Additionally, the HC-Receiver must keep some information about the
- * Ack Vectors it has recently sent. For each packet sent carrying an
- * Ack Vector, it remembers four variables:
+ * This implements a fixed-size circular buffer within an array and is largely
+ * based on Appendix A of RFC 4340.
  *
- * @av_records - list of dccp_ackvec_record
- * @av_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
- *
- * @av_time - the time in usecs
- * @av_buf - circular buffer of acknowledgeable packets
+ * @av_buf:	   circular buffer storage area
+ * @av_buf_head:   head index; begin of live portion in @av_buf
+ * @av_buf_tail:   tail index; first index _after_ the live portion in @av_buf
+ * @av_buf_ackno:  highest seqno of acknowledgeable packet recorded in @av_buf
+ * @av_buf_nonce:  ECN nonce sums, each covering subsequent segments of up to
+ *		   %DCCP_SINGLE_OPT_MAXLEN cells in the live portion of @av_buf
+ * @av_records:	   list of %dccp_ackvec_record (Ack Vectors sent previously)
+ * @av_time:	   the time in usecs
+ * @av_veclen:	   length of the live portion of @av_buf
  */
 struct dccp_ackvec {
-	u64			av_buf_ackno;
+	u8			av_buf[DCCPAV_MAX_ACKVEC_LEN];
+	u16			av_buf_head;
+	u16			av_buf_tail;
+	u64			av_buf_ackno:48;
+	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
 	struct list_head	av_records;
 	ktime_t			av_time;
-	u16			av_buf_head;
 	u16			av_vec_len;
-	u8			av_buf_nonce;
-	u8			av_ack_nonce;
-	u8			av_buf[DCCP_MAX_ACKVEC_LEN];
 };
 
-/** struct dccp_ackvec_record - ack vector record
+/** struct dccp_ackvec_record - Records information about sent Ack Vectors
  *
- * ACK vector record as defined in Appendix A of spec.
+ * These list entries define the additional information which the HC-Receiver
+ * keeps about recently-sent Ack Vectors; again refer to RFC 4340, Appendix A.
  *
- * The list is sorted by avr_ack_seqno
+ * @avr_node:	    the list node in @av_records
+ * @avr_ack_seqno:  sequence number of the packet the Ack Vector was sent on
+ * @avr_ack_ackno:  the Ack number that this record/Ack Vector refers to
+ * @avr_ack_ptr:    pointer into @av_buf where this record starts
+ * @avr_ack_runlen: run length of @avr_ack_ptr at the time of sending
+ * @avr_ack_nonce:  the sum of @av_buf_nonce's at the time this record was sent
  *
- * @avr_node - node in av_records
- * @avr_ack_seqno - sequence number of the packet this record was sent on
- * @avr_ack_ackno - sequence number being acknowledged
- * @avr_ack_ptr - pointer into av_buf where this record starts
- * @avr_ack_nonce - av_ack_nonce at the time this record was sent
- * @avr_sent_len - lenght of the record in av_buf
+ * The list as a whole is sorted in descending order by @avr_ack_seqno.
  */
 struct dccp_ackvec_record {
 	struct list_head avr_node;
-	u64		 avr_ack_seqno;
-	u64		 avr_ack_ackno;
+	u64		 avr_ack_seqno:48;
+	u64		 avr_ack_ackno:48;
 	u16		 avr_ack_ptr;
-	u16		 avr_sent_len;
-	u8		 avr_ack_nonce;
+	u8		 avr_ack_runlen;
+	u8		 avr_ack_nonce:1;
 };
 
 struct sock;
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -69,7 +69,8 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	/* Figure out how many options do we need to represent the ackvec */
 	const u16 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts, i;
+	u16 len = av->av_vec_len + 2 * nr_opts;
+	u8 i, nonce = 0;
 	u32 elapsed_time;
 	const unsigned char *tail, *from;
 	unsigned char *to;
@@ -102,7 +103,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	to   = skb_push(skb, len);
 	len  = av->av_vec_len;
 	from = av->av_buf + av->av_buf_head;
-	tail = av->av_buf + DCCP_MAX_ACKVEC_LEN;
+	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 
 	for (i = 0; i < nr_opts; ++i) {
 		int copylen = len;
@@ -110,7 +111,13 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 		if (len > DCCP_SINGLE_OPT_MAXLEN)
 			copylen = DCCP_SINGLE_OPT_MAXLEN;
 
-		*to++ = DCCPO_ACK_VECTOR_0;
+		/*
+		 * RFC 4340, 12.2: Encode the Nonce Echo for this Ack Vector via
+		 * its type; ack_nonce is the sum of all individual buf_nonce's.
+		 */
+		nonce ^= av->av_buf_nonce[i];
+
+		*to++ = DCCPO_ACK_VECTOR_0 + av->av_buf_nonce[i];
 		*to++ = copylen + 2;
 
 		/* Check if buf_head wraps */
@@ -131,25 +138,19 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/*
-	 *	From RFC 4340, A.2:
-	 *
-	 *	For each acknowledgement it sends, the HC-Receiver will add an
-	 *	acknowledgement record.  ack_seqno will equal the HC-Receiver
-	 *	sequence number it used for the ack packet; ack_ptr will equal
-	 *	buf_head; ack_ackno will equal buf_ackno; and ack_nonce will
-	 *	equal buf_nonce.
+	 * Each sent Ack Vector is recorded in the list, as per A.2 of RFC 4340.
 	 */
-	avr->avr_ack_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-	avr->avr_ack_ptr   = av->av_buf_head;
-	avr->avr_ack_ackno = av->av_buf_ackno;
-	avr->avr_ack_nonce = av->av_buf_nonce;
-	avr->avr_sent_len  = av->av_vec_len;
+	avr->avr_ack_seqno  = DCCP_SKB_CB(skb)->dccpd_seq;
+	avr->avr_ack_ptr    = av->av_buf_head;
+	avr->avr_ack_ackno  = av->av_buf_ackno;
+	avr->avr_ack_nonce  = nonce;
+	avr->avr_ack_runlen = av->av_buf[av->av_buf_head] & DCCP_ACKVEC_LEN_MASK;
 
 	dccp_ackvec_insert_avr(av, avr);
 
 	dccp_pr_debug("%s ACK Vector 0, len=%d, ack_seqno=%llu, "
 		      "ack_ackno=%llu\n",
-		      dccp_role(sk), avr->avr_sent_len,
+		      dccp_role(sk), avr->avr_ack_runlen,
 		      (unsigned long long)avr->avr_ack_seqno,
 		      (unsigned long long)avr->avr_ack_ackno);
 	return 0;
@@ -160,11 +161,10 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
 
 	if (av != NULL) {
-		av->av_buf_head	 = DCCP_MAX_ACKVEC_LEN - 1;
-		av->av_buf_ackno = UINT48_MAX + 1;
-		av->av_buf_nonce = 0;
+		av->av_buf_head	 = DCCPAV_MAX_ACKVEC_LEN - 1;
 		av->av_time	 = ktime_set(0, 0);
 		av->av_vec_len	 = 0;
+		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
 		INIT_LIST_HEAD(&av->av_records);
 	}
 
@@ -212,7 +212,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 	unsigned int gap;
 	long new_head;
 
-	if (av->av_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
+	if (av->av_vec_len + packets > DCCPAV_MAX_ACKVEC_LEN)
 		return -ENOBUFS;
 
 	gap	 = packets - 1;
@@ -224,7 +224,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 			       gap + new_head + 1);
 			gap = -new_head;
 		}
-		new_head += DCCP_MAX_ACKVEC_LEN;
+		new_head += DCCPAV_MAX_ACKVEC_LEN;
 	}
 
 	av->av_buf_head = new_head;
@@ -315,7 +315,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 				goto out_duplicate;
 
 			delta -= len + 1;
-			if (++index = DCCP_MAX_ACKVEC_LEN)
+			if (++index = DCCPAV_MAX_ACKVEC_LEN)
 				index = 0;
 		}
 	}
@@ -366,7 +366,7 @@ static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 	if (av->av_buf_head <= avr->avr_ack_ptr)
 		av->av_vec_len = avr->avr_ack_ptr - av->av_buf_head;
 	else
-		av->av_vec_len = DCCP_MAX_ACKVEC_LEN - 1 -
+		av->av_vec_len = DCCPAV_MAX_ACKVEC_LEN - 1 -
 				 av->av_buf_head + avr->avr_ack_ptr;
 
 	/* free records */
@@ -390,7 +390,7 @@ void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av, struct sock *sk,
 		if (ackno = avr->avr_ack_seqno) {
 			dccp_pr_debug("%s ACK packet 0, len=%d, ack_seqno=%llu, "
 				      "ack_ackno=%llu, ACKED!\n",
-				      dccp_role(sk), 1,
+				      dccp_role(sk), avr->avr_ack_runlen,
 				      (unsigned long long)avr->avr_ack_seqno,
 				      (unsigned long long)avr->avr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
