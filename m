From: 'Christoph Hellwig' <hch@lst.de>
Date: Wed, 22 Jul 2020 08:07:24 +0000
Subject: Re: get rid of the address_space override in setsockopt
Message-Id: <20200722080724.GB26864@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 21, 2020 at 10:26:58AM +0000, David Laight wrote:
> From: Christoph Hellwig
> > Sent: 20 July 2020 13:47
> > 
> > setsockopt is the last place in architecture-independ code that still
> > uses set_fs to force the uaccess routines to operate on kernel pointers.
> > 
> > This series adds a new sockptr_t type that can contained either a kernel
> > or user pointer, and which has accessors that do the right thing, and
> > then uses it for setsockopt, starting by refactoring some low-level
> > helpers and moving them over to it before finally doing the main
> > setsockopt method.
> 
> Another 'gotcha' ...
> 
> On an least some architectures (possibly only m68k) IIRC all structures
> are actually passed by reference.
> (This used to be true for sparc - but it may have changed in the
> last 30 years.)

Tough luck for ABIs wit suboptimal calling conventions.  At least we can
do the right thing for those that do not have the problem.
