From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 13:11:36 +0000
Subject: [PATCH 4/5] [DCCP]: Unaligned pointer access
Message-Id: <20071024131136.GG6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes `unaligned (read) access' errors of the type

Kernel unaligned access at TPC[100f970c] dccp_parse_options+0x4f4/0x7e0 [dccp]
Kernel unaligned access at TPC[1011f2e4] ccid3_hc_tx_parse_options+0x1ac/0x380 [dccp_ccid3]
Kernel unaligned access at TPC[100f9898] dccp_parse_options+0x680/0x880 [dccp]

by using the get_unaligned macro for parsing options.

Commiter note: Preserved the sparse __be{16,32} annotations.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   11 +++++++----
 net/dccp/options.c     |   33 ++++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 25772c3..05f263e 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -40,6 +40,8 @@
 #include "lib/tfrc.h"
 #include "ccid3.h"
 
+#include <asm/unaligned.h>
+
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
@@ -544,6 +546,7 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
+	__be32 opt_val;
 
 	opt_recv = &hctx->ccid3hctx_options_received;
 
@@ -563,8 +566,8 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_loss_event_rate -						ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((__be32 *)value);
+			opt_recv->ccid3or_loss_event_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_loss_event_rate);
@@ -585,8 +588,8 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_receive_rate -						ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((__be32 *)value);
+			opt_recv->ccid3or_receive_rate = ntohl(opt_val);
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_receive_rate);
diff --git a/net/dccp/options.c b/net/dccp/options.c
index d361b55..d286cff 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -14,6 +14,7 @@
 #include <linux/dccp.h>
 #include <linux/module.h>
 #include <linux/types.h>
+#include <asm/unaligned.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 
@@ -59,6 +60,7 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 	unsigned char opt, len;
 	unsigned char *value;
 	u32 elapsed_time;
+	__be32 opt_val;
 	int rc;
 	int mandatory = 0;
 
@@ -145,7 +147,8 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			if (len != 4)
 				goto out_invalid_option;
 
-			opt_recv->dccpor_timestamp = ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((__be32 *)value);
+			opt_recv->dccpor_timestamp = ntohl(opt_val);
 
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
 			dp->dccps_timestamp_time = ktime_get_real();
@@ -159,7 +162,8 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			if (len != 4 && len != 6 && len != 8)
 				goto out_invalid_option;
 
-			opt_recv->dccpor_timestamp_echo = ntohl(*(__be32 *)value);
+			opt_val = get_unaligned((__be32 *)value);
+			opt_recv->dccpor_timestamp_echo = ntohl(opt_val);
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
 				      "ackno=%llu", dccp_role(sk),
@@ -168,16 +172,20 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
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
+				__be16 opt_val2 = get_unaligned((__be16 *)value);
+				elapsed_time = ntohs(opt_val2);
+			} else {		/* 4-byte elapsed time */
+				opt_val = get_unaligned((__be32 *)value);
+				elapsed_time = ntohl(opt_val);
+			}
 
 			dccp_pr_debug_cat(", ELAPSED_TIME=%u\n", elapsed_time);
 
@@ -192,10 +200,13 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			if (pkt_type = DCCP_PKT_DATA)
 				continue;
 
-			if (len = 2)
-				elapsed_time = ntohs(*(__be16 *)value);
-			else
-				elapsed_time = ntohl(*(__be32 *)value);
+			if (len = 2) {
+				__be16 opt_val2 = get_unaligned((__be16 *)value);
+				elapsed_time = ntohs(opt_val2);
+			} else {
+				opt_val = get_unaligned((__be32 *)value);
+				elapsed_time = ntohl(opt_val);
+			}
 
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
-- 
1.5.3.4

