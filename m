From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 27 Jul 2020 14:09:09 +0000
Subject: RE: get rid of the address_space override in setsockopt v2
Message-Id: <5d958e937db54849b4ef9046e7e12277@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Al Viro
> Sent: 27 July 2020 14:48
> 
> On Mon, Jul 27, 2020 at 09:51:45AM +0000, David Laight wrote:
> 
> > I'm sure there is code that processes options in chunks.
> > This probably means it is possible to put a chunk boundary
> > at the end of userspace and continue processing the very start
> > of kernel memory.
> >
> > At best this faults on the kernel copy code and crashes the system.
> 
> Really?  Care to provide some details, or is it another of your "I can't
> be possibly arsed to check what I'm saying, but it stands for reason
> that..." specials?

I did more 'homework' than sometimes :-)
Slightly difficult without a searchable net-next tree.
However, as has been pointed out is a different thread
this code is used to update IPv6 flow labels:

> > -		if (copy_from_user(fl->opt+1, optval+CMSG_ALIGN(sizeof(*freq)), olen))
> > +		sockptr_advance(optval, CMSG_ALIGN(sizeof(*freq)));
> > +		if (copy_from_sockptr(fl->opt + 1, optval, olen))
> >  			goto done;

and doesn't work because the advances are no longer cumulative.

Now access_ok() has to take the base address and length to stop
'running into' kernel space, but the code above can advance from
a valid user pointer (which won't fault) to a kernel address.

If there were always an unmapped 'guard' page in the user address
space the access_ok() check prior to copy_to/from_user() wouldn't
need the length.
So I surmise that no such guard page exists and so the above
can advance from user addresses into kernel ones.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
