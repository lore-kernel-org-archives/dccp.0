From: David Miller <davem@davemloft.net>
Date: Mon, 31 May 2010 07:31:09 +0000
Subject: Re: [PATCH 22/27] net/dccp: Use memdup_user
Message-Id: <20100531.003109.260112093.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 22 May 2010 10:25:19 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Use memdup_user when user data is immediately copied into the
> allocated region.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
