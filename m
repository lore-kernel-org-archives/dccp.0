From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:15:01 +0000
Subject: Re: [PATCH 9/10]: [DCCP] CCID2: Halve cwnd once upon multiple
Message-Id: <20060919.131501.66804561.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914171408.GK20651@mandriva.com>
In-Reply-To: <20060914171408.GK20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:14:11 -0300

> When multiple losses occur in one RTT, the window should be halved only once [a
> single "congestion event"].  This is now implemented, although not perfectly.
> Slightly changed the interface for changing the cwnd: pass hctx instead of dp.
> This is required in order to allow for change_cwnd to be called from _init().
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

More trailing whitespace, GRRR!

Applied, thanks.

