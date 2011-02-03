From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 03 Feb 2011 14:43:28 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <af0e6326c36977b0383bcac61f22b14f@localhost>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On Thu, 03 Feb 2011 15:00:28 +0100, Hagen Paul Pfeifer wrote:

> Davem, there is _no_ research how this huge IW will behave in
environments
> with a small BDP. Belief it or not, but there are networks out there
with a
> BDP similar to ~1980. Why for heaven's sake should this work in these
> environments? There are only _two_ extensive analysis one from Cherry
and

s/Cherry/Jerry/  ;-)

Hagen
