From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:29:43 +0000
Subject: [PATCH 5/5] CCID 4: Use 1460 bytes as segment size in TCP
Message-Id: <20070920112943.GD26233@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Uses hard-coded value of 1460 bytes in TCP throughput calculation.

Signed-off-by: Tommi Saviranta <wnd@iki.fi>

---
diff -Nrup a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
--- a/net/dccp/ccids/ccid4.c	2007-09-20 13:32:42.000000000 +0300
+++ b/net/dccp/ccids/ccid4.c	2007-09-20 14:02:43.000000000 +0300
@@ -459,7 +459,7 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 	/* perform step (4) of draft rfc3448bis, section 4.3 */
 	if (hctx->ccid4hctx_p > 0)
-		hctx->ccid4hctx_x_calc = tfrc_calc_x(hctx->ccid4hctx_s,
+		hctx->ccid4hctx_x_calc = tfrc_calc_x(1460,
 						     hctx->ccid4hctx_rtt,
 						     hctx->ccid4hctx_p);
 	ccid4_hc_tx_update_x(sk, &now);
@@ -740,7 +740,7 @@ static int ccid4_hc_rx_insert_options(st
 	return 0;
 }
 
-/** ccid4_first_li  -  Implements [RFC 3448, 6.3.1]
+/** ccid4_first_li  -  Implements [RFC 3448, 6.3.1], with s = 1460 [TFRC-SP]
  *
  * Determine the length of the first loss interval via inverse lookup.
  * Assume that X_recv can be computed by the throughput equation
@@ -770,7 +770,7 @@ static u32 ccid4_first_li(struct sock *s
 		}
 	}
 
-	fval = scaled_div(hcrx->ccid4hcrx_s, hcrx->ccid4hcrx_rtt);
+	fval = scaled_div(1460, hcrx->ccid4hcrx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
