From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:08:10 +0000
Subject: Re: [PATCH 5/10]: [DCCP] CCID2: Initialize ssthresh to infinity
Message-Id: <20060919.130810.107286118.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914171017.GF20651@mandriva.com>
In-Reply-To: <20060914171017.GF20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:10:18 -0300

> Initialize the slow-start threshold to infinity.  This way, upon
> connection initiation, slow-start will be exited only upon a packet
> loss.  This patch will allow connections to quickly gain speed.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Applied.

In the future perhaps the discovered packet loss point should be
remembered in a routing metric and used as the slow start
threshold on future connections or something like that.
