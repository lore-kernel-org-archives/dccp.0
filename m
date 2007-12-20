From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:59:15 +0000
Subject: [PATCH 6/8] Share ccid3_hc_rx_insert_options function via tfrc_ccids
Message-Id: <200712201359.15561.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3][CCID-4][TFRC_CCIDS] Share ccid3_hc_rx_insert_options function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -547,29 +547,6 @@ static void ccid3_hc_rx_send_feedback(st
 	dccp_send_ack(sk);
 }
 
-static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
-{
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	__be32 x_recv, pinv;
-
-	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
-		return 0;
-
-	if (dccp_packet_without_ack(skb))
-		return 0;
-
-	x_recv = htonl(hcrx->trx_x_recv);
-	pinv   = htonl(hcrx->trx_pinv);
-
-	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
-			       &pinv, sizeof(pinv)) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
-			       &x_recv, sizeof(x_recv)))
-		return -1;
-
-	return 0;
-}
-
 /** ccid3_first_li  -  Implements [RFC 3448, 6.3.1]
  *
  * Determine the length of the first loss interval via inverse lookup.
@@ -765,7 +742,7 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid3_hc_rx_exit,
-	.ccid_hc_rx_insert_options = ccid3_hc_rx_insert_options,
+	.ccid_hc_rx_insert_options = tfrc_rx_insert_options,
 	.ccid_hc_rx_packet_recv	   = ccid3_hc_rx_packet_recv,
 	.ccid_hc_rx_get_info	   = ccid3_hc_rx_get_info,
 	.ccid_hc_tx_get_info	   = ccid3_hc_tx_get_info,
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -571,29 +571,6 @@ static void ccid4_hc_rx_send_feedback(st
 	dccp_send_ack(sk);
 }
 
-static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
-{
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	__be32 x_recv, pinv;
-
-	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
-		return 0;
-
-	if (dccp_packet_without_ack(skb))
-		return 0;
-
-	x_recv = htonl(hcrx->trx_x_recv);
-	pinv   = htonl(hcrx->trx_pinv);
-
-	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
-			       &pinv, sizeof(pinv)) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
-			       &x_recv, sizeof(x_recv)))
-		return -1;
-
-	return 0;
-}
-
 /** ccid4_first_li  -  Implements [RFC 3448, 6.3.1]
  *
  * Determine the length of the first loss interval via inverse lookup.
@@ -789,7 +766,7 @@ static struct ccid_operations ccid4 = {
 	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid4_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid4_hc_rx_exit,
-	.ccid_hc_rx_insert_options = ccid4_hc_rx_insert_options,
+	.ccid_hc_rx_insert_options = tfrc_rx_insert_options,
 	.ccid_hc_rx_packet_recv	   = ccid4_hc_rx_packet_recv,
 	.ccid_hc_rx_get_info	   = ccid4_hc_rx_get_info,
 	.ccid_hc_tx_get_info	   = ccid4_hc_tx_get_info,
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -130,3 +130,28 @@ int tfrc_tx_parse_options(struct sock *s
 }
 
 EXPORT_SYMBOL_GPL(tfrc_tx_parse_options);
+
+int tfrc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
+{
+	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	__be32 x_recv, pinv;
+
+	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
+		return 0;
+
+	if (dccp_packet_without_ack(skb))
+		return 0;
+
+	x_recv = htonl(hcrx->trx_x_recv);
+	pinv   = htonl(hcrx->trx_pinv);
+
+	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+			       &pinv, sizeof(pinv)) ||
+	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
+			       &x_recv, sizeof(x_recv)))
+		return -1;
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_rx_insert_options);
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -196,3 +196,5 @@ extern void tfrc_hc_tx_update_win_count(
 
 extern int tfrc_tx_parse_options(struct sock *sk, unsigned char option,
 			     unsigned char len, u16 idx, unsigned char *value);
+
+extern int tfrc_rx_insert_options(struct sock *sk, struct sk_buff *skb);
