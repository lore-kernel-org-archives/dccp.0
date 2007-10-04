From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:01:59 +0000
Subject: [PATCH 4/5]: Minisock unemployed
Message-Id: <200710041501.59708@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Minisock unemployed

This patch removes one unused field (Ack Ratio) from the minisock structure.
After this removal, only one field - the Boolean flag for enabling NDP count - remains.
So once this is put into dccp_sock as well, minisock becomes empty.

The reason is that all state-passing is now dynamic, through the use of feature
negotiation. The activation of features takes place at the end of the initial
handshake (with the exception of client sequence window, which uses the default of 100
until the handshake completes). The sysctls now seed the initial feature values and can
optionally be overridden on a per-connection basis using sockopts (as for example in the
CCID-sockopt patches).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   24 ++----------------------
 net/dccp/minisocks.c |    7 +------
 net/dccp/options.c   |    4 +---
 net/dccp/proto.c     |    2 --
 4 files changed, 4 insertions(+), 33 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -367,22 +367,6 @@ static inline unsigned int dccp_hdr_len(
 	return __dccp_hdr_len(dccp_hdr(skb));
 }
 
-
-/**
-  * struct dccp_minisock - Minimal DCCP connection representation
-  *
-  * Will be used to pass the state from dccp_request_sock to dccp_sock.
-  *
-  * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
-  * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
-  */
-struct dccp_minisock {
-	__u8			dccpms_send_ndp_count;
-	__u8			dccpms_ack_ratio;
-};
-
-extern void dccp_minisock_init(struct dccp_minisock *dmsk);
-
 /**
  * struct dccp_ts_echo  -  Record incoming timestamp to echo it later
  * @ts_time: arrival time of timestamp
@@ -481,6 +465,7 @@ struct dccp_ackvec;
  * @dccps_r_seq_win - remote Sequence Window (influences seq number validity)
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
+ * @dccps_send_ndp_count - local Send NDP Count feature (7.7.2)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
  * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
@@ -520,10 +505,10 @@ struct dccp_sock {
 	__u64				dccps_r_seq_win:48;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
+	__u8				dccps_send_ndp_count:1;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
 	unsigned long			dccps_rate_last;
-	struct dccp_minisock		dccps_minisock;
 	struct list_head		dccps_featneg;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
@@ -541,11 +526,6 @@ static inline struct dccp_sock *dccp_sk(
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
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -42,11 +42,6 @@ struct inet_timewait_death_row dccp_deat
 
 EXPORT_SYMBOL_GPL(dccp_death_row);
 
-void dccp_minisock_init(struct dccp_minisock *dmsk)
-{
-	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
-}
-
 void dccp_time_wait(struct sock *sk, int state, int timeo)
 {
 	struct inet_timewait_sock *tw = NULL;
@@ -353,7 +348,7 @@ int dccp_hdlr_ackvec(struct sock *sk, u6
 int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx)
 {
 	if (!rx)
-		dccp_msk(sk)->dccpms_send_ndp_count = (enable > 0);
+		dccp_sk(sk)->dccps_send_ndp_count = (enable > 0);
 	return 0;
 }
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -503,12 +503,10 @@ static void dccp_insert_option_padding(s
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
-	if (dmsk->dccpms_send_ndp_count &&
-	    dccp_insert_option_ndp(sk, skb))
+	if (dp->dccps_send_ndp_count && dccp_insert_option_ndp(sk, skb))
 		return -1;
 
 	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA) {
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -174,8 +174,6 @@ int dccp_init_sock(struct sock *sk, cons
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	dccp_minisock_init(&dp->dccps_minisock);
-
 	INIT_LIST_HEAD(&dp->dccps_featneg);
 	/* control socket doesn't need feat nego */
 	if (likely(ctl_sock_initialized))
