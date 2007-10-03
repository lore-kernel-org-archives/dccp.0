From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:54 +0000
Subject: [PATCH 12/14]: Implement both feature-local and feature-remote Sequence Window feature
Message-Id: <200710031502.54147@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Implement both feature-local and feature-remote Sequence Window feature

This adds full support for both local/remote Sequence Window feature, from which the 
 * sequence-number-validity (W) and 
 * acknowledgment-number-validity (W') windows 
derive as specified in RFC 4340, 7.5.3. 

Specifically, the following changes are introduced:
  * integrated new socket fields into dccp_sk;
  * updated the update_gsr/gss routines with regard to these fields, using modulo-48 arithmetic;
  * updated handler code: the Sequence Window feature is located at the TX side, so the local feature is
    meant if the handler-rx flag is false;
  * the initialisation of `rcv_wnd' in reqsk is removed, since
  	(i)   rcv_wnd is not used by the code anywhere;
	(ii)  sequence number checks are not done in the LISTEN state (table in 7.5.3);
	(iii) dccp_check_req already performs more stringent checks on the Ack number validity.

Until the handshake completes with activating negotiated values, the Sequence-Window default values
(100) are used. As indicated by the comment, I think that this is more than enough. Further, it only
applies to the client, since:
  * client's AWL is set in dccp_connect_init(),
  * client's SWL is set in dccp_rcv_request_sent_state_process() (from the ISR of the Response),
  * server's AWL/SWL are set when the new child socket is created in dccp_create_openreq_child();
    but at this stage dccp_feat_activate_values() has already updated the local/remote Sequence
    Window feature of the server, so it is using the latest values,
  * dccp_check_req() (used on reqsk's) does not need AWL/SWL and performs more stringent checks.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    3 ++-
 include/linux/dccp.h              |    6 ++++--
 net/dccp/dccp.h                   |   16 +++++++---------
 net/dccp/feat.c                   |   13 +++++++++++++
 net/dccp/minisocks.c              |   12 ++++--------
 5 files changed, 30 insertions(+), 20 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1082,6 +1082,19 @@ int dccp_feat_init(struct sock *sk)
 		rc = dccp_feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
 					sp[i].mandatory, sp[i].val, sp[i].len);
 
+	/*
+	 * Initial values for the remote and local Sequence Window feature. This
+	 * is only for the client startup phase, to seed AWL/SWL. Until then,
+	 *  - the default of 100 is enough for 75 Request-retransmissions,
+	 *  - sequence window checks are not performed in state LISTEN/REQUEST,
+	 *  - the only Ack window check is for the Ack completing the handshake.
+	 * After the handshake, local/remote Sequence Window will be updated
+	 * with the negotiated values (or the defaults again if not different).
+	 * The server's AWL/SWL derive directly from the negotiated values.
+	 */
+	for (i = 0; rc = 0 && i <= 1; i++)
+		rc = dccp_feat_activate(sk, DCCPF_SEQUENCE_WINDOW, i, NULL);
+
 	kfree(sp[0].val);
 	kfree(sp[1].val);
 	return rc;
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -380,12 +380,10 @@ static inline unsigned int dccp_hdr_len(
   *
   * Will be used to pass the state from dccp_request_sock to dccp_sock.
   *
-  * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
   * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
   */
 struct dccp_minisock {
-	__u64			dccpms_sequence_window;
 	__u8			dccpms_send_ndp_count;
 	__u8			dccpms_ack_ratio;
 };
@@ -486,6 +484,8 @@ struct dccp_ackvec;
  * @dccps_tstamp - most recently received timestamp to echo (RFC 4340, 13.1)
  * @dccps_l_ack_ratio - feature-local Ack Ratio
  * @dccps_r_ack_ratio - feature-remote Ack Ratio
+ * @dccps_l_seq_win - local Sequence Window (influences ack number validity)
+ * @dccps_r_seq_win - remote Sequence Window (influences seq number validity)
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
@@ -523,6 +523,8 @@ struct dccp_sock {
 	struct dccp_ts_echo		*dccps_tstamp;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
+	__u64				dccps_l_seq_win:48;
+	__u64				dccps_r_seq_win:48;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
 	unsigned long			dccps_ndp_count;
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -390,23 +390,21 @@ static inline void dccp_hdr_set_ack(stru
 static inline void dccp_update_gsr(struct sock *sk, u64 seq)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	const struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	dp->dccps_gsr = seq;
-	dccp_set_seqno(&dp->dccps_swl,
-		       dp->dccps_gsr + 1 - (dmsk->dccpms_sequence_window / 4));
-	dccp_set_seqno(&dp->dccps_swh,
-		       dp->dccps_gsr + (3 * dmsk->dccpms_sequence_window) / 4);
+	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
+	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
+	dp->dccps_swh = ADD48(dp->dccps_gsr, (3 * dp->dccps_r_seq_win) / 4);
 }
 
 static inline void dccp_update_gss(struct sock *sk, u64 seq)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	dp->dccps_awh = dp->dccps_gss = seq;
-	dccp_set_seqno(&dp->dccps_awl,
-		       (dp->dccps_gss -
-			dccp_msk(sk)->dccpms_sequence_window + 1));
+	dp->dccps_gss = seq;
+	/* Ack validity window depends on local Sequence Window value (7.5.1) */
+	dp->dccps_awl = SUB48(ADD48(dp->dccps_gss, 1), dp->dccps_l_seq_win);
+	dp->dccps_awh = dp->dccps_gss;
 }
 
 static inline int dccp_ack_pending(const struct sock *sk)
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -44,7 +44,6 @@ EXPORT_SYMBOL_GPL(dccp_death_row);
 
 void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
-	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
 	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
 }
 
@@ -111,7 +110,6 @@ struct sock *dccp_create_openreq_child(s
 		struct dccp_request_sock *dreq = dccp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
-		struct dccp_minisock *newdmsk = dccp_msk(newsk);
 
 		newdp->dccps_role	   = DCCP_ROLE_SERVER;
 		newdp->dccps_hc_rx_ackvec  = NULL;
@@ -129,9 +127,6 @@ struct sock *dccp_create_openreq_child(s
 		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 		 */
 
-		/* See dccp_v4_conn_request */
-		newdmsk->dccpms_sequence_window = req->rcv_wnd;
-
 		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
 		dccp_update_gsr(newsk, dreq->dreq_isr);
 
@@ -289,7 +284,6 @@ int dccp_reqsk_init(struct request_sock 
 
 	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->acked	= 0;
-	req->rcv_wnd		= sysctl_dccp_feat_sequence_window;
 	dreq->dreq_tstamp	= NULL;
 
 	/* inherit feature negotiation options from listening socket */
@@ -325,8 +319,10 @@ int dccp_hdlr_ccid(struct sock *sk, u64 
 
 int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
 {
-	if (!rx)
-		dccp_msk(sk)->dccpms_sequence_window = seq_win;
+	if (rx)
+		dccp_sk(sk)->dccps_r_seq_win = seq_win;
+	else
+		dccp_sk(sk)->dccps_l_seq_win = seq_win;
 	return 0;
 }
 
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -147,7 +147,8 @@ ack_ratio = 2
 	The default Ack Ratio (sec. 11.3) to use.
 
 seq_window = 100
-	The initial sequence window (sec. 7.5.2).
+	The initial sequence window (sec. 7.5.2) of the sender. This influences
+	the local ackno validity and the remote seqno validity windows (7.5.1).
 
 tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
