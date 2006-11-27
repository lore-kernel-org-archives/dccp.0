From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 18:50:06 +0000
Subject: [PATCH 3/3]: Binary search for reverse TFRC lookup
Message-Id: <200611271850.06509@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Binary search for reverse TFRC lookup

This replaces the linear search algorithm for reverse lookup with
binary search.

It has the advantage of better scalability: O(log2(N)) instead of O(N).
This means that the average number of iterations is reduced from 250 
(linear search if each value appears equally likely) down to at most 9.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |   36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -626,6 +626,21 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 
 EXPORT_SYMBOL_GPL(tfrc_calc_x);
 
+/* return largest index i such that fval <= lookup[i][small] */
+static inline u32 tfrc_binsearch(u32 fval, int small)
+{
+	u32 try, low = 0, high = TFRC_CALC_X_ARRSIZE - 1;
+
+	while(low < high) {
+		try = (low + high)/2;
+		if (fval <= tfrc_calc_x_lookup[try][small])
+			high = try;
+		else
+			low  = try + 1;
+	}
+	return high;
+}
+
 /**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
  *  @fvalue: function value to match, scaled by 1000000
@@ -634,8 +649,7 @@ EXPORT_SYMBOL_GPL(tfrc_calc_x);
  */
 u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
 {
-	int ctr = 0;
-	int small;
+	int index;
 
 	if (fvalue = 0)	/* f(p) = 0  <=> p = 0 */
 		return 0;
@@ -650,19 +664,13 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalu
 		return 1000000;
 	}
 
-	if (fvalue <= tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][1])
-		small = 1;
-	else
-		small = 0;
-
+	if (fvalue <= tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][1]) {
+		index = tfrc_binsearch(fvalue, 1);
+		return (index + 1) * TFRC_CALC_X_SPLIT/TFRC_CALC_X_ARRSIZE;
+	}
 
-	while (fvalue > tfrc_calc_x_lookup[ctr][small])
-		ctr++;
-
-	if (small)
-		return (ctr + 1) * TFRC_CALC_X_SPLIT/TFRC_CALC_X_ARRSIZE;
-	else
-		return (ctr + 1) * 1000000/TFRC_CALC_X_ARRSIZE;
+	index = tfrc_binsearch(fvalue, 0);
+	return (index + 1) * 1000000/TFRC_CALC_X_ARRSIZE;
 }
 
 EXPORT_SYMBOL_GPL(tfrc_calc_x_reverse_lookup);
