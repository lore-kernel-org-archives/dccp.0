From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:11:17 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether
Message-Id: <20060919.131117.42457999.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:12:07 -0300

> If not enough cwnd is available, tell the sender to check again as soon as
> possible.  This will increase CPU utilization (polling frequently for cwnd) but
> will improve network performance.  That is, the sender will need to wait less
> before detecting the increase of cwnd.  A better architecture would be for the
> CCID to call-back (or dequeue) from DCCP when it is able to transmit traffic --
> not the other way around as it currently occurs.
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Applied, but this is expensive.

Consider having 100,000 DCCP sockets, some large percentage of
which are polling in this manner, it simply doesn't scale.

And if anything this return value should be jiffies_to_msecs(1) or
something like that.
