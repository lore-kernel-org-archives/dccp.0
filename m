From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 03:06:21 +0000
Subject: [PATCH 4/6] DCCP: Add framework for faster restart
Message-Id: <200709061506.22323.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200708291136.19130.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291136.19130.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Set up options for enabling TFRC options. Also add variables for faster
restart.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 1f696f9..17a8016 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -209,7 +209,9 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
+#define DCCP_SOCKOPT_RX_FASTER_RESTART	129
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
+#define DCCP_SOCKOPT_TX_FASTER_RESTART	193
 
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 7e995c8..ea9e1f9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -918,6 +918,44 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	return 0;
 }
 
+static int ccid3_hc_rx_setsockopt(struct sock *sk, const int optname,
+				  int val, int optlen)
+{
+	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+
+	switch (optname) {
+	case DCCP_SOCKOPT_RX_FASTER_RESTART:
+		if (val)
+			hcrx->ccid3hcrx_extensions |= TFRC_EXT_FASTER_RESTART;
+		else
+			hcrx->ccid3hcrx_extensions &= ~TFRC_EXT_FASTER_RESTART;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	return 0;
+}
+
+static int ccid3_hc_tx_setsockopt(struct sock *sk, const int optname,
+				  int val, int optlen)
+{
+	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+
+	switch (optname) {
+	case DCCP_SOCKOPT_TX_FASTER_RESTART:
+		if (val)
+			hctx->ccid3hctx_extensions |= TFRC_EXT_FASTER_RESTART;
+		else
+			hctx->ccid3hctx_extensions &= ~TFRC_EXT_FASTER_RESTART;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	return 0;
+}
+
 static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "ccid3",
@@ -938,6 +976,8 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_get_info	   = ccid3_hc_tx_get_info,
 	.ccid_hc_rx_getsockopt	   = ccid3_hc_rx_getsockopt,
 	.ccid_hc_tx_getsockopt	   = ccid3_hc_tx_getsockopt,
+	.ccid_hc_rx_setsockopt	   = ccid3_hc_rx_setsockopt,
+	.ccid_hc_tx_setsockopt	   = ccid3_hc_tx_setsockopt,
 };
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 6de73f7..c77c8fb 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -117,6 +117,10 @@ struct ccid3_hc_tx_sock {
 	struct tfrc_tx_hist_head	ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
 	u8				ccid3hctx_extensions;
+	ktime_t				ccid3hctx_t_active_recv;
+	u64				ccid3hctx_x_active_recv;
+	u32				ccid3hctx_p_prev1;
+	u32				ccid3hctx_p_prev2;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
