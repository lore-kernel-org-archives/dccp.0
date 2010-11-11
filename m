From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 06:07:32 +0000
Subject: [PATCH 2/3] dccp ccid-2: Separate internals of Ack Vectors from option-parsing code
Message-Id: <1289455653-5463-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch
 * separates Ack Vector housekeeping code from option-insertion code;
 * shifts option-specific code from ackvec.c into options.c;
 * introduces a dedicated routine to take care of the Ack Vector records;
 * simplifies the dccp_ackvec_insert_avr() routine: the BUG_ON was redundant,
   since the list is automatically arranged in descending order of ack_seqno.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.h  |    2 +-
 net/dccp/ackvec.c  |  100 +++++++++------------------------------------------
 net/dccp/options.c |   60 +++++++++++++++++++++++++++++++
 3 files changed, 79 insertions(+), 83 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -111,7 +111,7 @@ extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 			     u64 *ackno, const u8 opt,
 			     const u8 *value, const u8 len);
 
-extern int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb);
+extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 
 static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
 {
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -52,99 +52,35 @@ void dccp_ackvec_free(struct dccp_ackvec *av)
 	}
 }
 
-static void dccp_ackvec_insert_avr(struct dccp_ackvec *av,
-				   struct dccp_ackvec_record *avr)
-{
-	/*
-	 * AVRs are sorted by seqno. Since we are sending them in order, we
-	 * just add the AVR at the head of the list.
-	 * -sorbo.
-	 */
-	if (!list_empty(&av->av_records)) {
-		const struct dccp_ackvec_record *head -					list_entry(av->av_records.next,
-						   struct dccp_ackvec_record,
-						   avr_node);
-		BUG_ON(before48(avr->avr_ack_seqno, head->avr_ack_seqno));
-	}
-
-	list_add(&avr->avr_node, &av->av_records);
-}
-
-int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
+/**
+ * dccp_ackvec_update_records  -  Record information about sent Ack Vectors
+ * @av:		Ack Vector records to update
+ * @seqno:	Sequence number of the packet carrying the Ack Vector just sent
+ * @nonce_sum:	The sum of all buffer nonces contained in the Ack Vector
+ */
+int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
-	/* Figure out how many options do we need to represent the ackvec */
-	const u8 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts;
-	u8 i, nonce = 0;
-	const unsigned char *tail, *from;
-	unsigned char *to;
 	struct dccp_ackvec_record *avr;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-		return -1;
-
 	avr = kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
 	if (avr = NULL)
-		return -1;
-
-	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
-
-	to   = skb_push(skb, len);
-	len  = av->av_vec_len;
-	from = av->av_buf + av->av_buf_head;
-	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
-
-	for (i = 0; i < nr_opts; ++i) {
-		int copylen = len;
-
-		if (len > DCCP_SINGLE_OPT_MAXLEN)
-			copylen = DCCP_SINGLE_OPT_MAXLEN;
-
-		/*
-		 * RFC 4340, 12.2: Encode the Nonce Echo for this Ack Vector via
-		 * its type; ack_nonce is the sum of all individual buf_nonce's.
-		 */
-		nonce ^= av->av_buf_nonce[i];
-
-		*to++ = DCCPO_ACK_VECTOR_0 + av->av_buf_nonce[i];
-		*to++ = copylen + 2;
-
-		/* Check if buf_head wraps */
-		if (from + copylen > tail) {
-			const u16 tailsize = tail - from;
-
-			memcpy(to, from, tailsize);
-			to	+= tailsize;
-			len	-= tailsize;
-			copylen	-= tailsize;
-			from	= av->av_buf;
-		}
-
-		memcpy(to, from, copylen);
-		from += copylen;
-		to   += copylen;
-		len  -= copylen;
-	}
+		return -ENOBUFS;
 
-	/*
-	 * Each sent Ack Vector is recorded in the list, as per A.2 of RFC 4340.
-	 */
-	avr->avr_ack_seqno  = DCCP_SKB_CB(skb)->dccpd_seq;
+	avr->avr_ack_seqno  = seqno;
 	avr->avr_ack_ptr    = av->av_buf_head;
 	avr->avr_ack_ackno  = av->av_buf_ackno;
-	avr->avr_ack_nonce  = nonce;
+	avr->avr_ack_nonce  = nonce_sum;
 	avr->avr_ack_runlen = dccp_ackvec_runlen(av->av_buf + av->av_buf_head);
+	/*
+	 * Since GSS is incremented for each packet, the list is automatically
+	 * arranged in descending order of @ack_seqno.
+	 */
+	list_add(&avr->avr_node, &av->av_records);
 
-	dccp_ackvec_insert_avr(av, avr);
-
-	dccp_pr_debug("%s ACK Vector 0, len=%d, ack_seqno=%llu, "
-		      "ack_ackno=%llu\n",
-		      dccp_role(sk), avr->avr_ack_runlen,
+	dccp_pr_debug("Added Vector, ack_seqno=%llu, ack_ackno=%llu (rl=%u)\n",
 		      (unsigned long long)avr->avr_ack_seqno,
-		      (unsigned long long)avr->avr_ack_ackno);
+		      (unsigned long long)avr->avr_ack_ackno,
+		      avr->avr_ack_runlen);
 	return 0;
 }
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -425,6 +425,66 @@ static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
 	return 0;
 }
 
+static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	/* Figure out how many options do we need to represent the ackvec */
+	const u8 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
+	u16 len = av->av_vec_len + 2 * nr_opts;
+	u8 i, nonce = 0;
+	const unsigned char *tail, *from;
+	unsigned char *to;
+
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
+		return -1;
+
+	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
+
+	to   = skb_push(skb, len);
+	len  = av->av_vec_len;
+	from = av->av_buf + av->av_buf_head;
+	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
+
+	for (i = 0; i < nr_opts; ++i) {
+		int copylen = len;
+
+		if (len > DCCP_SINGLE_OPT_MAXLEN)
+			copylen = DCCP_SINGLE_OPT_MAXLEN;
+
+		/*
+		 * RFC 4340, 12.2: Encode the Nonce Echo for this Ack Vector via
+		 * its type; ack_nonce is the sum of all individual buf_nonce's.
+		 */
+		nonce ^= av->av_buf_nonce[i];
+
+		*to++ = DCCPO_ACK_VECTOR_0 + av->av_buf_nonce[i];
+		*to++ = copylen + 2;
+
+		/* Check if buf_head wraps */
+		if (from + copylen > tail) {
+			const u16 tailsize = tail - from;
+
+			memcpy(to, from, tailsize);
+			to	+= tailsize;
+			len	-= tailsize;
+			copylen	-= tailsize;
+			from	= av->av_buf;
+		}
+
+		memcpy(to, from, copylen);
+		from += copylen;
+		to   += copylen;
+		len  -= copylen;
+	}
+	/*
+	 * Each sent Ack Vector is recorded in the list, as per A.2 of RFC 4340.
+	 */
+	if (dccp_ackvec_update_records(av, DCCP_SKB_CB(skb)->dccpd_seq, nonce))
+		return -ENOBUFS;
+	return 0;
+}
+
 /**
  * dccp_insert_option_mandatory  -  Mandatory option (5.8.2)
  * Note that since we are using skb_push, this function needs to be called
