From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:02:08 +0000
Subject: [PATCH 10/22] [DCCP]: Simplify TFRC calculation
Message-Id: <20061210030207.GL17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In migrating towards using the newer functions scaled_div/scaled_div32
for TFRC computations mapped from floating-point onto integer arithmetic,
this completes the last stage of modifications.

In particular, the overflow case for computing X_calc is circumvented by
 * breaking the computation into two stages
 * the first stage, res = (s*1E6)/R, cannot overflow due to use of u64
 * in the second stage, res = (res*1E6)/f, overflow on u32 is avoided due
   to (i) returning UINT_MAX in this case (which is logically appropriate)
   and (ii) issuing a warning message into the system log (since very likely
   there is a problem somewhere else with the parameters)

Lastly, all such scaling operations are now exported into tfrc.h, since
actually this form of scaled computation is specific to TFRC and not to CCID3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.h             |   19 -------------------
 net/dccp/ccids/lib/tfrc.h          |   23 ++++++++++++++++++++++-
 net/dccp/ccids/lib/tfrc_equation.c |   28 +++++++++++++---------------
 3 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index cd4fc54..da0ca3c 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -171,23 +171,4 @@ static inline struct ccid3_hc_rx_sock *c
     return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
 
-static inline u64 scaled_div(u64 a, u32 b)
-{
-	BUG_ON(b=0);
-	a *= 1000000;
-	do_div(a, b);
-	return a;
-}
-
-static inline u32 scaled_div32(u64 a, u32 b)
-{
-	u64 result = scaled_div(a, b);
-
-	if (result > UINT_MAX) {
-		DCCP_CRIT("Overflow: a(%llu)/b(%u) > ~0U",
-			  (unsigned long long)a, b);
-		return UINT_MAX;
-	}
-	return result;
-}
 #endif /* _DCCP_CCID3_H_ */
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index 45f30f5..faf5f7e 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -13,8 +13,29 @@ #define _TFRC_H_
  *  the Free Software Foundation; either version 2 of the License, or
  *  (at your option) any later version.
  */
-
 #include <linux/types.h>
+#include <asm/div64.h>
+
+/* integer-arithmetic divisions of type (a * 1000000)/b */
+static inline u64 scaled_div(u64 a, u32 b)
+{
+	BUG_ON(b=0);
+	a *= 1000000;
+	do_div(a, b);
+	return a;
+}
+
+static inline u32 scaled_div32(u64 a, u32 b)
+{
+	u64 result = scaled_div(a, b);
+
+	if (result > UINT_MAX) {
+		DCCP_CRIT("Overflow: a(%llu)/b(%u) > ~0U",
+			  (unsigned long long)a, b);
+		return UINT_MAX;
+	}
+	return result;
+}
 
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
diff --git a/net/dccp/ccids/lib/tfrc_equation.c b/net/dccp/ccids/lib/tfrc_equation.c
index ddac2c5..90009fd 100644
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -13,7 +13,6 @@
  */
 
 #include <linux/module.h>
-#include <asm/div64.h>
 #include "../../dccp.h"
 #include "tfrc.h"
 
@@ -616,15 +615,12 @@ static inline u32 tfrc_binsearch(u32 fva
  *  @R: RTT                  scaled by 1000000   (i.e., microseconds)
  *  @p: loss ratio estimate  scaled by 1000000
  *  Returns X_calc           in bytes per second (not scaled).
- *
- * Note: DO NOT alter this code unless you run test cases against it,
- *       as the code has been optimized to stop underflow/overflow.
  */
 u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 {
-	int index;
+	u16 index;
 	u32 f;
-	u64 tmp1, tmp2;
+	u64 result;
 
 	/* check against invalid parameters and divide-by-zero   */
 	BUG_ON(p >  1000000);		/* p must not exceed 100%   */
@@ -650,15 +646,17 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 		f = tfrc_calc_x_lookup[index][0];
 	}
 
-	/* The following computes X = s/(R*f(p)) in bytes per second. Since f(p)
-	 * and R are both scaled by 1000000, we need to multiply by 1000000^2.
-	 * => DO NOT alter this unless you test against overflow on 32 bit   */
-	tmp1 = ((u64)s * 100000000);
-	tmp2 = ((u64)R * (u64)f);
-	do_div(tmp2, 10000);
-	do_div(tmp1, tmp2); 
-
-	return (u32)tmp1; 
+	/*
+	 * Compute X = s/(R*f(p)) in bytes per second.
+	 * Since f(p) and R are both scaled by 1000000, we need to multiply by
+	 * 1000000^2. To avoid overflow, the result is computed in two stages.
+	 * This works under almost all reasonable operational conditions, for a
+	 * wide range of parameters. Yet, should some strange combination of
+	 * parameters result in overflow, the use of scaled_div32 will catch
+	 * this and return UINT_MAX - which is a logically adequate consequence.
+	 */
+	result = scaled_div(s, R);
+	return scaled_div32(result, f);
 }
 
 EXPORT_SYMBOL_GPL(tfrc_calc_x);
-- 
1.4.2.1.g3d5c

