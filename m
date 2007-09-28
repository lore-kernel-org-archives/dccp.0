From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:32 +0000
Subject: [PATCH 8/9]: Set per-connection CCIDs via socket options
Message-Id: <200709281630.33024@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Set per-connection CCIDs via socket options

With this patch, TX/RX CCIDs can now be changed on a per-connection basis, which
overrides the defaults set by the global sysctl variables for TX/RX CCIDs.

To make full use of this facility, the remaining patches of this patch set are
needed, which track dependencies and activate negotiated feature values.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   14 ++++++++++++++
 include/linux/dccp.h              |    5 +++++
 net/dccp/proto.c                  |   34 ++++++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -61,6 +61,20 @@ DCCP_SOCKOPT_AVAILABLE_CCIDS is also rea
 supported by the endpoint (see include/linux/dccp.h for symbolic constants).
 The caller needs to provide a sufficiently large (> 2) array of type uint8_t.
 
+DCCP_SOCKOPT_CCID is write-only and sets both the TX and RX CCIDs at the same
+time, combining the operation of the next two socket options. This option is
+preferrable over the latter two, since often applications will use the same
+type of CCID for both directions, and mixed use of CCIDs is not currently well
+understood. This socket option takes as argument at least one uint8_t value, or
+an array of uint8_t values, which must match available CCIDS (see above). CCIDs
+must be registered before calling connect() or listen().
+
+DCCP_SOCKOPT_TX_CCID is read/write. It returns the current CCID (if set) or sets
+the preference list for the TX CCID, using the same format as DCCP_SOCKOPT_CCID.
+Please note that the getsockopt argument type is `int', not uint8_t.
+
+DCCP_SOCKOPT_RX_CCID is analogous to DCCP_SOCKOPT_TX_CCID, but for the RX CCID.
+
 DCCP_SOCKOPT_SERVER_TIMEWAIT enables the server (listening socket) to hold
 timewait state when closing the connection (RFC 4340, 8.3). The usual case is
 that the closing server sends a CloseReq, whereupon the client holds timewait
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -213,11 +213,16 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_AVAILABLE_CCIDS	12
+#define DCCP_SOCKOPT_CCID		13
+#define DCCP_SOCKOPT_TX_CCID		14
+#define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
+/* maximum number of CCID preferences that can be registered at one time */
+#define DCCP_CCID_LIST_MAX_LEN	       16
 
 #ifdef __KERNEL__
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -444,6 +444,36 @@ static int dccp_setsockopt_service(struc
 	return 0;
 }
 
+static int dccp_setsockopt_ccid(struct sock *sk, int type,
+				char __user *optval, int optlen)
+{
+	u8 *val;
+	int rc = 0;
+
+	BUILD_BUG_ON(sizeof(u8) != 1);
+
+	if (optlen < 1 || optlen > DCCP_CCID_LIST_MAX_LEN)
+		return -EINVAL;
+
+	val = kmalloc(optlen, GFP_KERNEL);
+	if (val = NULL)
+		return -ENOMEM;
+
+	if (copy_from_user(val, optval, optlen))
+		rc = -EFAULT;
+
+	lock_sock(sk);
+	if (!rc && (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID))
+		rc = dccp_feat_register_change(sk, DCCPF_CCID, 1, val, optlen);
+
+	if (!rc && (type = DCCP_SOCKOPT_RX_CCID || type = DCCP_SOCKOPT_CCID))
+		rc = dccp_feat_register_change(sk, DCCPF_CCID, 0, val, optlen);
+	release_sock(sk);
+
+	kfree(val);
+	return rc;
+}
+
 static int dccp_setsockopt_change(struct sock *sk, char __user *optval,
 				  int optlen, bool is_local)
 {
@@ -520,6 +550,10 @@ static int do_dccp_setsockopt(struct soc
 		return dccp_setsockopt_change(sk, optval, optlen, true);
 	case DCCP_SOCKOPT_CHANGE_R:
 		return dccp_setsockopt_change(sk, optval, optlen, false);
+	case DCCP_SOCKOPT_CCID:
+	case DCCP_SOCKOPT_RX_CCID:
+	case DCCP_SOCKOPT_TX_CCID:
+		return dccp_setsockopt_ccid(sk, optname, optval, optlen);
 	default:
 		if (optlen < sizeof(int))
 			return -EINVAL;
