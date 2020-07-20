From: Eric Biggers <ebiggers@kernel.org>
Date: Mon, 20 Jul 2020 17:55:43 +0000
Subject: Re: [PATCH 03/24] net: add a new sockptr_t type
Message-Id: <20200720175543.GF1292162@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-4-hch@lst.de>
In-Reply-To: <20200720124737.118617-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 20, 2020 at 07:43:22PM +0200, Christoph Hellwig wrote:
> On Mon, Jul 20, 2020 at 09:37:48AM -0700, Eric Biggers wrote:
> > How does this not introduce a massive security hole when
> > CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE?
> > 
> > AFAICS, userspace can pass in a pointer >= TASK_SIZE,
> > and this code makes it be treated as a kernel pointer.
> 
> Yeah, we'll need to validate that before initializing the pointer.
> 
> But thinking this a little further:  doesn't this mean any
> set_fs(KERNEL_DS) that has other user pointers than the one it is
> intended for has the same issue?  Pretty much all of these are gone
> in mainline now, but in older stable kernels there might be some
> interesting cases, especially in the compat ioctl handlers.

Yes.  I thought that eliminating that class of bug is one of the main
motivations for your "remove set_fs" work.  See commit 128394eff343
("sg_write()/bsg_write() is not fit to be called under KERNEL_DS") for a case
where this type of bug was fixed.

Are you aware of any specific cases that weren't already fixed?  If there are
any, they need to be urgently fixed.

- Eric
