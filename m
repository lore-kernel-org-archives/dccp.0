From: David Miller <davem@davemloft.net>
Date: Thu, 23 Jul 2020 00:01:12 +0000
Subject: Re: [PATCH net-next v5] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200722.170112.664348766467297694.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200720160614.117090-1-richard_siegfried@systemli.org>
In-Reply-To: <20200720160614.117090-1-richard_siegfried@systemli.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Richard Sailer <richard_siegfried@systemli.org>
Date: Mon, 20 Jul 2020 18:06:14 +0200

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
> v5: More infos into dccp.rst, +empty line after declarations

Applied, but I wonder if you'll also need something like tcp's SIOCOUTQNSD?
