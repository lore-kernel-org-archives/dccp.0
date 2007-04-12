From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 12 Apr 2007 14:39:53 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <461E44B9.5020904@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> That is one of the problems here - in the RFC such problems do not arise, but the implementation needs
> to address these correctly.

The RFC's solution to this problem, which involves t_gran, EXACTLY addresses this

> |  Your token bucket math, incidentally, is wrong.  The easiest way to see this 
> |  is to note that, according to your math, ANY token bucket filter attempting to 
> |  limit the average output rate would have to have n = 0, making TBFs useless. 
> |  The critical error is in assuming that a TBF allows "s * (n + R * rho)" bytes 
> |  to be sent in a period R.  This is not right; a TBF allows a maximum of s * R 
> |  * rho per longer-term period R; that's the point.  A token bucket filter 
> |  allows only SHORT-term bursts to compensate for earlier slow periods.  Which 
> |  is exactly what we need.
> Please take another look. The formula is correct (you will find the same one e.g in Andrew
> Tanenbaum's book). 

So I assume what you are referring to is the clause "average rate OVER ONE 
RTT"?  Sorry I missed that.  I missed it because it is not TFRC's goal.  Can 
you point to the section in RFC3448 or RFC4342 that prohibits a TFRC sender 
from ever sending a (transient) rate more than X over one RTT?  RFC3448 4.6 
allows burstiness much more than a single packet, and the intro allows 
fluctuations of up to a factor of 2 relative to the fair rate

> I think (with regard to the paragraph below) that your perspective is an entirely different one,
> namely to solve the question "which kind of token bucket do we need to obtain an a rate which
> is on average consistent with X". 

That is *TFRC's* perspective: finding packet sends that on average are 
consistent with X.  As demonstrated by 4.6 and elsewhere

How much above X may an application transiently send?  The intro would argue 2x.

> But until this is truly resolved I want this patch in.

Fine, I disagree, Ian disagrees (as far as I read its messages).  You are 
fixing one problem and creating another: artificially low send rates

Eddie
