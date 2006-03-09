From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:10 +0000
Subject: [PATCH 5/5] [DCCP] options: Make dccp_insert_options & friends yell on error
Message-Id: <11418736903418-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

And not the silly LIMIT_NETDEBUG and silently return without inserting
the option requested.

Also drop some old debugging messages associated to option insertion.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ackvec.c      |   14 +++---
 net/dccp/ccid.h        |   18 ++++----
 net/dccp/ccids/ccid3.c |   37 +++++++++-------
 net/dccp/dccp.h        |    8 ++--
 net/dccp/options.c     |  109 ++++++++++++++++++++----------------------------
 net/dccp/output.c      |   18 +++++++-
 6 files changed, 102 insertions(+), 102 deletions(-)

3dabf50385c2b28630c104ca8cdbb0be7b1b6d70
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 08b1b08..10ff54b 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -81,15 +81,16 @@ int dccp_insert_option_ackvec(struct soc
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
 		return -1;
 
-	avr = dccp_ackvec_record_new();
-	if (avr = NULL)
-		return -1;
-
 	dccp_timestamp(sk, &now);
 	elapsed_time = timeval_delta(&now, &av->dccpav_time) / 10;
 
-	if (elapsed_time != 0)
-		dccp_insert_option_elapsed_time(sk, skb, elapsed_time);
+	if (elapsed_time != 0 &&
+	    dccp_insert_option_elapsed_time(sk, skb, elapsed_time))
+		return -1;
+
+	avr = dccp_ackvec_record_new();
+	if (avr = NULL)
+		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
@@ -310,7 +311,6 @@ int dccp_ackvec_add(struct dccp_ackvec *
 	av->dccpav_buf_ackno = ackno;
 	dccp_timestamp(sk, &av->dccpav_time);
 out:
-	dccp_pr_debug("");
 	return 0;
 
 out_duplicate:
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 3199f07..803edad 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -41,9 +41,9 @@ struct ccid_operations {
 						    unsigned char option,
 						    unsigned char len, u16 idx,
 						    unsigned char* value);
-	void		(*ccid_hc_rx_insert_options)(struct sock *sk,
+	int		(*ccid_hc_rx_insert_options)(struct sock *sk,
 						     struct sk_buff *skb);
-	void		(*ccid_hc_tx_insert_options)(struct sock *sk,
+	int		(*ccid_hc_tx_insert_options)(struct sock *sk,
 						     struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_recv)(struct sock *sk,
 						  struct sk_buff *skb);
@@ -146,18 +146,20 @@ static inline int ccid_hc_rx_parse_optio
 	return rc;
 }
 
-static inline void ccid_hc_tx_insert_options(struct ccid *ccid, struct sock *sk,
-					     struct sk_buff *skb)
+static inline int ccid_hc_tx_insert_options(struct ccid *ccid, struct sock *sk,
+					    struct sk_buff *skb)
 {
 	if (ccid->ccid_ops->ccid_hc_tx_insert_options != NULL)
-		ccid->ccid_ops->ccid_hc_tx_insert_options(sk, skb);
+		return ccid->ccid_ops->ccid_hc_tx_insert_options(sk, skb);
+	return 0;
 }
 
-static inline void ccid_hc_rx_insert_options(struct ccid *ccid, struct sock *sk,
-					     struct sk_buff *skb)
+static inline int ccid_hc_rx_insert_options(struct ccid *ccid, struct sock *sk,
+					    struct sk_buff *skb)
 {
 	if (ccid->ccid_ops->ccid_hc_rx_insert_options != NULL)
-		ccid->ccid_ops->ccid_hc_rx_insert_options(sk, skb);
+		return ccid->ccid_ops->ccid_hc_rx_insert_options(sk, skb);
+	return 0;
 }
 
 static inline void ccid_hc_rx_get_info(struct ccid *ccid, struct sock *sk,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index ff426a9..0b9630b 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -574,16 +574,15 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 }
 
-static void ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
+static int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
 	BUG_ON(hctx = NULL);
 
-	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
-		return;
-
-	 DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	if (sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN)
+		DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	return 0;
 }
 
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
@@ -774,7 +773,7 @@ static void ccid3_hc_rx_send_feedback(st
 	dccp_send_ack(sk);
 }
 
-static void ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
+static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
@@ -782,23 +781,27 @@ static void ccid3_hc_rx_insert_options(s
 	BUG_ON(hcrx = NULL);
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
-		return;
+		return 0;
 
 	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_last_counter;
 
 	if (dccp_packet_without_ack(skb))
-		return;
-		
-	if (hcrx->ccid3hcrx_elapsed_time != 0)
-		dccp_insert_option_elapsed_time(sk, skb,
-						hcrx->ccid3hcrx_elapsed_time);
-	dccp_insert_option_timestamp(sk, skb);
+		return 0;
+
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
-	dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
-			   &pinv, sizeof(pinv));
-	dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
-			   &x_recv, sizeof(x_recv));
+		
+	if ((hcrx->ccid3hcrx_elapsed_time != 0 &&
+	     dccp_insert_option_elapsed_time(sk, skb,
+					     hcrx->ccid3hcrx_elapsed_time)) ||
+	    dccp_insert_option_timestamp(sk, skb) ||
+	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+		    	       &pinv, sizeof(pinv)) ||
+	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
+		    	       &x_recv, sizeof(x_recv)))
+		return -1;
+
+	return 0;
 }
 
 /* calculate first loss interval
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 7f5be08..34e70fb 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -326,13 +326,13 @@ static inline int dccp_ack_pending(const
 	       inet_csk_ack_scheduled(sk);
 }
 
-extern void dccp_insert_options(struct sock *sk, struct sk_buff *skb);
-extern void dccp_insert_option_elapsed_time(struct sock *sk,
+extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
+extern int dccp_insert_option_elapsed_time(struct sock *sk,
 					    struct sk_buff *skb,
 					    u32 elapsed_time);
-extern void dccp_insert_option_timestamp(struct sock *sk,
+extern int dccp_insert_option_timestamp(struct sock *sk,
 					 struct sk_buff *skb);
-extern void dccp_insert_option(struct sock *sk, struct sk_buff *skb,
+extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			       unsigned char option,
 			       const void *value, unsigned char len);
 
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 0161a18..da16760 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -283,17 +283,14 @@ static inline int dccp_ndp_len(const int
 	return likely(ndp <= 0xFF) ? 1 : ndp <= 0xFFFF ? 2 : 3;
 }
 
-void dccp_insert_option(struct sock *sk, struct sk_buff *skb,
+int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			const unsigned char option,
 			const void *value, const unsigned char len)
 {
 	unsigned char *to;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 2 > DCCP_MAX_OPT_LEN) {
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: packet too small to insert "
-			       "%d option!\n", option);
-		return;
-	}
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 2 > DCCP_MAX_OPT_LEN)
+		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len + 2;
 
@@ -302,11 +299,12 @@ void dccp_insert_option(struct sock *sk,
 	*to++ = len + 2;
 
 	memcpy(to, value, len);
+	return 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_insert_option);
 
-static void dccp_insert_option_ndp(struct sock *sk, struct sk_buff *skb)
+static int dccp_insert_option_ndp(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	int ndp = dp->dccps_ndp_count;
@@ -322,7 +320,7 @@ static void dccp_insert_option_ndp(struc
 		const int len = ndp_len + 2;
 
 		if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-			return;
+			return -1;
 
 		DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
@@ -331,6 +329,8 @@ static void dccp_insert_option_ndp(struc
 		*ptr++ = len;
 		dccp_encode_value_var(ndp, ptr, ndp_len);
 	}
+
+	return 0;
 }
 
 static inline int dccp_elapsed_time_len(const u32 elapsed_time)
@@ -338,27 +338,18 @@ static inline int dccp_elapsed_time_len(
 	return elapsed_time = 0 ? 0 : elapsed_time <= 0xFFFF ? 2 : 4;
 }
 
-void dccp_insert_option_elapsed_time(struct sock *sk,
-				     struct sk_buff *skb,
-				     u32 elapsed_time)
+int dccp_insert_option_elapsed_time(struct sock *sk, struct sk_buff *skb,
+				    u32 elapsed_time)
 {
-#ifdef CONFIG_IP_DCCP_DEBUG
-	struct dccp_sock *dp = dccp_sk(sk);
-	const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
-					"CLIENT TX opt: " : "server TX opt: ";
-#endif
 	const int elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	const int len = 2 + elapsed_time_len;
 	unsigned char *to;
 
 	if (elapsed_time_len = 0)
-		return;
+		return 0;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN) {
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: packet too small to "
-					 "insert elapsed time!\n");
-		return;
-	}
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
+		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
@@ -374,10 +365,7 @@ void dccp_insert_option_elapsed_time(str
 		memcpy(to, &var32, 4);
 	}
 
-	dccp_pr_debug("%sELAPSED_TIME=%u, len=%d, seqno=%llu\n",
-		      debug_prefix, elapsed_time,
-		      len,
-		      (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq);
+	return 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
@@ -398,7 +386,7 @@ void dccp_timestamp(const struct sock *s
 
 EXPORT_SYMBOL_GPL(dccp_timestamp);
 
-void dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
+int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
 	struct timeval tv;
 	__be32 now;
@@ -408,19 +396,15 @@ void dccp_insert_option_timestamp(struct
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
 
-	dccp_insert_option(sk, skb, DCCPO_TIMESTAMP, &now, sizeof(now));
+	return dccp_insert_option(sk, skb, DCCPO_TIMESTAMP, &now, sizeof(now));
 }
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_timestamp);
 
-static void dccp_insert_option_timestamp_echo(struct sock *sk,
-					      struct sk_buff *skb)
+static int dccp_insert_option_timestamp_echo(struct sock *sk,
+					     struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-#ifdef CONFIG_IP_DCCP_DEBUG
-	const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
-					"CLIENT TX opt: " : "server TX opt: ";
-#endif
 	struct timeval now;
 	__be32 tstamp_echo;
 	u32 elapsed_time;
@@ -432,11 +416,8 @@ static void dccp_insert_option_timestamp
 	elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	len = 6 + elapsed_time_len;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN) {
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: packet too small to insert "
-					 "timestamp echo!\n");
-		return;
-	}
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
+		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
@@ -456,14 +437,10 @@ static void dccp_insert_option_timestamp
 		memcpy(to, &var32, 4);
 	}
 
-	dccp_pr_debug("%sTIMESTAMP_ECHO=%u, len=%d, seqno=%llu\n",
-		      debug_prefix, dp->dccps_timestamp_echo,
-		      len,
-		      (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq);
-
 	dp->dccps_timestamp_echo = 0;
 	dp->dccps_timestamp_time.tv_sec = 0;
 	dp->dccps_timestamp_time.tv_usec = 0;
+	return 0;
 }
 
 static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
@@ -491,7 +468,7 @@ static int dccp_insert_feat_opt(struct s
 	return 0;
 }
 
-static void dccp_insert_feat(struct sock *sk, struct sk_buff *skb)
+static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_opt_pend *opt, *next;
@@ -551,44 +528,48 @@ static void dccp_insert_feat(struct sock
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
 	}
+
+	return 0;
 }
 
-void dccp_insert_options(struct sock *sk, struct sk_buff *skb)
+int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
-	if (dp->dccps_options.dccpo_send_ndp_count)
-		dccp_insert_option_ndp(sk, skb);
+	if (dp->dccps_options.dccpo_send_ndp_count &&
+	    dccp_insert_option_ndp(sk, skb))
+		return -1;
 
 	if (!dccp_packet_without_ack(skb)) {
 		if (dp->dccps_options.dccpo_send_ack_vector &&
-		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec))
-			dccp_insert_option_ackvec(sk, skb);
-		if (dp->dccps_timestamp_echo != 0)
-			dccp_insert_option_timestamp_echo(sk, skb);
+		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
+		    dccp_insert_option_ackvec(sk, skb))
+			return -1;
+
+		if (dp->dccps_timestamp_echo != 0 &&
+		    dccp_insert_option_timestamp_echo(sk, skb))
+			return -1;
 	}
 
 	if (dp->dccps_hc_rx_insert_options) {
-		ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb);
+		if (ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb))
+			return -1;
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 	if (dp->dccps_hc_tx_insert_options) {
-		ccid_hc_tx_insert_options(dp->dccps_hc_tx_ccid, sk, skb);
+		if (ccid_hc_tx_insert_options(dp->dccps_hc_tx_ccid, sk, skb))
+			return -1;
 		dp->dccps_hc_tx_insert_options = 0;
 	}
 
 	/* Feature negotiation */
-	switch(DCCP_SKB_CB(skb)->dccpd_type) {
-		/* Data packets can't do feat negotiation */
-	case DCCP_PKT_DATA:
-	case DCCP_PKT_DATAACK:
-		break;
-	default:
-		dccp_insert_feat(sk, skb);
-		break;
-	}
+	/* Data packets can't do feat negotiation */
+	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA &&
+	    DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATAACK &&
+	    dccp_insert_options_feat(sk, skb))
+		return -1;
 
 	/* XXX: insert other options when appropriate */
 
@@ -602,4 +583,6 @@ void dccp_insert_options(struct sock *sk
 			DCCP_SKB_CB(skb)->dccpd_opt_len += padding;
 		}
 	}
+
+	return 0;
 }
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 2975e3d..7409e4a 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -83,7 +83,11 @@ static int dccp_transmit_skb(struct sock
 		}
 
 		dcb->dccpd_seq = dp->dccps_gss;
-		dccp_insert_options(sk, skb);
+
+		if (dccp_insert_options(sk, skb)) {
+			kfree_skb(skb);
+			return -EPROTO;
+		}
 		
 		skb->h.raw = skb_push(skb, dccp_header_size);
 		dh = dccp_hdr(skb);
@@ -296,7 +300,11 @@ struct sk_buff *dccp_make_response(struc
 	dreq = dccp_rsk(req);
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
 	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
-	dccp_insert_options(sk, skb);
+
+	if (dccp_insert_options(sk, skb)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 
 	skb->h.raw = skb_push(skb, dccp_header_size);
 
@@ -344,7 +352,11 @@ static struct sk_buff *dccp_make_reset(s
 	DCCP_SKB_CB(skb)->dccpd_reset_code = code;
 	DCCP_SKB_CB(skb)->dccpd_type	   = DCCP_PKT_RESET;
 	DCCP_SKB_CB(skb)->dccpd_seq	   = dp->dccps_gss;
-	dccp_insert_options(sk, skb);
+
+	if (dccp_insert_options(sk, skb)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 
 	skb->h.raw = skb_push(skb, dccp_header_size);
 
-- 
1.2.2.gd27d


