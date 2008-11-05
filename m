From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Nov 2008 06:53:21 +0000
Subject: [PATCH 3/5] dccp: List management for new feature negotiation
Message-Id: <20081105065321.GE3482@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1222068117-13401-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1222068117-13401-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds list initial fields and list management functions for the new
feature negotiation implementation.

Thanks to Arnaldo for suggestions and improvements.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    2 +
 net/dccp/feat.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 0 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -441,6 +441,8 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern void dccp_feat_list_purge(struct list_head *fn_list);
+
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -60,6 +60,79 @@ static const struct {
 };
 #define DCCP_FEAT_SUPPORTED_MAX		ARRAY_SIZE(dccp_feat_table)
 
+/**
+ * dccp_feat_index  -  Hash function to map feature number into array position
+ * Returns consecutive array index or -1 if the feature is not understood.
+ */
+static int dccp_feat_index(u8 feat_num)
+{
+	/* The first 9 entries are occupied by the types from RFC 4340, 6.4 */
+	if (feat_num > DCCPF_RESERVED && feat_num <= DCCPF_DATA_CHECKSUM)
+		return feat_num - 1;
+
+	/*
+	 * Other features: add cases for new feature types here after adding
+	 * them to the above table.
+	 */
+	switch (feat_num) {
+	case DCCPF_SEND_LEV_RATE:
+			return DCCP_FEAT_SUPPORTED_MAX - 1;
+	}
+	return -1;
+}
+
+static u8 dccp_feat_type(u8 feat_num)
+{
+	int idx = dccp_feat_index(feat_num);
+
+	if (idx < 0)
+		return FEAT_UNKNOWN;
+	return dccp_feat_table[idx].reconciliation;
+}
+
+static void dccp_feat_val_destructor(u8 feat_num, dccp_feat_val *val)
+{
+	if (unlikely(val = NULL))
+		return;
+	if (dccp_feat_type(feat_num) = FEAT_SP)
+		kfree(val->sp.vec);
+	memset(val, 0, sizeof(*val));
+}
+
+static void dccp_feat_entry_destructor(struct dccp_feat_entry *entry)
+{
+	if (entry != NULL) {
+		dccp_feat_val_destructor(entry->feat_num, &entry->val);
+		kfree(entry);
+	}
+}
+
+/*
+ * List management functions
+ *
+ * Feature negotiation lists rely on and maintain the following invariants:
+ * - each feat_num in the list is known, i.e. we know its type and default value
+ * - each feat_num/is_local combination is unique (old entries are overwritten)
+ * - SP values are always freshly allocated
+ * - list is sorted in increasing order of feature number (faster lookup)
+ */
+
+static inline void dccp_feat_list_pop(struct dccp_feat_entry *entry)
+{
+	list_del(&entry->node);
+	dccp_feat_entry_destructor(entry);
+}
+
+void dccp_feat_list_purge(struct list_head *fn_list)
+{
+	struct dccp_feat_entry *entry, *next;
+
+	list_for_each_entry_safe(entry, next, fn_list, node)
+		dccp_feat_entry_destructor(entry);
+	INIT_LIST_HEAD(fn_list);
+}
+EXPORT_SYMBOL_GPL(dccp_feat_list_purge);
+
 int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 		     u8 *val, u8 len, gfp_t gfp)
 {

