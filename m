From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Dec 2006 07:23:16 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <200612110723.16639@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 12/9/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID3]: BUG-FIX - conversion errors
|  > -                       u16 w_init = min(    4 * hctx->ccid3hctx_s,
|  > -                                        max(2 * hctx->ccid3hctx_s, 4380));
|  > +                       __u64 w_init = min(    4 * hctx->ccid3hctx_s,
|  > +                                          max(2 * hctx->ccid3hctx_s, 4380));
|  
|  This has broken this code on line 478 of ccid3.c:
|  			ccid3_pr_debug("%s(%p), s=%u, w_init=%u, "
|  				       "R_sample=%ldus, X=%u\n", dccp_role(sk),
|  				       sk, hctx->ccid3hctx_s, w_init, r_sample,
|  				       (unsigned)(hctx->ccid3hctx_x >> 6));
|  
|  
|  If I change the line to this it works for me:
|  			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
|  
Hi there - sorry about the whitespace errors and the above one. I thought about this one
when I went home on Friday. I will re-work the above, also to use MSS instead of `s', which
does make sense.

Thanks for all the good work, Arnaldo.

Gerrit
