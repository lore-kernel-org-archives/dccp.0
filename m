From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 19 Jan 2007 15:07:30 +0000
Subject: RFC 4342 Erratum: use Request/Response RTT
Message-Id: <200701191507.31045@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

following a discussion with Ian, it became clear that the best way to fix
some of the outstanding scheduling problems is to implement the Erratum to
RFC 4342 and use the initial Request/Response handshake as basis for calculating t_ipi.

I am referring to this posting (sorry the original was no longer in the inbox):
 http://www.mail-archive.com/dccp@vger.kernel.org/msg01319.html

and was using the RFC 4340/2 erratum page:
 http://www.read.cs.ucla.edu/dccp/rfc4340errata

Now, having spent almost half a day to come up with a solution for initial RTT
estimates, I found that there are still several things open/unclear:

 * RFC 3448, 4.2 specifies an initial sending rate of 1 packet per second
 * RFC 3448, 4.6 specifies t_ipi = s/X => still gives 1 second
 * I can't find an override-clause in RFC 4342 for this

Question: Is the aim to use section 4.2 of RFC 3448 and if yes, to what extent 
          (this section has quite a few changes to other parts of the algorithm, too).

Can you please clarify, maybe I have got the wrong erratum. 

It would be good to have this clear - so as to implement it.


Gerrit
