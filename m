From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 12 Oct 2022 21:29:02 +0000
Subject: RE: [PATCH v1 3/5] treewide: use get_random_u32() when possible
Message-Id: <d45bd258e033453b85a137112e7694e1@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
In-Reply-To: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Joe Perches
> Sent: 12 October 2022 20:17
> 
> On Wed, 2022-10-05 at 23:48 +0200, Jason A. Donenfeld wrote:
> > The prandom_u32() function has been a deprecated inline wrapper around
> > get_random_u32() for several releases now, and compiles down to the
> > exact same code. Replace the deprecated wrapper with a direct call to
> > the real function.
> []
> > diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
> []
> > @@ -734,7 +734,7 @@ static int send_connect(struct c4iw_ep *ep)
> >  				   &ep->com.remote_addr;
> >  	int ret;
> >  	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
> > -	u32 isn = (prandom_u32() & ~7UL) - 1;
> > +	u32 isn = (get_random_u32() & ~7UL) - 1;
> 
> trivia:
> 
> There are somewhat odd size mismatches here.
> 
> I had to think a tiny bit if random() returned a value from 0 to 7
> and was promoted to a 64 bit value then truncated to 32 bit.
> 
> Perhaps these would be clearer as ~7U and not ~7UL

That makes no difference - the compiler will generate the same code.

The real question is WTF is the code doing?
The '& ~7u' clears the bottom 3 bits.
The '- 1' then sets the bottom 3 bits and decrements the
(random) high bits.

So is the same as get_random_u32() | 7.
But I bet the coder had something else in mind.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
