From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 04 Oct 2008 09:13:24 +0000
Subject: [PATCH 3/5] dccp: List management for new feature negotiation
Message-Id: <1223111606-5308-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1222068117-13401-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1222068117-13401-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds list fields and list management functions for the new feature
negotiation implementation. The new code is kept in parallel to the old
code, until removed at the end of the patch set.

Thanks to Arnaldo for suggestions to improve the code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/feat.c |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 129 insertions(+), 0 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -143,6 +143,135 @@ static void dccp_feat_entry_destructor(struct dccp_feat_entry *entry)
 	}
 }
 
+/*
+ * List management functions
+ *
+ * Feature negotiation lists rely on and maintain the following invariants:
+ * - each feat_num in the list is known, i.e. we know its type and default value
+ * - each feat_num/is_local combination is unique (old entries are overwritten)
+ * - SP values are always freshly allocated
+ * - list is sorted in increasing order of feature number (faster lookup)
+ */
+static struct dccp_feat_entry *dccp_feat_list_lookup(struct list_head *fn_list,
+						     u8 feat_num, bool is_local)
+{
+	struct dccp_feat_entry *entry;
+
+	list_for_each_entry(entry, fn_list, node)
+		if (entry->feat_num = feat_num && entry->is_local = is_local)
+			return entry;
+		else if (entry->feat_num > feat_num)
+			break;
+	return NULL;
+}
+
+/**
+ * dccp_feat_entry_new  -  Central list update routine (called by all others)
+ * @head:  list to add to
+ * @feat:  feature number
+ * @local: whether the local (1) or remote feature with number @feat is meant
+ * This is the only constructor and serves to ensure the above invariants.
+ */
+static struct dccp_feat_entry *
+	      dccp_feat_entry_new(struct list_head *head, u8 feat, bool local)
+{
+	struct dccp_feat_entry *entry;
+
+	list_for_each_entry(entry, head, node)
+		if (entry->feat_num = feat && entry->is_local = local) {
+			dccp_feat_val_destructor(entry->feat_num, &entry->val);
+			return entry;
+		} else if (entry->feat_num > feat) {
+			head = &entry->node;
+			break;
+		}
+
+	entry = kmalloc(sizeof(*entry), gfp_any());
+	if (entry != NULL) {
+		entry->feat_num = feat;
+		entry->is_local = local;
+		list_add_tail(&entry->node, head);
+	}
+	return entry;
+}
+
+/**
+ * dccp_feat_push_change  -  Add/overwrite a Change option in the list
+ * @fn_list: feature-negotiation list to update
+ * @feat: one of %dccp_feature_numbers
+ * @local: whether local (1) or remote (0) @feat_num is meant
+ * @needs_mandatory: whether to use Mandatory feature negotiation options
+ * @fval: pointer to NN/SP value to be inserted (will be copied)
+ */
+static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
+				 u8 mandatory, dccp_feat_val *fval)
+{
+	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
+
+	if (new = NULL)
+		return -ENOMEM;
+
+	new->feat_num	     = feat;
+	new->is_local	     = local;
+	new->state	     = FEAT_INITIALISING;
+	new->needs_confirm   = 0;
+	new->empty_confirm   = 0;
+	new->val	     = *fval;
+	new->needs_mandatory = mandatory;
+
+	return 0;
+}
+
+/**
+ * dccp_feat_push_confirm  -  Add a Confirm entry to the FN list
+ * @fn_list: feature-negotiation list to add to
+ * @feat: one of %dccp_feature_numbers
+ * @local: whether local (1) or remote (0) @feat_num is being confirmed
+ * @fval: pointer to NN/SP value to be inserted or NULL
+ * Returns 0 on success, a Reset code for further processing otherwise.
+ */
+static int dccp_feat_push_confirm(struct list_head *fn_list, u8 feat, u8 local,
+				  dccp_feat_val *fval)
+{
+	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
+
+	if (new = NULL)
+		return DCCP_RESET_CODE_TOO_BUSY;
+
+	new->feat_num	     = feat;
+	new->is_local	     = local;
+	new->state	     = FEAT_STABLE;	/* transition in 6.6.2 */
+	new->needs_confirm   = 1;
+	new->empty_confirm   = (fval = NULL);
+	new->val.nn	     = 0;		/* zeroes the whole structure */
+	if (!new->empty_confirm)
+		new->val     = *fval;
+	new->needs_mandatory = 0;
+
+	return 0;
+}
+
+static int dccp_push_empty_confirm(struct list_head *fn_list, u8 feat, u8 local)
+{
+	return dccp_feat_push_confirm(fn_list, feat, local, NULL);
+}
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
