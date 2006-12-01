From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:27:01 +0000
Subject: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <200612011827.01580@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Add protection against invalid parameters to TFRC routines

 1) For the forward X_calc lookup, it 
    * protects effectively against RTT=0 (this case is possible), by
      returning the maximal lookup value instead of just setting it to 1
    * reformulates the array-bounds exceeded condition: this only happens
      if p is greater than 1E6 (due to the scaling)
    * the case of negative indices can now with certainty be excluded, 
      since documentation shows that the formulas are within bounds
    * additional protection against p = 0 (would give divide-by-zero)

 2) For the reverse lookup, it warns against
    * protects against exceeding array bounds
    * now returns 0 if f(p) = 0, due to function definition
    * warns about minimal resolution error and returns the smallest table
      value instead of p=0 [this would mask congestion conditions]

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |   33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -588,22 +588,19 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 	u32 f;
 	u64 tmp1, tmp2;
 
+	/* check against invalid parameters and divide-by-zero   */
+	BUG_ON(p >  1000000);		/* p must not exceed 100%   */
+	BUG_ON(p = 0);			/* f(0) = 0, divide by zero */
+	if(R = 0) {			/* possible  divide by zero */
+		DCCP_CRIT("WARNING: RTT is 0, returning maximum X_calc.");
+		return ~0U;
+ 	}
+
 	if (p < TFRC_CALC_X_SPLIT) 		      /* 0      <= p <  0.05  */
 		index = (p / (TFRC_CALC_X_SPLIT / TFRC_CALC_X_ARRSIZE)) - 1;
 	else		 			      /* 0.05   <= p <= 1.00  */
 		index = (p / (1000000 / TFRC_CALC_X_ARRSIZE)) - 1;
 
-	if (index < 0)
-		/* p should be 0 unless there is a bug in my code */
-		index = 0;
-
-	if (R = 0) {
-		DCCP_WARN("RTT=0, setting to 1\n");
-		R = 1; /* RTT can't be zero or else divide by zero */
-	}
-
-	BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
-
 	if (p >= TFRC_CALC_X_SPLIT)
 		f = tfrc_calc_x_lookup[index][0];
 	else
@@ -633,13 +630,21 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalu
 	int ctr = 0;
 	int small;
 
-	if (fvalue < tfrc_calc_x_lookup[0][1])
+	if (fvalue = 0)	/* f(p) = 0  whenever  p = 0 */
 		return 0;
 
+	/* Error cases. */
+	if (fvalue < tfrc_calc_x_lookup[0][1]) {
+		DCCP_WARN("fvalue %d smaller than resolution\n", fvalue);
+		return tfrc_calc_x_lookup[0][1];
+	}
+	if (fvalue > tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][0]) {
+		DCCP_WARN("fvalue %d exceeds bounds!\n", fvalue);
+		return 1000000;
+	}
+
 	if (fvalue <= tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][1])
 		small = 1;
-	else if (fvalue > tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][0])
-		return 1000000;
 	else
 		small = 0;
 
