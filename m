From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Feb 2007 01:20:54 +0000
Subject: Re: RFC 4342 Erratum: use Request/Response RTT
Message-Id: <45CA7AF6.7050702@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,

I don't actually completely understand where you're coming from.  The initial 
send rate is not 1 packet per second, it is 2-4 packets per RTT, as per 
RFC4342.  So the initial t_ipi is going to be s/X, where X = 2-4 packets per RTT.

If you follow the logic through RFC3448 4.2-4.4, you will see that due to this 
line,

              If (t_now - tld >= R)
                  X = max(min(2*X, 2*X_recv), s/R);
                  tld = t_now;

(where tld is initialized to -1 as regards section 4.2), the sending rate X 
becomes 1 packet/RTT (= s/R) as soon as a round-trip time sample is available. 
  The erratum allows the implementer to sidestep all of this silliness by 
simply starting at X = 2-4 packets/RTT, since the RTT sample is available 
immediately.

Eddie


Gerrit Renker wrote:
> Hi Eddie,
> 
> following a discussion with Ian, it became clear that the best way to fix
> some of the outstanding scheduling problems is to implement the Erratum to
> RFC 4342 and use the initial Request/Response handshake as basis for calculating t_ipi.
> 
> I am referring to this posting (sorry the original was no longer in the inbox):
>  http://www.mail-archive.com/dccp@vger.kernel.org/msg01319.html
> 
> and was using the RFC 4340/2 erratum page:
>  http://www.read.cs.ucla.edu/dccp/rfc4340errata
> 
> Now, having spent almost half a day to come up with a solution for initial RTT
> estimates, I found that there are still several things open/unclear:
> 
>  * RFC 3448, 4.2 specifies an initial sending rate of 1 packet per second
>  * RFC 3448, 4.6 specifies t_ipi = s/X => still gives 1 second
>  * I can't find an override-clause in RFC 4342 for this
> 
> Question: Is the aim to use section 4.2 of RFC 3448 and if yes, to what extent 
>           (this section has quite a few changes to other parts of the algorithm, too).
> 
> Can you please clarify, maybe I have got the wrong erratum. 
> 
> It would be good to have this clear - so as to implement it.
> 
> 
> Gerrit
