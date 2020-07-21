From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 21 Jul 2020 10:14:20 +0000
Subject: RE: [PATCH 03/24] net: add a new sockptr_t type
Message-Id: <6727969f2f6e467fa2d43f9773cefa27@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-4-hch@lst.de>
In-Reply-To: <20200720124737.118617-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig
> Sent: 20 July 2020 13:47
> 
> Add a uptr_t type that can hold a pointer to either a user or kernel
> memory region, and simply helpers to copy to and from it.  For
> architectures like x86 that have non-overlapping user and kernel
> address space it just is a union and uses a TASK_SIZE check to
> select the proper copy routine.  For architectures with overlapping
> address spaces a flag to indicate the address space is used instead.
> 
...
> +#else /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
> +typedef struct {
> +	union {
> +		void		*kernel;
> +		void __user	*user;
> +	};
> +	bool		is_kernel : 1;
> +} sockptr_t;

If you need to do that you might as well make it a struct
where either the kernel or user address is defined.
Far safer for all architectures.

Indeed you could add the length (to save passing an
extra parameter through the layers).

The system call code could even copy the code into a
kernel buffer (setting both pointers).
So that code that didn't need to access beyond the end
of the implied buffer (most of it) could just access the
kernel buffer.

For getsockopt() you'd need some way of supressing the
'default' copy back of the user buffer.

This would also allow some of the sctp getsockopt to
read (usually 4 bytes) from the 'user' buffer without
the wrapper code always having to read in the entire
user buffer.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
