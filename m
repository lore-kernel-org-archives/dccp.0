From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 23 Jul 2020 14:56:33 +0000
Subject: RE: [PATCH 03/26] bpfilter: reject kernel addresses
Message-Id: <5fc6b1716f1b4534bda95bab49512754@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-4-hch@lst.de>
In-Reply-To: <20200723060908.50081-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: 'Christoph Hellwig'
> Sent: 23 July 2020 15:45
> 
> On Thu, Jul 23, 2020 at 02:42:11PM +0000, David Laight wrote:
> > From: Christoph Hellwig
> > > Sent: 23 July 2020 07:09
> > >
> > > The bpfilter user mode helper processes the optval address using
> > > process_vm_readv.  Don't send it kernel addresses fed under
> > > set_fs(KERNEL_DS) as that won't work.
> >
> > What sort of operations is the bpf filter doing on the sockopt buffers?
> >
> > Any attempts to reject some requests can be thwarted by a second
> > application thread modifying the buffer after the bpf filter has
> > checked that it allowed.
> >
> > You can't do security by reading a user buffer twice.
> 
> I'm not saying that I approve of the design, but the current bpfilter
> design uses process_vm_readv to access the buffer, which obviously does
> not work with kernel buffers.

Is this a different bit of bpf that that which used to directly
intercept setsockopt() requests and pass them down from a kernel buffer?

I can't held feeling that bpf is getting 'too big for its boots' and
will have a local-user privilege escalation hiding in it somewhere.

I've had to fix my 'out of tree' driver to remove the [sg]etsockopt()
calls. Some of the replacements will go badly wrong if I've accidentally
lost track of the socket type.
I do have a daemon process sleeping in the driver - so I can wake it up
and make the requests from it with a user buffer.
I may have to implement that to get the negotiated number of 'ostreams'
to an SCTP connection.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
