From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:51:23 +0000
Subject: [PATCH 09/15] [DCCP] ackvec: Convert to ktime_t
Message-Id: <20070819235123.GM24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ackvec.c |   11 +++++------
 net/dccp/ackvec.h |    4 ++--
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 7ac775f..3f8984b 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -73,17 +73,17 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 			     DCCP_MAX_ACKVEC_OPT_LEN - 1) /
 			    DCCP_MAX_ACKVEC_OPT_LEN;
 	u16 len = av->dccpav_vec_len + 2 * nr_opts, i;
-	struct timeval now;
 	u32 elapsed_time;
 	const unsigned char *tail, *from;
 	unsigned char *to;
 	struct dccp_ackvec_record *avr;
+	suseconds_t delta;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
 		return -1;
 
-	dccp_timestamp(sk, &now);
-	elapsed_time = timeval_delta(&now, &av->dccpav_time) / 10;
+	delta = ktime_us_delta(ktime_get_real(), av->dccpav_time);
+	elapsed_time = delta / 10;
 
 	if (elapsed_time != 0 &&
 	    dccp_insert_option_elapsed_time(sk, skb, elapsed_time))
@@ -159,8 +159,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
 		av->dccpav_buf_ackno	= UINT48_MAX + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
-		av->dccpav_time.tv_sec	= 0;
-		av->dccpav_time.tv_usec	= 0;
+		av->dccpav_time	     = ktime_set(0, 0);
 		av->dccpav_vec_len	= 0;
 		INIT_LIST_HEAD(&av->dccpav_records);
 	}
@@ -321,7 +320,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 	}
 
 	av->dccpav_buf_ackno = ackno;
-	dccp_timestamp(sk, &av->dccpav_time);
+	av->dccpav_time = ktime_get_real();
 out:
 	return 0;
 
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 96504a3..9ef0737 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -12,8 +12,8 @@
  */
 
 #include <linux/compiler.h>
+#include <linux/ktime.h>
 #include <linux/list.h>
-#include <linux/time.h>
 #include <linux/types.h>
 
 /* Read about the ECN nonce to see why it is 253 */
@@ -52,7 +52,7 @@
 struct dccp_ackvec {
 	u64		dccpav_buf_ackno;
 	struct list_head dccpav_records;
-	struct timeval	dccpav_time;
+	ktime_t		dccpav_time;
 	u16		dccpav_buf_head;
 	u16		dccpav_vec_len;
 	u8		dccpav_buf_nonce;
-- 
1.5.2.2

