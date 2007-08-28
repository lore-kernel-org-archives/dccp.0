From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Aug 2007 23:28:42 +0000
Subject: [PATCH 2/6] DCCP: Add setsocketopts for CCIDs
Message-Id: <200708291128.42798.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

For faster restart and TFRCbis we need to pass socket options down to
CCIDs. Add framework in for this.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index c65cb24..65f91ba 100644
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
@@ -187,4 +192,24 @@ static inline int ccid_hc_tx_getsockopt(struct ccid 
*ccid, struct sock *sk,
 						 optval, optlen);
 	return rc;
 }
+
+static inline int ccid_hc_rx_setsockopt(struct ccid*ccid, struct sock *sk,
+				const int optname, int val, int optlen)
+{
+	int rc = -ENOPROTOOPT;
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
+	if (ccid->ccid_ops->ccid_hc_tx_setsockopt != NULL)
+		rc = ccid->ccid_ops->ccid_hc_tx_setsockopt(sk, optname,
+						 val, optlen);
+	return rc;
+}
 #endif /* _CCID_H */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index fc5ffae..bd81176 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -526,6 +526,14 @@ static int do_dccp_setsockopt(struct sock *sk, int level, 
int optname,
 			 * ChangeL(MinimumChecksumCoverage, val) */
 		}
 		break;
+	case 128 ... 191:
+		err = ccid_hc_rx_setsockopt(dp->dccps_hc_rx_ccid, sk, optname,
+					     val, optlen);
+		break;
+	case 192 ... 255:
+		err = ccid_hc_tx_setsockopt(dp->dccps_hc_tx_ccid, sk, optname,
+					     val, optlen);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
