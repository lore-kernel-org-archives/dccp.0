From: David Miller <davem@davemloft.net>
Date: Mon, 15 Mar 2010 23:07:04 +0000
Subject: Re: net-2.6 [Bug-Fix][dccp]: fix oops caused after failed
Message-Id: <20100315.160704.112076366.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20100315061318.GA6110@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20100315061318.GA6110@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Mar 2010 07:13:19 +0100

> dccp: fix panic caused by failed initialisation
> 
> This fixes a kernel panic reported thanks to Andre Noll:
> 
> if DCCP is compiled into the kernel and any out of the initialisation
> steps in net/dccp/proto.c:dccp_init() fail, a subsequent attempt to create
> a SOCK_DCCP socket will panic, since inet{,6}_create() are not prevented
> from creating DCCP sockets.
> 
> This patch fixes the problem by propagating a failure in dccp_init() to
> dccp_v{4,6}_init_net(), and from there to dccp_v{4,6}_init(), so that the
> DCCP protocol is not made available if its initialisation fails.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks Gerrit.
