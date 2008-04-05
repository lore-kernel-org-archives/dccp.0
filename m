From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 14:27:19 +0000
Subject: [PATCH 4/5] [DCCP]: Allow changing qpolicy for a socket
Message-Id: <20080411102604.A824BBD40@poczta.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch enables applications to manipulate qpolicy using getsockopt and
setsockopt calls. Qpolicy is inherited on accept().

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    1 +
 net/dccp/minisocks.c |    2 +-
 net/dccp/proto.c     |    6 ++++++
 net/dccp/qpolicy.c   |   23 +++++++++++++++++++++++
 net/dccp/qpolicy.h   |    3 +++
 5 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index dfae04f..f3a926a 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -216,6 +216,7 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_CCID		13
 #define DCCP_SOCKOPT_TX_CCID		14
 #define DCCP_SOCKOPT_RX_CCID		15
+#define DCCP_SOCKOPT_QPOLICY_ID		16
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index f9a6211..6e1cbcc 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -142,7 +142,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 			return NULL;
 		}
 		dccp_init_xmit_timers(newsk);
-		dccp_qpolicy_init(newsk);
+		dccp_qpolicy_inherit(newsk, sk);
 
 		DCCP_INC_STATS_BH(DCCP_MIB_PASSIVEOPENS);
 	}
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7652175..a997b11 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -542,6 +542,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		err = dccp_setsockopt_cscov(sk, val, true);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_ID:
+		err = dccp_qpolicy_set_id(sk, val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -645,6 +648,9 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		val = dp->dccps_pcrlen;
 		break;
+	case DCCP_SOCKOPT_QPOLICY_ID:
+		val = dccp_qpolicy_get_id(sk);
+		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 57b5797..35a4b85 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -26,6 +26,29 @@ void dccp_qpolicy_init(struct sock *sk)
 	dp->dccps_qpolicy.qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
 }
 
+int dccp_qpolicy_set_id(struct sock *sk, int id)
+{
+	if (!(sk->sk_state = DCCP_CLOSED) || (sk->sk_state = DCCP_LISTEN))
+		return -EISCONN;
+	if (id >= ARRAY_SIZE(qpolicy_operations))
+		return -EINVAL;
+	dccp_sk(sk)->dccps_qpolicy.qpol_ops = qpolicy_operations[id];
+	return 0;
+}
+
+int dccp_qpolicy_get_id(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_qpolicy.qpol_ops->policy_id;
+}
+
+void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	int policy_id = dccp_qpolicy_get_id(oldsk);
+	dccp_sk(sk)->dccps_qpolicy.qpol_ops = qpolicy_operations[policy_id];
+
+
 void qpolicy_push(struct sock *sk, struct sk_buff *skb,
 				void *control, __kernel_size_t controllen)
 {
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index 77aa387..b563a58 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -34,6 +34,9 @@ struct dccp_qpolicy_operations {
 
 /** these operate on data that is common to all policies */
 void dccp_qpolicy_init(struct sock *sk);
+int dccp_qpolicy_set_id(struct sock *sk, int id);
+int dccp_qpolicy_get_id(struct sock *sk);
+void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk);
 void dccp_qpolicy_destroy(struct sock *sk);
 
 /** these are wrappers for methods provided by policy currently in use */
-- 
1.5.4.5


