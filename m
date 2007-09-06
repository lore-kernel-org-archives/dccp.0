From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 03:04:26 +0000
Subject: [PATCH 2/6] DCCP: Add setsocketopts for CCIDs
Message-Id: <200709061504.26877.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200708291128.42798.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291128.42798.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

For faster restart and TFRCbis we need to pass socket options down to
CCIDs. Add framework in for this.

Shift check for LISTEN as part of this, as suggested by Gerrit Renker.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index c65cb24..0067526 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -65,6 +65,11 @@ struct ccid_operations {
 						 const int optname, int len,
 						 u32 __user *optval,
 						 int __user *optlen);
+	int		(*ccid_hc_rx_setsockopt)(struct sock *sk,
+				const int optname, int val, int optlen);
+	int		(*ccid_hc_tx_setsockopt)(struct sock *sk,
+				const int optname, int val, int optlen);
+
 };
 
 extern int ccid_register(struct ccid_operations *ccid_ops);
@@ -171,6 +176,11 @@ static inline int ccid_hc_rx_getsockopt(struct ccid *ccid, struct sock *sk,
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
+
+	/* Listen socks don't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return -EINVAL;
+
 	if (ccid->ccid_ops->ccid_hc_rx_getsockopt != NULL)
 		rc = ccid->ccid_ops->ccid_hc_rx_getsockopt(sk, optname, len,
 						 optval, optlen);
@@ -182,9 +192,44 @@ static inline int ccid_hc_tx_getsockopt(struct ccid *ccid, struct sock *sk,
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
+
+	/* Listen socks don't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return -EINVAL;
+
 	if (ccid->ccid_ops->ccid_hc_tx_getsockopt != NULL)
 		rc = ccid->ccid_ops->ccid_hc_tx_getsockopt(sk, optname, len,
 						 optval, optlen);
 	return rc;
 }
+
+static inline int ccid_hc_rx_setsockopt(struct ccid*ccid, struct sock *sk,
+				const int optname, int val, int optlen)
+{
+	int rc = -ENOPROTOOPT;
+
+	/* Listen socks don't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return -EINVAL;
+
+	if (ccid->ccid_ops->ccid_hc_rx_setsockopt != NULL)
+		rc = ccid->ccid_ops->ccid_hc_rx_setsockopt(sk, optname,
+						 val, optlen);
+	return rc;
+}
+
+static inline int ccid_hc_tx_setsockopt(struct ccid*ccid, struct sock *sk,
+				const int optname, int val, int optlen)
+{
+	int rc = -ENOPROTOOPT;
+
+	/* Listen socks don't have a private CCID block */
+	if (sk->sk_state = DCCP_LISTEN)
+		return -EINVAL;
+
+	if (ccid->ccid_ops->ccid_hc_tx_setsockopt != NULL)
+		rc = ccid->ccid_ops->ccid_hc_tx_setsockopt(sk, optname,
+						 val, optlen);
+	return rc;
+}
 #endif /* _CCID_H */
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 45ba4be..7e995c8 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -609,10 +609,6 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const void *val;
 
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(hctx->ccid3hctx_tfrc))
@@ -901,10 +897,6 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	const void *val;
 	struct tfrc_rx_info rx_info;
 
-	/* Listen socks don't have a private CCID block */
-	if (sk->sk_state = DCCP_LISTEN)
-		return -EINVAL;
-
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index fc5ffae..4ac6529 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -526,6 +526,14 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 			 * ChangeL(MinimumChecksumCoverage, val) */
 		}
 		break;
+	case 128 ... 191:
+		err = ccid_hc_rx_setsockopt(dp->dccps_hc_rx_ccid, sk, optname,
+			val, optlen);
+		break;
+	case 192 ... 255:
+		err = ccid_hc_tx_setsockopt(dp->dccps_hc_tx_ccid, sk, optname,
+			val, optlen);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
