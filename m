From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:41 +0000
Subject: [PATCH 5/7] dccp ccid-3: X truncated due to type conversion
Message-Id: <1213102423-27486-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a bug in computing the inter-packet-interval t_ipi = s/X:

 scaled_div32(a, b) uses u32 for b, but in "scaled_div32(s, X)" the type of the
 sending rate `X' is u64. Since X is scaled by 2^6, this truncates rates greater
 than 2^26 Bps (~537 Mbps).

Using full 64-bit division now.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc.h |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -15,7 +15,7 @@
  *  (at your option) any later version.
  */
 #include <linux/types.h>
-#include <asm/div64.h>
+#include <linux/math64.h>
 #include "../../dccp.h"
 /* internal includes that this module exports: */
 #include "loss_interval.h"
@@ -29,21 +29,19 @@ extern int tfrc_debug;
 #endif
 
 /* integer-arithmetic divisions of type (a * 1000000)/b */
-static inline u64 scaled_div(u64 a, u32 b)
+static inline u64 scaled_div(u64 a, u64 b)
 {
 	BUG_ON(b=0);
-	a *= 1000000;
-	do_div(a, b);
-	return a;
+	return div64_u64(a * 1000000, b);
 }
 
-static inline u32 scaled_div32(u64 a, u32 b)
+static inline u32 scaled_div32(u64 a, u64 b)
 {
 	u64 result = scaled_div(a, b);
 
 	if (result > UINT_MAX) {
-		DCCP_CRIT("Overflow: a(%llu)/b(%u) > ~0U",
-			  (unsigned long long)a, b);
+		DCCP_CRIT("Overflow: %llu/%llu > UINT_MAX",
+			  (unsigned long long)a, (unsigned long long)b);
 		return UINT_MAX;
 	}
 	return result;
