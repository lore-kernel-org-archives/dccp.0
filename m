From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 26 Nov 2006 03:18:39 +0000
Subject: [PATCH 2/4] [DCCP] ackvec: infrastructure for sending more than one ackvec per packet
Message-Id: <20061126031838.GC17851@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Commiter note:

This was split from Andrea's original patch, in the process I changed the type
of the ackvec index fields to u16 instead of to int and haven't folded
dccp_ackvec_parse with dccp_ackvec_check_rcv_ackno.

Next patch will actually do the insertion of more than one ackvec per packet,
using, initially, up to a max of 2 ackvecs as per Andrea's original patch, then
I'll work on support for larger ackvecs, be it using a sysctl or using
setsockopt.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ackvec.c  |   23 +++++++++++------------
 net/dccp/ackvec.h  |   18 +++++++++++-------
 net/dccp/options.c |    3 ++-
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 215355d..41d34d1 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -169,13 +169,13 @@ void dccp_ackvec_free(struct dccp_ackvec
 }
 
 static inline u8 dccp_ackvec_state(const struct dccp_ackvec *av,
-				   const u8 index)
+				   const u32 index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_STATE_MASK;
 }
 
 static inline u8 dccp_ackvec_len(const struct dccp_ackvec *av,
-				 const u8 index)
+				 const u32 index)
 {
 	return av->dccpav_buf[index] & DCCP_ACKVEC_LEN_MASK;
 }
@@ -275,7 +275,7 @@ int dccp_ackvec_add(struct dccp_ackvec *
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->dccpav_buf_ackno);
-		u8 index = av->dccpav_buf_head;
+		u32 index = av->dccpav_buf_head;
 
 		while (1) {
 			const u8 len = dccp_ackvec_len(av, index);
@@ -385,7 +385,7 @@ void dccp_ackvec_check_rcv_ackno(struct 
 }
 
 static void dccp_ackvec_check_rcv_ackvector(struct dccp_ackvec *av,
-					    struct sock *sk, u64 ackno,
+					    struct sock *sk, u64 *ackno,
 					    const unsigned char len,
 					    const unsigned char *vector)
 {
@@ -408,7 +408,7 @@ static void dccp_ackvec_check_rcv_ackvec
 		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
 		u64 ackno_end_rl;
 
-		dccp_set_seqno(&ackno_end_rl, ackno - rl);
+		dccp_set_seqno(&ackno_end_rl, *ackno - rl);
 
 		/*
 		 * If our AVR sequence number is greater than the ack, go
@@ -416,13 +416,13 @@ static void dccp_ackvec_check_rcv_ackvec
 		 */
 		list_for_each_entry_from(avr, &av->dccpav_records,
 					 dccpavr_node) {
-			if (!after48(avr->dccpavr_ack_seqno, ackno))
+			if (!after48(avr->dccpavr_ack_seqno, *ackno))
 				goto found;
 		}
 		/* End of the dccpav_records list, not found, exit */
 		break;
 found:
-		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
+		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, *ackno)) {
 			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
 			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
 				dccp_pr_debug("%s ACK vector 0, len=%d, "
@@ -442,21 +442,20 @@ found:
 			 */
 		}
 
-		dccp_set_seqno(&ackno, ackno_end_rl - 1);
+		dccp_set_seqno(ackno, ackno_end_rl - 1);
 		++vector;
 	}
 }
 
 int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-		      const u8 opt, const u8 *value, const u8 len)
+		      u64 *ackno, const u8 opt, const u8 *value, const u8 len)
 {
-	if (len > DCCP_MAX_ACKVEC_LEN)
+	if (len > DCCP_MAX_ACKVEC_OPT_LEN)
 		return -1;
 
 	/* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
 	dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec, sk,
-					DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				        len, value);
+					ackno, len, value);
 	return 0;
 }
 
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index d6a58db..96504a3 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -17,7 +17,9 @@ #include <linux/time.h>
 #include <linux/types.h>
 
 /* Read about the ECN nonce to see why it is 253 */
-#define DCCP_MAX_ACKVEC_LEN 253
+#define DCCP_MAX_ACKVEC_OPT_LEN 253
+/* We can spread an ack vector across multiple options */
+#define DCCP_MAX_ACKVEC_LEN (DCCP_MAX_ACKVEC_OPT_LEN * 2)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
@@ -51,8 +53,8 @@ struct dccp_ackvec {
 	u64		dccpav_buf_ackno;
 	struct list_head dccpav_records;
 	struct timeval	dccpav_time;
-	u8		dccpav_buf_head;
-	u8		dccpav_vec_len;
+	u16		dccpav_buf_head;
+	u16		dccpav_vec_len;
 	u8		dccpav_buf_nonce;
 	u8		dccpav_ack_nonce;
 	u8		dccpav_buf[DCCP_MAX_ACKVEC_LEN];
@@ -75,9 +77,9 @@ struct dccp_ackvec_record {
 	struct list_head dccpavr_node;
 	u64		 dccpavr_ack_seqno;
 	u64		 dccpavr_ack_ackno;
-	u8		 dccpavr_ack_ptr;
+	u16		 dccpavr_ack_ptr;
+	u16		 dccpavr_sent_len;
 	u8		 dccpavr_ack_nonce;
-	u8		 dccpavr_sent_len;
 };
 
 struct sock;
@@ -96,7 +98,8 @@ extern int dccp_ackvec_add(struct dccp_a
 extern void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
 					struct sock *sk, const u64 ackno);
 extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-			     const u8 opt, const u8 *value, const u8 len);
+			     u64 *ackno, const u8 opt,
+			     const u8 *value, const u8 len);
 
 extern int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb);
 
@@ -135,7 +138,8 @@ static inline void dccp_ackvec_check_rcv
 }
 
 static inline int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-				    const u8 opt, const u8 *value, const u8 len)
+				    const u64 *ackno, const u8 opt,
+				    const u8 *value, const u8 len)
 {
 	return -1;
 }
diff --git a/net/dccp/options.c b/net/dccp/options.c
index ee709ae..f398b43 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -62,6 +62,7 @@ int dccp_parse_options(struct sock *sk, 
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const u8 pkt_type = DCCP_SKB_CB(skb)->dccpd_type;
+	u64 ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
 	unsigned char *opt_ptr = options;
 	const unsigned char *opt_end = (unsigned char *)dh +
@@ -149,7 +150,7 @@ int dccp_parse_options(struct sock *sk, 
 				break;
 
 			if (dccp_msk(sk)->dccpms_send_ack_vector &&
-			    dccp_ackvec_parse(sk, skb, opt, value, len))
+			    dccp_ackvec_parse(sk, skb, &ackno, opt, value, len))
 				goto out_invalid_option;
 			break;
 		case DCCPO_TIMESTAMP:
-- 
1.4.2.1.g3d5c

