From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Jun 2010 11:14:34 +0000
Subject: [PATCH 1/2] dccp: remove unused function argument
Message-Id: <1277205275-5862-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes an unused 'sk' argument from several option-inserting functions.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c      |    2 +-
 net/dccp/ccids/ccid3.c |    4 ++--
 net/dccp/dccp.h        |   12 ++++--------
 net/dccp/options.c     |   14 ++++++--------
 4 files changed, 13 insertions(+), 19 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -82,7 +82,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	elapsed_time = delta / 10;
 
 	if (elapsed_time != 0 &&
-	    dccp_insert_option_elapsed_time(sk, skb, elapsed_time))
+	    dccp_insert_option_elapsed_time(skb, elapsed_time))
 		return -1;
 
 	avr = dccp_ackvec_record_new();
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -715,9 +715,9 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	x_recv = htonl(hc->rx_x_recv);
 	pinv   = htonl(hc->rx_pinv);
 
-	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+	if (dccp_insert_option(skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
+	    dccp_insert_option(skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)))
 		return -1;
 
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -446,16 +446,12 @@ extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
-extern int dccp_insert_option_elapsed_time(struct sock *sk,
-					    struct sk_buff *skb,
-					    u32 elapsed_time);
+extern int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
 extern u32 dccp_timestamp(void);
 extern void dccp_timestamping_init(void);
-extern int dccp_insert_option_timestamp(struct sock *sk,
-					 struct sk_buff *skb);
-extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
-			       unsigned char option,
-			       const void *value, unsigned char len);
+extern int dccp_insert_option_timestamp(struct sk_buff *skb);
+extern int dccp_insert_option(struct sk_buff *skb, unsigned char option,
+			      const void *value, unsigned char len);
 
 #ifdef CONFIG_SYSCTL
 extern int dccp_sysctl_init(void);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -299,9 +299,8 @@ static inline u8 dccp_ndp_len(const u64 ndp)
 	return likely(ndp <= USHRT_MAX) ? 2 : (ndp <= UINT_MAX ? 4 : 6);
 }
 
-int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
-			const unsigned char option,
-			const void *value, const unsigned char len)
+int dccp_insert_option(struct sk_buff *skb, const unsigned char option,
+		       const void *value, const unsigned char len)
 {
 	unsigned char *to;
 
@@ -354,8 +353,7 @@ static inline int dccp_elapsed_time_len(const u32 elapsed_time)
 	return elapsed_time = 0 ? 0 : elapsed_time <= 0xFFFF ? 2 : 4;
 }
 
-int dccp_insert_option_elapsed_time(struct sock *sk, struct sk_buff *skb,
-				    u32 elapsed_time)
+int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed_time)
 {
 	const int elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
 	const int len = 2 + elapsed_time_len;
@@ -386,13 +384,13 @@ int dccp_insert_option_elapsed_time(struct sock *sk, struct sk_buff *skb,
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
 
-int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
+int dccp_insert_option_timestamp(struct sk_buff *skb)
 {
 	__be32 now = htonl(dccp_timestamp());
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
 
-	return dccp_insert_option(sk, skb, DCCPO_TIMESTAMP, &now, sizeof(now));
+	return dccp_insert_option(skb, DCCPO_TIMESTAMP, &now, sizeof(now));
 }
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_timestamp);
@@ -533,7 +531,7 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 			 * Obtain RTT sample from Request/Response exchange.
 			 * This is currently used in CCID 3 initialisation.
 			 */
-			if (dccp_insert_option_timestamp(sk, skb))
+			if (dccp_insert_option_timestamp(skb))
 				return -1;
 
 		} else if (dp->dccps_hc_rx_ackvec != NULL &&
-- 
1.6.0.rc2

