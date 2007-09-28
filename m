From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:35 +0000
Subject: [PATCH 9/9]: API to query the current TX/RX CCID
Message-Id: <200709281630.35654@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: API to query the current TX/RX CCID

This provides function to query the current TX/RX CCID dynamically, without
reliance on the minisock value, using dynamic information available in the
currently loaded CCID module.
This query function is then used 
 (a) to provide the getsockopt part for getting/setting CCIDs via sockopts;
 (b) replaces the current use in dccp_probe.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h  |    9 +++++++++
 net/dccp/probe.c |    7 ++-----
 net/dccp/proto.c |    6 ++++++
 3 files changed, 17 insertions(+), 5 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -93,6 +93,15 @@ extern struct ccid *ccid_hc_rx_new(unsig
 extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
 				   gfp_t gfp);
 
+static inline int ccid_get_current_id(struct dccp_sock *dp, bool rx)
+{
+	struct ccid *ccid = rx? dp->dccps_hc_rx_ccid : dp->dccps_hc_tx_ccid;
+
+	if (ccid = NULL || ccid->ccid_ops = NULL)
+		return -1;
+	return ccid->ccid_ops->ccid_id;
+}
+
 extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -668,6 +668,12 @@ static int do_dccp_getsockopt(struct soc
 		break;
 	case DCCP_SOCKOPT_AVAILABLE_CCIDS:
 		return ccid_getsockopt_available_ccids(sk, len, optval, optlen);
+	case DCCP_SOCKOPT_TX_CCID:
+	case DCCP_SOCKOPT_RX_CCID:
+		val = ccid_get_current_id(dp, optname = DCCP_SOCKOPT_RX_CCID);
+		if (val < 0)
+			return -ENOPROTOOPT;
+		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
 		break;
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -78,14 +78,11 @@ static void printl(const char *fmt, ...)
 static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t size)
 {
-	const struct dccp_minisock *dmsk = dccp_msk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
-	const struct ccid3_hc_tx_sock *hctx;
+	struct ccid3_hc_tx_sock *hctx = NULL;
 
-	if (dmsk->dccpms_tx_ccid = DCCPC_CCID3)
+	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
 		hctx = ccid3_hc_tx_sk(sk);
-	else
-		hctx = NULL;
 
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
