From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:16 +0000
Subject: [PATCH 3/11]: Upgrade NDP count from u32 to u64
Message-Id: <200710011518.16688@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Upgrade NDP count from u32 to u64

This upgrades the data type and part of the processing code for the NDP count
option from 4 to 6 bytes, since the option can be up to 6 bytes (RFC 4340).

The data type is 8 bytes, but the actual limit is enforced by the maximum
of dccp_bytes_per_value(), which is 6.

I didn't update the full CCID3 code, though; but inserted overflow warnings which
will raise alarms when NDP counts greater than 2^32-1 appear. The reason is that
the code has been thoroughly tested with an u32 NDP, and changing to u64 will have
many subtle consequences: there are for instance many comparisons between signed
integer and u64, getting one of these wrong will twist the outcome. So, I'd prefer
to wait for the warnings first and do a separate patch later if CCID3 really runs
into that limit.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h                |    2 +-
 net/dccp/ccids/ccid3.c              |    4 ++--
 net/dccp/ccids/lib/packet_history.c |    7 ++++++-
 net/dccp/ccids/lib/packet_history.h |   14 +++++++++-----
 net/dccp/options.c                  |   13 ++++---------
 5 files changed, 22 insertions(+), 18 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -454,7 +454,7 @@ extern int dccp_parse_options(struct soc
 			      struct sk_buff *skb);
 
 struct dccp_options_received {
-	u32	dccpor_ndp;		/* FIXME: can be up to 6 bytes (7.7) */
+	u64	dccpor_ndp;
 	u32	dccpor_timestamp;
 	u32	dccpor_timestamp_echo;
 	u32	dccpor_elapsed_time;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -786,8 +786,8 @@ static void ccid3_hc_rx_packet_recv(stru
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	enum   ccid3_fback_type  do_feedback = FBACK_NONE;
-	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
-	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
+	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
 
 #if 1
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -340,11 +340,16 @@ static void __three_after_loss(struct tf
  */
 int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 			struct tfrc_loss_hist *lh,
-			struct sk_buff *skb, u32 ndp,
+			struct sk_buff *skb, u64 ndp,
 			u32 (*calc_first_li)(struct sock *), struct sock *sk)
 {
 	int is_new_loss = 0;
 
+	if (ndp > 0xFFFFFFFF) {
+		DCCP_WARN("NDP count is over u32 limit. Update algorithm.\n");
+		ndp = 0xFFFFFFFF;
+	}
+
 	if (h->loss_count = 1)
 		__one_after_loss(h, skb, ndp);
 	else if (h->loss_count != 2)
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -101,7 +101,7 @@ struct tfrc_rx_hist_entry {
 	u64		seqno:48,
 			ccval:4,
 			ptype:4;
-	u32		ndp;
+	u32		ndp;		/* FIXME: Upgrade to u64 */
 	ktime_t		stamp;
 };
 
@@ -156,7 +156,7 @@ static inline int tfrc_rx_loss_pending(s
 
 /* any data packets missing between last reception and skb ? */
 static inline int tfrc_rx_new_loss_indicated(struct tfrc_rx_hist *h,
-					     struct sk_buff *skb, u32 ndp)
+					     struct sk_buff *skb, u64 ndp)
 {
 	int delta = dccp_delta_seqno(last_rcv(h)->seqno,
 				     DCCP_SKB_CB(skb)->dccpd_seq);
@@ -202,27 +202,31 @@ static inline void tfrc_rx_hist_swap(str
 }
 
 static inline void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *new,
-					        struct sk_buff *skb, u32 ndp)
+					        struct sk_buff *skb, u64 ndp)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 
 	new->seqno = DCCP_SKB_CB(skb)->dccpd_seq;
 	new->ccval = dh->dccph_ccval;
 	new->ptype = dh->dccph_type;
+	if (ndp > 0xFFFFFFFF) {
+		DCCP_WARN("NDP count is over u32 limit. Update algorithm.\n");
+		ndp = 0xFFFFFFFF;
+	}
 	new->ndp   = ndp;
 	new->stamp = ktime_get_real();
 }
 
 /* commit packet details of skb to history (record highest received seqno) */
 static inline void tfrc_rx_hist_update(struct tfrc_rx_hist *h,
-				       struct sk_buff *skb, u32 ndp)
+				       struct sk_buff *skb, u64 ndp)
 {
 	tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
 struct tfrc_loss_hist;
 extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
-				struct sk_buff *skb, u32 ndp,
+				struct sk_buff *skb, u64 ndp,
 				u32 (*first_li)(struct sock *), struct sock *);
 extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -119,12 +119,11 @@ int dccp_parse_options(struct sock *sk, 
 				mandatory = 1;
 			break;
 		case DCCPO_NDP_COUNT:
-			if (len > 6)	/* FIXME: make dccpor_ndp u64 */
+			if (len > 6)
 				goto out_invalid_option;
-
 			opt_recv->dccpor_ndp = dccp_decode_value_var(value, len);
-			dccp_pr_debug("%s rx opt: NDP count=%d\n", dccp_role(sk),
-				      opt_recv->dccpor_ndp);
+			dccp_pr_debug("%s opt: NDP count=%llu\n", dccp_role(sk),
+				      (unsigned long long)opt_recv->dccpor_ndp);
 			break;
 		case DCCPO_CHANGE_L:
 			/* fall through */
@@ -330,7 +329,7 @@ EXPORT_SYMBOL_GPL(dccp_insert_option);
 static int dccp_insert_option_ndp(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	int ndp = dp->dccps_ndp_count;
+	u64 ndp = dp->dccps_ndp_count;
 
 	if (dccp_non_data_packet(skb))
 		++dp->dccps_ndp_count;
@@ -340,10 +339,6 @@ static int dccp_insert_option_ndp(struct
 	if (ndp > 0) {
 		unsigned char *ptr;
 		const int ndp_len = dccp_bytes_per_value(ndp);
-		/*
-		 * FIXME: increase the data type of dccps_ndp_count to u64 and
-		 * track changes in code - NDP is up to 6 bytes (RFC 4340, 7.7)
-		 */
 		const int len = ndp_len + 2;
 
 		if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
