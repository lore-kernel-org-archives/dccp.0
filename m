From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:35 +0000
Subject: [PATCH 9/25] Adapt CCID-4 according to the latest changes to CCID-3
Message-Id: <200710312130.35629.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Adapt CCID-4 according to the latest changes to CCID-3

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -156,7 +156,6 @@ static inline void ccid4_hc_tx_x_header_
  *
  */
 static void ccid4_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
-
 {
 	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid4hctx_x_recv;
@@ -939,7 +938,7 @@ static int ccid4_hc_rx_getsockopt(struct
 
 static struct ccid_operations ccid4 = {
 	.ccid_id		   = DCCPC_CCID4,
-	.ccid_name		   = "ccid4",
+	.ccid_name		   = "TCP-Friendly Rate Control (Small-Packet variant)",
 	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid4_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid4_hc_tx_init,
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -128,10 +128,9 @@ struct ccid4_hc_tx_sock {
 
 static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
 {
-	void *ccid4_tx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-
-	BUG_ON(ccid4_tx_priv = NULL);
-	return ccid4_tx_priv;
+    struct ccid4_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+    BUG_ON(hctx = NULL);
+    return hctx;
 }
 
 /* CCID4 receiver states */
@@ -177,10 +176,9 @@ struct ccid4_hc_rx_sock {
 
 static inline struct ccid4_hc_rx_sock *ccid4_hc_rx_sk(const struct sock *sk)
 {
-	void *ccid4_rx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
-
-	BUG_ON(ccid4_rx_priv = NULL);
-	return ccid4_rx_priv;
+    struct ccid4_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+    BUG_ON(hcrx = NULL);
+    return hcrx;
 }
 
 #endif /* _DCCP_CCID4_H_ */
