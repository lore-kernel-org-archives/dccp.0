From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 19:15:58 +0000
Subject: [DCCP]: Allow applications to change tx_qlen
Message-Id: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_u/89HVWKsp7zeEq"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--Boundary-00=_u/89HVWKsp7zeEq
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This patch makes manipulation of tx_qlen parameter possible using getsockopt
and setsockopt calls.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h      |    1 +
 net/dccp/proto.c          |    6 ++++++
 net/dccp/qpolicy.c        |   13 +++++++++++++
 net/dccp/qpolicy.h        |    3 +++
 net/dccp/qpolicy_prio.c   |    3 ++-
 net/dccp/qpolicy_simple.c |    3 ++-
 6 files changed, 27 insertions(+), 2 deletions(-)
-- 
Regards,
Tomasz Grobelny

--Boundary-00=_u/89HVWKsp7zeEq
Content-Type: text/x-patch;
  name="64f35297930f4c5091f05cf2ad57038ec3062221.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="64f35297930f4c5091f05cf2ad57038ec3062221.diff"

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 3b40133..745d7b1 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -209,6 +209,7 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_QPOLICY_ID		16
+#define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 24e56a2..4eda91f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -547,6 +547,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_QPOLICY_ID:
 		err = dccp_qpolicy_set_id(sk, val);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
+		err = dccp_qpolicy_set_txqlen(sk, val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -653,6 +656,9 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_QPOLICY_ID:
 		val = dccp_qpolicy_get_id(sk);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
+		val = dccp_qpolicy_get_txqlen(sk);
+		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 7315bf0..d774a57 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -25,6 +25,7 @@ void dccp_qpolicy_init(struct sock *sk)
 	struct dccp_sock *dp = dccp_sk(sk);
 	dp->dccps_qpolicy = kmalloc(sizeof(struct dccp_qpolicy), GFP_KERNEL);
 	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
+	dp->dccps_qpolicy->qpol_txqlen = sysctl_dccp_tx_qlen;
 }
 
 int dccp_qpolicy_set_id(struct sock *sk, int id)
@@ -45,6 +46,18 @@ void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk)
 {
 	dccp_qpolicy_init(sk);
 	dccp_qpolicy_set_id(sk, dccp_qpolicy_get_id(oldsk));
+	dccp_qpolicy_set_txqlen(sk, dccp_qpolicy_get_txqlen(oldsk));
+}
+
+int dccp_qpolicy_set_txqlen(struct sock *sk, int len)
+{
+	dccp_sk(sk)->dccps_qpolicy->qpol_txqlen = len;
+	return 0;
+}
+
+int dccp_qpolicy_get_txqlen(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
 }
 
 void dccp_qpolicy_destroy(struct sock *sk)
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index ccfbf1b..b0cd0cb 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -31,6 +31,7 @@ struct dccp_qpolicy_operations
 struct dccp_qpolicy
 {
 	struct dccp_qpolicy_operations	*qpol_ops;
+	int				qpol_txqlen;
 	char				qpol_priv[0];
 };
 
@@ -39,6 +40,8 @@ void dccp_qpolicy_init(struct sock *sk);
 int dccp_qpolicy_set_id(struct sock *sk, int id);
 int dccp_qpolicy_get_id(struct sock *sk);
 void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk);
+int dccp_qpolicy_set_txqlen(struct sock *sk, int len);
+int dccp_qpolicy_get_txqlen(struct sock *sk);
 void dccp_qpolicy_destroy(struct sock *sk);
 
 /** these are wrappers for methods provided by policy currently in use */
diff --git a/net/dccp/qpolicy_prio.c b/net/dccp/qpolicy_prio.c
index 2fde6e5..d27aa8b 100644
--- a/net/dccp/qpolicy_prio.c
+++ b/net/dccp/qpolicy_prio.c
@@ -34,13 +34,14 @@ struct sk_buff *dccp_queue_get_worst(struct sk_buff_head *list)
 
 void prio_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
 {
+	int tx_qlen = dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
 	struct dccp_policy_prio *dcp = (struct dccp_policy_prio *)control;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	SKB_PRIO(dcb)->priority = 127;
 	if(dcp)
 		memcpy(SKB_PRIO(dcb), dcp, min(sizeof(struct dccp_policy_prio), controllen));
 	skb_queue_tail(&sk->sk_write_queue, skb);
-	if(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)
+	if(sk->sk_write_queue.qlen >= tx_qlen)
 	{
 		struct sk_buff* worst=dccp_queue_get_worst(&sk->sk_write_queue);
 		skb_unlink(worst, &sk->sk_write_queue);
diff --git a/net/dccp/qpolicy_simple.c b/net/dccp/qpolicy_simple.c
index a839049..c482d94 100644
--- a/net/dccp/qpolicy_simple.c
+++ b/net/dccp/qpolicy_simple.c
@@ -20,7 +20,8 @@ void simple_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_s
 
 int simple_full(struct sock *sk)
 {
-	return (sysctl_dccp_tx_qlen && (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen));
+	int tx_qlen = dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
+	return (tx_qlen && (sk->sk_write_queue.qlen >= tx_qlen));
 }
 
 struct sk_buff* simple_top(struct sock *sk)

--Boundary-00=_u/89HVWKsp7zeEq--


