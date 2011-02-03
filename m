From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 03 Feb 2011 14:00:28 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On Wed, 02 Feb 2011 17:07:50 -0800 (PST), David Miller wrote:

> +/* TCP initial congestion window */
> +#define TCP_INIT_CWND		10
> +

Davem, there is _no_ research how this huge IW will behave in environments
with a small BDP. Belief it or not, but there are networks out there with a
BDP similar to ~1980. Why for heaven's sake should this work in these
environments? There are only _two_ extensive analysis one from Cherry and
and one from Ilpo. Both analysis focus on current mainstream BDP. I started
to setup a ns-2 environment but due to lack of time I am a little bit
behind schedule. Anyway, why not make this a tunable per route knob so that
it is easier to fix things, e.g. set IW back to 3.

HGN
