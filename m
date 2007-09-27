From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:21:21 +0000
Subject: [PATCH 8/11]: Cleanup routines for feature negotiation
Message-Id: <200709271521.21444@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Cleanup routines for feature negotiation

This inserts the required de-allocation routines for memory allocated
by feature negotiation in the socket destructors.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h  |    2 ++
 net/dccp/ipv4.c  |    1 +
 net/dccp/ipv6.c  |    1 +
 net/dccp/proto.c |    1 +
 4 files changed, 5 insertions(+)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -422,6 +422,8 @@ static inline int dccp_ack_pending(const
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern void dccp_feat_list_purge(struct list_head *fn_list);
+
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -553,6 +553,7 @@ static void dccp_v4_reqsk_destructor(str
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
+	dccp_feat_list_purge(&dreq->dreq_featneg);
 	if (dreq->dreq_tstamp != NULL)
 		kfree(dreq->dreq_tstamp);
 	kfree(inet_rsk(req)->opt);
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -297,6 +297,7 @@ static void dccp_v6_reqsk_destructor(str
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
+	dccp_feat_list_purge(&dreq->dreq_featneg);
 	if (dreq->dreq_tstamp != NULL)
 		kfree(dreq->dreq_tstamp);
 	if (inet6_rsk(req)->pktopts != NULL)
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -270,6 +270,7 @@ int dccp_destroy_sock(struct sock *sk)
 
 	/* clean up feature negotiation state */
 	dccp_feat_clean(dmsk);
+	dccp_feat_list_purge(&dp->dccps_featneg);
 
 	return 0;
 }
