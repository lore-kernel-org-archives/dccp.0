From: David Miller <davem@davemloft.net>
Date: Wed, 27 Sep 2006 23:35:06 +0000
Subject: Re: [PATCH] CCID2: Fix format string for 64-bit quantities
Message-Id: <20060927.163506.26278321.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060926214823.GA30020@shorty.sorbonet.org>
In-Reply-To: <20060926214823.GA30020@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 26 Sep 2006 22:48:23 +0100

> Use correct format string when printing 64 bit quantities (%L instead of %ll).
> 
> Note to Arnaldo: This patch is to be applied after the 3 patches I already sent
> you.  Else, it will either apply with some fuzz, or not at all.
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

Where is "%L" defined for non-float types?  Is it supported by
all gcc versions?

The usual way to fix this it to simply cast the argument to
"long long" or "unsigned long long" and retain the format
string.

