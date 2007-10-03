From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:47 +0000
Subject: [PATCH 9/14]: Phase out the use of boolean flag for Ack Vectors
Message-Id: <200710031502.47513@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[ACKVEC]: Phase out the use of boolean flag for Ack Vectors

This removes the use of the sysctl and the minisock variable for the Send Ack
Vector feature, which is now handled fully dynamically via feature negotiation;
i.e. when CCID2 is enabled, Ack Vectors are automatically enabled (as per RFC 4341, 4.).

Using a sysctl in parallel to this implementation would open the door to crashes, since
much of the code relies on tests of the boolean minisock / sysctl variable. Thus, this
patch replaces all tests of type

	if (dccp_msk(sk)->dccpms_send_ack_vector)
		/* ... */
with
	if (dp->dccps_hc_rx_ackvec != NULL)
		/* ... */

The dccps_hc_rx_ackvec is allocated by the dccp_hdlr_ackvec() when feature negotiation
concluded that Ack Vectors are to be used on the half-connection. Otherwise, it is NULL
(due to dccp_init_sock/dccp_create_openreq_child), so that the test is a valid one.

The activation handler for Ack Vectors is called as soon as the feature negotiation has
concluded:
 * at the server when the Ack marking the transition RESPOND => OPEN arrives;
 * at the client after it has sent above ACK, marking the transition REQUEST => PARTOPEN.

To support Ack Vectors as early as possible, adding the sequence number from the server-Response
in dccp_rcv_request_sent_state_process() has been enabled by shifting the call to dccp_ackvec_add()
after dccp_feat_activate_values() (which takes care of all the feature activation).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    3 ---
 net/dccp/dccp.h      |    3 +--
 net/dccp/diag.c      |    2 +-
 net/dccp/input.c     |   22 ++++++++++++----------
 net/dccp/minisocks.c |    1 -
 net/dccp/options.c   |    5 ++---
 net/dccp/proto.c     |    3 +--
 net/dccp/sysctl.c    |    8 --------
 8 files changed, 17 insertions(+), 30 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -138,8 +138,7 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_ACK_VECTOR_1:
 			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
-
-			if (dccp_msk(sk)->dccpms_send_ack_vector &&
+			if (dp->dccps_hc_rx_ackvec != NULL &&
 			    dccp_ackvec_parse(sk, skb, &ackno, opt, value, len))
 				goto out_invalid_option;
 			break;
@@ -528,7 +527,7 @@ int dccp_insert_options(struct sock *sk,
 			 */
 			if (dccp_insert_option_timestamp(sk, skb))
 				return -1;
-		} else if (dmsk->dccpms_send_ack_vector &&
+		} else if (dp->dccps_hc_rx_ackvec != NULL &&
 			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
 			   dccp_insert_option_ackvec(sk, skb))
 				return -1;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -202,7 +202,6 @@ EXPORT_SYMBOL_GPL(dccp_init_sock);
 int dccp_destroy_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	/*
 	 * DCCP doesn't use sk_write_queue, just sk_send_head
@@ -225,7 +224,7 @@ int dccp_destroy_sock(struct sock *sk)
 		dp->dccps_tstamp = NULL;
 	}
 
-	if (dmsk->dccpms_send_ack_vector) {
+	if (dp->dccps_hc_rx_ackvec != NULL) {
 		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 		dp->dccps_hc_rx_ackvec = NULL;
 	}
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -29,7 +29,7 @@ static void dccp_get_info(struct sock *s
 	info->tcpi_backoff	= icsk->icsk_backoff;
 	info->tcpi_pmtu		= icsk->icsk_pmtu_cookie;
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector)
+	if (dp->dccps_hc_rx_ackvec != NULL)
 		info->tcpi_options |= TCPI_OPT_SACK;
 
 	ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -121,7 +121,7 @@ static void dccp_event_ack_recv(struct s
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector)
+	if (dp->dccps_hc_rx_ackvec != NULL)
 		dccp_ackvec_check_rcv_ackno(dp->dccps_hc_rx_ackvec, sk,
 					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
@@ -330,7 +330,7 @@ int dccp_rcv_established(struct sock *sk
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_event_ack_recv(sk, skb);
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector &&
+	if (dp->dccps_hc_rx_ackvec != NULL &&
 	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 			    DCCP_SKB_CB(skb)->dccpd_seq,
 			    DCCP_ACKVEC_STATE_RECEIVED))
@@ -395,12 +395,6 @@ static int dccp_rcv_request_sent_state_p
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
 			    dp->dccps_options_received.dccpor_timestamp_echo));
 
-		if (dccp_msk(sk)->dccpms_send_ack_vector &&
-		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
-			goto unable_to_proceed;
-
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
 		/*
@@ -464,10 +458,18 @@ static int dccp_rcv_request_sent_state_p
 		/*
 		 * If feature negotiation throws an error, we can not proceed
 		 * (one or more feature values are undefined), so we send a
-		 * Reset. Otherwise, the Ack will clear any pending Confirms.
+		 * Reset. Otherwise, the Ack will clear any pending Confirms;
+		 * and activate_values may have activated sending Ack Vectors.
 		 */
 		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
 			goto unable_to_proceed;
+
+		if (dp->dccps_hc_rx_ackvec != NULL &&
+		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
+				    DCCP_SKB_CB(skb)->dccpd_seq,
+				    DCCP_ACKVEC_STATE_RECEIVED))
+			goto unable_to_proceed;
+
 		dccp_send_ack(sk);
 		return -1;
 	}
@@ -591,7 +593,7 @@ int dccp_rcv_state_process(struct sock *
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);
 
-		if (dccp_msk(sk)->dccpms_send_ack_vector &&
+		if (dp->dccps_hc_rx_ackvec != NULL &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 				    DCCP_SKB_CB(skb)->dccpd_seq,
 				    DCCP_ACKVEC_STATE_RECEIVED))
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -372,7 +372,6 @@ static inline unsigned int dccp_hdr_len(
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
 #define DCCPF_INITIAL_CCID			DCCPC_CCID2
-#define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
@@ -382,7 +381,6 @@ static inline unsigned int dccp_hdr_len(
   * Will be used to pass the state from dccp_request_sock to dccp_sock.
   *
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
-  * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
   * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
   * @dccpms_pending - List of features being negotiated
@@ -390,7 +388,6 @@ static inline unsigned int dccp_hdr_len(
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
-	__u8			dccpms_send_ack_vector;
 	__u8			dccpms_send_ndp_count;
 	__u8			dccpms_ack_ratio;
 	struct list_head	dccpms_pending;
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -99,7 +99,6 @@ extern int  sysctl_dccp_feat_sequence_wi
 extern int  sysctl_dccp_feat_rx_ccid;
 extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_feat_ack_ratio;
-extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
@@ -415,7 +414,7 @@ static inline int dccp_ack_pending(const
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_tstamp != NULL ||
 #ifdef CONFIG_IP_DCCP_ACKVEC
-	       (dccp_msk(sk)->dccpms_send_ack_vector &&
+	       (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
 #endif
 	       inet_csk_ack_scheduled(sk);
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -46,7 +46,6 @@ void dccp_minisock_init(struct dccp_mini
 {
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
 	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
-	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
 }
 
 void dccp_time_wait(struct sock *sk, int state, int timeo)
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -19,7 +19,6 @@ int sysctl_dccp_feat_sequence_window = D
 int sysctl_dccp_feat_rx_ccid	     = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_tx_ccid	     = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_ack_ratio	     = DCCPF_INITIAL_ACK_RATIO;
-int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
 
 /* the maximum queue length for tx in packets. 0 is no limit */
 int sysctl_dccp_tx_qlen		__read_mostly = 5;
@@ -64,13 +63,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "send_ackvec",
-		.data		= &sysctl_dccp_feat_send_ack_vector,
-		.maxlen		= sizeof(sysctl_dccp_feat_send_ack_vector),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
