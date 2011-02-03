From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 03 Feb 2011 14:26:03 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <1b6ae8e6f5a57cf75b434f55911fd09b@localhost>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On Thu, 3 Feb 2011 09:17:14 -0500, John Heffner wrote:

> There's already a per-route tunable, right (RTAX_INITCWND)?

Yes, __u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);

I was a little bit nervous ... ;)

HGN
