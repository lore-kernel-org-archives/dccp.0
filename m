From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:20 +0000
Subject: [PATCH 3/9]: Resolve feature dependencies resulting from choice of CCID
Message-Id: <200709281630.20184@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Resolve feature dependencies resulting from choice of CCID

This adds a hook to resolve features whose value depends on the choice of
CCID. It is done at the server since it can only be done after the CCID
values have been negotiated; i.e. the client will add its CCID preference
list on the Change options sent in the Request, which will be reconciled
with the local preference list of the server.

The concept is documented on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html#ccid_dependencies

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    1 +
 net/dccp/feat.c   |   25 +++++++++++++++++++++++++
 net/dccp/output.c |   13 +++++++++----
 3 files changed, 35 insertions(+), 4 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -423,6 +423,7 @@ static inline int dccp_ack_pending(const
 }
 
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
+extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -547,6 +547,31 @@ int dccp_feat_finalise_settings(struct d
 	return 0;
 }
 
+/**
+ * dccp_feat_server_ccid_dependencies  -  Resolve CCID-dependent features
+ * It is the server which resolves the dependencies once the CCID has been
+ * fully negotiated. If no CCID has been negotiated, it uses the default CCID.
+ */
+int dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq)
+{
+	struct list_head *fn = &dreq->dreq_featneg;
+	struct dccp_feat_entry *entry;
+	u8 is_local, ccid;
+
+	for (is_local = 0; is_local <= 1; is_local++) {
+		entry = dccp_feat_list_lookup(fn, DCCPF_CCID, is_local);
+
+		if (entry != NULL && !entry->empty_confirm)
+			ccid = entry->val.sp.vec[0];
+		else
+			ccid = dccp_feat_default_value(DCCPF_CCID);
+
+		if (dccp_feat_propagate_ccid(fn, ccid, is_local))
+			return -1;
+	}
+	return 0;
+}
+
 static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -303,10 +303,12 @@ struct sk_buff *dccp_make_response(struc
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
 	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
 
-	if (dccp_insert_options_rsk(dreq, skb)) {
-		kfree_skb(skb);
-		return NULL;
-	}
+	/* Resolve feature dependencies resulting from choice of CCID */
+	if (dccp_feat_server_ccid_dependencies(dreq))
+		goto response_failed;
+
+	if (dccp_insert_options_rsk(dreq, skb))
+		goto response_failed;
 
 	/* Build and checksum header */
 	dh = dccp_zeroed_hdr(skb, dccp_header_size);
@@ -327,6 +329,9 @@ struct sk_buff *dccp_make_response(struc
 	inet_rsk(req)->acked = 1;
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
+response_failed:
+	kfree_skb(skb);
+	return NULL;
 }
 
 EXPORT_SYMBOL_GPL(dccp_make_response);
