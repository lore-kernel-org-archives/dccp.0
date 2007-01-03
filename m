From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 11:40:20 +0000
Subject: Re: [PATCH 2/4] DCCP: Add more debugging
Message-Id: <200701031140.21022@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612281706.25874.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612281706.25874.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

I have tested this at home and found a small error:

|  +	if (hctx->ccid3hctx_x != old_x) {
|  +		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
|  +		               "X_recv=%llu\n", old_x, hctx->ccid3hctx_x,
|  +			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv);
|   		ccid3_update_send_time(hctx);
=> old_x, x, and x_recv are all scaled by 2^6 and need to be divided (would give wrong results).

I have fixed this in the online version (3c_CCID3_add_more_debugging_McDonald.diff);
the inter-diff between previous and now is (having also updated `x' -> `X' for consistency):

diff -u b/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
--- b/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -100,8 +100,8 @@
        hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
                                           TFRC_OPSYS_HALF_TIME_GRAN);

-       ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, x=%llu\n",
-                      hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
+       ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%llu\n",
+                      hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
                       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);

 }
@@ -148,8 +148,9 @@

        if (hctx->ccid3hctx_x != old_x) {
                ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
-                              "X_recv=%llu\n", old_x, hctx->ccid3hctx_x,
-                              hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv);
+                              "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
+                              hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
+
                ccid3_update_send_time(hctx);
        }
 }
