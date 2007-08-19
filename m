From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:52:20 +0000
Subject: [PATCH 12/15] [DCCP]: Convert dccps_timestamp_time to ktime_t
Message-Id: <20070819235220.GP24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/dccp.h |    3 ++-
 net/dccp/options.c   |   13 +++++--------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index fda2148..3a4b96b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -215,6 +215,7 @@ struct dccp_so_feat {
 #ifdef __KERNEL__
 
 #include <linux/in.h>
+#include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/uio.h>
 #include <linux/workqueue.h>
@@ -498,7 +499,7 @@ struct dccp_sock {
 	__u64				dccps_gar;
 	__be32				dccps_service;
 	struct dccp_service_list	*dccps_service_list;
-	struct timeval			dccps_timestamp_time;
+	ktime_t				dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 34d536d..95b75d8 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -158,7 +158,7 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			opt_recv->dccpor_timestamp = ntohl(*(__be32 *)value);
 
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
-			dccp_timestamp(sk, &dp->dccps_timestamp_time);
+			dp->dccps_timestamp_time = ktime_get_real();
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
 				      dccp_role(sk), opt_recv->dccpor_timestamp,
@@ -405,14 +405,12 @@ static int dccp_insert_option_timestamp_echo(struct sock *sk,
 					     struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct timeval now;
 	__be32 tstamp_echo;
-	u32 elapsed_time;
 	int len, elapsed_time_len;
 	unsigned char *to;
-
-	dccp_timestamp(sk, &now);
-	elapsed_time = timeval_delta(&now, &dp->dccps_timestamp_time) / 10;
+	const suseconds_t delta = ktime_us_delta(ktime_get_real(),
+						 dp->dccps_timestamp_time);
+	u32 elapsed_time = delta / 10;
 	elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	len = 6 + elapsed_time_len;
 
@@ -438,8 +436,7 @@ static int dccp_insert_option_timestamp_echo(struct sock *sk,
 	}
 
 	dp->dccps_timestamp_echo = 0;
-	dp->dccps_timestamp_time.tv_sec = 0;
-	dp->dccps_timestamp_time.tv_usec = 0;
+	dp->dccps_timestamp_time = ktime_set(0, 0);
 	return 0;
 }
 
-- 
1.5.2.2

