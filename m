From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:32:19 +0000
Subject: [PATCH 6/7] [DCCP]: Fix setting of packet size in CCID3
Message-Id: <200609221432.20022.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Set initial packet size to defaults as existing code doesn't work
as set_sockopt occurs after initialisation so dccps_packet_size
is of no use really.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 7b4699a..e6c8e4c 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -642,15 +642,9 @@ static int ccid3_hc_tx_parse_options(str
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hctx->ccid3hctx_s = dp->dccps_packet_size;
-	else
-		hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
-
+	hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
 	/* Set transmission rate to 1 packet per second */
 	hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
 	hctx->ccid3hctx_t_rto = USEC_PER_SEC;
@@ -1113,17 +1107,11 @@ static void ccid3_hc_rx_packet_recv(stru
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hcrx->ccid3hcrx_s = dp->dccps_packet_size;
-	else
-		hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
-
+	hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 962df0e..c8f7d5a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -35,6 +35,7 @@ #include <linux/poll.h>
 #include "ccid.h"
 #include "dccp.h"
 #include "feat.h"
+#include "ccids/ccid3.h"
 
 DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
@@ -457,7 +458,10 @@ out_free_val:
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
-	struct dccp_sock *dp;
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
+	struct ccid3_hc_tx_sock *hctx;
+	struct ccid3_hc_rx_sock *hcrx;
 	int err;
 	int val;
 
@@ -471,7 +475,6 @@ static int do_dccp_setsockopt(struct soc
 		return dccp_setsockopt_service(sk, val, optval, optlen);
 
 	lock_sock(sk);
-	dp = dccp_sk(sk);
 	err = 0;
 
 	switch (optname) {
@@ -497,6 +500,30 @@ static int do_dccp_setsockopt(struct soc
 						     optval);
 		break;
 
+	case DCCP_SOCKOPT_TX_PACKET_SIZE:
+		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
+			err = -EINVAL;
+		else
+			if (val >= TFRC_MIN_PACKET_SIZE &&
+			   val <= TFRC_MAX_PACKET_SIZE) {
+				hctx = ccid3_hc_tx_sk(sk);
+				hctx->ccid3hctx_s = val;
+			} else
+				err = -EINVAL;
+		break;
+
+	case DCCP_SOCKOPT_RX_PACKET_SIZE:
+		if (dmsk->dccpms_rx_ccid != DCCPC_CCID3)
+			err = -EINVAL;
+		else
+			if (val >= TFRC_MIN_PACKET_SIZE &&
+			   val <= TFRC_MAX_PACKET_SIZE) {
+				hcrx = ccid3_hc_rx_sk(sk);
+				hcrx->ccid3hcrx_s = val;
+			} else
+				err = -EINVAL;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -565,7 +592,10 @@ out:
 static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
-	struct dccp_sock *dp;
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
+	struct ccid3_hc_tx_sock *hctx;
+	struct ccid3_hc_rx_sock *hcrx;
 	int val, len;
 
 	if (get_user(len, optlen))
@@ -574,13 +604,25 @@ static int do_dccp_getsockopt(struct soc
 	if (len < sizeof(int))
 		return -EINVAL;
 
-	dp = dccp_sk(sk);
-
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
 		val = dp->dccps_packet_size;
 		len = sizeof(dp->dccps_packet_size);
 		break;
+	case DCCP_SOCKOPT_TX_PACKET_SIZE:
+		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
+			return -EINVAL;
+		hctx = ccid3_hc_tx_sk(sk);
+		val = hctx->ccid3hctx_s;
+		len = sizeof(val);
+		break;
+	case DCCP_SOCKOPT_RX_PACKET_SIZE:
+		if (dmsk->dccpms_rx_ccid != DCCPC_CCID3)
+			return -EINVAL;
+	 	hcrx = ccid3_hc_rx_sk(sk);
+		val = hcrx->ccid3hcrx_s;
+		len = sizeof(val);
+		break;
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);
