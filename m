From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:40 +0000
Subject: [PATCH 4/7] dccp ccid-3: TFRC reverse-lookup Bug-Fix
Message-Id: <1213102423-27486-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a bug in the reverse lookup of p: given a value f(p), instead of p,
the function returned the smallest tabulated value f(p).

The smallest tabulated value of

   10^6 * f(p) =  sqrt(2*p/3) + 12 * sqrt(3*p/8) * (32 * p^3 + p)

for p=0.0001 is 8172.

Since this value is scaled by 10^6, the outcome of this bug is that a loss
of 8172/10^6 = 0.8172% was reported whenever the input was below the table
resolution of 0.01%.

This means that the value was over 80 times too high, resulting in large spikes
of the initial loss interval, thus unnecessarily reducing the throughput.

Also corrected the printk format (%u for u32).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -661,7 +661,7 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 
 EXPORT_SYMBOL_GPL(tfrc_calc_x);
 
-/*
+/**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
  *
  *  @fvalue: function value to match, scaled by 1000000
@@ -676,11 +676,11 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
 
 	/* Error cases. */
 	if (fvalue < tfrc_calc_x_lookup[0][1]) {
-		DCCP_WARN("fvalue %d smaller than resolution\n", fvalue);
-		return tfrc_calc_x_lookup[0][1];
+		DCCP_WARN("fvalue %u smaller than resolution\n", fvalue);
+		return TFRC_SMALLEST_P;
 	}
 	if (fvalue > tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][0]) {
-		DCCP_WARN("fvalue %d exceeds bounds!\n", fvalue);
+		DCCP_WARN("fvalue %u exceeds bounds!\n", fvalue);
 		return 1000000;
 	}
 
