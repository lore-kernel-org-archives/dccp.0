From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:41:43 +0000
Subject: [PATCH 2/6]: Migrate TX history to singly-linked list
Message-Id: <200706111341.43594@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Migrate TX history to singly-linked list

The patch set migrates TFRC TX history to a singly-linked list (implementing a
suggestion by Arnaldo Carvalho de Melo) and prepares locking. Adding locking
is important, since receiver and sender write/read asynchronously on the
TX history.

This patch presents only the data structures, so that the remaining patches in
the patch set are mostly self-explanatory.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h              |    3 ++-
 net/dccp/ccids/lib/packet_history.c |    2 ++
 net/dccp/ccids/lib/packet_history.h |   30 +++++++++++++++++++++---------
 3 files changed, 25 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -41,6 +41,8 @@
 /*
  * 	Transmitter History Routines
  */
+DEFINE_RWLOCK(tfrc_tx_hist_lock);
+
 struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
 {
 	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -52,18 +52,30 @@
 /*
  * 	Transmitter History data structures and declarations
  */
-struct dccp_tx_hist_entry {
-	struct list_head dccphtx_node;
-	u64		 dccphtx_seqno;
-	struct timeval	 dccphtx_tstamp;
-};
+extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
+extern void		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
 
-struct dccp_tx_hist {
-	struct kmem_cache *dccptxh_slab;
+/**
+ *  tfrc_tx_hist  -  Simple singly-linked TX history list
+ *  @next:  next oldest entry (LIFO order)
+ *  @seqno: sequence number of this entry
+ *  @stamp: send time of packet with sequence number @seqno
+ */
+struct tfrc_tx_hist {
+	struct tfrc_tx_hist	*next;
+	u64			seqno;
+	ktime_t			stamp;
 };
 
-extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
-extern void 		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
+/**
+ *  tfrc_tx_hist_head  -  Head of TX history
+ *  @first: begin of the list
+ *  @cache: where list entries are allocated from
+ */
+struct tfrc_tx_hist_head {
+	struct tfrc_tx_hist	*first;
+	struct kmem_cache	*cache;
+};
 
 static inline struct dccp_tx_hist_entry *
 			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -40,6 +40,7 @@
 #include <linux/time.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
+#include "lib/packet_history.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
@@ -111,7 +112,7 @@ struct ccid3_hc_tx_sock {
 	ktime_t				ccid3hctx_t_ld;
 	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
-	struct list_head		ccid3hctx_hist;
+	struct tfrc_tx_hist_head	ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
