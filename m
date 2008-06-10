From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 10:07:55 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <20080610100755.GB8582@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <484E42BE.9020408@cn.fujitsu.com>
In-Reply-To: <484E42BE.9020408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have dug out the patch to which this applies. Since it is a bug-fix, I
would much rather like to merge your patch with the existing one, as done
below.

Wei, can you please have a look at it and add your Signed-Off if you are
ok with it?

Incidentally, your patch also fixes a second problem: the same problem
would occur if security_inet_conn_request(sk, skb, req) failed; but it
was apparently not triggered so far; this is also avoided below.

If there is no disagreement, I will upload this to the test tree within
the next hour.

-----------------------> Patch v2 (in test tree) <----------------------
dccp: Socket support for feature negotiation and its initialisation

This provides feature-negotiation initialisation for both DCCP sockets and
DCCP request_sockets, to support feature negotiation during connection setup.

It also resolves a FIXME regarding the congestion control initialisation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |    4 ++++
 net/dccp/dccp.h      |    3 ++-
 net/dccp/feat.c      |   19 +++++++++++++++++++
 net/dccp/feat.h      |    1 +
 net/dccp/input.c     |    2 --
 net/dccp/ipv4.c      |    3 ++-
 net/dccp/ipv6.c      |    8 +++++---
 net/dccp/minisocks.c |    7 ++++++-
 net/dccp/proto.c     |    1 +
 9 files changed, 40 insertions(+), 8 deletions(-)

--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -409,7 +409,11 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
-	dccp_reqsk_init(req, skb);
+	ireq6 = inet6_rsk(req);
+	ireq6->pktopts = NULL;
+
+	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
+		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
 	if (dccp_parse_options(sk, dreq, skb))
@@ -418,10 +422,8 @@ static int dccp_v6_conn_request(struct s
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
-	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -590,8 +590,6 @@ int dccp_rcv_state_process(struct sock *
 			if (inet_csk(sk)->icsk_af_ops->conn_request(sk,
 								    skb) < 0)
 				return 1;
-
-			/* FIXME: do congestion control initialization */
 			goto discard;
 		}
 		if (dh->dccph_type = DCCP_PKT_RESET)
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -416,6 +416,7 @@ extern void dccp_minisock_init(struct dc
  * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
  * @dreq_isr: initial sequence number received on the Request
  * @dreq_service: service code present on the Request (there is just one)
+ * @dreq_featneg: feature negotiation options for this connection
  * The following two fields are analogous to the ones in dccp_sock:
  * @dreq_timestamp_echo: last received timestamp to echo (13.1)
  * @dreq_timestamp_echo: the time of receiving the last @dreq_timestamp_echo
@@ -425,6 +426,7 @@ struct dccp_request_sock {
 	__u64			 dreq_iss;
 	__u64			 dreq_isr;
 	__be32			 dreq_service;
+	struct list_head	 dreq_featneg;
 	__u32			 dreq_timestamp_echo;
 	__u32			 dreq_timestamp_time;
 };
@@ -502,6 +504,7 @@ struct dccp_ackvec;
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
  * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
  * @dccps_minisock - associated minisock (accessed via dccp_msk)
+ * @dccps_featneg - tracks feature-negotiation state (mostly during handshake)
  * @dccps_hc_rx_ackvec - rx half connection ack vector
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
  * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
@@ -539,6 +542,7 @@ struct dccp_sock {
 	unsigned long			dccps_ndp_count;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
+	struct list_head		dccps_featneg;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -193,6 +193,7 @@ int dccp_init_sock(struct sock *sk, cons
 
 	dccp_init_xmit_timers(sk);
 
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
@@ -272,6 +272,25 @@ void dccp_feat_list_purge(struct list_he
 }
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
@@ -125,6 +125,7 @@ struct sock *dccp_create_openreq_child(s
 		newdp->dccps_timestamp_time = dreq->dreq_timestamp_time;
 		newicsk->icsk_rto	    = DCCP_TIMEOUT_INIT;
 
+		INIT_LIST_HEAD(&newdp->dccps_featneg);
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
 
@@ -303,7 +304,8 @@ void dccp_reqsk_send_ack(struct sk_buff 
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
 
-void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb)
+int dccp_reqsk_init(struct request_sock *req,
+		    struct dccp_sock const *dp, struct sk_buff const *skb)
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
@@ -311,6 +313,9 @@ void dccp_reqsk_init(struct request_sock
 	inet_rsk(req)->acked	  = 0;
 	req->rcv_wnd		  = sysctl_dccp_feat_sequence_window;
 	dreq->dreq_timestamp_echo = 0;
+
+	/* inherit feature negotiation options from listening socket */
+	return dccp_feat_clone_list(&dp->dccps_featneg, &dreq->dreq_featneg);
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_init);
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -593,7 +593,8 @@ int dccp_v4_conn_request(struct sock *sk
 	if (req = NULL)
 		goto drop;
 
-	dccp_reqsk_init(req, skb);
+	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
+		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
 	if (dccp_parse_options(sk, dreq, skb))
