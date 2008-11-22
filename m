From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 22 Nov 2008 10:30:37 +0000
Subject: [PATCH 1/5] dccp: Set per-connection CCIDs via socket options
Message-Id: <1227349841-9440-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With this patch, TX/RX CCIDs can now be changed on a per-connection basis, which
overrides the defaults set by the global sysctl variables for TX/RX CCIDs.

To make full use of this facility, the remaining patches of this patch set are
needed, which track dependencies and activate negotiated feature values.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   14 ++++++++++++++
 include/linux/dccp.h              |    5 +++++
 net/dccp/ackvec.c                 |    9 ++++-----
 net/dccp/ackvec.h                 |    5 ++---
 net/dccp/feat.h                   |    2 ++
 net/dccp/proto.c                  |   34 ++++++++++++++++++++++++++++++++++
 6 files changed, 61 insertions(+), 8 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -61,6 +61,20 @@ DCCP_SOCKOPT_AVAILABLE_CCIDS is also read-only and returns the list of CCIDs
 supported by the endpoint (see include/linux/dccp.h for symbolic constants).
 The caller needs to provide a sufficiently large (> 2) array of type uint8_t.
 
+DCCP_SOCKOPT_CCID is write-only and sets both the TX and RX CCIDs at the same
+time, combining the operation of the next two socket options. This option is
+preferrable over the latter two, since often applications will use the same
+type of CCID for both directions; and mixed use of CCIDs is not currently well
+understood. This socket option takes as argument at least one uint8_t value, or
+an array of uint8_t values, which must match available CCIDS (see above). CCIDs
+must be registered on the socket before calling connect() or listen().
+
+DCCP_SOCKOPT_TX_CCID is read/write. It returns the current CCID (if set) or sets
+the preference list for the TX CCID, using the same format as DCCP_SOCKOPT_CCID.
+Please note that the getsockopt argument type here is `int', not uint8_t.
+
+DCCP_SOCKOPT_RX_CCID is analogous to DCCP_SOCKOPT_TX_CCID, but for the RX CCID.
+
 DCCP_SOCKOPT_SERVER_TIMEWAIT enables the server (listening socket) to hold
 timewait state when closing the connection (RFC 4340, 8.3). The usual case is
 that the closing server sends a CloseReq, whereupon the client holds timewait
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -168,6 +168,8 @@ enum {
 	DCCPO_MIN_CCID_SPECIFIC = 128,
 	DCCPO_MAX_CCID_SPECIFIC = 255,
 };
+/* maximum size of a single TLV-encoded DCCP option (sans type/len bytes) */
+#define DCCP_SINGLE_OPT_MAXLEN	253
 
 /* DCCP CCIDS */
 enum {
@@ -203,6 +205,9 @@ enum dccp_feature_numbers {
 #define DCCP_SOCKOPT_SEND_CSCOV		10
 #define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_AVAILABLE_CCIDS	12
+#define DCCP_SOCKOPT_CCID		13
+#define DCCP_SOCKOPT_TX_CCID		14
+#define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -22,6 +22,8 @@
 /* Wmin2 and Wmax=2^46-1 from 7.5.2 */
 #define DCCPF_SEQ_WMIN		32
 #define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
+/* Maximum number of SP values that fit in a single (Confirm) option */
+#define DCCP_FEAT_MAX_SP_VALS	(DCCP_SINGLE_OPT_MAXLEN - 2)
 
 enum dccp_feat_type {
 	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -11,15 +11,14 @@
  *	published by the Free Software Foundation.
  */
 
+#include <linux/dccp.h>
 #include <linux/compiler.h>
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/types.h>
 
-/* Read about the ECN nonce to see why it is 253 */
-#define DCCP_MAX_ACKVEC_OPT_LEN 253
 /* We can spread an ack vector across multiple options */
-#define DCCP_MAX_ACKVEC_LEN (DCCP_MAX_ACKVEC_OPT_LEN * 2)
+#define DCCP_MAX_ACKVEC_LEN (DCCP_SINGLE_OPT_MAXLEN * 2)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -12,7 +12,6 @@
 #include "ackvec.h"
 #include "dccp.h"
 
-#include <linux/dccp.h>
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -68,7 +67,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	/* Figure out how many options do we need to represent the ackvec */
-	const u16 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_MAX_ACKVEC_OPT_LEN);
+	const u8 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
 	u16 len = av->av_vec_len + 2 * nr_opts, i;
 	u32 elapsed_time;
 	const unsigned char *tail, *from;
@@ -100,8 +99,8 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	for (i = 0; i < nr_opts; ++i) {
 		int copylen = len;
 
-		if (len > DCCP_MAX_ACKVEC_OPT_LEN)
-			copylen = DCCP_MAX_ACKVEC_OPT_LEN;
+		if (len > DCCP_SINGLE_OPT_MAXLEN)
+			copylen = DCCP_SINGLE_OPT_MAXLEN;
 
 		*to++ = DCCPO_ACK_VECTOR_0;
 		*to++ = copylen + 2;
@@ -432,7 +431,7 @@ found:
 int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 		      u64 *ackno, const u8 opt, const u8 *value, const u8 len)
 {
-	if (len > DCCP_MAX_ACKVEC_OPT_LEN)
+	if (len > DCCP_SINGLE_OPT_MAXLEN)
 		return -1;
 
 	/* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -506,6 +506,36 @@ static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
 	return rc;
 }
 
+static int dccp_setsockopt_ccid(struct sock *sk, int type,
+				char __user *optval, int optlen)
+{
+	u8 *val;
+	int rc = 0;
+
+	if (optlen < 1 || optlen > DCCP_FEAT_MAX_SP_VALS)
+		return -EINVAL;
+
+	val = kmalloc(optlen, GFP_KERNEL);
+	if (val = NULL)
+		return -ENOMEM;
+
+	if (copy_from_user(val, optval, optlen)) {
+		kfree(val);
+		return -EFAULT;
+	}
+
+	lock_sock(sk);
+	if (type = DCCP_SOCKOPT_TX_CCID || type = DCCP_SOCKOPT_CCID)
+		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);
+
+	if (!rc && (type = DCCP_SOCKOPT_RX_CCID || type = DCCP_SOCKOPT_CCID))
+		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 0, val, optlen);
+	release_sock(sk);
+
+	kfree(val);
+	return rc;
+}
+
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
@@ -520,6 +550,10 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	case DCCP_SOCKOPT_CHANGE_R:
 		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
 		return 0;
+	case DCCP_SOCKOPT_CCID:
+	case DCCP_SOCKOPT_RX_CCID:
+	case DCCP_SOCKOPT_TX_CCID:
+		return dccp_setsockopt_ccid(sk, optname, optval, optlen);
 	}
 
 	if (optlen < (int)sizeof(int))
