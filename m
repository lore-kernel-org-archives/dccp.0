From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 06:07:31 +0000
Subject: [PATCH 1/3] dccp ccid-2: Ack Vector interface clean-up
Message-Id: <1289455653-5463-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch brings the Ack Vector interface up to date. Its main purpose is
to lay the basis for the subsequent patches of this set, which will use the
new data structure fields and routines.

There are no real algorithmic changes, rather an adaptation:

 (1) Replaced the static Ack Vector size (2) with a #define so that it can
     be adapted (with low loss / Ack Ratio, a value of 1 works, so 2 seems
     to be sufficient for the moment) and added a solution so that computing
     the ECN nonce will continue to work - even with larger Ack Vectors.

 (2) Replaced the #defines for Ack Vector states with a complete enum.

 (3) Replaced #defines to compute Ack Vector length and state with general
     purpose routines (inlines), and updated code to use these.

 (4) Added a `tail' field (conversion to circular buffer in subsequent patch).

 (5) Updated the (outdated) documentation for Ack Vector struct.

 (6) All sequence number containers now trimmed to 48 bits.

 (7) Removal of unused bits:
     * removed dccpav_ack_nonce from struct dccp_ackvec, since this is already
       redundantly stored in the `dccpavr_ack_nonce' (of Ack Vector record);
     * removed Elapsed Time for Ack Vectors (it was nowhere used);
     * replaced semantics of dccpavr_sent_len with dccpavr_ack_runlen, since
       the code needs to be able to remember the old run length;
     * reduced the de-/allocation routines (redundant / duplicate tests).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.h      |  103 +++++++++++++++-------------
 net/dccp/ackvec.c      |  178 +++++++++++++++++-------------------------------
 net/dccp/ccids/ccid2.c |   13 ++--
 net/dccp/input.c       |    6 +-
 net/dccp/options.c     |    1 +
 5 files changed, 128 insertions(+), 173 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -3,9 +3,9 @@
 /*
  *  net/dccp/ackvec.h
  *
- *  An implementation of the DCCP protocol
+ *  An implementation of Ack Vectors for the DCCP protocol
+ *  Copyright (c) 2007 University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@mandriva.com>
- *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License version 2 as
  *	published by the Free Software Foundation.
@@ -13,75 +13,84 @@
 
 #include <linux/dccp.h>
 #include <linux/compiler.h>
-#include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/types.h>
 
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
 
 /* Estimated minimum average Ack Vector length - used for updating MPS */
 #define DCCPAV_MIN_OPTLEN	16
 
-#define DCCP_ACKVEC_STATE_RECEIVED	0
-#define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
-#define DCCP_ACKVEC_STATE_NOT_RECEIVED	(3 << 6)
+enum dccp_ackvec_states {
+	DCCPAV_RECEIVED =	0x00,
+	DCCPAV_ECN_MARKED =	0x40,
+	DCCPAV_RESERVED =	0x80,
+	DCCPAV_NOT_RECEIVED =	0xC0
+};
+#define DCCPAV_MAX_RUNLEN	0x3F
 
-#define DCCP_ACKVEC_STATE_MASK		0xC0 /* 11000000 */
-#define DCCP_ACKVEC_LEN_MASK		0x3F /* 00111111 */
+static inline u8 dccp_ackvec_runlen(const u8 *cell)
+{
+	return *cell & DCCPAV_MAX_RUNLEN;
+}
 
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
- *
- * Additionally, the HC-Receiver must keep some information about the
- * Ack Vectors it has recently sent. For each packet sent carrying an
- * Ack Vector, it remembers four variables:
+static inline u8 dccp_ackvec_state(const u8 *cell)
+{
+	return *cell & ~DCCPAV_MAX_RUNLEN;
+}
+
+/** struct dccp_ackvec - Ack Vector main data structure
  *
- * @av_records - list of dccp_ackvec_record
- * @av_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
+ * This implements a fixed-size circular buffer within an array and is largely
+ * based on Appendix A of RFC 4340.
  *
- * @av_time - the time in usecs
- * @av_buf - circular buffer of acknowledgeable packets
+ * @av_buf:	   circular buffer storage area
+ * @av_buf_head:   head index; begin of live portion in @av_buf
+ * @av_buf_tail:   tail index; first index _after_ the live portion in @av_buf
+ * @av_buf_ackno:  highest seqno of acknowledgeable packet recorded in @av_buf
+ * @av_buf_nonce:  ECN nonce sums, each covering subsequent segments of up to
+ *		   %DCCP_SINGLE_OPT_MAXLEN cells in the live portion of @av_buf
+ * @av_records:	   list of %dccp_ackvec_record (Ack Vectors sent previously)
+ * @av_veclen:	   length of the live portion of @av_buf
  */
 struct dccp_ackvec {
-	u64			av_buf_ackno;
-	struct list_head	av_records;
-	ktime_t			av_time;
+	u8			av_buf[DCCPAV_MAX_ACKVEC_LEN];
 	u16			av_buf_head;
+	u16			av_buf_tail;
+	u64			av_buf_ackno:48;
+	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
+	struct list_head	av_records;
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
@@ -1,7 +1,8 @@
 /*
  *  net/dccp/ackvec.c
  *
- *  An implementation of the DCCP protocol
+ *  An implementation of Ack Vectors for the DCCP protocol
+ *  Copyright (c) 2007 University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
  *
  *      This program is free software; you can redistribute it and/or modify it
@@ -23,24 +24,32 @@
 static struct kmem_cache *dccp_ackvec_slab;
 static struct kmem_cache *dccp_ackvec_record_slab;
 
-static struct dccp_ackvec_record *dccp_ackvec_record_new(void)
+struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
-	struct dccp_ackvec_record *avr -			kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
+	struct dccp_ackvec *av = kmem_cache_zalloc(dccp_ackvec_slab, priority);
+
+	if (av != NULL) {
+		av->av_buf_head	= DCCPAV_MAX_ACKVEC_LEN - 1;
+		INIT_LIST_HEAD(&av->av_records);
+	}
+	return av;
+}
 
-	if (avr != NULL)
-		INIT_LIST_HEAD(&avr->avr_node);
+static void dccp_ackvec_purge_records(struct dccp_ackvec *av)
+{
+	struct dccp_ackvec_record *cur, *next;
 
-	return avr;
+	list_for_each_entry_safe(cur, next, &av->av_records, avr_node)
+		kmem_cache_free(dccp_ackvec_record_slab, cur);
+	INIT_LIST_HEAD(&av->av_records);
 }
 
-static void dccp_ackvec_record_delete(struct dccp_ackvec_record *avr)
+void dccp_ackvec_free(struct dccp_ackvec *av)
 {
-	if (unlikely(avr = NULL))
-		return;
-	/* Check if deleting a linked record */
-	WARN_ON(!list_empty(&avr->avr_node));
-	kmem_cache_free(dccp_ackvec_record_slab, avr);
+	if (likely(av != NULL)) {
+		dccp_ackvec_purge_records(av);
+		kmem_cache_free(dccp_ackvec_slab, av);
+	}
 }
 
 static void dccp_ackvec_insert_avr(struct dccp_ackvec *av,
@@ -68,24 +77,16 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	/* Figure out how many options do we need to represent the ackvec */
 	const u8 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts, i;
-	u32 elapsed_time;
+	u16 len = av->av_vec_len + 2 * nr_opts;
+	u8 i, nonce = 0;
 	const unsigned char *tail, *from;
 	unsigned char *to;
 	struct dccp_ackvec_record *avr;
-	suseconds_t delta;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
 		return -1;
 
-	delta = ktime_us_delta(ktime_get_real(), av->av_time);
-	elapsed_time = delta / 10;
-
-	if (elapsed_time != 0 &&
-	    dccp_insert_option_elapsed_time(skb, elapsed_time))
-		return -1;
-
-	avr = dccp_ackvec_record_new();
+	avr = kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
 	if (avr = NULL)
 		return -1;
 
@@ -94,7 +95,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	to   = skb_push(skb, len);
 	len  = av->av_vec_len;
 	from = av->av_buf + av->av_buf_head;
-	tail = av->av_buf + DCCP_MAX_ACKVEC_LEN;
+	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 
 	for (i = 0; i < nr_opts; ++i) {
 		int copylen = len;
@@ -102,7 +103,13 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
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
@@ -123,75 +130,24 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
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
+	avr->avr_ack_runlen = dccp_ackvec_runlen(av->av_buf + av->av_buf_head);
 
 	dccp_ackvec_insert_avr(av, avr);
 
 	dccp_pr_debug("%s ACK Vector 0, len=%d, ack_seqno=%llu, "
 		      "ack_ackno=%llu\n",
-		      dccp_role(sk), avr->avr_sent_len,
+		      dccp_role(sk), avr->avr_ack_runlen,
 		      (unsigned long long)avr->avr_ack_seqno,
 		      (unsigned long long)avr->avr_ack_ackno);
 	return 0;
 }
 
-struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
-{
-	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
-
-	if (av != NULL) {
-		av->av_buf_head	 = DCCP_MAX_ACKVEC_LEN - 1;
-		av->av_buf_ackno = UINT48_MAX + 1;
-		av->av_buf_nonce = 0;
-		av->av_time	 = ktime_set(0, 0);
-		av->av_vec_len	 = 0;
-		INIT_LIST_HEAD(&av->av_records);
-	}
-
-	return av;
-}
-
-void dccp_ackvec_free(struct dccp_ackvec *av)
-{
-	if (unlikely(av = NULL))
-		return;
-
-	if (!list_empty(&av->av_records)) {
-		struct dccp_ackvec_record *avr, *next;
-
-		list_for_each_entry_safe(avr, next, &av->av_records, avr_node) {
-			list_del_init(&avr->avr_node);
-			dccp_ackvec_record_delete(avr);
-		}
-	}
-
-	kmem_cache_free(dccp_ackvec_slab, av);
-}
-
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
@@ -204,7 +160,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 	long gap;
 	long new_head;
 
-	if (av->av_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
+	if (av->av_vec_len + packets > DCCPAV_MAX_ACKVEC_LEN)
 		return -ENOBUFS;
 
 	gap	 = packets - 1;
@@ -212,18 +168,18 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 
 	if (new_head < 0) {
 		if (gap > 0) {
-			memset(av->av_buf, DCCP_ACKVEC_STATE_NOT_RECEIVED,
+			memset(av->av_buf, DCCPAV_NOT_RECEIVED,
 			       gap + new_head + 1);
 			gap = -new_head;
 		}
-		new_head += DCCP_MAX_ACKVEC_LEN;
+		new_head += DCCPAV_MAX_ACKVEC_LEN;
 	}
 
 	av->av_buf_head = new_head;
 
 	if (gap > 0)
 		memset(av->av_buf + av->av_buf_head + 1,
-		       DCCP_ACKVEC_STATE_NOT_RECEIVED, gap);
+		       DCCPAV_NOT_RECEIVED, gap);
 
 	av->av_buf[av->av_buf_head] = state;
 	av->av_vec_len += packets;
@@ -236,6 +192,8 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		    const u64 ackno, const u8 state)
 {
+	u8 *cur_head = av->av_buf + av->av_buf_head,
+	   *buf_end  = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 	/*
 	 * Check at the right places if the buffer is full, if it is, tell the
 	 * caller to start dropping packets till the HC-Sender acks our ACK
@@ -260,7 +218,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 
 	/* See if this is the first ackno being inserted */
 	if (av->av_vec_len = 0) {
-		av->av_buf[av->av_buf_head] = state;
+		*cur_head = state;
 		av->av_vec_len = 1;
 	} else if (after48(ackno, av->av_buf_ackno)) {
 		const u64 delta = dccp_delta_seqno(av->av_buf_ackno, ackno);
@@ -269,10 +227,9 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
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
@@ -285,21 +242,17 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->av_buf_ackno);
-		u32 index = av->av_buf_head;
 
 		while (1) {
-			const u8 len = dccp_ackvec_len(av, index);
-			const u8 av_state = dccp_ackvec_state(av, index);
+			const u8 len = dccp_ackvec_runlen(cur_head);
 			/*
 			 * valid packets not yet in av_buf have a reserved
 			 * entry, with a len equal to 0.
 			 */
-			if (av_state = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
-			    len = 0 && delta = 0) { /* Found our
-							 reserved seat! */
+			if (*cur_head = DCCPAV_NOT_RECEIVED && delta = 0) {
 				dccp_pr_debug("Found %llu reserved seat!\n",
 					      (unsigned long long)ackno);
-				av->av_buf[index] = state;
+				*cur_head = state;
 				goto out;
 			}
 			/* len = 0 means one packet */
@@ -307,13 +260,12 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 				goto out_duplicate;
 
 			delta -= len + 1;
-			if (++index = DCCP_MAX_ACKVEC_LEN)
-				index = 0;
+			if (++cur_head = buf_end)
+				cur_head = av->av_buf;
 		}
 	}
 
 	av->av_buf_ackno = ackno;
-	av->av_time = ktime_get_real();
 out:
 	return 0;
 
@@ -333,13 +285,13 @@ static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 	if (av->av_buf_head <= avr->avr_ack_ptr)
 		av->av_vec_len = avr->avr_ack_ptr - av->av_buf_head;
 	else
-		av->av_vec_len = DCCP_MAX_ACKVEC_LEN - 1 -
+		av->av_vec_len = DCCPAV_MAX_ACKVEC_LEN - 1 -
 				 av->av_buf_head + avr->avr_ack_ptr;
 
 	/* free records */
 	list_for_each_entry_safe_from(avr, next, &av->av_records, avr_node) {
-		list_del_init(&avr->avr_node);
-		dccp_ackvec_record_delete(avr);
+		list_del(&avr->avr_node);
+		kmem_cache_free(dccp_ackvec_record_slab, avr);
 	}
 }
 
@@ -357,7 +309,7 @@ void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av, struct sock *sk,
 		if (ackno = avr->avr_ack_seqno) {
 			dccp_pr_debug("%s ACK packet 0, len=%d, ack_seqno=%llu, "
 				      "ack_ackno=%llu, ACKED!\n",
-				      dccp_role(sk), 1,
+				      dccp_role(sk), avr->avr_ack_runlen,
 				      (unsigned long long)avr->avr_ack_seqno,
 				      (unsigned long long)avr->avr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
@@ -387,7 +339,7 @@ static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
 	 */
 	avr = list_entry(av->av_records.next, struct dccp_ackvec_record, avr_node);
 	while (i--) {
-		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
+		const u8 rl = dccp_ackvec_runlen(vector);
 		u64 ackno_end_rl;
 
 		dccp_set_seqno(&ackno_end_rl, *ackno - rl);
@@ -404,8 +356,7 @@ static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
 		break;
 found:
 		if (between48(avr->avr_ack_seqno, ackno_end_rl, *ackno)) {
-			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
-			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
+			if (dccp_ackvec_state(vector) != DCCPAV_NOT_RECEIVED) {
 				dccp_pr_debug("%s ACK vector 0, len=%d, "
 					      "ack_seqno=%llu, ack_ackno=%llu, "
 					      "ACKED!\n",
@@ -448,10 +399,9 @@ int __init dccp_ackvec_init(void)
 	if (dccp_ackvec_slab = NULL)
 		goto out_err;
 
-	dccp_ackvec_record_slab -			kmem_cache_create("dccp_ackvec_record",
-					  sizeof(struct dccp_ackvec_record),
-					  0, SLAB_HWCACHE_ALIGN, NULL);
+	dccp_ackvec_record_slab = kmem_cache_create("dccp_ackvec_record",
+					     sizeof(struct dccp_ackvec_record),
+					     0, SLAB_HWCACHE_ALIGN, NULL);
 	if (dccp_ackvec_record_slab = NULL)
 		goto out_destroy_slab;
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -513,8 +513,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 					 &vector, &veclen)) != -1) {
 		/* go through this ack vector */
 		while (veclen--) {
-			const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-			u64 ackno_end_rl = SUB48(ackno, rl);
+			u64 ackno_end_rl = SUB48(ackno, dccp_ackvec_runlen(vector));
 
 			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
 				       (unsigned long long)ackno,
@@ -537,17 +536,15 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = *vector &
-						 DCCP_ACKVEC_STATE_MASK;
+				const u8 state = dccp_ackvec_state(vector);
 
 				/* new packet received or marked */
-				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
+				if (state != DCCPAV_NOT_RECEIVED &&
 				    !seqp->ccid2s_acked) {
-					if (state =
-					    DCCP_ACKVEC_STATE_ECN_MARKED) {
+					if (state = DCCPAV_ECN_MARKED)
 						ccid2_congestion_event(sk,
 								       seqp);
-					} else
+					else
 						ccid2_new_ack(sk, seqp,
 							      &maxincr);
 
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -378,8 +378,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 	if (dp->dccps_hc_rx_ackvec != NULL &&
 	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-			    DCCP_SKB_CB(skb)->dccpd_seq,
-			    DCCP_ACKVEC_STATE_RECEIVED))
+			    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
 		goto discard;
 	dccp_deliver_input_to_ccids(sk, skb);
 
@@ -637,8 +636,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 		if (dp->dccps_hc_rx_ackvec != NULL &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
+				    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
 			goto discard;
 
 		dccp_deliver_input_to_ccids(sk, skb);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -340,6 +340,7 @@ static inline int dccp_elapsed_time_len(const u32 elapsed_time)
 	return elapsed_time = 0 ? 0 : elapsed_time <= 0xFFFF ? 2 : 4;
 }
 
+/* FIXME: This function is currently not used anywhere */
 int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed_time)
 {
 	const int elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
