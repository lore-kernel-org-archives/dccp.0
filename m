From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Jun 2007 14:10:45 +0000
Subject: [PATCH 3/4]: Unaligned pointer access
Message-Id: <200706281510.45724@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Unaligned pointer access

This fixes `unaligned (read) access' errors of the type

 Kernel unaligned access at TPC[100f970c] dccp_parse_options+0x4f4/0x7e0 [dccp]
 Kernel unaligned access at TPC[1011f2e4] ccid3_hc_tx_parse_options+0x1ac/0x380 [dccp_ccid3]
 Kernel unaligned access at TPC[100f9898] dccp_parse_options+0x680/0x880 [dccp]

by using the get_unaligned macro for parsing options.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    9 +++++----
 net/dccp/ccids/ccid3.h |    1 +
 net/dccp/options.c     |   34 ++++++++++++++++++++++------------
 3 files changed, 28 insertions(+), 16 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -14,6 +14,7 @@
 #include <linux/dccp.h>
 #include <linux/module.h>
 #include <linux/types.h>
+#include <asm/unaligned.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 
@@ -68,7 +69,7 @@ int dccp_parse_options(struct sock *sk, 
 	struct dccp_options_received *opt_recv = &dp->dccps_options_received;
 	unsigned char opt, len;
 	unsigned char *value;
-	u32 elapsed_time;
+	u32 elapsed_time, opt_val;
 	int rc;
 	int mandatory = 0;
 
@@ -155,7 +156,8 @@ int dccp_parse_options(struct sock *sk, 
 			if (len != 4)
 				goto out_invalid_option;
 
-			opt_recv->dccpor_timestamp = ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->dccpor_timestamp = ntohl(opt_val);
 
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
 			dccp_timestamp(sk, &dp->dccps_timestamp_time);
@@ -169,7 +171,8 @@ int dccp_parse_options(struct sock *sk, 
 			if (len != 4 && len != 6 && len != 8)
 				goto out_invalid_option;
 
-			opt_recv->dccpor_timestamp_echo = ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->dccpor_timestamp_echo = ntohl(opt_val);
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
 				      "ackno=%llu", dccp_role(sk),
@@ -178,16 +181,20 @@ int dccp_parse_options(struct sock *sk, 
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
 
+			value += 4;
 
-			if (len = 4) {
+			if (len = 4) {		/* no elapsed time included */
 				dccp_pr_debug_cat("\n");
 				break;
 			}
 
-			if (len = 6)
-				elapsed_time = ntohs(*(__be16 *)(value + 4));
-			else
-				elapsed_time = ntohl(*(__be32 *)(value + 4));
+			if (len = 6) {		/* 2-byte elapsed time */
+				opt_val = get_unaligned((u16 *)value);
+				elapsed_time = ntohs((u16)opt_val);
+			} else {		/* 4-byte elapsed time */
+				opt_val = get_unaligned((u32 *)value);
+				elapsed_time = ntohl(opt_val);
+			}
 
 			dccp_pr_debug_cat(", ELAPSED_TIME=%d\n", elapsed_time);
 
@@ -202,10 +209,13 @@ int dccp_parse_options(struct sock *sk, 
 			if (pkt_type = DCCP_PKT_DATA)
 				continue;
 
-			if (len = 2)
-				elapsed_time = ntohs(*(__be16 *)value);
-			else
-				elapsed_time = ntohl(*(__be32 *)value);
+			if (len = 2) {
+				opt_val = get_unaligned((u16 *)value);
+				elapsed_time = ntohs((u16)opt_val);
+			} else {
+				opt_val = get_unaligned((u32 *)value);
+				elapsed_time = ntohl(opt_val);
+			}
 
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -510,6 +510,7 @@ static int ccid3_hc_tx_parse_options(str
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
+	u32 opt_val;
 
 	opt_recv = &hctx->ccid3hctx_options_received;
 
@@ -529,8 +530,8 @@ static int ccid3_hc_tx_parse_options(str
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_loss_event_rate -						ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->ccid3or_loss_event_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_loss_event_rate);
@@ -551,8 +552,8 @@ static int ccid3_hc_tx_parse_options(str
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_receive_rate -						ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((u32 *)value);
+			opt_recv->ccid3or_receive_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_receive_rate);
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -41,6 +41,7 @@
 #include <linux/time.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
+#include <asm/unaligned.h>
 #include "lib/tfrc.h"
 #include "../ccid.h"
 
