From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 18:06:15 +0000
Subject: [PATCH 1/2] [DCCP] ccid3: Fixup some type conversions related to rtts
Message-Id: <20061210180615.GB25274@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Spotted by David Miller when compiling on sparc64, I reproduced it here on
parisc64, that are the only platforms to define __kernel_suseconds_t as an
'int', all the others, x86_64 and x86 included typedef it as a 'long', but from
the definition of suseconds_t it should just be an 'int' on platforms where it
is >= 32bits, it would not require all the castings from suseconds_t to (int)
when printking variables of this type, that are not needed on parisc64 and
sparc64.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   18 +++++++++---------
 net/dccp/ccids/ccid3.h |    6 +++---
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 6bc77ff..5e817e2 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -399,7 +399,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	struct timeval now;
 	unsigned long t_nfb;
 	u32 pinv;
-	long r_sample, t_elapsed;
+	suseconds_t r_sample, t_elapsed;
 
 	BUG_ON(hctx = NULL);
 
@@ -446,8 +446,8 @@ static void ccid3_hc_tx_packet_recv(stru
 
 		DCCP_BUG_ON(r_sample < 0);
 		if (unlikely(r_sample <= t_elapsed))
-			DCCP_WARN("WARNING: r_sample=%ldus <= t_elapsed=%ldus\n",
-				  r_sample, t_elapsed);
+			DCCP_WARN("WARNING: r_sample=%dus <= t_elapsed=%dus\n",
+				  (int)r_sample, (int)t_elapsed);
 		else
 			r_sample -= t_elapsed;
 		CCID3_RTT_SANITY_CHECK(r_sample);
@@ -474,8 +474,8 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_update_send_time(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
-				       "R_sample=%ldus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s, w_init, r_sample,
+				       "R_sample=%dus, X=%u\n", dccp_role(sk),
+				       sk, hctx->ccid3hctx_s, w_init, (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
@@ -491,9 +491,9 @@ static void ccid3_hc_tx_packet_recv(stru
 						    hctx->ccid3hctx_p);
 			ccid3_hc_tx_update_x(sk, &now);
 
-			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%ldus), s=%u, "
+			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%dus), s=%u, "
 				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_rtt, r_sample,
+				       sk, hctx->ccid3hctx_rtt, (int)r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
 				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
@@ -821,8 +821,8 @@ found:
 	DCCP_BUG_ON(delta < 0);
 
 	rtt = delta * 4 / interval;
-	ccid3_pr_debug("%s(%p), approximated RTT to %ldus\n",
-		       dccp_role(sk), sk, rtt);
+	ccid3_pr_debug("%s(%p), approximated RTT to %dus\n",
+		       dccp_role(sk), sk, (int)rtt);
 
 	/*
 	 * Determine the length of the first loss interval via inverse lookup.
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 3fa0f69..3e3a9cc 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -52,12 +52,12 @@ #define TFRC_OPSYS_HALF_TIME_GRAN  (USEC
 #define TFRC_T_MBI		   64
 
 /* What we think is a reasonable upper limit on RTT values */
-#define CCID3_SANE_RTT_MAX	   (4 * USEC_PER_SEC)
+#define CCID3_SANE_RTT_MAX	   ((suseconds_t)(4 * USEC_PER_SEC))
 
 #define CCID3_RTT_SANITY_CHECK(rtt) 			do {		   \
 		if (rtt > CCID3_SANE_RTT_MAX) {				   \
-			DCCP_CRIT("RTT (%ld) too large, substituting %ld", \
-				  rtt, CCID3_SANE_RTT_MAX);		   \
+			DCCP_CRIT("RTT (%d) too large, substituting %d",   \
+				  (int)rtt, (int)CCID3_SANE_RTT_MAX);	   \
 			rtt = CCID3_SANE_RTT_MAX;			   \
 		} 					} while (0)
 
-- 
1.4.2.1.g3d5c

