From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:46 +0000
Subject: dccp-test-tree [PATCH 9/10] Userspace support for modifying the ECN bits of Data/DataAck packets
Message-Id: <1249847327-6792-10-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This allows to pass ECN bits as cmsg ancillary data with a cmsg_type of
DCCP_SCM_ECN_BITS for Data/DataAck packets.

The scope of this patch is for developing user-space applications that work
with, modify, or control the use of ECN bits on data packets.

RFC: This is an AF-independent alternative to using IP_TOS/IPV6_TCLASS for
     modifying the ECN bits.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   12 ++++++++++--
 include/linux/dccp.h              |    1 +
 net/dccp/output.c                 |   10 +++++++---
 net/dccp/proto.c                  |   20 ++++++++++++++++++++
 4 files changed, 38 insertions(+), 5 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -32,8 +32,16 @@ is at http://www.ietf.org/html.charters/dccp-charter.html
 ECN Support
 ===== By default, all outgoing packets are sent with ECT(0) as per RFC 3168, sec. 5.
-This can be disabled by setting the `ecn_local' sysctl to 0 (see below). The
-ECN Nonce (RFC 3540) is not supported.
+This can be disabled by setting the `ecn_local' sysctl to 0 (see below).
+
+For Data/DataAck packets, the ECN bits can be modified by passing an appropriate
+cmsg(3) value as ancillary data to sendmsg(2). The argument is an uint8_t value
+between 0..3 (corresponding to Not-ECT, ECT(1), ECT(0), and CE). Values greater
+than 3 are not accepted. Values need to be wrapped into a cmsg(3) header:
+	cmsg->cmsg_level = SOL_DCCP;
+	cmsg->cmsg_type	 = DCCP_SCM_ECN_BITS;
+	cmsg->cmsg_len	 = CMSG_LEN(sizeof(uint8_t));	/* or CMSG_LEN(1) */
+
 
 Missing features
 ========
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -202,6 +202,7 @@ enum dccp_cmsg_type {
 	DCCP_SCM_PRIORITY = 1,
 	DCCP_SCM_QPOLICY_MAX = 0xFFFF,
 	/* ^-- Up to here reserved exclusively for qpolicy parameters */
+	DCCP_SCM_ECN_BITS,
 	DCCP_SCM_MAX
 };
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -53,7 +53,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 		const u32 dccp_header_size = sizeof(*dh) +
 					     sizeof(struct dccp_hdr_ext) +
 					  dccp_packet_hdr_len(dcb->dccpd_type);
-		int err, set_ack = 1;
+		int err, set_ack = 1, ecn_bits = INET_ECN_ECT_0;
 		u64 ackno = dp->dccps_gsr;
 		/*
 		 * Increment GSS here already in case the option code needs it.
@@ -66,6 +66,8 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			set_ack = 0;
 			/* fall through */
 		case DCCP_PKT_DATAACK:
+			/* ECN bits of Data/DataAck are set in dccp_sendmsg() */
+			ecn_bits = DCCP_SKB_CB(skb)->dccpd_ecn;
 		case DCCP_PKT_RESET:
 			break;
 
@@ -130,8 +132,10 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
-		if (dp->dccps_r_ecn_ok)
-			INET_ECN_xmit(sk);
+		if (dp->dccps_r_ecn_ok) {
+			inet_sk(sk)->tos &= ~INET_ECN_MASK;
+			inet_sk(sk)->tos |= ecn_bits & INET_ECN_MASK;
+		}
 
 		icsk->icsk_af_ops->send_check(sk, 0, skb);
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -707,7 +707,17 @@ EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 
 static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 {
+	const struct dccp_sock *dp = dccp_sk(skb->sk);
 	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
+	u8 val;
+
+	/*
+	 * Setting ECN bits via DCCP_SCM_ECN_BITS: Data/DataAck only.
+	 * See dccp_transmit_skb() where further processing takes place.
+	 * By default, when no cmsg bits are supplied and when ECN is not
+	 * disabled, ECT(0) is used for all outgoing packets (RFC 3168, 5.).
+	 */
+	DCCP_SKB_CB(skb)->dccpd_ecn = INET_ECN_ECT_0;
 
 	/*
 	 * Assign an (opaque) qpolicy priority value to skb->priority.
@@ -739,6 +749,16 @@ static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 				return -EINVAL;
 			skb->priority = *(__u32 *)CMSG_DATA(cmsg);
 			break;
+		case DCCP_SCM_ECN_BITS:
+			if (!dp->dccps_r_ecn_ok)
+				return -EINVAL;
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(__u8)))
+				return -EINVAL;
+			val = *(__u8 *)CMSG_DATA(cmsg);
+			if (val > INET_ECN_MASK)
+				return -EINVAL;
+			DCCP_SKB_CB(skb)->dccpd_ecn = val;
+			break;
 		default:
 			return -EINVAL;
 		}
-- 
1.6.0.rc2

