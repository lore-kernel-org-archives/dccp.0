From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:44:37 +0000
Subject: [PATCH 02/37] dccp: Implement lookup table for feature-negotiation information
Message-Id: <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A lookup table for feature-negotiation information, extracted from RFC 4340/42,
is provided by this patch. All currently known features can be found in this
table, along with their feature location, their default value, and type.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |    9 ++--
 net/dccp/feat.c      |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+), 4 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -176,19 +176,20 @@ enum {
 };
 
 /* DCCP features (RFC 4340 section 6.4) */
-enum {
+enum dccp_feature_numbers {
 	DCCPF_RESERVED = 0,
 	DCCPF_CCID = 1,
-	DCCPF_SHORT_SEQNOS = 2,		/* XXX: not yet implemented */
+	DCCPF_SHORT_SEQNOS = 2,
 	DCCPF_SEQUENCE_WINDOW = 3,
-	DCCPF_ECN_INCAPABLE = 4,	/* XXX: not yet implemented */
+	DCCPF_ECN_INCAPABLE = 4,
 	DCCPF_ACK_RATIO = 5,
 	DCCPF_SEND_ACK_VECTOR = 6,
 	DCCPF_SEND_NDP_COUNT = 7,
 	DCCPF_MIN_CSUM_COVER = 8,
-	DCCPF_DATA_CHECKSUM = 9,	/* XXX: not yet implemented */
+	DCCPF_DATA_CHECKSUM = 9,
 	/* 10-127 reserved */
 	DCCPF_MIN_CCID_SPECIFIC = 128,
+	DCCPF_SEND_LEV_RATE = 192,	/* RFC 4342, sec. 8.4 */
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -23,6 +23,80 @@
 
 #define DCCP_FEAT_SP_NOAGREE (-123)
 
+static const struct {
+	u8			feat_num;		/* DCCPF_xxx */
+	enum dccp_feat_type	rxtx;			/* RX or TX  */
+	enum dccp_feat_type	reconciliation;		/* SP or NN  */
+	u8			default_value;		/* as in 6.4 */
+/*
+ *    Lookup table for location and type of features (from RFC 4340/4342)
+ *  +--------------------------+----+-----+----+----+---------+-----------+
+ *  | Feature                  | Location | Reconc. | Initial |  Section  |
+ *  |                          | RX | TX  | SP | NN |  Value  | Reference |
+ *  +--------------------------+----+-----+----+----+---------+-----------+
+ *  | DCCPF_CCID               |    |  X  | X  |    |   2     | 10        |
+ *  | DCCPF_SHORT_SEQNOS       |    |  X  | X  |    |   0     |  7.6.1    |
+ *  | DCCPF_SEQUENCE_WINDOW    |    |  X  |    | X  | 100     |  7.5.2    |
+ *  | DCCPF_ECN_INCAPABLE      | X  |     | X  |    |   0     | 12.1      |
+ *  | DCCPF_ACK_RATIO          |    |  X  |    | X  |   2     | 11.3      |
+ *  | DCCPF_SEND_ACK_VECTOR    | X  |     | X  |    |   0     | 11.5      |
+ *  | DCCPF_SEND_NDP_COUNT     |    |  X  | X  |    |   0     |  7.7.2    |
+ *  | DCCPF_MIN_CSUM_COVER     | X  |     | X  |    |   0     |  9.2.1    |
+ *  | DCCPF_DATA_CHECKSUM      | X  |     | X  |    |   0     |  9.3.1    |
+ *  | DCCPF_SEND_LEV_RATE      | X  |     | X  |    |   0     | 4342/8.4  |
+ *  +--------------------------+----+-----+----+----+---------+-----------+
+ */
+} dccp_feat_table[] = {
+	{ DCCPF_CCID,		 FEAT_AT_TX, FEAT_SP, 2 },
+	{ DCCPF_SHORT_SEQNOS,	 FEAT_AT_TX, FEAT_SP, 0 },
+	{ DCCPF_SEQUENCE_WINDOW, FEAT_AT_TX, FEAT_NN, 100 },
+	{ DCCPF_ECN_INCAPABLE,	 FEAT_AT_RX, FEAT_SP, 0 },
+	{ DCCPF_ACK_RATIO,	 FEAT_AT_TX, FEAT_NN, 2 },
+	{ DCCPF_SEND_ACK_VECTOR, FEAT_AT_RX, FEAT_SP, 0 },
+	{ DCCPF_SEND_NDP_COUNT,  FEAT_AT_TX, FEAT_SP, 0 },
+	{ DCCPF_MIN_CSUM_COVER,  FEAT_AT_RX, FEAT_SP, 0 },
+	{ DCCPF_DATA_CHECKSUM,	 FEAT_AT_RX, FEAT_SP, 0 },
+	{ DCCPF_SEND_LEV_RATE,	 FEAT_AT_RX, FEAT_SP, 0 },
+};
+#define DCCP_FEAT_SUPPORTED_MAX		ARRAY_SIZE(dccp_feat_table)
+
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
+static int dccp_feat_default_value(u8 feat_num)
+{
+	int idx = dccp_feat_index(feat_num);
+
+	return idx < 0 ? : dccp_feat_table[idx].default_value;
+}
+
 /* copy constructor, fval must not already contain allocated memory */
 static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 {
@@ -37,6 +111,42 @@ static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 	return 0;
 }
 
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
@@ -653,6 +763,8 @@ const char *dccp_feat_name(const u8 feat)
 	if (feat > DCCPF_DATA_CHECKSUM && feat < DCCPF_MIN_CCID_SPECIFIC)
 		return feature_names[DCCPF_RESERVED];
 
+	if (feat =  DCCPF_SEND_LEV_RATE)
+		return "Send Loss Event Rate";
 	if (feat >= DCCPF_MIN_CCID_SPECIFIC)
 		return "CCID-specific";
 
-- 
1.6.0.rc2

