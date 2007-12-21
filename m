From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:29:00 +0000
Subject: [PATCH 2/2] Share ccid{3/4}_hc_rx_set_state function via tfrc_ccids
Message-Id: <200712210129.00434.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Share ccid{3/4}_hc_rx_set_state function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -468,19 +468,6 @@ static int ccid3_hc_tx_getsockopt(struct
 	return 0;
 }
 
-static void ccid3_hc_rx_set_state(struct sock *sk,
-				  enum tfrc_hc_rx_states state)
-{
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	enum tfrc_hc_rx_states oldstate = hcrx->trx_state;
-
-	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
-		       tfrc_rx_state_name(state));
-	WARN_ON(state = oldstate);
-	hcrx->trx_state = state;
-}
-
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
 				      const struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
@@ -588,7 +575,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
-			ccid3_hc_rx_set_state(sk, TRX_STATE_DATA);
+			tfrc_rx_set_state(sk, TRX_STATE_DATA);
 			hcrx->trx_s = payload;
 			/*
 			 * Not necessary to update trx_bytes_recv here,
@@ -675,7 +662,7 @@ static void ccid3_hc_rx_exit(struct sock
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
-	ccid3_hc_rx_set_state(sk, TRX_STATE_TERM);
+	tfrc_rx_set_state(sk, TRX_STATE_TERM);
 
 	tfrc_rx_hist_purge(&hcrx->trx_hist);
 	tfrc_lh_cleanup(&hcrx->trx_li_hist);
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -505,19 +505,6 @@ static int ccid4_hc_tx_getsockopt(struct
 	return 0;
 }
 
-static void ccid4_hc_rx_set_state(struct sock *sk,
-				  enum tfrc_hc_rx_states state)
-{
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	enum tfrc_hc_rx_states oldstate = hcrx->trx_state;
-
-	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
-		       tfrc_rx_state_name(state));
-	WARN_ON(state = oldstate);
-	hcrx->trx_state = state;
-}
-
 static void ccid4_hc_rx_send_feedback(struct sock *sk,
 				      const struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
@@ -622,7 +609,7 @@ static void ccid4_hc_rx_packet_recv(stru
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
-			ccid4_hc_rx_set_state(sk, TRX_STATE_DATA);
+			tfrc_rx_set_state(sk, TRX_STATE_DATA);
 			hcrx->trx_s = payload;
                        /*
                         * Not necessary to update trx_bytes_recv here,
@@ -709,7 +696,7 @@ static void ccid4_hc_rx_exit(struct sock
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
-	ccid4_hc_rx_set_state(sk, TRX_STATE_TERM);
+	tfrc_rx_set_state(sk, TRX_STATE_TERM);
 
 	tfrc_rx_hist_purge(&hcrx->trx_hist);
 	tfrc_lh_cleanup(&hcrx->trx_li_hist);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -176,3 +176,17 @@ void tfrc_tx_set_state(struct sock *sk, 
 }
 
 EXPORT_SYMBOL_GPL(tfrc_tx_set_state);
+
+void tfrc_rx_set_state(struct sock *sk,
+				  enum tfrc_hc_rx_states state)
+{
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	enum tfrc_hc_rx_states oldstate = hcrx->trx_state;
+
+	tfrc_pr_debug("%s(%p) %-8.8s -> %s\n", dccp_role(sk), sk,
+			tfrc_rx_state_name(oldstate),
+			tfrc_rx_state_name(state));
+	WARN_ON(state = oldstate);
+	hcrx->trx_state = state;
+}
+
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -200,3 +200,5 @@ extern int tfrc_tx_parse_options(struct 
 extern int tfrc_rx_insert_options(struct sock *sk, struct sk_buff *skb);
 
 extern void tfrc_tx_set_state(struct sock *sk, enum tfrc_hc_tx_states state);
+
+extern void tfrc_rx_set_state(struct sock *sk, enum tfrc_hc_tx_states state);
