From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Dec 2008 16:40:56 +0000
Subject: [PATCH 6/7] dccp: Remove manual influence on NDP Count feature
Message-Id: <1228581657-6724-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Updating the NDP count feature is handled automatically now:
 * for CCID-2 it is disabled, since the code does not use NDP counts;
 * for CCID-3 it is enabled, as NDP counts are used to determine loss lengths.

Allowing the user to change NDP values leads to unpredictable and failing
behaviour, since it is then possible to disable NDP counts even when they
are needed (e.g. in CCID-3).

This means that only those user settings are sensible that agree with the
values for Send NDP Count implied by the choice of CCID. But those settings
are already activated by the feature negotiation (CCID dependency tracking),
hence this form of support is redundant.

At startup the initialisation of the NDP count feature uses the default
value of 0, which is done implicitly by the zeroing-out of the socket when
it is allocated. If the choice of CCID or feature negotiation enables NDP
count, this will then be updated via the NDP activation handler.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    3 ---
 include/linux/dccp.h              |    4 ++--
 net/dccp/dccp.h                   |    1 -
 net/dccp/feat.c                   |    2 +-
 net/dccp/minisocks.c              |    1 -
 net/dccp/options.c                |    4 +---
 net/dccp/sysctl.c                 |    7 -------
 7 files changed, 4 insertions(+), 18 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -133,9 +133,6 @@ retries2
 	importance for retransmitted acknowledgments and feature negotiation,
 	data packets are never retransmitted. Analogue of tcp_retries2.
 
-send_ndp = 1
-	Whether or not to send NDP count options (sec. 7.7.2).
-
 send_ackvec = 1
 	Whether or not to send Ack Vector options (sec. 11.5).
 
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -371,14 +371,12 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
   *
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
   * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
-  * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   * @dccpms_pending - List of features being negotiated
   * @dccpms_conf -
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
 	__u8			dccpms_send_ack_vector;
-	__u8			dccpms_send_ndp_count;
 	struct list_head	dccpms_pending;
 	struct list_head	dccpms_conf;
 };
@@ -490,6 +488,7 @@ struct dccp_ackvec;
  * @dccps_r_ack_ratio - feature-remote Ack Ratio
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
+ * @dccps_send_ndp_count - local Send NDP Count feature (7.7.2)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
  * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
@@ -529,6 +528,7 @@ struct dccp_sock {
 	__u16				dccps_r_ack_ratio;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
+	__u8				dccps_send_ndp_count:1;
 	__u64				dccps_ndp_count:48;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -99,7 +99,6 @@ extern int  sysctl_dccp_feat_sequence_window;
 extern int  sysctl_dccp_feat_rx_ccid;
 extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_feat_send_ack_vector;
-extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -85,7 +85,7 @@ static int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx)
 static int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx)
 {
 	if (!rx)
-		dccp_msk(sk)->dccpms_send_ndp_count = (enable > 0);
+		dccp_sk(sk)->dccps_send_ndp_count = (enable > 0);
 	return 0;
 }
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -46,7 +46,6 @@ void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
 	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
-	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
 }
 
 void dccp_time_wait(struct sock *sk, int state, int timeo)
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -27,7 +27,6 @@ int sysctl_dccp_feat_sequence_window = DCCPF_INITIAL_SEQUENCE_WINDOW;
 int sysctl_dccp_feat_rx_ccid	      = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
-int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
 u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
@@ -531,8 +530,7 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
-	if (dmsk->dccpms_send_ndp_count &&
-	    dccp_insert_option_ndp(sk, skb))
+	if (dp->dccps_send_ndp_count && dccp_insert_option_ndp(sk, skb))
 		return -1;
 
 	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA) {
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -48,13 +48,6 @@ static struct ctl_table dccp_default_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "send_ndp",
-		.data		= &sysctl_dccp_feat_send_ndp_count,
-		.maxlen		= sizeof(sysctl_dccp_feat_send_ndp_count),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
