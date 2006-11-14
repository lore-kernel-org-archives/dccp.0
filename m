From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 14 Nov 2006 15:59:46 +0000
Subject: [PATCH 4/5][DCCP]: Miscellaneous code tidy-ups
Message-Id: <20061114155945.GF6903@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch does not change code; it performs some trivial clean/tidy-ups:

  * removal of a `debug_prefix' string in favour of the
    already existing dccp_role(sk)

  * add documentation of structures and constants

  * separated out the cases for invalid packets (step 1
    of the packet validation)

  * removing duplicate statements

  * combining declaration & initialisation

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/linux/dccp.h |   18 +++++++++++++++++-
 net/dccp/ackvec.c    |   27 ++++++---------------------
 net/dccp/ipv4.c      |   39 +++++++++++++++++++--------------------
 net/dccp/ipv6.c      |    6 ++----
 net/dccp/options.c   |   18 +++++++-----------
 net/dccp/output.c    |    1 +
 net/dccp/proto.c     |    8 ++------
 7 files changed, 54 insertions(+), 63 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 696319e..d308f12 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -209,6 +209,7 @@ #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
+/* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
 
 #ifdef __KERNEL__
@@ -355,6 +356,9 @@ #define DCCP_NDP_LIMIT 0xFFFFFF
   * @dccpms_ccid - Congestion Control Id (CCID) (section 10)
   * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
   * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
+  * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
+  * @dccpms_pending - List of features being negotiated
+  * @dccpms_conf -
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
@@ -452,14 +456,26 @@ struct dccp_ackvec;
  * @dccps_gss - greatest sequence number sent
  * @dccps_gsr - greatest valid sequence number received
  * @dccps_gar - greatest valid ack number received on a non-Sync; initialized to %dccps_iss
+ * @dccps_service - first (passive sock) or unique (active sock) service code
+ * @dccps_service_list - second .. last service code on passive socket
  * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
  * @dccps_packet_size - Set thru setsockopt
- * @dccps_role - Role of this sock, one of %dccp_role
+ * @dccps_l_ack_ratio -
+ * @dccps_r_ack_ratio -
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
+ * @dccps_mss_cache -
+ * @dccps_minisock -
  * @dccps_hc_rx_ackvec - rx half connection ack vector
+ * @dccps_hc_rx_ccid -
+ * @dccps_hc_tx_ccid -
+ * @dccps_options_received -
+ * @dccps_epoch -
+ * @dccps_role - Role of this sock, one of %dccp_role
+ * @dccps_hc_rx_insert_options -
+ * @dccps_hc_tx_insert_options -
  * @dccps_xmit_timer - timer for when CCID is not ready to send
  */
 struct dccp_sock {
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index f820887..0c54b89 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -67,10 +67,6 @@ static void dccp_ackvec_insert_avr(struc
 int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-#ifdef CONFIG_IP_DCCP_DEBUG
-	const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
-				"CLIENT tx: " : "server tx: ";
-#endif
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	int len = av->dccpav_vec_len + 2;
 	struct timeval now;
@@ -129,9 +125,9 @@ #endif
 
 	dccp_ackvec_insert_avr(av, avr);
 
-	dccp_pr_debug("%sACK Vector 0, len=%d, ack_seqno=%llu, "
+	dccp_pr_debug("%s ACK Vector 0, len=%d, ack_seqno=%llu, "
 		      "ack_ackno=%llu\n",
-		      debug_prefix, avr->dccpavr_sent_len,
+		      dccp_role(sk), avr->dccpavr_sent_len,
 		      (unsigned long long)avr->dccpavr_ack_seqno,
 		      (unsigned long long)avr->dccpavr_ack_ackno);
 	return 0;
@@ -380,14 +376,9 @@ void dccp_ackvec_check_rcv_ackno(struct 
 	 */
 	list_for_each_entry_reverse(avr, &av->dccpav_records, dccpavr_node) {
 		if (ackno = avr->dccpavr_ack_seqno) {
-#ifdef CONFIG_IP_DCCP_DEBUG
-			struct dccp_sock *dp = dccp_sk(sk);
-			const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
-						"CLIENT rx ack: " : "server rx ack: ";
-#endif
-			dccp_pr_debug("%sACK packet 0, len=%d, ack_seqno=%llu, "
+			dccp_pr_debug("%s ACK packet 0, len=%d, ack_seqno=%llu, "
 				      "ack_ackno=%llu, ACKED!\n",
-				      debug_prefix, 1,
+				      dccp_role(sk), 1,
 				      (unsigned long long)avr->dccpavr_ack_seqno,
 				      (unsigned long long)avr->dccpavr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
@@ -437,16 +428,10 @@ found:
 		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
 			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
 			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
-#ifdef CONFIG_IP_DCCP_DEBUG
-				struct dccp_sock *dp = dccp_sk(sk);
-				const char *debug_prefix -					dp->dccps_role = DCCP_ROLE_CLIENT ?
-					"CLIENT rx ack: " : "server rx ack: ";
-#endif
-				dccp_pr_debug("%sACK vector 0, len=%d, "
+				dccp_pr_debug("%s ACK vector 0, len=%d, "
 					      "ack_seqno=%llu, ack_ackno=%llu, "
 					      "ACKED!\n",
-					      debug_prefix, len,
+					      dccp_role(sk), len,
 					      (unsigned long long)
 					      avr->dccpavr_ack_seqno,
 					      (unsigned long long)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 61c0901..34d6d19 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -518,7 +518,7 @@ static void dccp_v4_ctl_send_reset(struc
 				       sizeof(struct dccp_hdr_reset);
 	struct sk_buff *skb;
 	struct dst_entry *dst;
-	u64 seqno;
+	u64 seqno = 0;
 
 	/* Never send a reset in response to a reset. */
 	if (rxdh->dccph_type = DCCP_PKT_RESET)
@@ -552,13 +552,11 @@ static void dccp_v4_ctl_send_reset(struc
 				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
-	seqno = 0;
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
 
 	dccp_hdr_set_seq(dh, seqno);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
-			 DCCP_SKB_CB(rxskb)->dccpd_seq);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
 
 	dccp_csum_outgoing(skb);
 	dh->dccph_checksum = dccp_v4_csum_finish(skb, rxskb->nh.iph->saddr,
@@ -734,6 +732,11 @@ discard:
 
 EXPORT_SYMBOL_GPL(dccp_v4_do_rcv);
 
+/**
+ *	dccp_invalid_packet  -  check for malformed packets
+ *	Implements RFC 4340, 8.5:  Step 1: Check header basics
+ *	Packets that fail these checks are ignored and do not receive Resets.
+ */
 int dccp_invalid_packet(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
@@ -742,6 +745,7 @@ int dccp_invalid_packet(struct sk_buff *
 	if (skb->pkt_type != PACKET_HOST)
 		return 1;
 
+	/* If the packet is shorter than 12 bytes, drop packet and return */
 	if (!pskb_may_pull(skb, sizeof(struct dccp_hdr))) {
 		LIMIT_NETDEBUG(KERN_WARNING "DCCP: pskb_may_pull failed\n");
 		return 1;
@@ -749,42 +753,37 @@ int dccp_invalid_packet(struct sk_buff *
 
 	dh = dccp_hdr(skb);
 
-	/* If the packet type is not understood, drop packet and return */
+	/* If P.type is not understood, drop packet and return */
 	if (dh->dccph_type >= DCCP_PKT_INVALID) {
 		LIMIT_NETDEBUG(KERN_WARNING "DCCP: invalid packet type\n");
 		return 1;
 	}
 
 	/*
-	 * If P.Data Offset is too small for packet type, or too large for
-	 * packet, drop packet and return
+	 * If P.Data Offset is too small for packet type, drop packet and return
 	 */
 	if (dh->dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
 		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too small 1\n",
-			       dh->dccph_doff);
+					    "too small\n", dh->dccph_doff);
 		return 1;
 	}
-
+	/*
+	 * If P.Data Offset is too too large for packet, drop packet and return
+	 */
 	if (!pskb_may_pull(skb, dh->dccph_doff * sizeof(u32))) {
 		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too small 2\n",
-			       dh->dccph_doff);
+					    "too large\n", dh->dccph_doff);
 		return 1;
 	}
 
-	dh = dccp_hdr(skb);
-
 	/*
 	 * If P.type is not Data, Ack, or DataAck and P.X = 0 (the packet
 	 * has short sequence numbers), drop packet and return
 	 */
-	if (dh->dccph_x = 0 &&
-	    dh->dccph_type != DCCP_PKT_DATA &&
-	    dh->dccph_type != DCCP_PKT_ACK &&
-	    dh->dccph_type != DCCP_PKT_DATAACK) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.type (%s) not Data, Ack "
-					    "nor DataAck and P.X = 0\n",
+	if (dh->dccph_type >= DCCP_PKT_DATA    &&
+	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x = 0)  {
+		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.type (%s) not Data||Ack||"
+					    "DataAck, while P.X = 0\n",
 			       dccp_packet_name(dh->dccph_type));
 		return 1;
 	}
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 63b185d..7e26ecd 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -318,7 +318,7 @@ static void dccp_v6_ctl_send_reset(struc
 				       sizeof(struct dccp_hdr_reset);
 	struct sk_buff *skb;
 	struct flowi fl;
-	u64 seqno;
+	u64 seqno = 0;
 
 	if (rxdh->dccph_type = DCCP_PKT_RESET)
 		return;
@@ -345,13 +345,11 @@ static void dccp_v6_ctl_send_reset(struc
 				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
 
 	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
-	seqno = 0;
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
 
 	dccp_hdr_set_seq(dh, seqno);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
-			 DCCP_SKB_CB(rxskb)->dccpd_seq);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
 
 	dccp_csum_outgoing(skb);
 	dh->dccph_checksum = dccp_v6_csum_finish(skb, &rxskb->nh.ipv6h->saddr,
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 2d0ef27..7e50678 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -60,10 +60,6 @@ static u32 dccp_decode_value_var(const u
 int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-#ifdef CONFIG_IP_DCCP_DEBUG
-	const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
-					"CLIENT rx opt: " : "server rx opt: ";
-#endif
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const u8 pkt_type = DCCP_SKB_CB(skb)->dccpd_type;
 	unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
@@ -119,7 +115,7 @@ #endif
 				goto out_invalid_option;
 
 			opt_recv->dccpor_ndp = dccp_decode_value_var(value, len);
-			dccp_pr_debug("%sNDP count=%d\n", debug_prefix,
+			dccp_pr_debug("%s rx opt: NDP count=%d\n", dccp_role(sk),
 				      opt_recv->dccpor_ndp);
 			break;
 		case DCCPO_CHANGE_L:
@@ -165,8 +161,8 @@ #endif
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
 			dccp_timestamp(sk, &dp->dccps_timestamp_time);
 
-			dccp_pr_debug("%sTIMESTAMP=%u, ackno=%llu\n",
-				      debug_prefix, opt_recv->dccpor_timestamp,
+			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
+				      dccp_role(sk), opt_recv->dccpor_timestamp,
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			break;
@@ -176,8 +172,8 @@ #endif
 
 			opt_recv->dccpor_timestamp_echo = ntohl(*(__be32 *)value);
 
-			dccp_pr_debug("%sTIMESTAMP_ECHO=%u, len=%d, ackno=%llu, ",
-				      debug_prefix,
+			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
+				      "ackno=%llu, ",  dccp_role(sk),
 				      opt_recv->dccpor_timestamp_echo,
 				      len + 2,
 				      (unsigned long long)
@@ -211,8 +207,8 @@ #endif
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
 
-			dccp_pr_debug("%sELAPSED_TIME=%d\n", debug_prefix,
-				      elapsed_time);
+			dccp_pr_debug("%s rx opt: ELAPSED_TIME=%d\n",
+				      dccp_role(sk), elapsed_time);
 			break;
 			/*
 			 * From RFC 4340, sec. 10.3:
diff --git a/net/dccp/output.c b/net/dccp/output.c
index ef22f3c..c34eada 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -333,6 +333,7 @@ struct sk_buff *dccp_make_response(struc
 		return NULL;
 	}
 
+	/* Build and checksum header */
 	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
 	dh->dccph_sport	= inet_sk(sk)->sport;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 9c9c08c..0225bda 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -452,9 +452,8 @@ out_free_val:
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
-	struct dccp_sock *dp;
-	int err;
-	int val;
+	struct dccp_sock *dp = dccp_sk(sk);
+	int val, err = 0;
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -466,9 +465,6 @@ static int do_dccp_setsockopt(struct soc
 		return dccp_setsockopt_service(sk, val, optval, optlen);
 
 	lock_sock(sk);
-	dp = dccp_sk(sk);
-	err = 0;
-
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
 		dp->dccps_packet_size = val;
