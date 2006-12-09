From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sat, 09 Dec 2006 11:26:16 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <20061209112616.GA17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, Dec 09, 2006 at 04:57:12PM +1300, Ian McDonald wrote:
> On 12/9/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> >[CCID3]: BUG-FIX - conversion errors
> >-                       u16 w_init = min(    4 * hctx->ccid3hctx_s,
> >-                                        max(2 * hctx->ccid3hctx_s, 4380));
> >+                       __u64 w_init = min(    4 * hctx->ccid3hctx_s,
> >+                                          max(2 * hctx->ccid3hctx_s, 
> >4380));
> 
> This has broken this code on line 478 of ccid3.c:
> 			ccid3_pr_debug("%s(%p), s=%u, w_init=%u, "
> 				       "R_sample=%ldus, X=%u\n", 
> 				       dccp_role(sk),
> 				       sk, hctx->ccid3hctx_s, w_init, 
> 				       r_sample,
> 				       (unsigned)(hctx->ccid3hctx_x >> 6));
> 
> 
> If I change the line to this it works for me:
> 			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "

Thanks Ian, applied this fix.

- Arnaldo
- 
