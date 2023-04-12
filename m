From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 12 Apr 2023 14:28:41 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <6436c01979c9b_163b6294b4@willemb.c.googlers.com.notmuch>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Breno Leitao wrote:
> On Tue, Apr 11, 2023 at 09:28:29AM -0600, Jens Axboe wrote:
> > On 4/11/23 9:24?AM, Willem de Bruijn wrote:
> > > Jens Axboe wrote:
> > >> On 4/11/23 9:00?AM, Willem de Bruijn wrote:
> > >> But that doesn't work, because sock->ops->ioctl() assumes the arg is
> > >> memory in userspace. Or do you mean change all of the sock->ops->ioctl()
> > >> to pass in on-stack memory (or similar) and have it work with a kernel
> > >> address?
> > > 
> > > That was what I suggested indeed.
> > > 
> > > It's about as much code change as this patch series. But it avoids
> > > the code duplication.
> > 
> > Breno, want to tackle that as a prep patch first? Should make the
> > functional changes afterwards much more straightforward, and will allow
> > support for anything really.
> 
> Absolutely. I just want to make sure that I got the proper approach that
> we agreed here.
> 
> Let me explain what I understood taking TCP as an example:
> 
> 1) Rename tcp_ioctl() to something as _tcp_ioctl() where the 'arg'
> argument is now just a kernel memory (located in the stack frame from the
> callee).
> 
> 2) Recreate "tcp_ioctl()" that will basically allocate a 'arg' in the
> stack and call _tcp_ioctl() passing that 'arg' argument. At the bottom of
> this (tcp_ioctl() function) function, call `put_user(in_kernel_arg, userspace_arg)
> 
> 3) Repeat it for the 20 protocols that implement ioctl:
> 
> 	ag  "struct proto .* = {" -A 20 net/ | grep \.ioctl
> 	net/dccp/ipv6.c 	.ioctl	= dccp_ioctl,
> 	net/dccp/ipv4.c		.ioctl	= dccp_ioctl,
> 	net/ieee802154/socket.c .ioctl	= dgram_ioctl,
> 	net/ipv4/udplite.c	.ioctl	= udp_ioctl,
> 	net/ipv4/raw.c 		.ioctl	= raw_ioctl,
> 	net/ipv4/udp.c		.ioctl	= udp_ioctl,
> 	net/ipv4/tcp_ipv4.c 	.ioctl	= tcp_ioctl,
> 	net/ipv6/raw.c		.ioctl	= rawv6_ioctl,
> 	net/ipv6/tcp_ipv6.c	.ioctl	= tcp_ioctl,
> 	net/ipv6/udp.c	 	.ioctl	= udp_ioctl,
> 	net/ipv6/udplite.c	.ioctl	= udp_ioctl,
> 	net/l2tp/l2tp_ip6.c	.ioctl	= l2tp_ioctl,
> 	net/l2tp/l2tp_ip.c	.ioctl	= l2tp_ioctl,
> 	net/phonet/datagram.:	.ioctl	= pn_ioctl,
> 	net/phonet/pep.c	.ioctl	= pep_ioctl,
> 	net/rds/af_rds.c	.ioctl	=	rds_ioctl,
> 	net/sctp/socket.c	.ioctl  =	sctp_ioctl,
> 	net/sctp/socket.c	.ioctl	= sctp_ioctl,
> 	net/xdp/xsk.c		.ioctl	= sock_no_ioctl,
> 	net/mptcp/protocol.c	.ioctl	= mptcp_ioctl,
> 
> Am I missing something?

The suggestion is to convert all to take kernel memory and do the
put_cmsg in the caller of .ioctl. Rather than create a wrapper for
each individual instance and add a separate .iouring_cmd for each.

"change all of the sock->ops->ioctl() to pass in on-stack memory
(or similar) and have it work with a kernel address"
