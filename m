From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 05 Apr 2008 19:15:50 +0000
Subject: [DCCP]: Allow changing qpolicy for a socket
Message-Id: <200804052115.50563.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_m/89HfOldBIueuR"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--Boundary-00=_m/89HfOldBIueuR
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This patch enables applications to manipulate qpolicy using getsockopt and
setsockopt calls. Qpolicy is inherited on accept().

Signed-off-by: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
---
 include/linux/dccp.h |    1 +
 net/dccp/minisocks.c |    2 +-
 net/dccp/proto.c     |    6 ++++++
 net/dccp/qpolicy.c   |   20 ++++++++++++++++++++
 net/dccp/qpolicy.h   |    3 +++
 5 files changed, 31 insertions(+), 1 deletions(-)
-- 
Regards,
Tomasz Grobelny

--Boundary-00=_m/89HfOldBIueuR
Content-Type: text/x-patch;
  name="18a7bfe6542b0c13922dea204d38171e7ffdbb73.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="18a7bfe6542b0c13922dea204d38171e7ffdbb73.diff"

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 3484a4a..3b40133 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -208,6 +208,7 @@ enum dccp_feature_numbers {
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
index f3916ac..24e56a2 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -544,6 +544,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		err = dccp_setsockopt_cscov(sk, val, true);
 		break;
+	case DCCP_SOCKOPT_QPOLICY_ID:
+		err = dccp_qpolicy_set_id(sk, val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -647,6 +650,9 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
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
index df8861a..7315bf0 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -27,6 +27,26 @@ void dccp_qpolicy_init(struct sock *sk)
 	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
 }
 
+int dccp_qpolicy_set_id(struct sock *sk, int id)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	if(id >= ARRAY_SIZE(qpolicy_operations))
+		return -EINVAL;
+	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[id];
+	return 0;
+}
+
+int dccp_qpolicy_get_id(struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_qpolicy->qpol_ops->policy_id;
+}
+
+void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk)
+{
+	dccp_qpolicy_init(sk);
+	dccp_qpolicy_set_id(sk, dccp_qpolicy_get_id(oldsk));
+}
+
 void dccp_qpolicy_destroy(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
diff --git a/net/dccp/qpolicy.h b/net/dccp/qpolicy.h
index dd4b94d..ccfbf1b 100644
--- a/net/dccp/qpolicy.h
+++ b/net/dccp/qpolicy.h
@@ -36,6 +36,9 @@ struct dccp_qpolicy
 
 /** these operate on data that is common to all policies */
 void dccp_qpolicy_init(struct sock *sk);
+int dccp_qpolicy_set_id(struct sock *sk, int id);
+int dccp_qpolicy_get_id(struct sock *sk);
+void dccp_qpolicy_inherit(struct sock *sk, struct sock *oldsk);
 void dccp_qpolicy_destroy(struct sock *sk);
 
 /** these are wrappers for methods provided by policy currently in use */

--Boundary-00=_m/89HfOldBIueuR--



