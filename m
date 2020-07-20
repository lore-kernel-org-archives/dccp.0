From: Eric Biggers <ebiggers@kernel.org>
Date: Mon, 20 Jul 2020 16:37:48 +0000
Subject: Re: [PATCH 03/24] net: add a new sockptr_t type
Message-Id: <20200720163748.GA1292162@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-4-hch@lst.de>
In-Reply-To: <20200720124737.118617-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 20, 2020 at 02:47:16PM +0200, Christoph Hellwig wrote:
> Add a uptr_t type that can hold a pointer to either a user or kernel
> memory region, and simply helpers to copy to and from it.  For
> architectures like x86 that have non-overlapping user and kernel
> address space it just is a union and uses a TASK_SIZE check to
> select the proper copy routine.  For architectures with overlapping
> address spaces a flag to indicate the address space is used instead.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/sockptr.h | 121 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 121 insertions(+)
>  create mode 100644 include/linux/sockptr.h
> 
> diff --git a/include/linux/sockptr.h b/include/linux/sockptr.h
> new file mode 100644
> index 00000000000000..e41dfa52555dec
> --- /dev/null
> +++ b/include/linux/sockptr.h
> @@ -0,0 +1,121 @@
> +/* SPDX-License-Identifier: GPL-2.0-only */
> +/*
> + * Copyright (c) 2020 Christoph Hellwig.
> + *
> + * Support for "universal" pointers that can point to either kernel or userspace
> + * memory.
> + */
> +#ifndef _LINUX_SOCKPTR_H
> +#define _LINUX_SOCKPTR_H
> +
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +
> +#ifdef CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE
> +typedef union {
> +	void		*kernel;
> +	void __user	*user;
> +} sockptr_t;
> +
> +static inline bool sockptr_is_kernel(sockptr_t sockptr)
> +{
> +	return (unsigned long)sockptr.kernel >= TASK_SIZE;
> +}
> +
> +static inline sockptr_t KERNEL_SOCKPTR(void *p)
> +{
> +	return (sockptr_t) { .kernel = p };
> +}
> +#else /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
> +typedef struct {
> +	union {
> +		void		*kernel;
> +		void __user	*user;
> +	};
> +	bool		is_kernel : 1;
> +} sockptr_t;
> +
> +static inline bool sockptr_is_kernel(sockptr_t sockptr)
> +{
> +	return sockptr.is_kernel;
> +}
> +
> +static inline sockptr_t KERNEL_SOCKPTR(void *p)
> +{
> +	return (sockptr_t) { .kernel = p, .is_kernel = true };
> +}
> +#endif /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
> +
> +static inline sockptr_t USER_SOCKPTR(void __user *p)
> +{
> +	return (sockptr_t) { .user = p };
> +}
> +
> +static inline bool sockptr_is_null(sockptr_t sockptr)
> +{
> +	return !sockptr.user && !sockptr.kernel;
> +}
> +
> +static inline int copy_from_sockptr(void *dst, sockptr_t src, size_t size)
> +{
> +	if (!sockptr_is_kernel(src))
> +		return copy_from_user(dst, src.user, size);
> +	memcpy(dst, src.kernel, size);
> +	return 0;
> +}

How does this not introduce a massive security hole when
CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE?

AFAICS, userspace can pass in a pointer >= TASK_SIZE,
and this code makes it be treated as a kernel pointer.

- Eric
