From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:29:34 +0000
Subject: [PATCHv2 3/8] Apply new naming schema for TFRC TX/RX states
Message-Id: <200712210129.34259.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3][CCID-4][TFRC_CCIDS] Apply new naming schema for TFRC TX/RX states.

As discussed with Gerrit and Arnaldo, this patches rename the name schema agreed in discussion the the DCCP mailing list.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

--------------------> Patch v2 <-------------------------

The first version of this patch doest apply properly in the current ccid4 branch. This new version it is ok.

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -163,9 +163,9 @@ static void ccid3_hc_tx_no_feedback_time
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       tfrc_tx_state_name(hctx->tfrchctx_state));
 
-	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->tfrchctx_state = TTX_STATE_FBACK)
+		ccid3_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+	else if (hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
 	/*
@@ -245,7 +245,7 @@ static int ccid3_hc_tx_send_packet(struc
 		return -EBADMSG;
 
 	switch (hctx->tfrchctx_state) {
-	case TFRC_SSTATE_NO_SENT:
+	case TTX_STATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
@@ -274,10 +274,10 @@ static int ccid3_hc_tx_send_packet(struc
 		}
 		ccid3_update_send_interval(hctx);
 
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
+		ccid3_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 		break;
-	case TFRC_SSTATE_NO_FBACK:
-	case TFRC_SSTATE_FBACK:
+	case TTX_STATE_NO_FBACK:
+	case TTX_STATE_FBACK:
 		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
@@ -293,7 +293,7 @@ static int ccid3_hc_tx_send_packet(struc
 
 		tfrc_hc_tx_update_win_count(hctx, now);
 		break;
-	case TFRC_SSTATE_TERM:
+	case TTX_STATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return -EINVAL;
 	}
@@ -332,8 +332,8 @@ static void ccid3_hc_tx_packet_recv(stru
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->tfrchctx_state != TFRC_SSTATE_FBACK &&
-	    hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->tfrchctx_state != TTX_STATE_FBACK &&
+	    hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
 		return;
 
 	opt_recv = &hctx->tfrchctx_options_received;
@@ -367,8 +367,8 @@ static void ccid3_hc_tx_packet_recv(stru
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->tfrchctx_state = TFRC_SSTATE_NO_FBACK) {
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+	if (hctx->tfrchctx_state = TTX_STATE_NO_FBACK) {
+		ccid3_hc_tx_set_state(sk, TTX_STATE_FBACK);
 
 		if (hctx->tfrchctx_t_rto = 0) {
 			/*
@@ -505,7 +505,7 @@ static int ccid3_hc_tx_init(struct ccid 
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
+	hctx->tfrchctx_state = TTX_STATE_NO_SENT;
 	hctx->tfrchctx_hist = NULL;
 	setup_timer(&hctx->tfrchctx_no_feedback_timer,
 			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
@@ -517,7 +517,7 @@ static void ccid3_hc_tx_exit(struct sock
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
-	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
+	ccid3_hc_tx_set_state(sk, TTX_STATE_TERM);
 	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	tfrc_tx_hist_purge(&hctx->tfrchctx_hist);
@@ -574,7 +574,7 @@ static void ccid3_hc_rx_send_feedback(st
 	ktime_t now;
 	s64 delta = 0;
 
-	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_TERM))
 		return;
 
 	now = ktime_get_real();
@@ -691,11 +691,11 @@ static void ccid3_hc_rx_packet_recv(stru
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
-			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
+			ccid3_hc_rx_set_state(sk, TRX_STATE_DATA);
 			hcrx->tfrchcrx_s = payload;
 			/*
 			 * Not necessary to update tfrchcrx_bytes_recv here,
@@ -774,7 +774,7 @@ static int ccid3_hc_rx_init(struct ccid 
 {
 	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->tfrchcrx_state = TRX_STATE_NO_DATA;
 	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
 	return tfrc_rx_hist_alloc(&hcrx->tfrchcrx_hist);
 }
@@ -783,7 +783,7 @@ static void ccid3_hc_rx_exit(struct sock
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
-	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
+	ccid3_hc_rx_set_state(sk, TRX_STATE_TERM);
 
 	tfrc_rx_hist_purge(&hcrx->tfrchcrx_hist);
 	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -191,9 +191,9 @@ static void ccid4_hc_tx_no_feedback_time
 	ccid4_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       tfrc_tx_state_name(hctx->tfrchctx_state));
 
-	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
-		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->tfrchctx_state = TTX_STATE_FBACK)
+		ccid4_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+	else if (hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
 	/*
@@ -273,7 +273,7 @@ static int ccid4_hc_tx_send_packet(struc
 		return -EBADMSG;
 
 	switch (hctx->tfrchctx_state) {
-	case TFRC_SSTATE_NO_SENT:
+	case TTX_STATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
@@ -302,10 +302,10 @@ static int ccid4_hc_tx_send_packet(struc
 		}
 		ccid4_update_send_interval(hctx);
 
-		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
+		ccid4_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 		break;
-	case TFRC_SSTATE_NO_FBACK:
-	case TFRC_SSTATE_FBACK:
+	case TTX_STATE_NO_FBACK:
+	case TTX_STATE_FBACK:
 		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
 		ccid4_pr_debug("delay=%ld\n", (long)delay);
 		/*
@@ -321,7 +321,7 @@ static int ccid4_hc_tx_send_packet(struc
 
 		tfrc_hc_tx_update_win_count(hctx, now);
 		break;
-	case TFRC_SSTATE_TERM:
+	case TTX_STATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return -EINVAL;
 	}
@@ -360,8 +360,8 @@ static void ccid4_hc_tx_packet_recv(stru
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->tfrchctx_state != TFRC_SSTATE_FBACK &&
-	    hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->tfrchctx_state != TTX_STATE_FBACK &&
+	    hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
 		return;
 
 	opt_recv = &hctx->tfrchctx_options_received;
@@ -395,8 +395,8 @@ static void ccid4_hc_tx_packet_recv(stru
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->tfrchctx_state = TFRC_SSTATE_NO_FBACK) {
-		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+	if (hctx->tfrchctx_state = TTX_STATE_NO_FBACK) {
+		ccid4_hc_tx_set_state(sk, TTX_STATE_FBACK);
 
 		if (hctx->tfrchctx_t_rto = 0) {
 			/*
@@ -536,7 +536,7 @@ static int ccid4_hc_tx_init(struct ccid 
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
+	hctx->tfrchctx_state = TTX_STATE_NO_SENT;
 	hctx->tfrchctx_hist = NULL;
 	setup_timer(&hctx->tfrchctx_no_feedback_timer,
 			ccid4_hc_tx_no_feedback_timer, (unsigned long)sk);
@@ -548,7 +548,7 @@ static void ccid4_hc_tx_exit(struct sock
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
-	ccid4_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
+	ccid4_hc_tx_set_state(sk, TTX_STATE_TERM);
 	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	tfrc_tx_hist_purge(&hctx->tfrchctx_hist);
@@ -605,7 +605,7 @@ static void ccid4_hc_rx_send_feedback(st
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_TERM))
 		return;
 
 	switch (fbtype) {
@@ -719,11 +719,11 @@ static void ccid4_hc_rx_packet_recv(stru
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool  is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
-			ccid4_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
+			ccid4_hc_rx_set_state(sk, TRX_STATE_DATA);
 			hcrx->tfrchcrx_s = payload;
                        /*
                         * Not necessary to update tfrchcrx_bytes_recv here,
@@ -802,7 +802,7 @@ static int ccid4_hc_rx_init(struct ccid 
 {
 	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->tfrchcrx_state = TRX_STATE_NO_DATA;
 	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
 	return tfrc_rx_hist_alloc(&hcrx->tfrchcrx_hist);
 }
@@ -811,7 +811,7 @@ static void ccid4_hc_rx_exit(struct sock
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
-	ccid4_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
+	ccid4_hc_rx_set_state(sk, TRX_STATE_TERM);
 
 	tfrc_rx_hist_purge(&hcrx->tfrchcrx_hist);
 	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -50,17 +50,17 @@ struct tfrc_options_received {
 
 /* TFRC sender states */
 enum tfrc_hc_tx_states {
-	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
+	TTX_STATE_NO_SENT = 1,
+	TTX_STATE_NO_FBACK,
+	TTX_STATE_FBACK,
+	TTX_STATE_TERM,
 };
 
 /* TFRC receiver states */
 enum tfrc_hc_rx_states {
-	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
+	TRX_STATE_NO_DATA = 1,
+	TRX_STATE_DATA,
+	TRX_STATE_TERM    = 127,
 };
 
 /* CCID3/4 feedback types */
@@ -160,10 +160,10 @@ static inline struct tfrc_hc_rx_sock *tf
 static const char *tfrc_tx_state_name(enum tfrc_hc_tx_states state)
 {
 	static char *tfrc_state_names[] = {
-	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
-	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
-	[TFRC_SSTATE_FBACK]    = "FBACK",
-	[TFRC_SSTATE_TERM]     = "TERM",
+	[TTX_STATE_NO_SENT]  = "NO_SENT",
+	[TTX_STATE_NO_FBACK] = "NO_FBACK",
+	[TTX_STATE_FBACK]    = "FBACK",
+	[TTX_STATE_TERM]     = "TERM",
 	};
 
 	return tfrc_state_names[state];
@@ -177,9 +177,9 @@ static const char *tfrc_tx_state_name(en
 static const char *tfrc_rx_state_name(enum tfrc_hc_rx_states state)
 {
 	static char *tfrc_rx_state_names[] = {
-	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
-	[TFRC_RSTATE_DATA]    = "DATA",
-	[TFRC_RSTATE_TERM]    = "TERM",
+	[TRX_STATE_NO_DATA] = "NO_DATA",
+	[TRX_STATE_DATA]    = "DATA",
+	[TRX_STATE_TERM]    = "TERM",
 	};
 
 	return tfrc_rx_state_names[state];
