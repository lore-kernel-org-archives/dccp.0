From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:22 +0000
Subject: [PATCH 04/10] [ACKVEC]: Implementation of circular Ack Vector buffer with overflow handling
Message-Id: <1203584968-8957-5-git-send-email-gerrit@erg.abdn.ac.uk>
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
 (c) The buffer lengthi is now computed dynamically (i.e. current fill level),
     as the span between head to tail.

As a result, dccp_ackvec_pending() is now simpler - the #ifdef is no longer
necessary since buf_empty is always true when IP_DCCP_ACKVEC is not configured.

Note on overflow handling:
-------------------------
 The Ack Vector code previously simply started to drop packets when the
 Ack Vector buffer overflowed. This means that the userspace application
 will not be able to receive, only because of an Ack Vector storage problem.

 Furthermore, overflow may be transient, so that applications may later
 recover from the overflow. Recovering from dropped packets is more difficult
 (e.g. video key frames).

 Hence the patch uses a different policy: when the buffer overflows, the oldest
 entries are subsequently overwritten. This has a higher chance of recovery.
 Details are on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c  |   33 +++++++++++++++++++++++++++++++--
 net/dccp/ackvec.h  |   17 ++++++++++++++---
 net/dccp/dccp.h    |   14 +++++++-------
 net/dccp/options.c |   12 ++++++------
 4 files changed, 58 insertions(+), 18 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -22,6 +22,7 @@
  * the maximum size of a single Ack Vector. Setting %DCCPAV_NUM_ACKVECS to 1
  * will be sufficient for most cases of low Ack Ratios, using a value of 2 gives
  * more headroom if Ack Ratio is higher or when the sender acknowledges slowly.
+ * The maximum value is bounded by the u16 types for indices and functions.
  */
 #define DCCPAV_NUM_ACKVECS	2
 #define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
@@ -53,8 +54,10 @@ static inline u8 dccp_ackvec_state(const u8 *cell)
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
@@ -63,7 +66,9 @@ struct dccp_ackvec {
 	u16			av_buf_head;
 	u16			av_buf_tail;
 	u64			av_buf_ackno:48;
+	u64			av_tail_ackno:48;
 	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
+	u8			av_overflow:1;
 	struct list_head	av_records;
 	u16			av_vec_len;
 };
@@ -111,10 +116,11 @@ extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 			     const u8 *value, const u8 len);
 
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
+extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
 
-static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
+static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
-	return av->av_vec_len;
+	return av->av_overflow = 0 && av->av_buf_head = av->av_buf_tail;
 }
 #else /* CONFIG_IP_DCCP_ACKVEC */
 static inline int dccp_ackvec_init(void)
@@ -158,9 +164,14 @@ static inline int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8
 	return -1;
 }
 
-static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
+static inline u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
 {
 	return 0;
 }
+
+static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
+{
+	return true;
+}
 #endif /* CONFIG_IP_DCCP_ACKVEC */
 #endif /* _ACKVEC_H */
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -30,8 +30,8 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
 
 	if (av != NULL) {
-		av->av_buf_head	 = DCCPAV_MAX_ACKVEC_LEN - 1;
-		av->av_vec_len	 = 0;
+		av->av_buf_head	= av->av_buf_tail = DCCPAV_MAX_ACKVEC_LEN - 1;
+		av->av_overflow = 0;
 		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
 		INIT_LIST_HEAD(&av->av_records);
 	}
@@ -75,6 +75,14 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
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
@@ -88,6 +96,27 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 }
 
 /*
+ * Buffer index and length computation using modulo-buffersize arithmetic.
+ * Note that, as pointers move from right to left, head is `before' tail.
+ */
+static inline u16 dccp_ackvec_idx_add(const u16 a, const u16 b)
+{
+	return (a + b) % DCCPAV_MAX_ACKVEC_LEN;
+}
+
+static inline u16 dccp_ackvec_idx_sub(const u16 a, const u16 b)
+{
+	return dccp_ackvec_idx_add(a, DCCPAV_MAX_ACKVEC_LEN - b);
+}
+
+u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
+{
+	if (unlikely(av->av_overflow))
+		return DCCPAV_MAX_ACKVEC_LEN;
+	return dccp_ackvec_idx_sub(av->av_buf_tail, av->av_buf_head);
+}
+
+/*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
  * this simplifies table updates if one of the missing packets arrives.
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -428,15 +428,15 @@ static inline void dccp_schedule_ack(struct sock *sk)
 	inet_csk_schedule_ack(sk);
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
-	return
-#ifdef CONFIG_IP_DCCP_ACKVEC
-	       (dp->dccps_hc_rx_ackvec != NULL &&
-		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
-#endif
-	       inet_csk_ack_scheduled(sk);
+	return dccp_ackvec_pending(sk) || inet_csk_ack_scheduled(sk);
 }
 
 extern int  dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -432,9 +432,10 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
-	const u16 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts;
+	const u16 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
+	u16 len = buflen + 2 * nr_opts;
 	u8 i, nonce = 0;
 	const unsigned char *tail, *from;
 	unsigned char *to;
@@ -445,7 +446,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
 	to   = skb_push(skb, len);
-	len  = av->av_vec_len;
+	len  = buflen;
 	from = av->av_buf + av->av_buf_head;
 	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 
@@ -583,9 +584,8 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 			if (dccp_insert_option_timestamp(sk, skb))
 				return -1;
 
-		} else if (dp->dccps_hc_rx_ackvec != NULL &&
-			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
-			   dccp_insert_option_ackvec(sk, skb)		 ) {
+		} else if (dccp_ackvec_pending(sk) &&
+			   dccp_insert_option_ackvec(sk, skb)) {
 				return -1;
 		}
 	}
