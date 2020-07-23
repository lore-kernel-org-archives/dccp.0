From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 23 Jul 2020 14:42:11 +0000
Subject: RE: [PATCH 03/26] bpfilter: reject kernel addresses
Message-Id: <c3dc5b4d84e64230bb6ca8df7bb70705@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-4-hch@lst.de>
In-Reply-To: <20200723060908.50081-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig
> Sent: 23 July 2020 07:09
> 
> The bpfilter user mode helper processes the optval address using
> process_vm_readv.  Don't send it kernel addresses fed under
> set_fs(KERNEL_DS) as that won't work.

What sort of operations is the bpf filter doing on the sockopt buffers?

Any attempts to reject some requests can be thwarted by a second
application thread modifying the buffer after the bpf filter has
checked that it allowed.

You can't do security by reading a user buffer twice.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
