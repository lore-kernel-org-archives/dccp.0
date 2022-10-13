From: Joe Perches <joe@perches.com>
Date: Thu, 13 Oct 2022 01:37:11 +0000
Subject: Re: [PATCH v1 3/5] treewide: use get_random_u32() when possible
Message-Id: <3f527ec95a12135eb40f5f2d156a2954feb7fbfe.camel@perches.com>
List-Id: <dccp.vger.kernel.org>
References: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
In-Reply-To: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 2022-10-12 at 21:29 +0000, David Laight wrote:
> From: Joe Perches
> > Sent: 12 October 2022 20:17
> > 
> > On Wed, 2022-10-05 at 23:48 +0200, Jason A. Donenfeld wrote:
> > > The prandom_u32() function has been a deprecated inline wrapper around
> > > get_random_u32() for several releases now, and compiles down to the
> > > exact same code. Replace the deprecated wrapper with a direct call to
> > > the real function.
> > []
> > > diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
> > []
> > > @@ -734,7 +734,7 @@ static int send_connect(struct c4iw_ep *ep)
> > >  				   &ep->com.remote_addr;
> > >  	int ret;
> > >  	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
> > > -	u32 isn = (prandom_u32() & ~7UL) - 1;
> > > +	u32 isn = (get_random_u32() & ~7UL) - 1;
> > 
> > trivia:
> > 
> > There are somewhat odd size mismatches here.
> > 
> > I had to think a tiny bit if random() returned a value from 0 to 7
> > and was promoted to a 64 bit value then truncated to 32 bit.
> > 
> > Perhaps these would be clearer as ~7U and not ~7UL
> 
> That makes no difference - the compiler will generate the same code.

True, more or less.  It's more a question for the reader.

> The real question is WTF is the code doing?

True.

> The '& ~7u' clears the bottom 3 bits.
> The '- 1' then sets the bottom 3 bits and decrements the
> (random) high bits.

Right.

> So is the same as get_random_u32() | 7.

True, it's effectively the same as the upper 29 bits are random
anyway and the bottom 3 bits are always set.

> But I bet the coder had something else in mind.

Likely.

And it was also likely copy/pasted a few times.
