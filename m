From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:51:50 +0000
Subject: [PATCH 2/9]: Loss-intervals access-macros and -functions
Message-Id: <200706171351.50245@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Loss-intervals access-macros and -functions

Access to the Loss Interval Records is not direct, but (like in object-oriented
programming) via functions.

The macros are for unprotected access, the functions implement safety checks
which ensure that the macros are called in a sane state.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -16,6 +16,27 @@
 #include "../../dccp.h"
 #include "loss_interval.h"
 
+/*
+ * Access macros: These require that at least one entry is present in lh,
+ * and implement array semantics (0 is first, n-1 is the last of n entries).
+ */
+#define __lih_index(lh, n)	LIH_INDEX((lh)->counter - (n) - 1)
+#define __lih_entry(lh, n)	(lh)->ring[__lih_index(lh, n)]
+#define __curr_entry(lh)	(lh)->ring[LIH_INDEX((lh)->counter - 1)]
+#define __next_entry(lh)	(lh)->ring[LIH_INDEX((lh)->counter)]
+
+/* given i with 0 <= i <= k, return I_i as per the rfc3448bis notation */
+static inline u32 tfrc_lh_get_interval(struct tfrc_loss_hist *lh, u8 i)
+{
+	BUG_ON(i >= lh->counter);
+	return __lih_entry(lh, i)->li_length;
+}
+
+static inline struct tfrc_loss_interval *tfrc_lh_peek(struct tfrc_loss_hist *lh)
+{
+	return lh->counter ? __curr_entry(lh) : NULL;
+}
+
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
 	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
