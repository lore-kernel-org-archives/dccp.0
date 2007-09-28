From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:27 +0000
Subject: [PATCH 6/9]: Provide feature negotiation for minimum-checksum-coverage
Message-Id: <200709281630.27686@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Provide feature negotiation for minimum-checksum-coverage

This provides feature negotiation for server minimum checksum coverage
which so far has been missing.

Since sender/receiver coverage values range only from 0...15, their
type has also been reduced in size from u16 to u4.

Feature-negotiation options are now generated for both sender and receiver
coverage, i.e. when the peer has `forgotten' to enable partial coverage
then feature negotiation will automatically enable (negotiate) the partial
coverage value for this connection.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 +--
 net/dccp/proto.c     |   52 ++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 41 insertions(+), 15 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -545,8 +545,8 @@ struct dccp_sock {
 	struct dccp_ts_echo		*dccps_tstamp;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
-	__u16				dccps_pcslen;
-	__u16				dccps_pcrlen;
+	__u8				dccps_pcslen:4;
+	__u8				dccps_pcrlen:4;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
 	unsigned long			dccps_rate_last;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -469,6 +469,41 @@ static int dccp_setsockopt_change(struct
 	return rc;
 }
 
+static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
+{
+	u8 *list, len;
+	int i, rc;
+
+	if (cscov < 0 || cscov > 15)
+		return -EINVAL;
+
+	if (rx)
+		dccp_sk(sk)->dccps_pcrlen = cscov;
+	else
+		dccp_sk(sk)->dccps_pcslen = cscov;
+	/*
+	 * Populate a list of permissible values, in the range cscov...15. This
+	 * is necessary since feature negotiation of single values only works if
+	 * both sides incidentally choose the same value. Since the list starts
+	 * lowest-value first, negotiation will pick the smallest shared value.
+	 */
+	if (cscov = 0)
+		return 0;
+	len = 16 - cscov;
+
+	list = kmalloc(len, GFP_KERNEL);
+	if (list = NULL)
+		return -ENOBUFS;
+
+	for (i = 0; i < len; i++)
+		list[i] = cscov++;
+
+	rc = dccp_feat_register_change(sk, DCCPF_MIN_CSUM_COVER, rx, list, len);
+
+	kfree(list);
+	return rc;
+}
+
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
@@ -502,20 +537,11 @@ static int do_dccp_setsockopt(struct soc
 		else
 			dp->dccps_server_timewait = (val != 0);
 		break;
-	case DCCP_SOCKOPT_SEND_CSCOV:	/* sender side, RFC 4340, sec. 9.2 */
-		if (val < 0 || val > 15)
-			err = -EINVAL;
-		else
-			dp->dccps_pcslen = val;
+	case DCCP_SOCKOPT_SEND_CSCOV:
+		err = dccp_setsockopt_cscov(sk, val, false);
 		break;
-	case DCCP_SOCKOPT_RECV_CSCOV:	/* receiver side, RFC 4340 sec. 9.2.1 */
-		if (val < 0 || val > 15)
-			err = -EINVAL;
-		else {
-			dp->dccps_pcrlen = val;
-			/* FIXME: add feature negotiation,
-			 * ChangeL(MinimumChecksumCoverage, val) */
-		}
+	case DCCP_SOCKOPT_RECV_CSCOV:
+		err = dccp_setsockopt_cscov(sk, val, true);
 		break;
 	default:
 		err = -ENOPROTOOPT;
