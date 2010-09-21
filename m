From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Sep 2010 10:28:54 +0000
Subject: [PATCH 1/5] dccp: Add packet type information to CCID-specific option parsing
Message-Id: <1285064938-5933-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This
 1. adds packet type information to ccid_hc_{rx,tx}_parse_options(). This is
    necessary, since table 3 in RFC 4340, 5.8 leaves it to the CCIDs to state
    which options may (not) appear on what packet type.

 2. adds such a check for CCID-3's {Loss Event, Receive} Rate as specified in
    RFC 4340 8.3 ("Receive Rate options MUST NOT be sent on DCCP-Data packets")
    and 8.5 ("Loss Event Rate options MUST NOT be sent on DCCP-Data packets").

 3. removes an unused argument `idx' from ccid_hc_{rx,tx}_parse_options(). This
    is also no longer necessary, since the CCID-specific option-parsing routines
    are passed every single parameter of the type-length-value option encoding.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |   46 +++++++++++++++++++++++-----------------------
 net/dccp/ccids/ccid3.c |   14 ++++++++------
 net/dccp/options.c     |   16 ++++------------
 3 files changed, 35 insertions(+), 41 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -62,18 +62,14 @@ struct ccid_operations {
 	void		(*ccid_hc_tx_exit)(struct sock *sk);
 	void		(*ccid_hc_rx_packet_recv)(struct sock *sk,
 						  struct sk_buff *skb);
-	int		(*ccid_hc_rx_parse_options)(struct sock *sk,
-						    unsigned char option,
-						    unsigned char len, u16 idx,
-						    unsigned char* value);
+	int		(*ccid_hc_rx_parse_options)(struct sock *sk, u8 pkt,
+						    u8 opt, u8 *val, u8 len);
 	int		(*ccid_hc_rx_insert_options)(struct sock *sk,
 						     struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_recv)(struct sock *sk,
 						  struct sk_buff *skb);
-	int		(*ccid_hc_tx_parse_options)(struct sock *sk,
-						    unsigned char option,
-						    unsigned char len, u16 idx,
-						    unsigned char* value);
+	int		(*ccid_hc_tx_parse_options)(struct sock *sk, u8 pkt,
+						    u8 opt, u8 *val, u8 len);
 	int		(*ccid_hc_tx_send_packet)(struct sock *sk,
 						  struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_sent)(struct sock *sk,
@@ -168,27 +164,31 @@ static inline void ccid_hc_tx_packet_recv(struct ccid *ccid, struct sock *sk,
 		ccid->ccid_ops->ccid_hc_tx_packet_recv(sk, skb);
 }
 
+/**
+ * ccid_hc_tx_parse_options  -  Parse CCID-specific options sent by the receiver
+ * @pkt: type of packet that @opt appears on (RFC 4340, 5.1)
+ * @opt: the CCID-specific option type (RFC 4340, 5.8 and 10.3)
+ * @val: value of @opt
+ * @len: length of @val in bytes
+ */
 static inline int ccid_hc_tx_parse_options(struct ccid *ccid, struct sock *sk,
-					   unsigned char option,
-					   unsigned char len, u16 idx,
-					   unsigned char* value)
+					   u8 pkt, u8 opt, u8 *val, u8 len)
 {
-	int rc = 0;
-	if (ccid->ccid_ops->ccid_hc_tx_parse_options != NULL)
-		rc = ccid->ccid_ops->ccid_hc_tx_parse_options(sk, option, len, idx,
-						    value);
-	return rc;
+	if (ccid->ccid_ops->ccid_hc_tx_parse_options = NULL)
+		return 0;
+	return ccid->ccid_ops->ccid_hc_tx_parse_options(sk, pkt, opt, val, len);
 }
 
+/**
+ * ccid_hc_rx_parse_options  -  Parse CCID-specific options sent by the sender
+ * Arguments are analogous to ccid_hc_tx_parse_options()
+ */
 static inline int ccid_hc_rx_parse_options(struct ccid *ccid, struct sock *sk,
-					   unsigned char option,
-					   unsigned char len, u16 idx,
-					   unsigned char* value)
+					   u8 pkt, u8 opt, u8 *val, u8 len)
 {
-	int rc = 0;
-	if (ccid->ccid_ops->ccid_hc_rx_parse_options != NULL)
-		rc = ccid->ccid_ops->ccid_hc_rx_parse_options(sk, option, len, idx, value);
-	return rc;
+	if (ccid->ccid_ops->ccid_hc_rx_parse_options = NULL)
+		return 0;
+	return ccid->ccid_ops->ccid_hc_rx_parse_options(sk, pkt, opt, val, len);
 }
 
 static inline int ccid_hc_rx_insert_options(struct ccid *ccid, struct sock *sk,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -481,9 +481,8 @@ done_computing_x:
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
-static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
-				     unsigned char len, u16 idx,
-				     unsigned char *value)
+static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
+				     u8 option, u8 *optval, u8 optlen)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv = &hc->tx_options_received;
@@ -492,12 +491,15 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 	switch (option) {
 	case TFRC_OPT_RECEIVE_RATE:
 	case TFRC_OPT_LOSS_EVENT_RATE:
-		if (unlikely(len != 4)) {
+		/* Must be ignored on Data packets, cf. RFC 4342 8.3 and 8.5 */
+		if (packet_type = DCCP_PKT_DATA)
+			break;
+		if (unlikely(optlen != 4)) {
 			DCCP_WARN("%s(%p), invalid len %d for %u\n",
-				  dccp_role(sk), sk, len, option);
+				  dccp_role(sk), sk, optlen, option);
 			return -EINVAL;
 		}
-		opt_val = ntohl(get_unaligned((__be32 *)value));
+		opt_val = ntohl(get_unaligned((__be32 *)optval));
 
 		if (option = TFRC_OPT_RECEIVE_RATE) {
 			opt_recv->ccid3or_receive_rate = opt_val;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -226,23 +226,15 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			dccp_pr_debug("%s rx opt: ELAPSED_TIME=%d\n",
 				      dccp_role(sk), elapsed_time);
 			break;
-		case 128 ... 191: {
-			const u16 idx = value - options;
-
+		case 128 ... 191:
 			if (ccid_hc_rx_parse_options(dp->dccps_hc_rx_ccid, sk,
-						     opt, len, idx,
-						     value) != 0)
+						     pkt_type, opt, value, len))
 				goto out_invalid_option;
-		}
 			break;
-		case 192 ... 255: {
-			const u16 idx = value - options;
-
+		case 192 ... 255:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
-						     opt, len, idx,
-						     value) != 0)
+						     pkt_type, opt, value, len))
 				goto out_invalid_option;
-		}
 			break;
 		default:
 			DCCP_CRIT("DCCP(%p): option %d(len=%d) not "
