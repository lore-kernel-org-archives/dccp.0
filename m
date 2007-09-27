From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:21:18 +0000
Subject: [PATCH 7/11]: Socket support for feature negotiation and its initialisation
Message-Id: <200709271521.18325@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Socket support for feature negotiation and its initialisation

This provides feature-negotiation initialisation for both DCCP sockets and
DCCP request_sockets, to support feature negotiation during connection setup.

It also resolves a FIXME regarding the congestion control initialisation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 ++++
 net/dccp/dccp.h      |    3 ++-
 net/dccp/feat.c      |   19 +++++++++++++++++++
 net/dccp/feat.h      |    1 +
 net/dccp/input.c     |    2 --
 net/dccp/ipv4.c      |    3 ++-
 net/dccp/ipv6.c      |    3 ++-
 net/dccp/minisocks.c |    7 ++++++-
 net/dccp/proto.c     |    1 +
 9 files changed, 37 insertions(+), 6 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -424,6 +424,7 @@ struct dccp_ts_echo {
  * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
  * @dreq_isr: initial sequence number received on the Request
  * @dreq_service: service code present on the Request (there is just one)
+ * @dreq_featneg: feature negotiation options for this connection
  * @dreq_tstamp: most recent timestamp received during connection setup
  */
 struct dccp_request_sock {
@@ -431,6 +432,7 @@ struct dccp_request_sock {
 	__u64			 dreq_iss;
 	__u64			 dreq_isr;
 	__be32			 dreq_service;
+	struct list_head	 dreq_featneg;
 	struct dccp_ts_echo	 *dreq_tstamp;
 };
 
@@ -506,6 +508,7 @@ struct dccp_ackvec;
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
  * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
  * @dccps_minisock - associated minisock (accessed via dccp_msk)
+ * @dccps_featneg - tracks feature-negotiation state (mostly during handshake)
  * @dccps_hc_rx_ackvec - rx half connection ack vector
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
  * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
@@ -542,6 +545,7 @@ struct dccp_sock {
 	__u32				dccps_mss_cache;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
+	struct list_head		dccps_featneg;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -177,6 +177,7 @@ int dccp_init_sock(struct sock *sk, cons
 
 	dccp_minisock_init(&dp->dccps_minisock);
 
+	INIT_LIST_HEAD(&dp->dccps_featneg);
 	/*
 	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
 	 * the listening (master) sock get CCID control blocks, which is not
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -95,6 +95,7 @@ extern int  dccp_feat_confirm_recv(struc
 				   u8 *val, u8 len);
 extern void dccp_feat_clean(struct dccp_minisock *dmsk);
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
+extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
 extern int  dccp_feat_init(struct dccp_minisock *dmsk);
 
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -273,6 +273,25 @@ void dccp_feat_list_purge(struct list_he
 
 EXPORT_SYMBOL_GPL(dccp_feat_list_purge);
 
+/* generate @to as full clone of @from - @to must not contain any nodes */
+int dccp_feat_clone_list(struct list_head const *from, struct list_head *to)
+{
+	struct dccp_feat_entry *entry, *new;
+
+	INIT_LIST_HEAD(to);
+	list_for_each_entry(entry, from, node) {
+		new = dccp_feat_clone_entry(entry);
+		if (new = NULL)
+			goto cloning_failed;
+		list_add_tail(&new->node, to);
+	}
+	return 0;
+
+cloning_failed:
+	dccp_feat_list_purge(to);
+	return -ENOMEM;
+}
+
 int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 		     u8 *val, u8 len, gfp_t gfp)
 {
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -236,7 +236,8 @@ extern const char *dccp_state_name(const
 extern void dccp_set_state(struct sock *sk, const int state);
 extern void dccp_done(struct sock *sk);
 
-extern void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb);
+extern int  dccp_reqsk_init(struct request_sock *rq, struct dccp_sock const *dp,
+			    struct sk_buff const *skb);
 
 extern int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -124,6 +124,7 @@ struct sock *dccp_create_openreq_child(s
 		newdp->dccps_service	   = dreq->dreq_service;
 		newicsk->icsk_rto	   = DCCP_TIMEOUT_INIT;
 
+		INIT_LIST_HEAD(&newdp->dccps_featneg);
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
 
@@ -302,7 +303,8 @@ void dccp_reqsk_send_ack(struct sk_buff 
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
 
-void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb)
+int dccp_reqsk_init(struct request_sock *req,
+		    struct dccp_sock const *dp, struct sk_buff const *skb)
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
@@ -310,6 +312,9 @@ void dccp_reqsk_init(struct request_sock
 	inet_rsk(req)->acked	= 0;
 	req->rcv_wnd		= sysctl_dccp_feat_sequence_window;
 	dreq->dreq_tstamp	= NULL;
+
+	/* inherit feature negotiation options from listening socket */
+	return dccp_feat_clone_list(&dp->dccps_featneg, &dreq->dreq_featneg);
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_init);
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -606,7 +606,8 @@ int dccp_v4_conn_request(struct sock *sk
 	if (req = NULL)
 		goto drop;
 
-	dccp_reqsk_init(req, skb);
+	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
+		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
 	if (dccp_parse_options(sk, dreq, skb))
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -419,7 +419,8 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
-	dccp_reqsk_init(req, skb);
+	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
+		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
 	if (dccp_parse_options(sk, dreq, skb))
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -511,8 +511,6 @@ int dccp_rcv_state_process(struct sock *
 			if (inet_csk(sk)->icsk_af_ops->conn_request(sk,
 								    skb) < 0)
 				return 1;
-
-			/* FIXME: do congestion control initialization */
 			goto discard;
 		}
 		if (dh->dccph_type = DCCP_PKT_RESET)
