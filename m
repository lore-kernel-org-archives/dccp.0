From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 17 Nov 2006 17:20:30 +0000
Subject: Re: [PATCH 0/7]:  message scheme tidy-up, tx_qlen, documentation
Message-Id: <20061117172029.GL17958@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200611171556.51081@strip-the-willow>
In-Reply-To: <200611171556.51081@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Nov 17, 2006 at 03:56:50PM +0000, Gerrit Renker wrote:
> This includes mostly Ian's tx_qlen patch, the promised tidy-up of the WARN/BUG
> message scheme, and some trivial things.
> 
> 
> Patch 1: This is Ian's tx_qlen updated tx_qlen patch.
>          I have removed the #define again (and was the one who suggested it);
>          it seemed not to be a good idea after all (looking at net/dccp/dccp.h).
> 
> 
> Patch 2: Adds the missing simplifications which were dropped somewhere inbetween
>          trying with and without using enum:8 for CCID 3 states. With that in place,
>          many conditions can be simplified, as is now done.
> 
> 
> The remaining patches are very trivial and have not been sent as a single patch
> in order to make the changes more clear when just reading through these. 
> 
> 
> 
> Patch 3: Implements a consistent set of WARN/BUG messages as per list discussion.

I only got patches 1 thru 3, any problems?

Gerrit, the "cherry-picking phase" is mostly over, your csets so far
have been of great quality, so could you please consider using git so
that I could just do a git-pull?

- Arnaldo
