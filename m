From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 21 Jul 2020 09:38:23 +0000
Subject: RE: get rid of the address_space override in setsockopt
Message-Id: <60c52e31e9f240718fcda0dd5c2faeca@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig
> Sent: 20 July 2020 13:47
>
> setsockopt is the last place in architecture-independ code that still
> uses set_fs to force the uaccess routines to operate on kernel pointers.
> 
> This series adds a new sockptr_t type that can contained either a kernel
> or user pointer, and which has accessors that do the right thing, and
> then uses it for setsockopt, starting by refactoring some low-level
> helpers and moving them over to it before finally doing the main
> setsockopt method.

Are you planning to make the equivalent change to getsockopt()?
Having mismatched interfaces would be very strange.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
