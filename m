From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:29 +0000
Subject: [PATCH 6/11][DCCP] ackvec: Introduce ack vector records
Message-Id: <39e6f6c70602031838x507afb2cm86aab1de5d533a1d@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11470_12356203.1139020709778"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11470_12356203.1139020709778
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11470_12356203.1139020709778
Content-Type: text/x-patch; name=6.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bahp4
Content-Disposition: attachment; filename="6.patch"

tree eb7f8a8d6cd052db0733fe81197fa99897c7f338
parent afdb503062867b41594a55474660105ad386dfc4
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138971876 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138971876 -0200

[DCCP] ackvec: Introduce ack vector records

Based on a patch by Andrea Bittau.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |  240 ++++++++++++++++++++++++++++++++++++++-------------------------
 ackvec.h |   31 ++++++--
 2 files changed, 173 insertions(+), 98 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 6440825..2a82acc 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -22,6 +22,47 @@
 #include <net/sock.h>
 
 static kmem_cache_t *dccp_ackvec_slab;
+static kmem_cache_t *dccp_ackvec_record_slab;
+
+static struct dccp_ackvec_record *dccp_ackvec_record_new(void)
+{
+	struct dccp_ackvec_record *avr =
+			kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
+
+	if (avr != NULL)
+		INIT_LIST_HEAD(&avr->dccpavr_node);
+
+	return avr;
+}
+
+static void dccp_ackvec_record_delete(struct dccp_ackvec_record *avr)
+{
+	if (unlikely(avr == NULL))
+		return;
+	/* Check if deleting a linked record */
+	WARN_ON(!list_empty(&avr->dccpavr_node));
+	kmem_cache_free(dccp_ackvec_record_slab, avr);
+}
+ 
+static void dccp_ackvec_insert_avr(struct dccp_ackvec *av, 
+				   struct dccp_ackvec_record *avr)
+{
+	/*
+	 * AVRs are sorted by seqno. Since we are sending them in order, we
+	 * just add the AVR at the head of the list.
+	 * -sorbo.
+	 */
+	if (!list_empty(&av->dccpav_records)) {
+		const struct dccp_ackvec_record *head =
+					list_entry(av->dccpav_records.next,
+						   struct dccp_ackvec_record,
+						   dccpavr_node);
+		BUG_ON(before48(avr->dccpavr_ack_seqno,
+				head->dccpavr_ack_seqno));
+	}
+
+	list_add(&avr->dccpavr_node, &av->dccpav_records);
+}
 
 int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
@@ -35,6 +76,14 @@ int dccp_insert_option_ackvec(struct soc
 	struct timeval now;
 	u32 elapsed_time;
 	unsigned char *to, *from;
+	struct dccp_ackvec_record *avr;
+
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
+		return -1;
+
+	avr = dccp_ackvec_record_new();
+	if (avr == NULL)
+		return -1;
 
 	dccp_timestamp(sk, &now);
 	elapsed_time = timeval_delta(&now, &av->dccpav_time) / 10;
@@ -42,19 +91,6 @@ int dccp_insert_option_ackvec(struct soc
 	if (elapsed_time != 0)
 		dccp_insert_option_elapsed_time(sk, skb, elapsed_time);
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-		return -1;
-
-	/*
-	 * XXX: now we have just one ack vector sent record, so
-	 * we have to wait for it to be cleared.
-	 *
-	 * Of course this is not acceptable, but this is just for
-	 * basic testing now.
-	 */
-	if (av->dccpav_ack_seqno != DCCP_MAX_SEQNO + 1)
-		return -1;
-
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
 	to    = skb_push(skb, len);
@@ -65,8 +101,8 @@ int dccp_insert_option_ackvec(struct soc
 	from = av->dccpav_buf + av->dccpav_buf_head;
 
 	/* Check if buf_head wraps */
-	if ((int)av->dccpav_buf_head + len > av->dccpav_vec_len) {
-		const u32 tailsize = av->dccpav_vec_len - av->dccpav_buf_head;
+	if ((int)av->dccpav_buf_head + len > DCCP_MAX_ACKVEC_LEN) {
+		const u32 tailsize = DCCP_MAX_ACKVEC_LEN - av->dccpav_buf_head;
 
 		memcpy(to, from, tailsize);
 		to   += tailsize;
@@ -83,21 +119,21 @@ int dccp_insert_option_ackvec(struct soc
 	 *	sequence number it used for the ack packet; ack_ptr will equal
 	 *	buf_head; ack_ackno will equal buf_ackno; and ack_nonce will
 	 *	equal buf_nonce.
-	 *
-	 * This implemention uses just one ack record for now.
 	 */
-	av->dccpav_ack_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-	av->dccpav_ack_ptr   = av->dccpav_buf_head;
-	av->dccpav_ack_ackno = av->dccpav_buf_ackno;
-	av->dccpav_ack_nonce = av->dccpav_buf_nonce;
-	av->dccpav_sent_len  = av->dccpav_vec_len;
+	avr->dccpavr_ack_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	avr->dccpavr_ack_ptr   = av->dccpav_buf_head;
+	avr->dccpavr_ack_ackno = av->dccpav_buf_ackno;
+	avr->dccpavr_ack_nonce = av->dccpav_buf_nonce;
+	avr->dccpavr_sent_len  = av->dccpav_vec_len;
+
+	dccp_ackvec_insert_avr(av, avr);
 
 	dccp_pr_debug("%sACK Vector 0, len=%d, ack_seqno=%llu, "
 		      "ack_ackno=%llu\n",
-		      debug_prefix, av->dccpav_sent_len,
-		      (unsigned long long)av->dccpav_ack_seqno,
-		      (unsigned long long)av->dccpav_ack_ackno);
-	return -1;
+		      debug_prefix, avr->dccpavr_sent_len,
+		      (unsigned long long)avr->dccpavr_ack_seqno,
+		      (unsigned long long)avr->dccpavr_ack_ackno);
+	return 0;
 }
 
 struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
@@ -107,13 +143,13 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 	if (av != NULL) {
 		av->dccpav_buf_head	=
 			av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
-		av->dccpav_buf_ackno	=
-			av->dccpav_ack_ackno = av->dccpav_ack_seqno = ~0LLU;
+		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
 		av->dccpav_ack_ptr	= 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
 		av->dccpav_sent_len	= av->dccpav_vec_len = 0;
+		INIT_LIST_HEAD(&av->dccpav_records);
 	}
 
 	return av;
@@ -121,6 +157,9 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
 
 void dccp_ackvec_free(struct dccp_ackvec *av)
 {
+	if (unlikely(av == NULL))
+		return;
+	WARN_ON(!list_empty(&av->dccpav_records));
 	kmem_cache_free(dccp_ackvec_slab, av);
 }
 
@@ -299,44 +338,50 @@ void dccp_ackvec_print(const struct dccp
 }
 #endif
 
-static void dccp_ackvec_throw_away_ack_record(struct dccp_ackvec *av)
+static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
+				     struct dccp_ackvec_record *avr)
 {
-	/*
-	 * As we're keeping track of the ack vector size (dccpav_vec_len) and
-	 * the sent ack vector size (dccpav_sent_len) we don't need
-	 * dccpav_buf_tail at all, but keep this code here as in the future
-	 * we'll implement a vector of ack records, as suggested in
-	 * draft-ietf-dccp-spec-11.txt Appendix A. -acme
-	 */
-#if 0
-	u32 new_buf_tail = av->dccpav_ack_ptr + 1;
-	if (new_buf_tail >= av->dccpav_vec_len)
-		new_buf_tail -= av->dccpav_vec_len;
-	av->dccpav_buf_tail = new_buf_tail;
-#endif
-	av->dccpav_vec_len -= av->dccpav_sent_len;
+	struct dccp_ackvec_record *next;
+
+	av->dccpav_buf_tail = avr->dccpavr_ack_ptr - 1;
+	if (av->dccpav_buf_tail == 0)
+		av->dccpav_buf_tail = DCCP_MAX_ACKVEC_LEN - 1;
+
+	av->dccpav_vec_len -= avr->dccpavr_sent_len;
+
+	/* free records */
+	list_for_each_entry_safe_from(avr, next, &av->dccpav_records,
+				      dccpavr_node) {
+		list_del_init(&avr->dccpavr_node);
+		dccp_ackvec_record_delete(avr);
+	}
 }
 
 void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av, struct sock *sk,
 				 const u64 ackno)
 {
-	/* Check if we actually sent an ACK vector */
-	if (av->dccpav_ack_seqno == DCCP_MAX_SEQNO + 1)
-		return;
+	struct dccp_ackvec_record *avr;
 
-	if (ackno == av->dccpav_ack_seqno) {
+	/*
+	 * If we traverse backwards, it should be faster when we have large
+	 * windows. We will be receiving ACKs for stuff we sent a while back
+	 * -sorbo.
+	 */
+	list_for_each_entry_reverse(avr, &av->dccpav_records, dccpavr_node) {
+		if (ackno == avr->dccpavr_ack_seqno) {
 #ifdef CONFIG_IP_DCCP_DEBUG
-		struct dccp_sock *dp = dccp_sk(sk);
-		const char *debug_prefix = dp->dccps_role == DCCP_ROLE_CLIENT ?
-					"CLIENT rx ack: " : "server rx ack: ";
+			struct dccp_sock *dp = dccp_sk(sk);
+			const char *debug_prefix = dp->dccps_role == DCCP_ROLE_CLIENT ?
+						"CLIENT rx ack: " : "server rx ack: ";
 #endif
-		dccp_pr_debug("%sACK packet 0, len=%d, ack_seqno=%llu, "
-			      "ack_ackno=%llu, ACKED!\n",
-			      debug_prefix, 1,
-			      (unsigned long long)av->dccpav_ack_seqno,
-			      (unsigned long long)av->dccpav_ack_ackno);
-		dccp_ackvec_throw_away_ack_record(av);
-		av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
+			dccp_pr_debug("%sACK packet 0, len=%d, ack_seqno=%llu, "
+				      "ack_ackno=%llu, ACKED!\n",
+				      debug_prefix, 1,
+				      (unsigned long long)avr->dccpavr_ack_seqno,
+				      (unsigned long long)avr->dccpavr_ack_ackno);
+			dccp_ackvec_throw_record(av, avr);
+			break;
+		}
 	}
 }
 
@@ -346,28 +391,20 @@ static void dccp_ackvec_check_rcv_ackvec
 					    const unsigned char *vector)
 {
 	unsigned char i;
+	struct dccp_ackvec_record *avr;
 
 	/* Check if we actually sent an ACK vector */
-	if (av->dccpav_ack_seqno == DCCP_MAX_SEQNO + 1)
+	if (list_empty(&av->dccpav_records))
 		return;
-	/*
-	 * We're in the receiver half connection, so if the received an ACK
-	 * vector ackno (e.g. 50) before dccpav_ack_seqno (e.g. 52), we're
-	 * not interested.
-	 *
-	 * Extra explanation with example:
-	 * 
-	 * if we received an ACK vector with ackno 50, it can only be acking
-	 * 50, 49, 48, etc, not 52 (the seqno for the ACK vector we sent).
-	 */
-	/* dccp_pr_debug("is %llu < %llu? ", ackno, av->dccpav_ack_seqno); */
-	if (before48(ackno, av->dccpav_ack_seqno)) {
-		/* dccp_pr_debug_cat("yes\n"); */
-		return;
-	}
-	/* dccp_pr_debug_cat("no\n"); */
 
 	i = len;
+	/*
+	 * XXX
+	 * I think it might be more efficient to work backwards. See comment on
+	 * rcv_ackno. -sorbo.
+	 */
+	avr = list_entry(av->dccpav_records.next, struct dccp_ackvec_record,
+			 dccpavr_node);
 	while (i--) {
 		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
 		u64 ackno_end_rl;
@@ -375,14 +412,20 @@ static void dccp_ackvec_check_rcv_ackvec
 		dccp_set_seqno(&ackno_end_rl, ackno - rl);
 
 		/*
-		 * dccp_pr_debug("is %llu <= %llu <= %llu? ", ackno_end_rl,
-		 * av->dccpav_ack_seqno, ackno);
+		 * If our AVR sequence number is greater than the ack, go
+		 * forward in the AVR list until it is not so.
 		 */
-		if (between48(av->dccpav_ack_seqno, ackno_end_rl, ackno)) {
+		list_for_each_entry_from(avr, &av->dccpav_records,
+					 dccpavr_node) {
+			if (!after48(avr->dccpavr_ack_seqno, ackno))
+				goto found;
+		}
+		/* End of the dccpav_records list, not found, exit */
+		break;
+found:
+		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
 			const u8 state = (*vector &
 					  DCCP_ACKVEC_STATE_MASK) >> 6;
-			/* dccp_pr_debug_cat("yes\n"); */
-
 			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
 #ifdef CONFIG_IP_DCCP_DEBUG
 				struct dccp_sock *dp = dccp_sk(sk);
@@ -395,19 +438,16 @@ static void dccp_ackvec_check_rcv_ackvec
 					      "ACKED!\n",
 					      debug_prefix, len,
 					      (unsigned long long)
-					      av->dccpav_ack_seqno,
+					      avr->dccpavr_ack_seqno,
 					      (unsigned long long)
-					      av->dccpav_ack_ackno);
-				dccp_ackvec_throw_away_ack_record(av);
+					      avr->dccpavr_ack_ackno);
+				dccp_ackvec_throw_record(av, avr);
 			}
 			/*
-			 * If dccpav_ack_seqno was not received, no problem
-			 * we'll send another ACK vector.
+			 * If it wasn't received, continue scanning... we might
+			 * find another one.
 			 */
-			av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
-			break;
 		}
-		/* dccp_pr_debug_cat("no\n"); */
 
 		dccp_set_seqno(&ackno, ackno_end_rl - 1);
 		++vector;
@@ -428,19 +468,31 @@ int dccp_ackvec_parse(struct sock *sk, c
 }
 
 static char dccp_ackvec_slab_msg[] __initdata =
-	KERN_CRIT "DCCP: Unable to create ack vectors slab cache\n";
+	KERN_CRIT "DCCP: Unable to create ack vectors slab caches\n";
 
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
 					     sizeof(struct dccp_ackvec), 0,
 					     SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (dccp_ackvec_slab == NULL) {
-		printk(dccp_ackvec_slab_msg);
-		return -ENOBUFS;
-	}
+	if (dccp_ackvec_slab == NULL)
+		goto out_err;
+
+	dccp_ackvec_record_slab =
+			kmem_cache_create("dccp_ackvec_record",
+					  sizeof(struct dccp_ackvec_record),
+					  0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (dccp_ackvec_record_slab == NULL)
+		goto out_destroy_slab;
 
 	return 0;
+
+out_destroy_slab:
+	kmem_cache_destroy(dccp_ackvec_slab);
+	dccp_ackvec_slab = NULL;
+out_err:
+	printk(dccp_ackvec_slab_msg);
+	return -ENOBUFS;
 }
 
 void dccp_ackvec_exit(void)
@@ -449,4 +501,8 @@ void dccp_ackvec_exit(void)
 		kmem_cache_destroy(dccp_ackvec_slab);
 		dccp_ackvec_slab = NULL;
 	}
+	if (dccp_ackvec_record_slab != NULL) {
+		kmem_cache_destroy(dccp_ackvec_record_slab);
+		dccp_ackvec_record_slab = NULL;
+	}
 }
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 470bae8..1d9ec4a 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -13,6 +13,7 @@
 
 #include <linux/config.h>
 #include <linux/compiler.h>
+#include <linux/list.h>
 #include <linux/time.h>
 #include <linux/types.h>
 
@@ -42,11 +43,8 @@
  * Ack Vectors it has recently sent. For each packet sent carrying an
  * Ack Vector, it remembers four variables:
  *
- * @dccpav_ack_seqno - the Sequence Number used for the packet
- * 		       (HC-Receiver seqno)
  * @dccpav_ack_ptr - the value of buf_head at the time of acknowledgement.
- * @dccpav_ack_ackno - the Acknowledgement Number used for the packet
- * 		       (HC-Sender seqno)
+ * @dccpav_records - list of dccp_ackvec_record
  * @dccpav_ack_nonce - the one-bit sum of the ECN Nonces for all State 0.
  *
  * @dccpav_time		- the time in usecs
@@ -54,8 +52,7 @@
  */
 struct dccp_ackvec {
 	u64		dccpav_buf_ackno;
-	u64		dccpav_ack_seqno;
-	u64		dccpav_ack_ackno;
+	struct list_head dccpav_records;
 	struct timeval	dccpav_time;
 	u8		dccpav_buf_head;
 	u8		dccpav_buf_tail;
@@ -67,6 +64,28 @@ struct dccp_ackvec {
 	u8		dccpav_buf[DCCP_MAX_ACKVEC_LEN];
 };
 
+/** struct dccp_ackvec_record - ack vector record
+ *
+ * ACK vector record as defined in Appendix A of spec. 
+ *
+ * The list is sorted by dccpavr_ack_seqno
+ *
+ * @dccpavr_node - node in dccpav_records
+ * @dccpavr_ack_seqno - sequence number of the packet this record was sent on
+ * @dccpavr_ack_ackno - sequence number being acknowledged
+ * @dccpavr_ack_ptr - pointer into dccpav_buf where this record starts
+ * @dccpavr_ack_nonce - dccpav_ack_nonce at the time this record was sent
+ * @dccpavr_sent_len - lenght of the record in dccpav_buf
+ */
+struct dccp_ackvec_record {
+	struct list_head dccpavr_node;
+	u64		 dccpavr_ack_seqno;
+	u64		 dccpavr_ack_ackno;
+	u8		 dccpavr_ack_ptr;
+	u8		 dccpavr_ack_nonce;
+	u8		 dccpavr_sent_len;
+};
+
 struct sock;
 struct sk_buff;
 

------=_Part_11470_12356203.1139020709778--
