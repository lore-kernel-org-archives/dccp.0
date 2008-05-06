From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 May 2008 07:38:04 +0000
Subject: [PATCH 3/4] [CCID]: CCID-specific option parsing routines need to know the packet type
Message-Id: <1210059485-691-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch ...

 1. adds packet type information to ccid_hc_{rx,tx}_parse_options(). This is
    necessary, since table 3 in RFC 4340, 5.8 leaves it to the CCIDs to state
    which options may (not) appear on what packet type.

 2. adds such a check for CCID-3's {Loss Event, Receive} Rate as specified in
    RFC 4340 8.3 ("Receive Rate options MUST NOT be sent on DCCP-Data packets")
    and 8.5 ("Loss Event Rate options MUST NOT be sent on DCCP-Data packets").

 3. removes an unused argument `idx' from ccid_hc_{rx,tx}_parse_options(). This
    is also no longer necessary, since the CCID-specific option-parsing routines
    are passed every single parameter of the type-length-value option encoding.

Added documentation and made argument naming scheme consistent.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |   46 +++++++++++++++++++++++-----------------------
 net/dccp/ccids/ccid2.c |    7 +++----
 net/dccp/ccids/ccid3.c |   14 ++++++++------
 net/dccp/options.c     |    6 ++----
 4 files changed, 36 insertions(+), 37 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -60,18 +60,14 @@ struct ccid_operations {
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
@@ -185,27 +181,31 @@ static inline void ccid_hc_tx_packet_recv(struct ccid *ccid, struct sock *sk,
 		ccid->ccid_ops->ccid_hc_tx_packet_recv(sk, skb);
 }
 
+/**
+ * ccid_hc_tx_parse_options  -  Parse CCID-specific options sent by the receiver
+ * @pkt: type of packet that @opt appears on (RFC 4340, 5.1: 4-bit value)
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
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -218,8 +218,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			break;
 		case DCCPO_MIN_RX_CCID_SPECIFIC ... DCCPO_MAX_RX_CCID_SPECIFIC:
 			if (ccid_hc_rx_parse_options(dp->dccps_hc_rx_ccid, sk,
-						     opt, len, value - options,
-						     value) != 0)
+						     pkt_type, opt, value, len))
 				goto out_invalid_option;
 			break;
 		case DCCPO_ACK_VECTOR_0:
@@ -234,8 +233,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			 */
 		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
-						     opt, len, value - options,
-						     value) != 0)
+						     pkt_type, opt, value, len))
 				goto out_invalid_option;
 			break;
 		default:
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -375,16 +375,15 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 		ccid2_change_l_ack_ratio(sk, hctx->cwnd);
 }
 
-static int ccid2_hc_tx_parse_options(struct sock *sk, unsigned char option,
-				     unsigned char len, u16 idx,
-				     unsigned char *value)
+static int ccid2_hc_tx_parse_options(struct sock *sk, u8 packet_type,
+				     u8 option, u8 *optval, u8 optlen)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
 	switch (option) {
 	case DCCPO_ACK_VECTOR_0:
 	case DCCPO_ACK_VECTOR_1:
-		return dccp_ackvec_parsed_add(&hctx->av_chunks, value, len,
+		return dccp_ackvec_parsed_add(&hctx->av_chunks, optval, optlen,
 					      option - DCCPO_ACK_VECTOR_0);
 	}
 	return 0;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -474,9 +474,8 @@ done_computing_x:
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
-static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
-				     unsigned char len, u16 idx,
-				     unsigned char *value)
+static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
+				     u8 option, u8 *optval, u8 optlen)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv = &hctx->options_received;
@@ -485,12 +484,15 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
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


The University of Aberdeen is a charity registered in Scotland, No SC013683.

