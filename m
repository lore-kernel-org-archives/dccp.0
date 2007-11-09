From: Tommi Saviranta <wnd@iki.fi>
Date: Fri, 09 Nov 2007 20:46:00 +0000
Subject: Re: [PATCH 6/25] Reduce allowed sending rate by a factor that
Message-Id: <20071109204600.GA666@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.18806.leandroal@gmail.com>
In-Reply-To: <200710312130.18806.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Nov 09, 2007 at 15:03:28 +0000, Gerrit Renker wrote:
> Maybe I should not have started this thread, after first suggesting to
> keep things separate. But I am guessing that eventually you would like
> to reduce code duplication, the above was a start.

That's definitely one of the long run goals. While it may not be one of
the top priorities to worry about code duplication, it definitely pays
to give it a thought already.

> Now with regard to the above - we end up having three different
> functions doing each a slice of the work and with interleaved calling.

Actually two functions. There is absolutely no reason why
ccid4_hc_tx_x_header_penalty() should be a separate function. Even now,
there is effectively exactly one place from where it is called. Silly
me.

> I have another suggestion which I believe may be simpler: The `header
> penalty' is just a multiplication applied to X. The sender does not
> use X directly, but rather t_ipi = s/X. And it has to compute this
> anyway, in update_send_interval(), each time X changes.

> Taken together, we have 
> 
> 	t_ipi = s / X'
> 	      = s / (X * s / (s + 36))
> 	      = (s + 36) / X
> 
> Thus, the suggestion is to
> 
>  * keep update_x the same for CCID3 and CCID4 
>  * only change update_send_interval()

> This has the added advantage of higher precision than the previous
> approach (accumulation of rounding errors).

I'm not sure how conservative we want to be about it, but if we take the
header size in account in update_send_interval() only, we do a bit of
unnecessary work when update_send_interval() is called from update_s().
The difference may be insignificant, especially considering higher
precision, which I didn't really think about.

>  /* 
>   * Update t_ipi with regard to the header penalty X *= s/(s + 36),
>   * which is factored into the t_ipi equation
>   */
>  hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s +  CCID4_NOM) << 6,
>                                              hctx->ccid3hctx_x);

Going for higher precision makes perfect sense. However the calculation
is slightly different for CCID 3 and 4, so I think updating
update_send_interval() isn't that simple:

  ccid3_t_ipi = s / x
  ccid4_t_ipi = max((s + CCID4_H) / x, CCID4_MIN_IPI)

I can't see of a good way to share that code between the CCIDs without
bits of extra information in struct tfrc_hc_tx_sock. I think we have
four options:

 * Set CCIDx_H and CCIDx_MIN_IPI in hctx and use them as part of t_ipi
   calculation,
 * set a bit in hctx to decide which equation to use,
 * add function pointer to suitable calculate_t_ipi() to be called from
   tfrc_update_send_interval(), and
 * try a different approach.

The first options is most likely pointless since some unnecessary work
would have to be done for CCID 3. The second option would probably lead
to spaghetti code where everything would eventually depends on that bit,
and shared_tfrc.c would contain lots of code that would in fact belong
to ccidx.c. (Don't get me wrong, I'm really not against this!) The third
option could give quick relief here, but it suffers from the same
problem as option two, although it looks neater at first. Besides that I
have no idea if using function pointers is considered a bad idea in
kernel code.

I don't think there are easy answers to this.

