From: Tommi Saviranta <wnd@iki.fi>
Date: Fri, 09 Nov 2007 13:14:29 +0000
Subject: Re: [PATCH 6/25] Reduce allowed sending rate by a factor that
Message-Id: <20071109131429.GB11914@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.18806.leandroal@gmail.com>
In-Reply-To: <200710312130.18806.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Nov 08, 2007 at 10:15:23 +0000, Gerrit Renker wrote:
> Since ccid4_hc_tx_x_header_penalty() is called in both the if/else
> branches, it looks to me that you can put it before the if/else. 
> If you then wanted to abstract this function, it looks as if a wrapper
> could be used:
> 
> 	ccid4_hc_tx_update_x(hctx) 
> 	{
>               ccid4_hc_tx_x_header_penalty(hctx);
> 		tfrc_hc_tx_update_x(...);
> 	}
> 
> Makes sense?

ccid4_hc_tx_x_header_penalty() modifies hctx->ccid4hctx_x. If new x
differs from old x at the end of ccid4_hc_tx_update_x(),
ccid4_update_send_interval() is called. As far as I can see, if we
wanted to have tfrc_hc_tx_update_x(), the caller of that function would
have to deal with changed x by calling *_update_send_interval(), which
is CCID-dependant.

Maybe tfrc_hc_tx_update_x() could update x, return old x, and indeed let
the caller to call ccid4_hc_tx_x_header_penalty(), if wanted, and
finally *_update_send_interval, if necessary. Since
ccid4_hc_tx_update_x() is currently called from two different places, we
could have something like this instead:

static void ccid4_hc_tx_update_x(hctx)
{
	const  __u64 old_x = tfrc_hc_tx_update_x(hctx);
	ccid4_hc_tx_x_header_penalty(hctx);
	if (hctx->ccid4hctx_x != old_x)
		ccid4_update_send_interval(hctx);
}

And respectively:

static void ccid3_hc_tx_update_x(hctx)
{
	const  __u64 old_x = tfrc_hc_tx_update_x(hctx);
	if (hctx->ccid4hctx_x != old_x)
		ccid3_update_send_interval(hctx);
}

Finally, tfrc_hc_tx_update_x() should be trimmed a little:

@@ -198,3 +198,2
-	if (hctx->ccid4hctx_x != old_x)
-		foo_update_send_interval(hctx);
+	return old_x;
 }

