From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:28 +0000
Subject: [PATCH 4/17] [DCCP]: Ackvec patches by Bittau
Message-Id: <200610241459.28411@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These patches were written by Andrea Bittau and 
were posted and signed-off by him as 

	 01_ackvec_opt
	 02_ackvec_speed
	 03_ackvec_ccid_speed

Given that he achieved Gigabit speed with these patches, I think they
should really be `in'.


Original commit messages:
============
[ACKVEC]: Split long ack vectors across multiple options
  ack vectors grow proportional to the window size.  If an ack vector does not fit
  into a single option, it must be spread across multiple options.  This patch
  will allow for windows to grow larger.
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00399.html

[ACKVEC - Optimization]:  Do not traverse records if none will be found
  Do not traverse the list of ack vector records [proportional to window size]
  when we know we will not find what we are looking for.  This is especially
  useful because ack vectors are checked twice:
    1) Upon parsing of options.
    2) Upon notification of a new ack.

  All of the work will occur during check #1.  Therefore, when check #2 is
  performed, no new work will be done.  This is now "detected" and there is no
  performance hit when doing #2.
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00400.html

[ACKVEC & CCID2]: Code optimizations
   These are code optimizations which are relevant when dealing with large windows.
   They are not coded the way I would like to, but they do the job for the
   short-term.  This patch should be more neat.
   http://www.mail-archive.com/dccp@vger.kernel.org/msg00401.html


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/ackvec.c      |  115 ++++++++++++++++++++++++++++++-------------------
 net/dccp/ackvec.h      |   22 ++++-----
 net/dccp/ccids/ccid2.c |   22 ++++++++-
 net/dccp/ccids/ccid2.h |    3 -
 net/dccp/options.c     |    7 +-
 5 files changed, 109 insertions(+), 60 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/options.c b/net/dccp/options.c
index fb0db1f..81c53e1 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -76,6 +76,7 @@ #endif
 	u32 elapsed_time;
 	int rc;
 	int mandatory = 0;
+	u64 ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 
 	memset(opt_recv, 0, sizeof(*opt_recv));
 
@@ -152,9 +153,9 @@ #endif
 			if (pkt_type = DCCP_PKT_DATA)
 				break;
 
-			if (dccp_msk(sk)->dccpms_send_ack_vector &&
-			    dccp_ackvec_parse(sk, skb, opt, value, len))
-				goto out_invalid_option;
+			if (dccp_msk(sk)->dccpms_send_ack_vector)
+				ackno = dccp_ackvec_parse(sk, ackno, opt,
+							  value, len);
 			break;
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 5b2ef4a..ebd7949 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -35,7 +35,7 @@ struct ccid2_seq {
 	struct ccid2_seq	*ccid2s_next;
 };
 
-#define CCID2_SEQBUF_LEN 256
+#define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
@@ -72,6 +72,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_rpdupack;
 	int			ccid2hctx_sendwait;
 	unsigned long		ccid2hctx_last_cong;
+	u64			ccid2hctx_high_ack;
 };
 
 struct ccid2_hc_rx_sock {
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 2fbb84b..e0f85e9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -618,7 +618,17 @@ static void ccid2_hc_tx_packet_recv(stru
 	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	if (ackno > hctx->ccid2hctx_high_ack)
+		hctx->ccid2hctx_high_ack = ackno;
+
+	seqp = hctx->ccid2hctx_seqt;
+	while (before48(seqp->ccid2s_seq, ackno)) {
+		seqp = seqp->ccid2s_next;
+		if (seqp = hctx->ccid2hctx_seqh) {
+			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+			break;
+		}
+	}
 
 	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
 	 * this single ack.  I round up.
@@ -695,7 +705,14 @@ static void ccid2_hc_tx_packet_recv(stru
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	seqp = hctx->ccid2hctx_seqt;
+	while (seqp->ccid2s_seq < hctx->ccid2hctx_high_ack) {
+		seqp = seqp->ccid2s_next;
+		if (seqp = hctx->ccid2hctx_seqh) {
+			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+			break;
+		}
+	}
 	done = 0;
 	while (1) {
 		if (seqp->ccid2s_acked) {
@@ -769,6 +786,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
+	hctx->ccid2hctx_high_ack = 0;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index cf8f20c..da1bec8 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -17,7 +17,9 @@ #include <linux/time.h>
 #include <linux/types.h>
 
 /* Read about the ECN nonce to see why it is 253 */
-#define DCCP_MAX_ACKVEC_LEN 253
+#define DCCP_MAX_ACKVEC_OPT_LEN 253
+/* We can spread an ack vector across multiple options */
+#define DCCP_MAX_ACKVEC_LEN     (DCCP_MAX_ACKVEC_OPT_LEN * 2)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
@@ -31,7 +33,7 @@ #define DCCP_ACKVEC_LEN_MASK		0x3F /* 00
  * This data structure is the one defined in RFC 4340, Appendix A.
  *
  * @dccpav_buf_head - circular buffer head
- * @dccpav_buf_tail - circular buffer tail
+ * @dccpav_vec_len -
  * @dccpav_buf_ackno - ack # of the most recent packet acknowledgeable in the
  * 		       buffer (i.e. %dccpav_buf_head)
  * @dccpav_buf_nonce - the one-bit sum of the ECN Nonces on all packets acked
@@ -41,20 +43,19 @@ #define DCCP_ACKVEC_LEN_MASK		0x3F /* 00
  * Ack Vectors it has recently sent. For each packet sent carrying an
  * Ack Vector, it remembers four variables:
  *
- * @dccpav_ack_ptr - the value of buf_head at the time of acknowledgement.
  * @dccpav_records - list of dccp_ackvec_record
+ * @dccpav_buf_nonce -
  * @dccpav_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
  *
- * @dccpav_time		- the time in usecs
+ * @dccpav_time	- the time in usecs
  * @dccpav_buf - circular buffer of acknowledgeable packets
  */
 struct dccp_ackvec {
 	u64		dccpav_buf_ackno;
 	struct list_head dccpav_records;
 	struct timeval	dccpav_time;
-	u8		dccpav_buf_head;
-	u8		dccpav_ack_ptr;
-	u8		dccpav_vec_len;
+	int		dccpav_buf_head;
+	int		dccpav_vec_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
 	u8		dccpav_buf[DCCP_MAX_ACKVEC_LEN];
@@ -77,9 +78,9 @@ struct dccp_ackvec_record {
 	struct list_head dccpavr_node;
 	u64		 dccpavr_ack_seqno;
 	u64		 dccpavr_ack_ackno;
-	u8		 dccpavr_ack_ptr;
+	int		 dccpavr_ack_ptr;
 	u8		 dccpavr_ack_nonce;
-	u8		 dccpavr_sent_len;
+	int		 dccpavr_sent_len;
 };
 
 struct sock;
@@ -94,10 +95,9 @@ extern void dccp_ackvec_free(struct dccp
 
 extern int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 			   const u64 ackno, const u8 state);
-
 extern void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
 					struct sock *sk, const u64 ackno);
-extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
+extern u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
 			     const u8 opt, const u8 *value, const u8 len);
 
 extern int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb);
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 01345df..f18f76e 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -72,11 +72,18 @@ #ifdef CONFIG_IP_DCCP_DEBUG
 				"CLIENT tx: " : "server tx: ";
 #endif
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
-	int len = av->dccpav_vec_len + 2;
+	int len;
 	struct timeval now;
 	u32 elapsed_time;
 	unsigned char *to, *from;
 	struct dccp_ackvec_record *avr;
+	int optc, i;
+
+	/* Figure out how many options do we need to represent the ackvec */
+	optc = av->dccpav_vec_len / DCCP_MAX_ACKVEC_OPT_LEN;
+	if (av->dccpav_vec_len % DCCP_MAX_ACKVEC_OPT_LEN)
+		optc++;
+	len = optc*2 + av->dccpav_vec_len;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
 		return -1;
@@ -94,24 +101,42 @@ #endif
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
-	to    = skb_push(skb, len);
-	*to++ = DCCPO_ACK_VECTOR_0;
-	*to++ = len;
-
-	len  = av->dccpav_vec_len;
+	to   = skb_push(skb, len);
 	from = av->dccpav_buf + av->dccpav_buf_head;
+	len  = av->dccpav_vec_len;
+
+	/* write the vectors */
+	for (i = 0; i < optc; i++) {
+		int copylen = len;
+		if (copylen > DCCP_MAX_ACKVEC_OPT_LEN)
+			copylen = DCCP_MAX_ACKVEC_OPT_LEN;
+
+		*to++ = DCCPO_ACK_VECTOR_0;
+		*to++ = copylen+2;
 
-	/* Check if buf_head wraps */
-	if ((int)av->dccpav_buf_head + len > DCCP_MAX_ACKVEC_LEN) {
-		const u32 tailsize = DCCP_MAX_ACKVEC_LEN - av->dccpav_buf_head;
+		/* Check if buf_head wraps */
+		if ((from + copylen) > &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN]) {
+			u32 tailsize = &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN] -
+				       from;
 
-		memcpy(to, from, tailsize);
-		to   += tailsize;
-		len  -= tailsize;
-		from = av->dccpav_buf;
+			memcpy(to, from, tailsize);
+			to	+= tailsize;
+			from     = av->dccpav_buf;
+			copylen	-= tailsize;
+			len     -= tailsize;
+
+			BUG_ON((from + copylen) >
+			       &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN]);
+		}
+
+		memcpy(to, from, copylen);
+		to   += copylen;
+		from += copylen;
+
+		len -= copylen;
 	}
+	BUG_ON(len != 0);
 
-	memcpy(to, from, len);
 	/*
 	 *	From RFC 4340, A.2:
 	 *
@@ -145,7 +170,6 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
 		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
-		av->dccpav_ack_ptr	= 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
 		av->dccpav_vec_len	= 0;
@@ -174,13 +198,13 @@ void dccp_ackvec_free(struct dccp_ackvec
 }
 
 static inline u8 dccp_ackvec_state(const struct dccp_ackvec *av,
-				   const u8 index)
+				   const int index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_STATE_MASK;
 }
 
 static inline u8 dccp_ackvec_len(const struct dccp_ackvec *av,
-				 const u8 index)
+				 const int index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_LEN_MASK;
 }
@@ -280,7 +304,7 @@ int dccp_ackvec_add(struct dccp_ackvec *
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->dccpav_buf_ackno);
-		u8 index = av->dccpav_buf_head;
+		int index = av->dccpav_buf_head;
 
 		while (1) {
 			const u8 len = dccp_ackvec_len(av, index);
@@ -389,30 +413,35 @@ #endif
 				      (unsigned long long)avr->dccpavr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
 			break;
-		}
+		} else if (avr->dccpavr_ack_seqno > ackno)
+			break; /* old news */
 	}
 }
 
-static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
-					    struct sock *sk, u64 ackno,
-					    const unsigned char len,
-					    const unsigned char *vector)
+static u64 dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
+					   struct sock *sk, u64 ackno,
+					   const unsigned char len,
+					   const unsigned char *vector)
 {
 	unsigned char i;
 	struct dccp_ackvec_record *avr;
+	int use_head = 1;
 
 	/* Check if we actually sent an ACK vector */
 	if (list_empty(&av->dccpav_records))
-		return;
+		return ackno; /* It's OK, because we will always return */
 
 	i = len;
-	/*
-	 * XXX
-	 * I think it might be more efficient to work backwards. See comment on
-	 * rcv_ackno. -sorbo.
-	 */
-	avr = list_entry(av->dccpav_records.next, struct dccp_ackvec_record,
-			 dccpavr_node);
+	list_for_each_entry_reverse(avr, &av->dccpav_records, dccpavr_node) {
+		if (!before48(avr->dccpavr_ack_seqno, ackno)) {
+			use_head = 0;
+			break;
+		}
+	}
+	if (use_head)
+		avr = list_entry(av->dccpav_records.next,
+				 struct dccp_ackvec_record, dccpavr_node);
+
 	while (i--) {
 		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
 		u64 ackno_end_rl;
@@ -429,7 +458,10 @@ static void dccp_ackvec_check_rcv_ackvec
 				goto found;
 		}
 		/* End of the dccpav_records list, not found, exit */
-		break;
+		break; /* Do not need to return a correct ackno because the next
+		        * batch of ackvectors will not make situation better
+			* (their acknos will be lower)
+			*/
 found:
 		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
 			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
@@ -449,30 +481,27 @@ #endif
 					      (unsigned long long)
 					      avr->dccpavr_ack_ackno);
 				dccp_ackvec_throw_record(av, avr);
-				break;
+				break; /* Don't care about other ACKs because we
+				        * released the most possible state
+					*/
 			}
 			/*
 			 * If it wasn't received, continue scanning... we might
 			 * find another one.
 			 */
 		}
-
 		dccp_set_seqno(&ackno, ackno_end_rl - 1);
 		++vector;
 	}
+	return ackno;
 }
 
-int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-		      const u8 opt, const u8 *value, const u8 len)
+inline u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
+				    const u8 opt, const u8 *value, const u8 len)
 {
-	if (len > DCCP_MAX_ACKVEC_LEN)
-		return -1;
-
 	/* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
-	dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec, sk,
-					DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				        len, value);
-	return 0;
+	return dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec,
+					       sk, ackno, len, value);
 }
 
 static char dccp_ackvec_slab_msg[] __initdata 

