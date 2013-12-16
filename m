From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 16 Dec 2013 19:29:56 +0000
Subject: [PATCH net-next 10/10] dccp: remove dead code
Message-Id: <20131216112956.420cf54d@nehalam.linuxnetplumber.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This function is defined but not used.
Remove it now, can come back when used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/dccp/dccp.h	2013-10-23 21:23:03.044671179 -0700
+++ b/net/dccp/dccp.h	2013-12-16 10:52:33.667013589 -0800
@@ -479,7 +479,6 @@ void dccp_feat_list_purge(struct list_he
 
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 int dccp_insert_options_rsk(struct dccp_request_sock *, struct sk_buff *);
-int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
 u32 dccp_timestamp(void);
 void dccp_timestamping_init(void);
 int dccp_insert_option(struct sk_buff *skb, unsigned char option,
--- a/net/dccp/options.c	2013-10-06 14:48:24.962449886 -0700
+++ b/net/dccp/options.c	2013-12-16 10:52:53.266746098 -0800
@@ -343,38 +343,6 @@ static inline int dccp_elapsed_time_len(
 	return elapsed_time = 0 ? 0 : elapsed_time <= 0xFFFF ? 2 : 4;
 }
 
-/* FIXME: This function is currently not used anywhere */
-int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed_time)
-{
-	const int elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
-	const int len = 2 + elapsed_time_len;
-	unsigned char *to;
-
-	if (elapsed_time_len = 0)
-		return 0;
-
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-		return -1;
-
-	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
-
-	to    = skb_push(skb, len);
-	*to++ = DCCPO_ELAPSED_TIME;
-	*to++ = len;
-
-	if (elapsed_time_len = 2) {
-		const __be16 var16 = htons((u16)elapsed_time);
-		memcpy(to, &var16, 2);
-	} else {
-		const __be32 var32 = htonl(elapsed_time);
-		memcpy(to, &var32, 4);
-	}
-
-	return 0;
-}
-
-EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
-
 static int dccp_insert_option_timestamp(struct sk_buff *skb)
 {
 	__be32 now = htonl(dccp_timestamp());
