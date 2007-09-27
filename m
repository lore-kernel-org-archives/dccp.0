From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:20:54 +0000
Subject: [PATCH 4/11]: Basic data structure for feature negotiation
Message-Id: <200709271520.54976@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Basic data structure for feature negotiation

For implementing an improved DCCP feature negotiation, data structures are provided:
	* a container for the various (SP or NN) values,
	* symbolic state names to track feature states,
	* an entry struct which holds all current information together,
	* elementary functions to fill in and process these structures.

Entry structs are arranged as a FIFO for the following reason: RFC 4340 specifies that
if multiple options of the same type are present, they are processed in the order of
their appearance in the packet; which means that this order needs to be preserved in the
local data structure (the later insertion code also respects this order).

The struct list_head has been chosen for the following reasons: the most frequent operations are
 * add new entry at tail (when receiving Change or setting socket options);
 * delete entry (when Confirm has been received);
 * deep copy of entire list (when cloning from listening socket onto request socket).

I am wondering whether struct list_head is `too fat' for a request socket, but have kept this
structure since it lead to simpler code. If structure sizes are an issue, I'd be willing to 
convert to singly-linked list later if necessary (but it would need a tail pointer).

The NN value has been set to 64 bit, which is a currently sufficient upper limit (Sequence Window 
feature has 48 bit).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,6 +14,66 @@
 #include <linux/types.h>
 #include "dccp.h"
 
+enum dccp_feat_type {
+	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
+	FEAT_AT_TX   = 2,	/* located at TX side of half-connection  */
+	FEAT_SP      = 4,	/* server-priority reconciliation (6.3.1) */
+	FEAT_NN	     = 8,	/* non-negotiable reconciliation (6.3.2)  */
+	FEAT_UNKNOWN = 0xFF	/* not understood or invalid feature	  */
+};
+
+enum dccp_feat_state {
+	FEAT_DEFAULT = 0,	/* using default values from 6.4 */
+	FEAT_INITIALISING,	/* feature is being initialised  */
+	FEAT_CHANGING,		/* Change sent but not confirmed yet */
+	FEAT_UNSTABLE,		/* local modification in state CHANGING */
+	FEAT_STABLE		/* both ends (think they) agree */
+};
+
+/**
+ * dccp_feat_val  -  Container for SP or NN feature values
+ * @nn:     single NN value
+ * @sp.vec: single SP value plus optional preference list
+ * @sp.len: length of @sp.vec in bytes
+ */
+typedef union {
+	u64 nn;
+	struct {
+		u8	*vec;
+		u8	len;
+	}   sp;
+} dccp_feat_val;
+
+/**
+ * struct feat_entry  -  Data structure to perform feature negotiation
+ * @feat_num: one of %dccp_feature_numbers
+ * @val: feature's current value (SP features may have preference list)
+ * @state: feature's current state
+ * @needs_mandatory: whether Mandatory options should be sent
+ * @needs_confirm: whether to send a Confirm instead of a Change
+ * @empty_confirm: whether to send an empty Confirm (depends on @needs_confirm)
+ * @is_local: feature location (1) or feature-remote (0)
+ * @node: list pointers, entries arranged in FIFO order
+ */
+struct dccp_feat_entry {
+	u8                      feat_num;
+	dccp_feat_val           val;
+	enum dccp_feat_state    state:8;
+	bool			needs_mandatory:1,
+				needs_confirm:1,
+				empty_confirm:1,
+				is_local:1;
+
+	struct list_head	node;
+};
+
+static inline u8 dccp_feat_genopt(struct dccp_feat_entry *entry)
+{
+	if (entry->needs_confirm)
+		return entry->is_local? DCCPO_CONFIRM_L : DCCPO_CONFIRM_R;
+	return entry->is_local? DCCPO_CHANGE_L : DCCPO_CHANGE_R;
+}
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -23,6 +23,56 @@
 
 #define DCCP_FEAT_SP_NOAGREE (-123)
 
+/* copy constructor, fval must not already contain allocated memory */
+static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
+{
+	fval->sp.len = len;
+	if (fval->sp.len > 0) {
+		fval->sp.vec = kmemdup(val, len, gfp_any());
+		if (fval->sp.vec = NULL) {
+			fval->sp.len = 0;
+			return -ENOBUFS;
+		}
+	}
+	return 0;
+}
+
+static void dccp_feat_val_destructor(u8 feat_num, dccp_feat_val *val)
+{
+	if (val && dccp_feat_type(feat_num) = FEAT_SP)
+		kfree(val->sp.vec);
+}
+
+static struct dccp_feat_entry *
+	      dccp_feat_clone_entry(struct dccp_feat_entry const *original)
+{
+	struct dccp_feat_entry *new;
+	u8 type = dccp_feat_type(original->feat_num);
+
+	if (type = FEAT_UNKNOWN)
+		return NULL;
+
+	new = kmemdup(original, sizeof(struct dccp_feat_entry), gfp_any());
+	if (new = NULL)
+		return NULL;
+
+	if (type = FEAT_SP && dccp_feat_clone_sp_val(&new->val,
+						      original->val.sp.vec,
+						      original->val.sp.len)) {
+		kfree(new);
+		return NULL;
+	}
+	return new;
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
 int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 		     u8 *val, u8 len, gfp_t gfp)
 {
