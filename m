From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:33:48 +0000
Subject: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <200609221433.48612.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes DCCP_SOCKOPT_PACKET_SIZE for two reasons:
* the current code doesn't work
* tx and rx should be different (introduced in former patch)

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index ef1c57b..18fbbb4 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -196,7 +196,6 @@ struct dccp_so_feat {
 };
 
 /* DCCP socket options */
-#define DCCP_SOCKOPT_PACKET_SIZE	1
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
@@ -465,7 +464,6 @@ struct dccp_sock {
 	struct dccp_service_list	*dccps_service_list;
 	struct timeval			dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
-	__u32				dccps_packet_size;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
 	unsigned long			dccps_ndp_count;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index c8f7d5a..c8c884e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -458,7 +458,6 @@ out_free_val:
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct ccid3_hc_tx_sock *hctx;
 	struct ccid3_hc_rx_sock *hcrx;
@@ -478,10 +477,6 @@ static int do_dccp_setsockopt(struct soc
 	err = 0;
 
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		dp->dccps_packet_size = val;
-		break;
-
 	case DCCP_SOCKOPT_CHANGE_L:
 		if (optlen != sizeof(struct dccp_so_feat))
 			err = -EINVAL;
@@ -605,10 +600,6 @@ static int do_dccp_getsockopt(struct soc
 		return -EINVAL;
 
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		val = dp->dccps_packet_size;
-		len = sizeof(dp->dccps_packet_size);
-		break;
 	case DCCP_SOCKOPT_TX_PACKET_SIZE:
 		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
 			return -EINVAL;
