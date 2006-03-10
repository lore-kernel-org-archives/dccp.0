From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 8/9] [DCCP] minisock: Rename struct dccp_options to struct dccp_minisock
Message-Id: <11420257372697-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This will later be included in struct dccp_request_sock so that we can have per
connection feature negotiation state while in the 3way handshake, when we clone
the DCCP_ROLE_LISTEN socket (in dccp_create_openreq_child) we'll just copy this
state from dreq_minisock to dccps_minisock.

Also the feature negotiation and option parsing code will mostly touch
dccps_minisock, which will simplify some stuff.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 include/linux/dccp.h |   43 ++++++++++++++++-----------
 net/dccp/dccp.h      |   11 +++----
 net/dccp/diag.c      |    2 +
 net/dccp/feat.c      |   81 +++++++++++++++++++++++---------------------------
 net/dccp/input.c     |    8 ++---
 net/dccp/minisocks.c |    9 +++---
 net/dccp/options.c   |   30 +++++++++----------
 net/dccp/proto.c     |   23 +++++++-------
 8 files changed, 104 insertions(+), 103 deletions(-)

7bbc1279b5199fbd225bec390fce70245acbb27f
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index e35f680..676333b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -328,21 +328,24 @@ static inline unsigned int dccp_hdr_len(
 #define DCCP_NDP_LIMIT 0xFFFFFF
 
 /**
-  * struct dccp_options - option values for a DCCP connection
-  *	@dccpo_sequence_window - Sequence Window Feature (section 7.5.2)
-  *	@dccpo_ccid - Congestion Control Id (CCID) (section 10)
-  *	@dccpo_send_ack_vector - Send Ack Vector Feature (section 11.5)
-  *	@dccpo_send_ndp_count - Send NDP Count Feature (7.7.2)
+  * struct dccp_minisock - Minimal DCCP connection representation
+  *
+  * Will be used to pass the state from dccp_request_sock to dccp_sock.
+  *
+  * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
+  * @dccpms_ccid - Congestion Control Id (CCID) (section 10)
+  * @dccpms_send_ack_vector - Send Ack Vector Feature (section 11.5)
+  * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   */
-struct dccp_options {
-	__u64	dccpo_sequence_window;
-	__u8	dccpo_rx_ccid;
-	__u8	dccpo_tx_ccid;
-	__u8	dccpo_send_ack_vector;
-	__u8	dccpo_send_ndp_count;
-	__u8			dccpo_ack_ratio;
-	struct list_head	dccpo_pending;
-	struct list_head	dccpo_conf;
+struct dccp_minisock {
+	__u64			dccpms_sequence_window;
+	__u8			dccpms_rx_ccid;
+	__u8			dccpms_tx_ccid;
+	__u8			dccpms_send_ack_vector;
+	__u8			dccpms_send_ndp_count;
+	__u8			dccpms_ack_ratio;
+	struct list_head	dccpms_pending;
+	struct list_head	dccpms_conf;
 };
 
 struct dccp_opt_conf {
@@ -360,8 +363,9 @@ struct dccp_opt_pend {
 	struct dccp_opt_conf    *dccpop_sc;
 };
 
-extern void __dccp_options_init(struct dccp_options *dccpo);
-extern void dccp_options_init(struct dccp_options *dccpo);
+extern void __dccp_minisock_init(struct dccp_minisock *dmsk);
+extern void dccp_minisock_init(struct dccp_minisock *dmsk);
+
 extern int dccp_parse_options(struct sock *sk, struct sk_buff *skb);
 
 struct dccp_request_sock {
@@ -457,7 +461,7 @@ struct dccp_sock {
 	__u16				dccps_r_ack_ratio;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
-	struct dccp_options		dccps_options;
+	struct dccp_minisock		dccps_minisock;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
@@ -473,6 +477,11 @@ static inline struct dccp_sock *dccp_sk(
 	return (struct dccp_sock *)sk;
 }
 
+static inline struct dccp_minisock *dccp_msk(const struct sock *sk)
+{
+	return (struct dccp_minisock *)&dccp_sk(sk)->dccps_minisock;
+}
+
 static inline int dccp_service_not_initialized(const struct sock *sk)
 {
 	return dccp_sk(sk)->dccps_service = DCCP_SERVICE_INVALID_VALUE;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 47de172..1fe5091 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -303,14 +303,13 @@ static inline void dccp_hdr_set_ack(stru
 static inline void dccp_update_gsr(struct sock *sk, u64 seq)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	const struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	dp->dccps_gsr = seq;
 	dccp_set_seqno(&dp->dccps_swl,
-		       (dp->dccps_gsr + 1 -
-		        (dp->dccps_options.dccpo_sequence_window / 4)));
+		       dp->dccps_gsr + 1 - (dmsk->dccpms_sequence_window / 4));
 	dccp_set_seqno(&dp->dccps_swh,
-		       (dp->dccps_gsr +
-			(3 * dp->dccps_options.dccpo_sequence_window) / 4));
+		       dp->dccps_gsr + (3 * dmsk->dccpms_sequence_window) / 4);
 }
 
 static inline void dccp_update_gss(struct sock *sk, u64 seq)
@@ -320,7 +319,7 @@ static inline void dccp_update_gss(struc
 	dp->dccps_awh = dp->dccps_gss = seq;
 	dccp_set_seqno(&dp->dccps_awl,
 		       (dp->dccps_gss -
-			dp->dccps_options.dccpo_sequence_window + 1));
+			dccp_msk(sk)->dccpms_sequence_window + 1));
 }
 				
 static inline int dccp_ack_pending(const struct sock *sk)
@@ -328,7 +327,7 @@ static inline int dccp_ack_pending(const
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_timestamp_echo != 0 ||
 #ifdef CONFIG_IP_DCCP_ACKVEC
-	       (dp->dccps_options.dccpo_send_ack_vector &&
+	       (dccp_msk(sk)->dccpms_send_ack_vector &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
 #endif
 	       inet_csk_ack_scheduled(sk);
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 3f78c00..0f25dc3 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -30,7 +30,7 @@ static void dccp_get_info(struct sock *s
 	info->tcpi_backoff	= icsk->icsk_backoff;
 	info->tcpi_pmtu		= icsk->icsk_pmtu_cookie;
 
-	if (dp->dccps_options.dccpo_send_ack_vector)
+	if (dccp_msk(sk)->dccpms_send_ack_vector)
 		info->tcpi_options |= TCPI_OPT_SACK;
 
 	ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 0ab5f84..ea77a53 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -22,7 +22,7 @@
 int dccp_feat_change(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len,
 		     gfp_t gfp)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt;
 	
 	dccp_pr_debug("feat change type=%d feat=%d\n", type, feature);
@@ -30,8 +30,7 @@ int dccp_feat_change(struct sock *sk, u8
 	/* XXX sanity check feat change request */
 
 	/* check if that feature is already being negotiated */
-	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
-			    dccpop_node) {
+	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 		/* ok we found a negotiation for this option already */
 		if (opt->dccpop_feat = feature && opt->dccpop_type = type) {
 			dccp_pr_debug("Replacing old\n");
@@ -59,7 +58,7 @@ int dccp_feat_change(struct sock *sk, u8
 
 	BUG_ON(opt->dccpop_val = NULL);
 
-	list_add_tail(&opt->dccpop_node, &dp->dccps_options.dccpo_pending);
+	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_pending);
 	return 0;
 }
 
@@ -68,10 +67,10 @@ EXPORT_SYMBOL_GPL(dccp_feat_change);
 static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	/* figure out if we are changing our CCID or the peer's */	
 	const int rx = type = DCCPO_CHANGE_R;
-	const u8 ccid_nr = rx ? dp->dccps_options.dccpo_rx_ccid :
-				dp->dccps_options.dccpo_tx_ccid;
+	const u8 ccid_nr = rx ? dmsk->dccpms_rx_ccid : dmsk->dccpms_tx_ccid;
 	struct ccid *new_ccid;
 
 	/* Check if nothing is being changed. */
@@ -85,11 +84,11 @@ static int dccp_feat_update_ccid(struct 
 	if (rx) {
 		ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
 		dp->dccps_hc_rx_ccid = new_ccid;
-		dp->dccps_options.dccpo_rx_ccid = new_ccid_nr;
+		dmsk->dccpms_rx_ccid = new_ccid_nr;
 	} else {
 		ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
 		dp->dccps_hc_tx_ccid = new_ccid;
-		dp->dccps_options.dccpo_tx_ccid = new_ccid_nr;
+		dmsk->dccpms_tx_ccid = new_ccid_nr;
 	}
 
 	return 0;
@@ -159,9 +158,9 @@ static int dccp_feat_reconcile(struct so
 		case DCCPF_CCID:
 			/* XXX did i get this right? =P */
 			if (opt->dccpop_type = DCCPO_CHANGE_L)
-				res = &dp->dccps_options.dccpo_tx_ccid;
+				res = &dccp_msk(sk)->dccpms_tx_ccid;
 			else
-				res = &dp->dccps_options.dccpo_rx_ccid;
+				res = &dccp_msk(sk)->dccpms_rx_ccid;
 			break;
 
 		default:
@@ -226,7 +225,7 @@ static int dccp_feat_reconcile(struct so
 
 static int dccp_feat_sp(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt;
 	int rc = 1;
 	u8 t;
@@ -242,8 +241,7 @@ static int dccp_feat_sp(struct sock *sk,
 		t = DCCPO_CHANGE_L;
 	
 	/* find our preference list for this feature */
-	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
-			    dccpop_node) {
+	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 		if (opt->dccpop_type != t || opt->dccpop_feat != feature)
 			continue;
 		
@@ -265,7 +263,7 @@ static int dccp_feat_sp(struct sock *sk,
 static int dccp_feat_nn(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
 {
 	struct dccp_opt_pend *opt;
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	u8 *copy;
 	int rc;
 
@@ -304,14 +302,14 @@ static int dccp_feat_nn(struct sock *sk,
 	}
 
 	dccp_pr_debug("Confirming NN feature %d (val=%d)\n", feature, *copy);
-	list_add_tail(&opt->dccpop_node, &dp->dccps_options.dccpo_conf);
+	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_conf);
 
 	return 0;
 }
 
 static void dccp_feat_empty_confirm(struct sock *sk, u8 type, u8 feature)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	/* XXX check if other confirms for that are queued and recycle slot */
 	struct dccp_opt_pend *opt = kzalloc(sizeof(*opt), GFP_ATOMIC);
 
@@ -330,20 +328,19 @@ static void dccp_feat_empty_confirm(stru
 
 	/* change feature */
 	dccp_pr_debug("Empty confirm feature %d type %d\n", feature, type);
-	list_add_tail(&opt->dccpop_node, &dp->dccps_options.dccpo_conf);
+	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_conf);
 }
 
 static void dccp_feat_flush_confirm(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	/* Check if there is anything to confirm in the first place */
-	int yes = !list_empty(&dp->dccps_options.dccpo_conf);
+	int yes = !list_empty(&dmsk->dccpms_conf);
 
 	if (!yes) {
 		struct dccp_opt_pend *opt;
 
-		list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
-				    dccpop_node) {
+		list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 			if (opt->dccpop_conf) {
 				yes = 1;
 				break;
@@ -407,7 +404,7 @@ int dccp_feat_confirm_recv(struct sock *
 {
 	u8 t;
 	struct dccp_opt_pend *opt;
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	int rc = 1;
 	int all_confirmed = 1;
 
@@ -418,8 +415,7 @@ int dccp_feat_confirm_recv(struct sock *
 	/* locate our change request */
 	t = type = DCCPO_CONFIRM_L ? DCCPO_CHANGE_R : DCCPO_CHANGE_L;
 
-	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
-			    dccpop_node) {
+	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 		if (!opt->dccpop_conf && opt->dccpop_type = t &&
 		    opt->dccpop_feat = feature) {
 			/* we found it */
@@ -462,10 +458,10 @@ EXPORT_SYMBOL_GPL(dccp_feat_confirm_recv
 
 void dccp_feat_clean(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt, *next;
 
-	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_pending,
+	list_for_each_entry_safe(opt, next, &dmsk->dccpms_pending,
 				 dccpop_node) {
                 BUG_ON(opt->dccpop_val = NULL);
                 kfree(opt->dccpop_val);
@@ -478,16 +474,15 @@ void dccp_feat_clean(struct sock *sk)
 
                 kfree(opt);
         }
-	INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
+	INIT_LIST_HEAD(&dmsk->dccpms_pending);
 
-	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_conf,
-				 dccpop_node) {
+	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
 		BUG_ON(opt = NULL);
 		if (opt->dccpop_val != NULL)
 			kfree(opt->dccpop_val);
 		kfree(opt);
 	}
-	INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
+	INIT_LIST_HEAD(&dmsk->dccpms_conf);
 }
 
 EXPORT_SYMBOL_GPL(dccp_feat_clean);
@@ -498,16 +493,15 @@ EXPORT_SYMBOL_GPL(dccp_feat_clean);
  */
 int dccp_feat_clone(struct sock *oldsk, struct sock *newsk)
 {
-	struct dccp_sock *olddp = dccp_sk(oldsk);
-	struct dccp_sock *newdp = dccp_sk(newsk);
+	struct dccp_minisock *olddmsk = dccp_msk(oldsk);
+	struct dccp_minisock *newdmsk = dccp_msk(newsk);
 	struct dccp_opt_pend *opt;
 	int rc = 0;
 
-	INIT_LIST_HEAD(&newdp->dccps_options.dccpo_pending);
-	INIT_LIST_HEAD(&newdp->dccps_options.dccpo_conf);
+	INIT_LIST_HEAD(&newdmsk->dccpms_pending);
+	INIT_LIST_HEAD(&newdmsk->dccpms_conf);
 
-	list_for_each_entry(opt, &olddp->dccps_options.dccpo_pending,
-			    dccpop_node) {
+	list_for_each_entry(opt, &olddmsk->dccpms_pending, dccpop_node) {
 		struct dccp_opt_pend *newopt;
 		/* copy the value of the option */
 		u8 *val = kmalloc(opt->dccpop_len, GFP_ATOMIC);
@@ -525,8 +519,7 @@ int dccp_feat_clone(struct sock *oldsk, 
 		/* insert the option */	
 		memcpy(newopt, opt, sizeof(*newopt));
 		newopt->dccpop_val = val;
-		list_add_tail(&newopt->dccpop_node, 
-			      &newdp->dccps_options.dccpo_pending);
+		list_add_tail(&newopt->dccpop_node, &newdmsk->dccpms_pending);
 		
 		/* XXX what happens with backlogs and multiple connections at
 		 * once...
@@ -567,27 +560,27 @@ static int __dccp_feat_init(struct sock 
 
 int dccp_feat_init(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	int rc;
 
-	INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
-	INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
+	INIT_LIST_HEAD(&dmsk->dccpms_pending);
+	INIT_LIST_HEAD(&dmsk->dccpms_conf);
 
 	/* CCID L */
 	rc = __dccp_feat_init(sk, DCCPO_CHANGE_L, DCCPF_CCID,
-			      &dp->dccps_options.dccpo_tx_ccid, 1);
+			      &dmsk->dccpms_tx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* CCID R */
 	rc = __dccp_feat_init(sk, DCCPO_CHANGE_R, DCCPF_CCID,
-			      &dp->dccps_options.dccpo_rx_ccid, 1);
+			      &dmsk->dccpms_rx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* Ack ratio */
 	rc = __dccp_feat_init(sk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
-			      &dp->dccps_options.dccpo_ack_ratio, 1);
+			      &dmsk->dccpms_ack_ratio, 1);
 out:
 	return rc;
 }
diff --git a/net/dccp/input.c b/net/dccp/input.c
index f53e3fc..bfc5366 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -60,7 +60,7 @@ static void dccp_event_ack_recv(struct s
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	if (dp->dccps_options.dccpo_send_ack_vector)
+	if (dccp_msk(sk)->dccpms_send_ack_vector)
 		dccp_ackvec_check_rcv_ackno(dp->dccps_hc_rx_ackvec, sk,
 					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
@@ -246,7 +246,7 @@ int dccp_rcv_established(struct sock *sk
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_event_ack_recv(sk, skb);
 
-	if (dp->dccps_options.dccpo_send_ack_vector &&
+	if (dccp_msk(sk)->dccpms_send_ack_vector &&
 	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 			    DCCP_SKB_CB(skb)->dccpd_seq,
 			    DCCP_ACKVEC_STATE_RECEIVED))
@@ -302,7 +302,7 @@ static int dccp_rcv_request_sent_state_p
 		if (dccp_parse_options(sk, skb))
 			goto out_invalid_packet;
 
-                if (dp->dccps_options.dccpo_send_ack_vector &&
+                if (dccp_msk(sk)->dccpms_send_ack_vector &&
                     dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
                                     DCCP_SKB_CB(skb)->dccpd_seq,
                                     DCCP_ACKVEC_STATE_RECEIVED))
@@ -486,7 +486,7 @@ int dccp_rcv_state_process(struct sock *
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);
 
- 		if (dp->dccps_options.dccpo_send_ack_vector &&
+ 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
  				    DCCP_SKB_CB(skb)->dccpd_seq,
  				    DCCP_ACKVEC_STATE_RECEIVED))
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5324fca..c0349e5 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -107,6 +107,7 @@ struct sock *dccp_create_openreq_child(s
 		const struct dccp_request_sock *dreq = dccp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(sk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
+		struct dccp_minisock *newdmsk = dccp_msk(newsk);
 
 		newdp->dccps_role	   = DCCP_ROLE_SERVER;
 		newdp->dccps_hc_rx_ackvec  = NULL;
@@ -118,7 +119,7 @@ struct sock *dccp_create_openreq_child(s
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
 
-		if (newdp->dccps_options.dccpo_send_ack_vector) {
+		if (newdmsk->dccpms_send_ack_vector) {
 			newdp->dccps_hc_rx_ackvec  						dccp_ackvec_alloc(GFP_ATOMIC);
 			if (unlikely(newdp->dccps_hc_rx_ackvec = NULL))
@@ -126,10 +127,10 @@ struct sock *dccp_create_openreq_child(s
 		}
 
 		newdp->dccps_hc_rx_ccid -			    ccid_hc_rx_new(newdp->dccps_options.dccpo_rx_ccid,
+			    ccid_hc_rx_new(newdmsk->dccpms_rx_ccid,
 					   newsk, GFP_ATOMIC);
 		newdp->dccps_hc_tx_ccid -			    ccid_hc_tx_new(newdp->dccps_options.dccpo_tx_ccid,
+			    ccid_hc_tx_new(newdmsk->dccpms_tx_ccid,
 					   newsk, GFP_ATOMIC);
 		if (unlikely(newdp->dccps_hc_rx_ccid = NULL ||
 			     newdp->dccps_hc_tx_ccid = NULL)) {
@@ -153,7 +154,7 @@ out_free:
 		 */
 
 		/* See dccp_v4_conn_request */
-		newdp->dccps_options.dccpo_sequence_window = req->rcv_wnd;
+		newdmsk->dccpms_sequence_window = req->rcv_wnd;
 
 		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
 		dccp_update_gsr(newsk, dreq->dreq_isr);
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 6e85550..e9feb2a 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -30,14 +30,14 @@ int dccp_feat_default_ack_ratio	      = 
 int dccp_feat_default_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
 int dccp_feat_default_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
-void dccp_options_init(struct dccp_options *dccpo)
+void dccp_minisock_init(struct dccp_minisock *dmsk)
 {
-	dccpo->dccpo_sequence_window = dccp_feat_default_sequence_window;
-	dccpo->dccpo_rx_ccid	     = dccp_feat_default_rx_ccid;
-	dccpo->dccpo_tx_ccid	     = dccp_feat_default_tx_ccid;
-	dccpo->dccpo_ack_ratio	     = dccp_feat_default_ack_ratio;
-	dccpo->dccpo_send_ack_vector = dccp_feat_default_send_ack_vector;
-	dccpo->dccpo_send_ndp_count  = dccp_feat_default_send_ndp_count;
+	dmsk->dccpms_sequence_window = dccp_feat_default_sequence_window;
+	dmsk->dccpms_rx_ccid	     = dccp_feat_default_rx_ccid;
+	dmsk->dccpms_tx_ccid	     = dccp_feat_default_tx_ccid;
+	dmsk->dccpms_ack_ratio	     = dccp_feat_default_ack_ratio;
+	dmsk->dccpms_send_ack_vector = dccp_feat_default_send_ack_vector;
+	dmsk->dccpms_send_ndp_count  = dccp_feat_default_send_ndp_count;
 }
 
 static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
@@ -151,7 +151,7 @@ int dccp_parse_options(struct sock *sk, 
 			if (pkt_type = DCCP_PKT_DATA)
 				break;
 
-			if (dp->dccps_options.dccpo_send_ack_vector &&
+			if (dccp_msk(sk)->dccpms_send_ack_vector &&
 			    dccp_ackvec_parse(sk, skb, opt, value, len))
 				goto out_invalid_option;
 			break;
@@ -472,12 +472,12 @@ static int dccp_insert_feat_opt(struct s
 static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct dccp_opt_pend *opt, *next;
 	int change = 0;
 
 	/* confirm any options [NN opts] */
-	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_conf,
-				 dccpop_node) {
+	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
 		dccp_insert_feat_opt(skb, opt->dccpop_type,
 				     opt->dccpop_feat, opt->dccpop_val,
 				     opt->dccpop_len);
@@ -486,11 +486,10 @@ static int dccp_insert_options_feat(stru
 			kfree(opt->dccpop_val);
 		kfree(opt);
 	}
-	INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
+	INIT_LIST_HEAD(&dmsk->dccpms_conf);
 
 	/* see which features we need to send */
-	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending,
-			    dccpop_node) {
+	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 		/* see if we need to send any confirm */
 		if (opt->dccpop_sc) {
 			dccp_insert_feat_opt(skb, opt->dccpop_type + 1,
@@ -536,15 +535,16 @@ static int dccp_insert_options_feat(stru
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
-	if (dp->dccps_options.dccpo_send_ndp_count &&
+	if (dmsk->dccpms_send_ndp_count &&
 	    dccp_insert_option_ndp(sk, skb))
 		return -1;
 
 	if (!dccp_packet_without_ack(skb)) {
-		if (dp->dccps_options.dccpo_send_ack_vector &&
+		if (dmsk->dccpms_send_ack_vector &&
 		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
 		    dccp_insert_option_ackvec(sk, skb))
 			return -1;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 3292837..d637b94 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -166,9 +166,10 @@ EXPORT_SYMBOL_GPL(dccp_unhash);
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	dccp_options_init(&dp->dccps_options);
+	dccp_minisock_init(&dp->dccps_minisock);
 	do_gettimeofday(&dp->dccps_epoch);
 
 	/*
@@ -184,22 +185,20 @@ int dccp_init_sock(struct sock *sk, cons
 		if (rc)
 			return rc;
 
-		if (dp->dccps_options.dccpo_send_ack_vector) {
+		if (dmsk->dccpms_send_ack_vector) {
 			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
 			if (dp->dccps_hc_rx_ackvec = NULL)
 				return -ENOMEM;
 		}
-		dp->dccps_hc_rx_ccid -				ccid_hc_rx_new(dp->dccps_options.dccpo_rx_ccid,
-					       sk, GFP_KERNEL);
-		dp->dccps_hc_tx_ccid -				ccid_hc_tx_new(dp->dccps_options.dccpo_tx_ccid,
-					       sk, GFP_KERNEL);
+		dp->dccps_hc_rx_ccid = ccid_hc_rx_new(dmsk->dccpms_rx_ccid,
+						      sk, GFP_KERNEL);
+		dp->dccps_hc_tx_ccid = ccid_hc_tx_new(dmsk->dccpms_tx_ccid,
+						      sk, GFP_KERNEL);
 	    	if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
 			     dp->dccps_hc_tx_ccid = NULL)) {
 			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
 			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-			if (dp->dccps_options.dccpo_send_ack_vector) {
+			if (dmsk->dccpms_send_ack_vector) {
 				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 				dp->dccps_hc_rx_ackvec = NULL;
 			}
@@ -208,8 +207,8 @@ int dccp_init_sock(struct sock *sk, cons
 		}
 	} else {
 		/* control socket doesn't need feat nego */
-		INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
-		INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
+		INIT_LIST_HEAD(&dmsk->dccpms_pending);
+		INIT_LIST_HEAD(&dmsk->dccpms_conf);
 	}	
 
 	dccp_init_xmit_timers(sk);
@@ -247,7 +246,7 @@ int dccp_destroy_sock(struct sock *sk)
 	kfree(dp->dccps_service_list);
 	dp->dccps_service_list = NULL;
 
-	if (dp->dccps_options.dccpo_send_ack_vector) {
+	if (dccp_msk(sk)->dccpms_send_ack_vector) {
 		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 		dp->dccps_hc_rx_ackvec = NULL;
 	}
-- 
1.2.2.gd27d


