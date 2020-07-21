From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 21 Jul 2020 05:28:21 +0000
Subject: Re: [PATCH 02/24] bpfilter: fix up a sparse annotation
Message-Id: <20200721052821.GS2786714@ZenIV.linux.org.uk>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-3-hch@lst.de>
In-Reply-To: <20200720124737.118617-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 21, 2020 at 07:23:26AM +0200, Christoph Hellwig wrote:
> On Tue, Jul 21, 2020 at 04:40:16AM +0200, Luc Van Oostenryck wrote:
> > >  	req.pid = current->pid;
> > >  	req.cmd = optname;
> > > -	req.addr = (long __force __user)optval;
> > > +	req.addr = (__force long)optval;
> > 
> > For casts to integers, even '__force' is not needed (since integers
> > can't be dereferenced, the concept of address-space is meaningless
> > for them, so it's never useful to warn when it's dropped and
> > '__force' is thus not needed).
> 
> That's what I thought. but if I remove it here I actually do get a
> warning:
> 
> CHECK   net/bpfilter/bpfilter_kern.c
> net/bpfilter/bpfilter_kern.c:52:21: warning: cast removes address space '__user' of expression

Cast to unsigned long.  Or to uintptr_t if you want to be fancy.
