From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Jun 2007 13:55:49 +0000
Subject: [PATCH v2   8/9]: Fix and simplify header includes
Message-Id: <200706281455.49281@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Updated forward declarations which were in tfrc.h to now be directly
adjacent to the place in the file where they are actually used.
Thanks to Ian for pointing this out.

The interdiff is (patchv2 further below in message body):
============================
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -17,8 +17,6 @@
 #include <asm/div64.h>
 #include "../../dccp.h"
 /* internal includes that this module exports: */
-struct tfrc_rx_hist;
-struct tfrc_loss_hist;
 #include "loss_interval.h"
 #include "packet_history.h"

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -221,6 +221,7 @@ static inline void tfrc_rx_hist_update(s
        tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }

+struct tfrc_loss_hist;
 extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
                                struct sk_buff *skb, u32 ndp,
                                u32 (*first_li)(struct sock *), struct sock *);
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -66,6 +66,7 @@ static inline u8 tfrc_lh_length(struct t
        return min(lh->counter, (u8)LIH_SIZE);
 }

+struct tfrc_rx_hist;
 extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
                                 u32 (*first_li)(struct sock *), struct sock *);
 extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);

-------------------------------> Patch v2 <----------------------------------------

[TFRC]: Fix and simplify header includes

This updates the header-include structure so that any module wishing to use
the service of the tfrc_lib module needs only include "tfrc.h" and has access
to all declarations it needs.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    4 ----
 net/dccp/ccids/ccid3.h              |    7 +++----
 net/dccp/ccids/lib/loss_interval.c  |    5 +----
 net/dccp/ccids/lib/loss_interval.h  |    2 +-
 net/dccp/ccids/lib/packet_history.c |    1 -
 net/dccp/ccids/lib/packet_history.h |    7 +++----
 net/dccp/ccids/lib/tfrc.h           |    3 +++
 7 files changed, 11 insertions(+), 18 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -16,6 +16,9 @@
 #include <linux/types.h>
 #include <asm/div64.h>
 #include "../../dccp.h"
+/* internal includes that this module exports: */
+#include "loss_interval.h"
+#include "packet_history.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
 extern int tfrc_debug;
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -10,11 +10,8 @@
  *  the Free Software Foundation; either version 2 of the License, or
  *  (at your option) any later version.
  */
-
-#include <linux/module.h>
 #include <net/sock.h>
-#include "../../dccp.h"
-#include "loss_interval.h"
+#include "tfrc.h"
 
 static struct kmem_cache  *tfrc_lh_slab  __read_mostly;
 /* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -1,3 +1,5 @@
+#ifndef _DCCP_CCID3_H_
+#define _DCCP_CCID3_H_
 /*
  *  net/dccp/ccids/ccid3.h
  *
@@ -33,15 +35,12 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#ifndef _DCCP_CCID3_H_
-#define _DCCP_CCID3_H_
-
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/time.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
-#include "lib/packet_history.h"
+#include "lib/tfrc.h"
 #include "../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -33,11 +33,7 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include "../ccid.h"
 #include "../dccp.h"
-#include "lib/packet_history.h"
-#include "lib/loss_interval.h"
-#include "lib/tfrc.h"
 #include "ccid3.h"
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -33,7 +33,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #include <linux/string.h>
 #include "packet_history.h"
 
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -1,3 +1,5 @@
+#ifndef _DCCP_PKT_HIST_
+#define _DCCP_PKT_HIST_
 /*
  *  net/dccp/packet_history.h
  *
@@ -33,10 +35,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
-#ifndef _DCCP_PKT_HIST_
-#define _DCCP_PKT_HIST_
-
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/time.h>
@@ -223,6 +221,7 @@ static inline void tfrc_rx_hist_update(s
 	tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
+struct tfrc_loss_hist;
 extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
 				struct sk_buff *skb, u32 ndp,
 				u32 (*first_li)(struct sock *), struct sock *);
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -12,7 +12,6 @@
  *  Software Foundation; either version 2 of the License, or (at your option)
  *  any later version.
  */
-
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/time.h>
@@ -67,6 +66,7 @@ static inline u8 tfrc_lh_length(struct t
 	return min(lh->counter, (u8)LIH_SIZE);
 }
 
+struct tfrc_rx_hist;
 extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
 				 u32 (*first_li)(struct sock *), struct sock *);
 extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
 
