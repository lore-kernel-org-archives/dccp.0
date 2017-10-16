From: David Miller <davem@davemloft.net>
Date: Mon, 16 Oct 2017 20:15:47 +0000
Subject: Re: [PATCH] net: dccp: mark expected switch fall-throughs
Message-Id: <20171016.211547.1957282103530139102.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20171015182210.GA13849@embeddedor.com>
In-Reply-To: <20171015182210.GA13849@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sun, 15 Oct 2017 13:22:10 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Notice that for options.c file, I placed the "fall through" comment
> on its own line, which is what GCC is expecting to find.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next.
