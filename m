From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:24 +0000
Subject: [PATCH 6/11]: Insert feature-negotiation options into skb
Message-Id: <200710011518.24129@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Insert feature-negotiation options into skb

The core insertion routine, provided by this patch, does a simple list walk and calls
an already existing function in options.c to do the actual insertion of individual options.

This replaces the earlier insertion routine from options.c

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    2 +
 net/dccp/feat.c    |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/options.c |   45 -----------------------------------------
 3 files changed, 59 insertions(+), 45 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -424,6 +424,8 @@ static inline int dccp_ack_pending(const
 
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
+extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
+				  struct sk_buff *skb);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -334,6 +334,63 @@ static u8 dccp_feat_sp_list_ok(u8 feat_n
 }
 
 /**
+ * dccp_feat_insert_opts  -  Generate FN options from current list state
+ * @skb: next sk_buff to be sent to the peer
+ * @dp: for client during handshake and general negotiation
+ * @dreq: used by the server only (all Changes/Confirms in LISTEN/RESPOND)
+ */
+int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
+			  struct sk_buff *skb)
+{
+	struct list_head *fn = dreq? &dreq->dreq_featneg : &dp->dccps_featneg;
+	struct dccp_feat_entry *pos, *next;
+	u8 opt, type, len, *ptr, nn_in_nbo[6];
+	bool rpt;
+
+	/* put entries into @skb in the order they appear in the list */
+	list_for_each_entry_safe_reverse(pos, next, fn, node) {
+		opt  = dccp_feat_genopt(pos);
+		type = dccp_feat_type(pos->feat_num);
+		rpt  = false;
+
+		if (pos->empty_confirm) {
+			len = 0;
+			ptr = NULL;
+		} else {
+			if (type = FEAT_SP) {
+				len = pos->val.sp.len;
+				ptr = pos->val.sp.vec;
+				rpt = pos->needs_confirm;
+			} else if (type = FEAT_NN) {
+				len = dccp_bytes_per_value(pos->val.nn);
+				ptr = nn_in_nbo;
+				dccp_encode_value_var(pos->val.nn, ptr, len);
+			} else {
+				DCCP_BUG("unknown feature %u", pos->feat_num);
+				return -1;
+			}
+		}
+
+		if (dccp_insert_fn_opt(skb, opt, pos->feat_num, ptr, len, rpt))
+			return -1;
+		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
+			return -1;
+		/*
+		 * Keeping State: Enter CHANGING state after transmitting the
+		 * Change option (6.6.2). Furthermore, Confirm options are not
+		 * retransmitted (6.2) - with the exception of request sockets,
+		 * where removal of the confirmed entry is deferred until the
+		 * child socket has been created.
+		 */
+		if (pos->state = FEAT_INITIALISING)
+			pos->state = FEAT_CHANGING;
+		else if (pos->needs_confirm && dreq = NULL)
+			dccp_feat_list_pop(pos);
+	}
+	return 0;
+}
+
+/**
  * dccp_feat_register_nn  -  Register new NN value on socket
  * @fn: feature-negotiation list to register with
  * @feat: an NN feature from %dccp_feature_numbers
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -505,51 +505,6 @@ int dccp_insert_fn_opt(struct sk_buff *s
 	return 0;
 }
 
-static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
-{
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	struct dccp_opt_pend *opt, *next;
-	int change = 0;
-
-	/* confirm any options [NN opts] */
-	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
-		dccp_insert_feat_opt(skb, opt->dccpop_type,
-				     opt->dccpop_feat, opt->dccpop_val,
-				     opt->dccpop_len);
-		/* fear empty confirms */
-		if (opt->dccpop_val)
-			kfree(opt->dccpop_val);
-		kfree(opt);
-	}
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);
-
-	/* see which features we need to send */
-	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
-		/* see if we need to send any confirm */
-		if (opt->dccpop_sc) {
-			dccp_insert_feat_opt(skb, opt->dccpop_type + 1,
-					     opt->dccpop_feat,
-					     opt->dccpop_sc->dccpoc_val,
-					     opt->dccpop_sc->dccpoc_len);
-
-			BUG_ON(!opt->dccpop_sc->dccpoc_val);
-			kfree(opt->dccpop_sc->dccpoc_val);
-			kfree(opt->dccpop_sc);
-			opt->dccpop_sc = NULL;
-		}
-
-		/* any option not confirmed, re-send it */
-		if (!opt->dccpop_conf) {
-			dccp_insert_feat_opt(skb, opt->dccpop_type,
-					     opt->dccpop_feat, opt->dccpop_val,
-					     opt->dccpop_len);
-			change++;
-		}
-	}
-
-	return 0;
-}
-
 /* The length of all options needs to be a multiple of 4 (5.8) */
 static void dccp_insert_option_padding(struct sk_buff *skb)
 {
