From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:10 +0000
Subject: [PATCH 35/37] dccp: Implement both feature-local and feature-remote Sequence Window feature
Message-Id: <1219945512-7723-36-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds full support for local/remote Sequence Window feature, from which the
  * sequence-number-validity (W) and
  * acknowledgment-number-validity (W') windows
derive as specified in RFC 4340, 7.5.3.

Specifically, the following changes are introduced:
  * integrated new socket fields into dccp_sk;
  * updated the update_gsr/gss routines with regard to these fields;
  * updated handler code: the Sequence Window feature is located at the TX side,
    so the local feature is meant if the handler-rx flag is false;
  * the initialisation of `rcv_wnd' in reqsk is removed, since
    - rcv_wnd is not used by the code anywhere;
    - sequence number checks are not done in the LISTEN state (cf. 7.5.3);
    - dccp_check_req checks the Ack number validity more rigorously;
  * the `struct dccp_minisock' became empty and is now removed.

Until the handshake completes with activating negotiated values, the local/remote
Sequence-Window values are undefined and thus can not reliably be estimated.
This issue is addressed in a separate patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    3 ++-
 include/linux/dccp.h              |   24 ++++--------------------
 net/dccp/dccp.h                   |   16 +++++++---------
 net/dccp/feat.c                   |   13 +++++++++++--
 net/dccp/minisocks.c              |   11 -----------
 net/dccp/proto.c                  |    2 --
 6 files changed, 24 insertions(+), 45 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -141,7 +141,8 @@ rx_ccid = 2
 	Default CCID for the receiver-sender half-connection; see tx_ccid.
 
 seq_window = 100
-	The initial sequence window (sec. 7.5.2).
+	The initial sequence window (sec. 7.5.2) of the sender. This influences
+	the local ackno validity and the remote seqno validity windows (7.5.1).
 
 tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -364,19 +364,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
 /**
-  * struct dccp_minisock - Minimal DCCP connection representation
-  *
-  * Will be used to pass the state from dccp_request_sock to dccp_sock.
-  *
-  * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
-  */
-struct dccp_minisock {
-	__u64			dccpms_sequence_window;
-};
-
-extern void dccp_minisock_init(struct dccp_minisock *dmsk);
-
-/**
  * struct dccp_request_sock  -  represent DCCP-specific connection request
  * @dreq_inet_rsk: structure inherited from
  * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
@@ -464,13 +451,14 @@ struct dccp_ackvec;
  * @dccps_timestamp_time - time of receiving latest @dccps_timestamp_echo
  * @dccps_l_ack_ratio - feature-local Ack Ratio
  * @dccps_r_ack_ratio - feature-remote Ack Ratio
+ * @dccps_l_seq_win - local Sequence Window (influences ack number validity)
+ * @dccps_r_seq_win - remote Sequence Window (influences seq number validity)
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_send_ndp_count - local Send NDP Count feature (7.7.2)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
  * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
- * @dccps_minisock - associated minisock (accessed via dccp_msk)
  * @dccps_featneg - tracks feature-negotiation state (mostly during handshake)
  * @dccps_hc_rx_ackvec - rx half connection ack vector
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
@@ -504,12 +492,13 @@ struct dccp_sock {
 	__u32				dccps_timestamp_time;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
+	__u64				dccps_l_seq_win:48;
+	__u64				dccps_r_seq_win:48;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
 	__u8				dccps_send_ndp_count:1;
 	__u64				dccps_ndp_count:48;
 	unsigned long			dccps_rate_last;
-	struct dccp_minisock		dccps_minisock;
 	struct list_head		dccps_featneg;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
@@ -527,11 +516,6 @@ static inline struct dccp_sock *dccp_sk(const struct sock *sk)
 	return (struct dccp_sock *)sk;
 }
 
-static inline struct dccp_minisock *dccp_msk(const struct sock *sk)
-{
-	return (struct dccp_minisock *)&dccp_sk(sk)->dccps_minisock;
-}
-
 static inline const char *dccp_role(const struct sock *sk)
 {
 	switch (dccp_sk(sk)->dccps_role) {
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -409,23 +409,21 @@ static inline void dccp_hdr_set_ack(struct dccp_hdr_ack_bits *dhack,
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
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -52,8 +52,17 @@ static int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
 
 static int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
 {
-	if (!rx)
-		dccp_msk(sk)->dccpms_sequence_window = seq_win;
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (rx) {
+		dp->dccps_r_seq_win = seq_win;
+		/* propagate changes to update SWL/SWH */
+		dccp_update_gsr(sk, dp->dccps_gsr);
+	} else {
+		dp->dccps_l_seq_win = seq_win;
+		/* propagate changes to update AWL */
+		dccp_update_gss(sk, dp->dccps_gss);
+	}
 	return 0;
 }
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -42,11 +42,6 @@ struct inet_timewait_death_row dccp_death_row = {
 
 EXPORT_SYMBOL_GPL(dccp_death_row);
 
-void dccp_minisock_init(struct dccp_minisock *dmsk)
-{
-	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
-}
-
 void dccp_time_wait(struct sock *sk, int state, int timeo)
 {
 	struct inet_timewait_sock *tw = NULL;
@@ -110,7 +105,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		struct dccp_request_sock *dreq = dccp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
-		struct dccp_minisock *newdmsk = dccp_msk(newsk);
 
 		newdp->dccps_role	    = DCCP_ROLE_SERVER;
 		newdp->dccps_hc_rx_ackvec   = NULL;
@@ -128,10 +122,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		 *    Initialize S.GAR := S.ISS
 		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 		 */
-
-		/* See dccp_v4_conn_request */
-		newdmsk->dccpms_sequence_window = req->rcv_wnd;
-
 		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
 		dccp_update_gss(newsk, dreq->dreq_iss);
 
@@ -289,7 +279,6 @@ int dccp_reqsk_init(struct request_sock *req,
 
 	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->acked	  = 0;
-	req->rcv_wnd		  = sysctl_dccp_feat_sequence_window;
 	dreq->dreq_timestamp_echo = 0;
 
 	/* inherit feature negotiation options from listening socket */
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -180,8 +180,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	dccp_minisock_init(&dp->dccps_minisock);
-
 	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
 	icsk->icsk_syn_retries	= sysctl_dccp_request_retries;
 	sk->sk_state		= DCCP_CLOSED;
-- 
1.6.0.rc2

