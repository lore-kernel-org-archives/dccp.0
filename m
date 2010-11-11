From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 06:07:33 +0000
Subject: [PATCH 3/3] dccp ccid-2: Implementation of circular Ack Vector buffer with overflow handling
Message-Id: <1289455653-5463-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This completes the implementation of a circular buffer for Ack Vectors, by
extending the current (linear array-based) implementation.  The changes are:

 (a) An `overflow' flag to deal with the case of overflow. As before, dynamic
     growth of the buffer will not be supported; but code will be added to deal
     robustly with overflowing Ack Vector buffers.

 (b) A `tail_seqno' field. When naively implementing the algorithm of Appendix A
     in RFC 4340, problems arise whenever subsequent Ack Vector records overlap,
     which can bring the entire run length calculation completely out of synch.
     (This is documented on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
                                             ack_vectors/tracking_tail_ackno/ .)
 (c) The buffer length is now computed dynamically (i.e. current fill level),
     as the span between head to tail.

As a result, dccp_ackvec_pending() is now simpler - the #ifdef is no longer
necessary since buf_empty is always true when IP_DCCP_ACKVEC is not configured.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.h  |   10 ++++++++--
 net/dccp/ackvec.c  |   31 ++++++++++++++++++++++++++++++-
 net/dccp/dccp.h    |   11 +++++++----
 net/dccp/options.c |   10 +++++-----
 4 files changed, 50 insertions(+), 12 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -21,6 +21,7 @@
  * the maximum size of a single Ack Vector. Setting %DCCPAV_NUM_ACKVECS to 1
  * will be sufficient for most cases of low Ack Ratios, using a value of 2 gives
  * more headroom if Ack Ratio is higher or when the sender acknowledges slowly.
+ * The maximum value is bounded by the u16 types for indices and functions.
  */
 #define DCCPAV_NUM_ACKVECS	2
 #define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
@@ -55,8 +56,10 @@ static inline u8 dccp_ackvec_state(const u8 *cell)
  * @av_buf_head:   head index; begin of live portion in @av_buf
  * @av_buf_tail:   tail index; first index _after_ the live portion in @av_buf
  * @av_buf_ackno:  highest seqno of acknowledgeable packet recorded in @av_buf
+ * @av_tail_ackno: lowest  seqno of acknowledgeable packet recorded in @av_buf
  * @av_buf_nonce:  ECN nonce sums, each covering subsequent segments of up to
  *		   %DCCP_SINGLE_OPT_MAXLEN cells in the live portion of @av_buf
+ * @av_overflow:   if 1 then buf_head = buf_tail indicates buffer wraparound
  * @av_records:	   list of %dccp_ackvec_record (Ack Vectors sent previously)
  * @av_veclen:	   length of the live portion of @av_buf
  */
@@ -65,7 +68,9 @@ struct dccp_ackvec {
 	u16			av_buf_head;
 	u16			av_buf_tail;
 	u64			av_buf_ackno:48;
+	u64			av_tail_ackno:48;
 	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
+	u8			av_overflow:1;
 	struct list_head	av_records;
 	u16			av_vec_len;
 };
@@ -112,9 +117,10 @@ extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 			     const u8 *value, const u8 len);
 
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
+extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
 
-static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
+static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
-	return av->av_vec_len;
+	return av->av_overflow = 0 && av->av_buf_head = av->av_buf_tail;
 }
 #endif /* _ACKVEC_H */
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -29,7 +29,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 	struct dccp_ackvec *av = kmem_cache_zalloc(dccp_ackvec_slab, priority);
 
 	if (av != NULL) {
-		av->av_buf_head	= DCCPAV_MAX_ACKVEC_LEN - 1;
+		av->av_buf_head	= av->av_buf_tail = DCCPAV_MAX_ACKVEC_LEN - 1;
 		INIT_LIST_HEAD(&av->av_records);
 	}
 	return av;
@@ -72,6 +72,14 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 	avr->avr_ack_nonce  = nonce_sum;
 	avr->avr_ack_runlen = dccp_ackvec_runlen(av->av_buf + av->av_buf_head);
 	/*
+	 * When the buffer overflows, we keep no more than one record. This is
+	 * the simplest way of disambiguating sender-Acks dating from before the
+	 * overflow from sender-Acks which refer to after the overflow; a simple
+	 * solution is preferable here since we are handling an exception.
+	 */
+	if (av->av_overflow)
+		dccp_ackvec_purge_records(av);
+	/*
 	 * Since GSS is incremented for each packet, the list is automatically
 	 * arranged in descending order of @ack_seqno.
 	 */
@@ -85,6 +93,27 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 }
 
 /*
+ * Buffer index and length computation using modulo-buffersize arithmetic.
+ * Note that, as pointers move from right to left, head is `before' tail.
+ */
+static inline u16 __ackvec_idx_add(const u16 a, const u16 b)
+{
+	return (a + b) % DCCPAV_MAX_ACKVEC_LEN;
+}
+
+static inline u16 __ackvec_idx_sub(const u16 a, const u16 b)
+{
+	return __ackvec_idx_add(a, DCCPAV_MAX_ACKVEC_LEN - b);
+}
+
+u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
+{
+	if (unlikely(av->av_overflow))
+		return DCCPAV_MAX_ACKVEC_LEN;
+	return __ackvec_idx_sub(av->av_buf_tail, av->av_buf_head);
+}
+
+/*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
  * this simplifies table updates if one of the missing packets arrives.
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -457,12 +457,15 @@ static inline void dccp_update_gss(struct sock *sk, u64 seq)
 	dp->dccps_awh = dp->dccps_gss;
 }
 
+static inline int dccp_ackvec_pending(const struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_hc_rx_ackvec != NULL &&
+	       !dccp_ackvec_is_empty(dccp_sk(sk)->dccps_hc_rx_ackvec);
+}
+
 static inline int dccp_ack_pending(const struct sock *sk)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
-	return (dp->dccps_hc_rx_ackvec != NULL &&
-		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
-	       inet_csk_ack_scheduled(sk);
+	return dccp_ackvec_pending(sk) || inet_csk_ack_scheduled(sk);
 }
 
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -429,9 +429,10 @@ static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
-	const u8 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts;
+	const u8 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
+	u16 len = buflen + 2 * nr_opts;
 	u8 i, nonce = 0;
 	const unsigned char *tail, *from;
 	unsigned char *to;
@@ -442,7 +443,7 @@ static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
 	to   = skb_push(skb, len);
-	len  = av->av_vec_len;
+	len  = buflen;
 	from = av->av_buf + av->av_buf_head;
 	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 
@@ -580,8 +581,7 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 			if (dccp_insert_option_timestamp(skb))
 				return -1;
 
-		} else if (dp->dccps_hc_rx_ackvec != NULL &&
-			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
+		} else if (dccp_ackvec_pending(sk) &&
 			   dccp_insert_option_ackvec(sk, skb)) {
 				return -1;
 		}
