From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:07 +0000
Subject: [PATCH 32/37] dccp ccid-2: Phase out the use of boolean Ack Vector sysctl
Message-Id: <1219945512-7723-33-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the use of the sysctl and the minisock variable for the Send Ack
Vector feature, which is now handled fully dynamically via feature negotiation;
i.e. when CCID2 is enabled, Ack Vectors are automatically enabled (as per
RFC 4341, 4.).

Using a sysctl in parallel to this implementation would open the door to
crashes, since much of the code relies on tests of the boolean minisock /
sysctl variable. Thus, this patch replaces all tests of type

	if (dccp_msk(sk)->dccpms_send_ack_vector)
		/* ... */
with
	if (dp->dccps_hc_rx_ackvec != NULL)
		/* ... */

The dccps_hc_rx_ackvec is allocated by the dccp_hdlr_ackvec() when feature
negotiation concluded that Ack Vectors are to be used on the half-connection.
Otherwise, it is NULL (due to dccp_init_sock/dccp_create_openreq_child),
so that the test is a valid one.

The activation handler for Ack Vectors is called as soon as the feature
negotiation has concluded at the
 * server when the Ack marking the transition RESPOND => OPEN arrives;
 * client after it has sent its ACK, marking the transition REQUEST => PARTOPEN.

Adding the sequence number of the Response packet to the Ack Vector has been
removed, since
 (a) connection establishment implies that the Response has been received;
 (b) the CCIDs only look at packets received in the (PART)OPEN state, i.e.
     this entry will always be ignored;
 (c) it can not be used for anything useful - to detect loss for instance, only
     packets received after the loss can serve as pseudo-dupacks.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    3 ---
 include/linux/dccp.h              |    3 ---
 net/dccp/dccp.h                   |    3 +--
 net/dccp/diag.c                   |    2 +-
 net/dccp/input.c                  |   12 +++---------
 net/dccp/minisocks.c              |    1 -
 net/dccp/options.c                |    7 ++-----
 net/dccp/proto.c                  |    3 +--
 net/dccp/sysctl.c                 |    7 -------
 9 files changed, 8 insertions(+), 33 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -133,9 +133,6 @@ retries2
 	importance for retransmitted acknowledgments and feature negotiation,
 	data packets are never retransmitted. Analogue of tcp_retries2.
 
-send_ackvec = 1
-	Whether or not to send Ack Vector options (sec. 11.5).
-
 tx_ccid = 2
 	Default CCID for the sender-receiver half-connection. Depending on the
 	choice of CCID, the Send Ack Vector feature is enabled automatically.
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -360,7 +360,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
 #define DCCPF_INITIAL_CCID			DCCPC_CCID2
-#define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
@@ -370,13 +369,11 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
   * Will be used to pass the state from dccp_request_sock to dccp_sock.
   *
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
-  * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
   * @dccpms_pending - List of features being negotiated
   * @dccpms_conf -
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
-	__u8			dccpms_send_ack_vector;
 	struct list_head	dccpms_pending;
 	struct list_head	dccpms_conf;
 };
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -98,7 +98,6 @@ extern int  sysctl_dccp_retries2;
 extern int  sysctl_dccp_feat_sequence_window;
 extern int  sysctl_dccp_feat_rx_ccid;
 extern int  sysctl_dccp_feat_tx_ccid;
-extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
@@ -434,7 +433,7 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_timestamp_echo != 0 ||
 #ifdef CONFIG_IP_DCCP_ACKVEC
-	       (dccp_msk(sk)->dccpms_send_ack_vector &&
+	       (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
 #endif
 	       inet_csk_ack_scheduled(sk);
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -29,7 +29,7 @@ static void dccp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_backoff	= icsk->icsk_backoff;
 	info->tcpi_pmtu		= icsk->icsk_pmtu_cookie;
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector)
+	if (dp->dccps_hc_rx_ackvec != NULL)
 		info->tcpi_options |= TCPI_OPT_SACK;
 
 	ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -163,7 +163,7 @@ static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector)
+	if (dp->dccps_hc_rx_ackvec != NULL)
 		dccp_ackvec_check_rcv_ackno(dp->dccps_hc_rx_ackvec, sk,
 					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
@@ -375,7 +375,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_event_ack_recv(sk, skb);
 
-	if (dccp_msk(sk)->dccpms_send_ack_vector &&
+	if (dp->dccps_hc_rx_ackvec != NULL &&
 	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 			    DCCP_SKB_CB(skb)->dccpd_seq,
 			    DCCP_ACKVEC_STATE_RECEIVED))
@@ -434,12 +434,6 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
 			    dp->dccps_options_received.dccpor_timestamp_echo));
 
-		if (dccp_msk(sk)->dccpms_send_ack_vector &&
-		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
-			goto out_invalid_packet; /* FIXME: change error code */
-
 		/* Stop the REQUEST timer */
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 		WARN_ON(sk->sk_send_head = NULL);
@@ -637,7 +631,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);
 
-		if (dccp_msk(sk)->dccpms_send_ack_vector &&
+		if (dp->dccps_hc_rx_ackvec != NULL &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 				    DCCP_SKB_CB(skb)->dccpd_seq,
 				    DCCP_ACKVEC_STATE_RECEIVED))
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -45,7 +45,6 @@ EXPORT_SYMBOL_GPL(dccp_death_row);
 void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
-	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
 }
 
 void dccp_time_wait(struct sock *sk, int state, int timeo)
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -26,7 +26,6 @@
 int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
 int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
-int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
 
 u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
@@ -145,8 +144,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_ACK_VECTOR_1:
 			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
-
-			if (dccp_msk(sk)->dccpms_send_ack_vector &&
+			if (dp->dccps_hc_rx_ackvec != NULL &&
 			    dccp_ackvec_parse(sk, skb, &ackno, opt, value, len))
 				goto out_invalid_option;
 			break;
@@ -526,7 +524,6 @@ static void dccp_insert_option_padding(struct sk_buff *skb)
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
@@ -547,7 +544,7 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 			if (dccp_insert_option_timestamp(sk, skb))
 				return -1;
 
-		} else if (dmsk->dccpms_send_ack_vector	&&
+		} else if (dp->dccps_hc_rx_ackvec != NULL &&
 			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
 			   dccp_insert_option_ackvec(sk, skb)) {
 				return -1;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -207,7 +207,6 @@ EXPORT_SYMBOL_GPL(dccp_init_sock);
 void dccp_destroy_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	/*
 	 * DCCP doesn't use sk_write_queue, just sk_send_head
@@ -225,7 +224,7 @@ void dccp_destroy_sock(struct sock *sk)
 	kfree(dp->dccps_service_list);
 	dp->dccps_service_list = NULL;
 
-	if (dmsk->dccpms_send_ack_vector) {
+	if (dp->dccps_hc_rx_ackvec != NULL) {
 		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 		dp->dccps_hc_rx_ackvec = NULL;
 	}
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -41,13 +41,6 @@ static struct ctl_table dccp_default_table[] = {
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
-- 
1.6.0.rc2

