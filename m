From: 'Christoph Hellwig' <hch@lst.de>
Date: Thu, 23 Jul 2020 14:44:55 +0000
Subject: Re: [PATCH 03/26] bpfilter: reject kernel addresses
Message-Id: <20200723144455.GA12280@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-4-hch@lst.de>
In-Reply-To: <20200723060908.50081-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jul 23, 2020 at 02:42:11PM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 23 July 2020 07:09
> > 
> > The bpfilter user mode helper processes the optval address using
> > process_vm_readv.  Don't send it kernel addresses fed under
> > set_fs(KERNEL_DS) as that won't work.
> 
> What sort of operations is the bpf filter doing on the sockopt buffers?
> 
> Any attempts to reject some requests can be thwarted by a second
> application thread modifying the buffer after the bpf filter has
> checked that it allowed.
> 
> You can't do security by reading a user buffer twice.

I'm not saying that I approve of the design, but the current bpfilter
design uses process_vm_readv to access the buffer, which obviously does
not work with kernel buffers.
