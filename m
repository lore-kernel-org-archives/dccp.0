From: David Miller <davem@davemloft.net>
Date: Fri, 06 May 2011 20:04:47 +0000
Subject: Re: [PATCH] dccp: handle invalid feature options length
Message-Id: <20110506.130447.183054252.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1304688438.29544.16.camel@dan>
In-Reply-To: <1304688438.29544.16.camel@dan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 6 May 2011 21:57:33 +0200

> Quoting Dan Rosenberg:
> | A length of zero (after subtracting two for the type and len fields) for
> | the DCCPO_{CHANGE,CONFIRM}_{L,R} options will cause an underflow due to
> | the subtraction.  The subsequent code may read past the end of the
> | options value buffer when parsing.  I'm unsure of what the consequences
> | of this might be, but it's probably not good.
> | 
> Please disregard my earlier message, I erred.
> Dan is right, his patch is correct and definitively valid.
> A length of 0 would be cast to 0xff and then cause buffer overrun.
> 
> | Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> | Cc: stable@kernel.org
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Great, I'll apply this, thanks!
