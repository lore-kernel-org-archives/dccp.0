From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 14:30:51 +0000
Subject: [PATCH 8/8]: Support inserting options during the 3-way handshake
Message-Id: <200709251530.51394@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support inserting options during the 3-way handshake

This provides a separate routine to insert options during the initial handshake.
The main purpose is to conduct feature negotiation, for the moment the only user
is the timestamp echo needed for the (CCID3) handshake RTT sample.

Padding of options has been put into a small separate routine, to be shared among
the two functions. This could also be used as a generic routine to finish inserting
options.

Also removed an `XXX' comment since its content was obvious.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    1 +
 net/dccp/options.c |   40 ++++++++++++++++++++++++++++------------
 net/dccp/output.c  |    2 +-
 3 files changed, 30 insertions(+), 13 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -303,7 +303,7 @@ struct sk_buff *dccp_make_response(struc
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
 	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
 
-	if (dccp_insert_options(sk, skb)) {
+	if (dccp_insert_options_rsk(dreq, skb)) {
 		kfree_skb(skb);
 		return NULL;
 	}
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -422,6 +422,7 @@ static inline int dccp_ack_pending(const
 }
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
+extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
 					    struct sk_buff *skb,
 					    u32 elapsed_time);
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -160,7 +160,7 @@ int dccp_parse_options(struct sock *sk, 
 			if (len != 4)
 				goto out_invalid_option;
 
-			tse = dreq? &dreq->dreq_tstamp : dp->dccps_tstamp;
+			tse = dreq? &dreq->dreq_tstamp : &dp->dccps_tstamp;
 			/*
 			 * Keep the earliest received timestamp on the socket,
 			 * until echoing to the peer frees it. This policy is
@@ -525,6 +525,18 @@ static int dccp_insert_options_feat(stru
 	return 0;
 }
 
+/* The length of all options needs to be a multiple of 4 (5.8) */
+static void dccp_insert_option_padding(struct sk_buff *skb)
+{
+	int padding = DCCP_SKB_CB(skb)->dccpd_opt_len % 4;
+
+	if (padding != 0) {
+		padding = 4 - padding;
+		memset(skb_push(skb, padding), 0, padding);
+		DCCP_SKB_CB(skb)->dccpd_opt_len += padding;
+	}
+}
+
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -568,18 +580,22 @@ int dccp_insert_options(struct sock *sk,
 	    dccp_insert_option_timestamp_echo(&dp->dccps_tstamp, skb))
 		return -1;
 
-	/* XXX: insert other options when appropriate */
+	dccp_insert_option_padding(skb);
+	return 0;
+}
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
-		/* The length of all options has to be a multiple of 4 */
-		int padding = DCCP_SKB_CB(skb)->dccpd_opt_len % 4;
-
-		if (padding != 0) {
-			padding = 4 - padding;
-			memset(skb_push(skb, padding), 0, padding);
-			DCCP_SKB_CB(skb)->dccpd_opt_len += padding;
-		}
-	}
+/**
+ * dccp_insert_options_rsk  -  dccp_insert_options for request sockets
+ * This function is analogous to above - also use with dccp_reserve_hdr_space().
+ */
+int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
+{
+	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
+
+	if (dreq->dreq_tstamp != NULL &&
+	    dccp_insert_option_timestamp_echo(&dreq->dreq_tstamp, skb))
+		return -1;
 
+	dccp_insert_option_padding(skb);
 	return 0;
 }
