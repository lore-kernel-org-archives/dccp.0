From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 27 Jul 2020 09:51:45 +0000
Subject: RE: get rid of the address_space override in setsockopt v2
Message-Id: <8ae792c27f144d4bb5cbea0c1cce4eed@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: David Miller
> Sent: 24 July 2020 23:44
> 
> From: Christoph Hellwig <hch@lst.de>
> Date: Thu, 23 Jul 2020 08:08:42 +0200
> 
> > setsockopt is the last place in architecture-independ code that still
> > uses set_fs to force the uaccess routines to operate on kernel pointers.
> >
> > This series adds a new sockptr_t type that can contained either a kernel
> > or user pointer, and which has accessors that do the right thing, and
> > then uses it for setsockopt, starting by refactoring some low-level
> > helpers and moving them over to it before finally doing the main
> > setsockopt method.
> >
> > Note that apparently the eBPF selftests do not even cover this path, so
> > the series has been tested with a testing patch that always copies the
> > data first and passes a kernel pointer.  This is something that works for
> > most common sockopts (and is something that the ePBF support relies on),
> > but unfortunately in various corner cases we either don't use the passed
> > in length, or in one case actually copy data back from setsockopt, or in
> > case of bpfilter straight out do not work with kernel pointers at all.
> >
> > Against net-next/master.
> >
> > Changes since v1:
> >  - check that users don't pass in kernel addresses
> >  - more bpfilter cleanups
> >  - cosmetic mptcp tweak
> 
> Series applied to net-next, I'm build testing and will push this out when
> that is done.

Hmmm... this code does:

int __sys_setsockopt(int fd, int level, int optname, char __user *user_optval,
		int optlen)
{
	sockptr_t optval;
	char *kernel_optval = NULL;
	int err, fput_needed;
	struct socket *sock;

	if (optlen < 0)
		return -EINVAL;

	err = init_user_sockptr(&optval, user_optval);
	if (err)
		return err;

And the called code does:
	if (copy_from_sockptr(&opt, optbuf, sizeof(opt)))
		return -EFAULT;


Which means that only the base of the user's buffer is checked
for being in userspace.

I'm sure there is code that processes options in chunks.
This probably means it is possible to put a chunk boundary
at the end of userspace and continue processing the very start
of kernel memory.

At best this faults on the kernel copy code and crashes the system.

Maybe there wasn't any code that actually incremented the user address.
But it is hardly robust.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
