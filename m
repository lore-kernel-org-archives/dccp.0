From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Jul 2008 14:51:48 +0000
Subject: [PATCH 2/4] dccp: Upgrade NDP count from 3 to 6 bytes
Message-Id: <1215874310-10534-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RFC 4340, 7.7 specifies up to 6 bytes for the NDP Count option, whereas the code
is limited to up to 3 bytes. This seems to be a relict of an earlier draft
version and is brought up to date by the patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h                |    6 ++----
 net/dccp/ccids/ccid3.c              |    2 +-
 net/dccp/ccids/lib/packet_history.c |    6 +++---
 net/dccp/ccids/lib/packet_history.h |    6 +++---
 net/dccp/options.c                  |   14 ++++++++------
 5 files changed, 17 insertions(+), 17 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -64,7 +64,7 @@ struct tfrc_rx_hist_entry {
 	u64		 tfrchrx_seqno:48,
 			 tfrchrx_ccval:4,
 			 tfrchrx_type:4;
-	u32		 tfrchrx_ndp; /* In fact it is from 8 to 24 bits */
+	u64		 tfrchrx_ndp:48;
 	ktime_t		 tfrchrx_tstamp;
 };
 
@@ -145,14 +145,14 @@ static inline int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
 }
 
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
-				    const struct sk_buff *skb, const u32 ndp);
+				    const struct sk_buff *skb, const u64 ndp);
 
 extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
 
 struct tfrc_loss_hist;
 extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 				struct tfrc_loss_hist *lh,
-				struct sk_buff *skb, u32 ndp,
+				struct sk_buff *skb, const u64 ndp,
 				u32 (*first_li)(struct sock *sk),
 				struct sock *sk);
 extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -364,8 +364,6 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
-#define DCCP_NDP_LIMIT 0xFFFFFF
-
 /**
   * struct dccp_minisock - Minimal DCCP connection representation
   *
@@ -437,7 +435,7 @@ extern int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			      struct sk_buff *skb);
 
 struct dccp_options_received {
-	u32	dccpor_ndp; /* only 24 bits */
+	u64	dccpor_ndp:48;
 	u32	dccpor_timestamp;
 	u32	dccpor_timestamp_echo;
 	u32	dccpor_elapsed_time;
@@ -533,7 +531,7 @@ struct dccp_sock {
 	__u16				dccps_r_ack_ratio;
 	__u16				dccps_pcslen;
 	__u16				dccps_pcrlen;
-	unsigned long			dccps_ndp_count;
+	__u64				dccps_ndp_count:48;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -794,7 +794,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	enum ccid3_fback_type do_feedback = CCID3_FBACK_NONE;
-	const u32 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
+	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -153,7 +153,7 @@ void tfrc_rx_packet_history_exit(void)
 
 static inline void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *entry,
 					       const struct sk_buff *skb,
-					       const u32 ndp)
+					       const u64 ndp)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 
@@ -166,7 +166,7 @@ static inline void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *entry,
 
 void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 			     const struct sk_buff *skb,
-			     const u32 ndp)
+			     const u64 ndp)
 {
 	struct tfrc_rx_hist_entry *entry = tfrc_rx_hist_last_rcv(h);
 
@@ -356,7 +356,7 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
  */
 int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 			struct tfrc_loss_hist *lh,
-			struct sk_buff *skb, u32 ndp,
+			struct sk_buff *skb, const u64 ndp,
 			u32 (*calc_first_li)(struct sock *), struct sock *sk)
 {
 	int is_new_loss = 0;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -124,12 +124,12 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 				mandatory = 1;
 			break;
 		case DCCPO_NDP_COUNT:
-			if (len > 3)
+			if (len > 6)
 				goto out_invalid_option;
 
 			opt_recv->dccpor_ndp = dccp_decode_value_var(value, len);
-			dccp_pr_debug("%s rx opt: NDP count=%d\n", dccp_role(sk),
-				      opt_recv->dccpor_ndp);
+			dccp_pr_debug("%s opt: NDP count=%llu\n", dccp_role(sk),
+				      (unsigned long long)opt_recv->dccpor_ndp);
 			break;
 		case DCCPO_CHANGE_L:
 			/* fall through */
@@ -307,9 +307,11 @@ static void dccp_encode_value_var(const u32 value, unsigned char *to,
 		*to++ = (value & 0xFF);
 }
 
-static inline int dccp_ndp_len(const int ndp)
+static inline u8 dccp_ndp_len(const u64 ndp)
 {
-	return likely(ndp <= 0xFF) ? 1 : ndp <= 0xFFFF ? 2 : 3;
+	if (likely(ndp <= 0xFF))
+		return 1;
+	return likely(ndp <= USHORT_MAX) ? 2 : (ndp <= UINT_MAX ? 4 : 6);
 }
 
 int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
@@ -336,7 +338,7 @@ EXPORT_SYMBOL_GPL(dccp_insert_option);
 static int dccp_insert_option_ndp(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	int ndp = dp->dccps_ndp_count;
+	u64 ndp = dp->dccps_ndp_count;
 
 	if (dccp_non_data_packet(skb))
 		++dp->dccps_ndp_count;
