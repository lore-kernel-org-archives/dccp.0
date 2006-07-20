From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 20 Jul 2006 17:59:58 +0000
Subject: [PATCH 1/3]: ACKVEC: Split long ack vectors across multiple options
Message-Id: <20060720175958.GA3313@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

ack vectors grow proportional to the window size.  If an ack vector does not fit
into a single option, it must be spread across multiple options.  This patch
will allow for windows to grow larger.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 4d176d3..35308cf 100644
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
 
-	/* Check if buf_head wraps */
-	if ((int)av->dccpav_buf_head + len > DCCP_MAX_ACKVEC_LEN) {
-		const u32 tailsize = DCCP_MAX_ACKVEC_LEN - av->dccpav_buf_head;
+	/* write the vectors */
+	for (i = 0; i < optc; i++) {
+		int copylen = len;
+		if (copylen > DCCP_MAX_ACKVEC_OPT_LEN)
+			copylen = DCCP_MAX_ACKVEC_OPT_LEN;
 
-		memcpy(to, from, tailsize);
-		to   += tailsize;
-		len  -= tailsize;
-		from = av->dccpav_buf;
+		*to++ = DCCPO_ACK_VECTOR_0;
+		*to++ = copylen+2;
+
+		/* Check if buf_head wraps */
+		if ((from + copylen) > &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN]) {
+			u32 tailsize = &av->dccpav_buf[DCCP_MAX_ACKVEC_LEN] -
+				       from;
+
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
 	 *	From draft-ietf-dccp-spec-11.txt:
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
@@ -396,17 +420,17 @@ #endif
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
 
 	/* Check if we actually sent an ACK vector */
 	if (list_empty(&av->dccpav_records))
-		return;
+		return ackno; /* It's OK, because we will always return */
 
 	i = len;
 	/*
@@ -432,7 +456,10 @@ static void dccp_ackvec_check_rcv_ackvec
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
@@ -452,7 +479,9 @@ #endif
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
@@ -463,19 +492,16 @@ #endif
 		dccp_set_seqno(&ackno, ackno_end_rl - 1);
 		++vector;
 	}
+
+	return ackno;
 }
 
-int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
+u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
 		      const u8 opt, const u8 *value, const u8 len)
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
 
 static char dccp_ackvec_slab_msg[] __initdata diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index ec9a988..691a7f4 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -18,7 +18,9 @@ #include <linux/time.h>
 #include <linux/types.h>
 
 /* Read about the ECN nonce to see why it is 253 */
-#define DCCP_MAX_ACKVEC_LEN 253
+#define DCCP_MAX_ACKVEC_OPT_LEN 253
+/* We can spread an ack vector across multiple options */
+#define DCCP_MAX_ACKVEC_LEN (DCCP_MAX_ACKVEC_OPT_LEN*2)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
@@ -54,9 +56,8 @@ struct dccp_ackvec {
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
@@ -79,9 +80,9 @@ struct dccp_ackvec_record {
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
@@ -99,7 +100,7 @@ extern int dccp_ackvec_add(struct dccp_a
 
 extern void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
 					struct sock *sk, const u64 ackno);
-extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
+extern u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
 			     const u8 opt, const u8 *value, const u8 len);
 
 extern int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb);
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index d208657..5f3e1c8 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -70,7 +70,7 @@ struct ccid2_txprofile {
 	unsigned long		ccid2txp_packets_last;
 };
 
-#define CCID2_SEQBUF_LEN 256
+#define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 1fe5091..303a75a 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -42,7 +42,7 @@ extern void dccp_tw_deschedule(struct in
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
 /* FIXME: Right size this */
-#define DCCP_MAX_OPT_LEN 128
+#define DCCP_MAX_OPT_LEN 1024
 
 #define DCCP_MAX_PACKET_HDR 32
 
diff --git a/net/dccp/options.c b/net/dccp/options.c
index e9feb2a..7817313 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -75,6 +75,7 @@ #endif
 	u32 elapsed_time;
 	int rc;
 	int mandatory = 0;
+	u64 ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 
 	memset(opt_recv, 0, sizeof(*opt_recv));
 
@@ -151,9 +152,9 @@ #endif
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
