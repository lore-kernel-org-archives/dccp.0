From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Sep 2008 05:23:05 +0000
Subject: v2 [PATCH 1/5] dccp: Basic data structure for feature negotiation
Message-Id: <20080924052305.GC4944@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the second/other revised patch for this set [v2 of 1/5].

Changes relative to v1: copied Arnaldos suggested layout and updated the
struct documentation accordingly. Compile-tested the result.

>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: Basic data structure for feature negotiation

This patch prepares for the new and extended feature-negotiation routines.

The following feature-negotiation data structures are provided:
	* a container for the various (SP or NN) values,
	* symbolic state names to track feature states,
	* an entry struct which holds all current information together,
	* elementary functions to fill in and process these structures.

Entry structs are arranged as FIFO for the following reason: RFC 4340 specifies
that if multiple options of the same type are present, they are processed in the
order of their appearance in the packet; which means that this order needs to be
preserved in the local data structure (the later insertion code also respects
this order).

The struct list_head has been chosen for the following reasons: the most 
frequent operations are
 * add new entry at tail (when receiving Change or setting socket options);
 * delete entry (when Confirm has been received);
 * deep copy of entire list (cloning from listening socket onto request socket).

The NN value has been set to 64 bit, which is a currently sufficient upper limit
(Sequence Window feature has 48 bit).

Thanks to Arnaldo who streamlined the field layout of the entry struct.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |   14 ++++++++++++
 net/dccp/feat.h |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,6 +14,67 @@
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
+ * @val: feature's current value (SP features may have preference list)
+ * @state: feature's current state
+ * @feat_num: one of %dccp_feature_numbers
+ * @needs_mandatory: whether Mandatory options should be sent
+ * @needs_confirm: whether to send a Confirm instead of a Change
+ * @empty_confirm: whether to send an empty Confirm (depends on @needs_confirm)
+ * @is_local: feature location (1) or feature-remote (0)
+ * @node: list pointers, entries arranged in FIFO order
+ */
+struct dccp_feat_entry {
+	dccp_feat_val           val;
+	enum dccp_feat_state    state:8;
+	u8                      feat_num;
+
+	bool			needs_mandatory,
+				needs_confirm,
+				empty_confirm,
+				is_local;
+
+	struct list_head	node;
+};
+
+static inline u8 dccp_feat_genopt(struct dccp_feat_entry *entry)
+{
+	if (entry->needs_confirm)
+		return entry->is_local ? DCCPO_CONFIRM_L : DCCPO_CONFIRM_R;
+	return entry->is_local ? DCCPO_CHANGE_L : DCCPO_CHANGE_R;
+}
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -23,6 +23,20 @@
 
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
 int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 		     u8 *val, u8 len, gfp_t gfp)
 {
