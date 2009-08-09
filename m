From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:47 +0000
Subject: dccp-test-tree [PATCH 10/10] Userspace support for reading ECN bits
Message-Id: <1249847327-6792-11-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds support to read the ECN bits of incoming DCCP packets.

RFC: This is an AF-independent alternative to IP_RECVTOS/IPV6_RECVTCLASS.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    6 ++++++
 include/linux/dccp.h              |    5 ++++-
 net/dccp/proto.c                  |   15 +++++++++++++++
 3 files changed, 25 insertions(+), 1 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -41,6 +41,8 @@ than 3 are not accepted. Values need to be wrapped into a cmsg(3) header:
 	cmsg->cmsg_level = SOL_DCCP;
 	cmsg->cmsg_type	 = DCCP_SCM_ECN_BITS;
 	cmsg->cmsg_len	 = CMSG_LEN(sizeof(uint8_t));	/* or CMSG_LEN(1) */
+The process can be reversed for recvmsg(2) when the DCCP_SOCKOPT_GET_ECN_BITS
+socket option is enabled (see below), using the same cmsg encapsulation.
 
 
 Missing features
@@ -131,6 +133,10 @@ DCCP_SOCKOPT_RECV_CSCOV is for the receiver and has a different meaning: it
 	restrictive this setting (see [RFC 4340, sec. 9.2.1]). Partial coverage
 	settings are inherited to the child socket after accept().
 
+DCCP_SOCKOPT_GET_ECN_BITS takes a boolean int value and enables the delivery
+	of ECN bits as ancillary data to recvmsg(2). The data is received as
+	uint8_t value at SOL_DCCP level and cmsg_type of DCCP_SCM_ECN_BITS.
+
 The following two options apply to CCID 3 exclusively and are getsockopt()-only.
 In either case, a TFRC info struct (defined in <linux/tfrc.h>) is returned.
 DCCP_SOCKOPT_CCID_RX_INFO
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -228,6 +228,7 @@ enum dccp_packet_dequeueing_policy {
 #define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_QPOLICY_ID		16
 #define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
+#define DCCP_SOCKOPT_GET_ECN_BITS	18
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -470,6 +471,7 @@ struct dccp_ackvec;
  * @dccps_r_seq_win - remote Sequence Window (influences seq number validity)
  * @dccps_l_ecn_ok - this host understands ECN bits (RFC 4340, 12.1)
  * @dccps_r_ecn_ok - the remote end understands ECN bits
+ * @dccps_get_ecn_bits - this host requests ECN bits as recvmsg() ancillary data
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_send_ndp_count - local Send NDP Count feature (7.7.2)
@@ -516,7 +518,8 @@ struct dccp_sock {
 	__u64				dccps_l_seq_win:48;
 	__u64				dccps_r_seq_win:48;
 	bool				dccps_l_ecn_ok:1,
-					dccps_r_ecn_ok:1;
+					dccps_r_ecn_ok:1,
+					dccps_get_ecn_bits:1;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
 	__u8				dccps_send_ndp_count:1;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -550,6 +550,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		else
 			dp->dccps_tx_qlen = val;
 		break;
+	case DCCP_SOCKOPT_GET_ECN_BITS:
+		dp->dccps_get_ecn_bits = (val != 0);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -663,6 +666,9 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
 		val = dp->dccps_tx_qlen;
 		break;
+	case DCCP_SOCKOPT_GET_ECN_BITS:
+		val = dp->dccps_get_ecn_bits;
+		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
@@ -825,6 +831,13 @@ out_discard:
 
 EXPORT_SYMBOL_GPL(dccp_sendmsg);
 
+static void dccp_cmsg_recv_ecn_bits(struct msghdr *msg, struct sk_buff *skb)
+{
+	u8 val = DCCP_SKB_CB(skb)->dccpd_ecn;
+
+	put_cmsg(msg, SOL_DCCP, DCCP_SCM_ECN_BITS, sizeof(val), &val);
+}
+
 int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 size_t len, int nonblock, int flags, int *addr_len)
 {
@@ -919,6 +932,8 @@ verify_sock_status:
 			len = -EFAULT;
 			break;
 		}
+		if (dccp_sk(sk)->dccps_get_ecn_bits)
+			dccp_cmsg_recv_ecn_bits(msg, skb);
 	found_fin_ok:
 		if (!(flags & MSG_PEEK))
 			sk_eat_skb(sk, skb, 0);
-- 
1.6.0.rc2

