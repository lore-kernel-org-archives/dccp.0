From: David Miller <davem@davemloft.net>
Date: Wed, 03 Jun 2020 17:47:25 +0000
Subject: Re: [PATCH v3] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200603.104725.187287052578354245.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200603111051.12224-1-richard_siegfried@systemli.org>
In-Reply-To: <20200603111051.12224-1-richard_siegfried@systemli.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Richard Sailer <richard_siegfried@systemli.org>
Date: Wed,  3 Jun 2020 13:10:51 +0200

> This adds support for the SIOCOUTQ IOCTL to get the send buffer fill
> of a DCCP socket, like UDP and TCP sockets already have.
> 
> Regarding the used data field: DCCP uses per packet sequence numbers,
> not per byte, so sequence numbers can't be used like in TCP. sk_wmem_queued
> is not used by DCCP and always 0, even in test on highly congested paths.
> Therefore this uses sk_wmem_alloc like in UDP.
> 
> Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
> ---
> v3: whitespace fixes

net-next is CLOSED
