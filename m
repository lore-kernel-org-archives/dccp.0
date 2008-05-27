From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:25:36 +0000
Subject: Re: [PATCH 2/7] [CCID-2]: Remove ccid2hc{tx,rx}_ prefixes
Message-Id: <20080527.062536.64095383.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:42 +0100

> This patch fixes two problems caused by the ubiquitous long "hctx->ccid2htx_"
> and "hcrx->ccid2hcrx_" prefixes:
>  * code becomes hard to read;
>  * multiple-line statements are almost inevitable even for simple expressions;
> The prefixes are not really necessary (compare with "struct tcp_sock").
> 
> There had been previous discussion of this on dccp@vger, but so far this was
> not followed up (most people agreed that the prefixes are too long).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Leandro Melo de Sales <leandroal@gmail.com>

You're the dccp maintainer, but...

The whole reason we use these member prefixes is so that the
tree is actually greppable.  tcp_sock is the way it is because
we never enforced this useful policy back when it was originally
created.

If you use short member names, it becomes eventually impossible
to grep for "->foo" and have it not match a ton of crap you
are completely not interested in.  Using a prefix creates a
struct member namespace, and thus fixes that problem.

Use editor macros if you don't want to type so much :-)

