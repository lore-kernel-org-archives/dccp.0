From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 10 Nov 2007 12:09:02 +0000
Subject: Re: [PATCH 6/25] Reduce allowed sending rate by a factor that accounts for packet header size
Message-Id: <20071110120902.GD10338@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.18806.leandroal@gmail.com>
In-Reply-To: <200710312130.18806.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > But I am guessing that eventually you would like
| > to reduce code duplication, the above was a start.
| 
| That's definitely one of the long run goals. While it may not be one of
| the top priorities to worry about code duplication, it definitely pays
| to give it a thought already.
| 
Agreed, I think it is useful to keep this discussion running in the
background, but maybe not make it top priority (more below).

| > Now with regard to the above - we end up having three different
| > functions doing each a slice of the work and with interleaved calling.
| 
| Actually two functions. There is absolutely no reason why
| ccid4_hc_tx_x_header_penalty() should be a separate function. Even now,
| there is effectively exactly one place from where it is called. Silly
| me.
No, not at all -- you are making good points here. Discussion is often the
only way to arrive at better code. I have experienced that myself, some of
the best ideas actually came out of discussions with Arnaldo and Ian.

| > I have another suggestion which I believe may be simpler: The `header
| > penalty' is just a multiplication applied to X. The sender does not
| > use X directly, but rather t_ipi = s/X. And it has to compute this
| > anyway, in update_send_interval(), each time X changes.
| 
| > Taken together, we have 
| > 
| > 	t_ipi = s / X'
| > 	      = s / (X * s / (s + 36))
| > 	      = (s + 36) / X
| > 
| > Thus, the suggestion is to
| > 
| >  * keep update_x the same for CCID3 and CCID4 
| >  * only change update_send_interval()
| 
| > This has the added advantage of higher precision than the previous
| > approach (accumulation of rounding errors).
| 
| I'm not sure how conservative we want to be about it, but if we take the
| header size in account in update_send_interval() only, we do a bit of
| unnecessary work when update_send_interval() is called from update_s().
The idea is nice, but how do you want to integrate it with the moving
average in update_s():

	const u16 old_s = hctx->ccid4hctx_s;

        hctx->ccid4hctx_s = old_s = 0 ? len : (9 * old_s + len) / 10;

When writing 

        hctx->ccid4hctx_s += 36,

the header penalty gets `smoothed out' (i.e. is lost) in the weighted 
average. But I think your approach is in essence good - to find the
highest possible abstraction; this is needed for the other work.

| >  hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s +  CCID4_NOM) << 6,
| >                                              hctx->ccid3hctx_x);
| 
| Going for higher precision makes perfect sense. However the calculation
| is slightly different for CCID 3 and 4, so I think updating
| update_send_interval() isn't that simple:
| 
|   ccid3_t_ipi = s / x
|   ccid4_t_ipi = max((s + CCID4_H) / x, CCID4_MIN_IPI)
| 
You have thought ahead and combined both requirements into one: the
above now gives most of the body for a new function
ccid4_update_send_interval(). Combining this with your comments to 
patch 5/25, this would make a nice replacement. Do you or Leandro want
to codify this?


| I can't see of a good way to share that code between the CCIDs without
| bits of extra information in struct tfrc_hc_tx_sock. I think we have
| four options:
| 
|  * Set CCIDx_H and CCIDx_MIN_IPI in hctx and use them as part of t_ipi
|    calculation,
|  * set a bit in hctx to decide which equation to use,
|  * add function pointer to suitable calculate_t_ipi() to be called from
|    tfrc_update_send_interval(), and
|  * try a different approach.
When thinking through this, I found another
   * add a function pointer (*update_intvl)() to update_x() 

<snip>	
| Besides that I have no idea if using function pointers is considered a
| bad idea in kernel code.
My understanding of the kernel coding guidelines is that simplicity and
clarity are a priority (since others need to read the code, too); and
that function pointers are a very useful abstraction technique. But
many function pointers as arguments are probably also not good.

| I don't think there are easy answers to this.
Fully agree. I think that it will be much easier to separate the
functional blocks when you've finished your CCID4 design. Then the
similarities between the new and the old code will be obvious.

I am saying this since I have used the same approach with UDP-Lite, and
found it very useful: in the begin it was utter code duplication, I
literally copy+pasted udp.c into udplite.c, for the whole time the code
was developed. When it became time to submit this for mainline, it was
easy/easier to abstract the difference between UDP and UDP-Lite, and the
result is now quite short. But it was only easy because the related code
was in one unit (not cut into pieces) during development, which helped a
lot.
