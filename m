From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:44:55 +0000
Subject: [PATCH 20/37] dccp: Insert feature-negotiation options into skb
Message-Id: <1219945512-7723-21-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch replaces the earlier insertion routine from options.c, so that
code specific to feature negotiation can remain in feat.c. This is possible
by calling a function already existing in options.c.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    2 +
 net/dccp/feat.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 0 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -443,6 +443,8 @@ static inline int dccp_ack_pending(const struct sock *sk)
 
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
+extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
+				  struct sk_buff *skb);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -297,6 +297,20 @@ cloning_failed:
 	return -ENOMEM;
 }
 
+/**
+ * dccp_feat_valid_nn_length  -  Enforce length constraints on NN options
+ * Length is between 0 and %DCCP_OPTVAL_MAXLEN. Used for outgoing packets only,
+ * incoming options are accepted as long as their values are valid.
+ */
+static u8 dccp_feat_valid_nn_length(u8 feat_num)
+{
+	if (feat_num = DCCPF_ACK_RATIO)	/* RFC 4340, 11.3 and 6.6.8 */
+		return 2;
+	if (feat_num = DCCPF_SEQUENCE_WINDOW)	/* RFC 4340, 7.5.2 and 6.5  */
+		return 6;
+	return 0;
+}
+
 static u8 dccp_feat_is_valid_nn_val(u8 feat_num, u64 val)
 {
 	switch (feat_num) {
@@ -339,6 +353,57 @@ static u8 dccp_feat_sp_list_ok(u8 feat_num, u8 const *sp_list, u8 sp_len)
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
+	struct list_head *fn = dreq ? &dreq->dreq_featneg : &dp->dccps_featneg;
+	struct dccp_feat_entry *pos, *next;
+	u8 opt, type, len, *ptr, nn_in_nbo[DCCP_OPTVAL_MAXLEN];
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
+				len = dccp_feat_valid_nn_length(pos->feat_num);
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
+		 * Enter CHANGING after transmitting the Change option (6.6.2).
+		 */
+		if (pos->state = FEAT_INITIALISING)
+			pos->state = FEAT_CHANGING;
+	}
+	return 0;
+}
+
+/**
  * __feat_register_nn  -  Register new NN value on socket
  * @fn: feature-negotiation list to register with
  * @feat: an NN feature from %dccp_feature_numbers
-- 
1.6.0.rc2

