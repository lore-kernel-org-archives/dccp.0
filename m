From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 16:04:49 +0000
Subject: [PATCH 5/5] [DCCP]: Allow applications to change tx_qlen
Message-Id: <20080411102604.CC589BD41@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch makes manipulation of tx_qlen parameter possible using getsockopt
and setsockopt calls.

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h      |    2 ++
 net/dccp/proto.c          |    6 ++++++
 net/dccp/qpolicy.c        |   17 +++++++++++++++++
 net/dccp/qpolicy.h        |    2 ++
 net/dccp/qpolicy_prio.c   |    3 ++-
 net/dccp/qpolicy_simple.c |    4 ++--
 6 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index f3a926a..7f60d34 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -217,6 +217,7 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_QPOLICY_ID		16
+#define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -420,6 +421,7 @@ struct dccp_service_list {
 
 struct dccp_qpolicy {
 	struct dccp_qpolicy_operations	*qpol_ops;
+	int				qpol_txqlen;
 	char				qpol_priv[0];
 };
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a997b11..15605c5 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -545,6 +545,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_QPOLICY_ID:
 		err = dccp_qpolicy_set_id(sk, val);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
+		err = dccp_qpolicy_set_txqlen(sk, val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -651,6 +654,9 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
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
index 35a4b85..1b87537 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -24,6 +24,7 @@ void dccp_qpolicy_init(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	dp->dccps_qpolicy.qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
+	dp->dccps_qpolicy.qpol_txqlen = sysctl_dccp_tx_qlen;
 }
 
 int dccp_qpolicy_set_id(struct sock *sk, int id)
@@ -47,7 +48,23 @@ void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk)
 
 	int policy_id = dccp_qpolicy_get_id(oldsk);
 	dccp_sk(sk)->dccps_qpolicy.qpol_ops = qpolicy_operations[policy_id];
+	dp->dccps_qpolicy.qpol_txqlen = dp->dccps_qpolicy.qpol_txqlen;
+}
+
+/**
+ * if it turns out that for some policies changing queue length doesn't make
+ * sense, or is overly complex this function could return error.
+ */
+int dccp_qpolicy_set_txqlen(struct sock *sk, int len)
+{
+	dccp_sk(sk)->dccps_qpolicy.qpol_txqlen = len;
+	return 0;
+}
 
+int dccp_qpolicy_get_txqlen(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_qpolicy.qpol_txqlen;
+}
 
 void qpolicy_push(struct sock *sk, struct sk_buff *skb,
 				void *control, __kernel_size_t controllen)
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index b563a58..2567e88 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -37,6 +37,8 @@ void dccp_qpolicy_init(struct sock *sk);
 int dccp_qpolicy_set_id(struct sock *sk, int id);
 int dccp_qpolicy_get_id(struct sock *sk);
 void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk);
+int dccp_qpolicy_set_txqlen(struct sock *sk, int len);
+int dccp_qpolicy_get_txqlen(struct sock *sk);
 void dccp_qpolicy_destroy(struct sock *sk);
 
 /** these are wrappers for methods provided by policy currently in use */
diff --git a/net/dccp/qpolicy_prio.c b/net/dccp/qpolicy_prio.c
index c2680b2..24a948e 100644
--- a/net/dccp/qpolicy_prio.c
+++ b/net/dccp/qpolicy_prio.c
@@ -33,6 +33,7 @@ static struct sk_buff *get_worst_skb(struct sk_buff_head *list)
 void prio_push(struct sock *sk, struct sk_buff *skb,
 		void *control, __kernel_size_t controllen)
 {
+	int tx_qlen = dccp_qpolicy_get_txqlen(sk);
 	struct dccp_packet_info *dcp = (struct dccp_packet_info *)control;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	int controllength = min(sizeof(struct dccp_packet_info), controllen);
@@ -40,7 +41,7 @@ void prio_push(struct sock *sk, struct sk_buff *skb,
 	if (dcp)
 		memcpy(&dcb->dccpd_policy, dcp, controllength);
 	skb_queue_tail(&sk->sk_write_queue, skb);
-	if (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen) {
+	if (sk->sk_write_queue.qlen >= tx_qlen) {
 		struct sk_buff *worst = get_worst_skb(&sk->sk_write_queue);
 		skb_unlink(worst, &sk->sk_write_queue);
 		kfree_skb(worst);
diff --git a/net/dccp/qpolicy_simple.c b/net/dccp/qpolicy_simple.c
index cd78e51..32cb1ff 100644
--- a/net/dccp/qpolicy_simple.c
+++ b/net/dccp/qpolicy_simple.c
@@ -21,8 +21,8 @@ void simple_push(struct sock *sk, struct sk_buff *skb,
 
 int simple_full(struct sock *sk)
 {
-	return (sysctl_dccp_tx_qlen &&
-		(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen));
+	int tx_qlen = dccp_qpolicy_get_txqlen(sk);
+	return (tx_qlen && (sk->sk_write_queue.qlen >= tx_qlen));
 }
 
 struct sk_buff *simple_top(struct sock *sk)
-- 
1.5.4.5

