From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:27:23 +0000
Subject: [PATCH 1/2] Share ccid{3/4}_hc_tx_set_state function via tfrc_ccids
Message-Id: <200712210127.23302.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Share ccid{3/4}_hc_tx_set_state function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -44,19 +44,6 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static void ccid3_hc_tx_set_state(struct sock *sk,
-				  enum tfrc_hc_tx_states state)
-{
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	enum tfrc_hc_tx_states oldstate = hctx->ttx_state;
-
-	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
-		       tfrc_tx_state_name(state));
-	WARN_ON(state = oldstate);
-	hctx->ttx_state = state;
-}
-
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
@@ -159,7 +146,7 @@ static void ccid3_hc_tx_no_feedback_time
 		       tfrc_tx_state_name(hctx->ttx_state));
 
 	if (hctx->ttx_state = TTX_STATE_FBACK)
-		ccid3_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 	else if (hctx->ttx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
@@ -268,7 +255,7 @@ static int ccid3_hc_tx_send_packet(struc
 		}
 		ccid3_update_send_interval(hctx);
 
-		ccid3_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 		break;
 	case TTX_STATE_NO_FBACK:
 	case TTX_STATE_FBACK:
@@ -361,7 +348,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
 	if (hctx->ttx_state = TTX_STATE_NO_FBACK) {
-		ccid3_hc_tx_set_state(sk, TTX_STATE_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_FBACK);
 
 		if (hctx->ttx_t_rto = 0) {
 			/*
@@ -446,7 +433,7 @@ static void ccid3_hc_tx_exit(struct sock
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
-	ccid3_hc_tx_set_state(sk, TTX_STATE_TERM);
+	tfrc_tx_set_state(sk, TTX_STATE_TERM);
 	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
 	tfrc_tx_hist_purge(&hctx->ttx_hist);
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -54,19 +54,6 @@ static int ccid4_debug;
 #define ccid4_pr_debug(format, a...)
 #endif
 
-static void ccid4_hc_tx_set_state(struct sock *sk,
-				  enum tfrc_hc_tx_states state)
-{
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	enum tfrc_hc_tx_states oldstate = hctx->ttx_state;
-
-	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
-		       tfrc_tx_state_name(state));
-	WARN_ON(state = oldstate);
-	hctx->ttx_state = state;
-}
-
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
@@ -192,7 +179,7 @@ static void ccid4_hc_tx_no_feedback_time
 		       tfrc_tx_state_name(hctx->ttx_state));
 
 	if (hctx->ttx_state = TTX_STATE_FBACK)
-		ccid4_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 	else if (hctx->ttx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
@@ -302,7 +289,7 @@ static int ccid4_hc_tx_send_packet(struc
 		}
 		ccid4_update_send_interval(hctx);
 
-		ccid4_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_NO_FBACK);
 		break;
 	case TTX_STATE_NO_FBACK:
 	case TTX_STATE_FBACK:
@@ -396,7 +383,7 @@ static void ccid4_hc_tx_packet_recv(stru
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
 	if (hctx->ttx_state = TTX_STATE_NO_FBACK) {
-		ccid4_hc_tx_set_state(sk, TTX_STATE_FBACK);
+		tfrc_tx_set_state(sk, TTX_STATE_FBACK);
 
 		if (hctx->ttx_t_rto = 0) {
 			/*
@@ -483,7 +470,7 @@ static void ccid4_hc_tx_exit(struct sock
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
-	ccid4_hc_tx_set_state(sk, TTX_STATE_TERM);
+	tfrc_tx_set_state(sk, TTX_STATE_TERM);
 	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
 	tfrc_tx_hist_purge(&hctx->ttx_hist);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -162,3 +162,17 @@ int tfrc_rx_insert_options(struct sock *
 }
 
 EXPORT_SYMBOL_GPL(tfrc_rx_insert_options);
+
+void tfrc_tx_set_state(struct sock *sk, enum tfrc_hc_tx_states state)
+{
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	enum tfrc_hc_tx_states oldstate = hctx->ttx_state;
+
+	tfrc_pr_debug("%s(%p) %-8.8s -> %s\n", dccp_role(sk), sk,
+			tfrc_tx_state_name(oldstate),
+			tfrc_tx_state_name(state));
+	WARN_ON(state = oldstate);
+	hctx->ttx_state = state;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_tx_set_state);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -198,3 +198,5 @@ extern int tfrc_tx_parse_options(struct 
 			unsigned char len, u16 idx, unsigned char *value);
 
 extern int tfrc_rx_insert_options(struct sock *sk, struct sk_buff *skb);
+
+extern void tfrc_tx_set_state(struct sock *sk, enum tfrc_hc_tx_states state);
