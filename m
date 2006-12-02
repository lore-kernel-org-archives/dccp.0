From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 02 Dec 2006 12:54:45 +0000
Subject: Re: [PATCH 7/8]: Deprecate TFRC_SMALLEST_P
Message-Id: <200612021254.45708@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.15505@strip-the-willow>
In-Reply-To: <200612011827.15505@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 12/2/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [DCCP]: Deprecate TFRC_SMALLEST_P
|  >
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  
|  Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

I would like to inform you that I have made a small change which 
would otherwise cause erratic behaviour:

In ccid3_hc_tx_no_feedback_timer():
/* If (X_calc > 2 * X_recv)
	X_recv = max(X_recv/2, s(2*t_mbi))
   Else
	X_recv = X_calc/4

-                       /* check also if p is zero -> x_calc is infinity? */
-                       if (hctx->ccid3hctx_p < TFRC_SMALLEST_P ||
-                           hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
								    hctx->ccid3hctx_s / (2 * TFRC_T_MBI));
			else
				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;

==> the previous replacement was:
+                       if (hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)

==> if p=0, the `else' case would be taken. But X_calc is then either a stale value or (at worst) 0
     which would mean that the sender cuts off here. Therefore, I have done the following: 
+			if (hctx->ccid3hctx_p  = 0 ||
+                           hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)

==> In this way we avoid using a stale or zero value of X_calc

Keep the Acked-by? 
