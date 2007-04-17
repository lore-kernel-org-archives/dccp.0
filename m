From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 17 Apr 2007 11:07:40 +0000
Subject: Re: RTT measurement, CCID3 implementability
Message-Id: <200704171207.40680@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <46229A62.9010805@cs.ucla.edu>
In-Reply-To: <46229A62.9010805@cs.ucla.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  - The DCCP specification does not require RTT measurements on every packet 
|  exchange.
|  
|  - It should be possible to use coarse grained timestamps (even jiffies) for 
|  most packets, with finer grained timestamps used on occasion, to improve the 
|  current estimate; for example, getting the time of day once per RTT.
This is not easily possible without at the same time revising the spec. If you e.g.
allow jiffie-based round-trip times, then you will need to set the minimum RTT value
to 1 jiffie, since otherwise divide-by-zero will be likely.

A further complication of jiffies is that the algorithm will have to work even when 
some unsuspecting user selects HZ0. That however makes the error in RTT measurement 
unbearably large - 10 milliseconds is in the order of a WAN connection within the same
country (see Perkin's slides below).


|  - Gerrit has come to strong conclusions about the "implementability" of CCID3. 
|    The evidence is supposedly here:
|  
|  http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/packet_scheduling/
|  http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/impact_of_tx_queue_lenghts/
|
You are mis-quoting. There is nothing in the pages about implementability of CCID3.

The pages show merely that with the given specification and given scheduling the present 
implementation operates like a non-congestion controlled raw socket above ca. 12 Mbits/sec. 

Which means that on 100Mbit ethernet it is 88% useless; on Gigabit ethernet it is 98.8% useless. 

Furthermore, isolating these measurements by insinuating that they must be somehow wrong is not 
really a good idea: you will meet the same problems in the user-space implementation of TFRC by 
Perkins et al ( http://www3.ietf.org/proceedings/06jul/slides/dccp-13.pdf ):
 
 * "Difficult to accurately schedule packets" (page 5)

 * "Timing inaccuracy in sender and receiver poses a _significant_ challenge to stable
    TFRC implementation" (page 6)

 * again the problem with shorter RTTs:
   "Have found stability difficult to achieve with RTT < 10-20 ms" (page 8)

 => The joke is on page 9 which assumes that a "Kernel implementation of TFRC is likely
    more accurate" :)


|  It's worth looking at these pages once again; the conclusions are far from the 
|  evidence.  A subset of strategies that have not been considered:
You are free to conduct your own measurements.

  
|     = Other methods of scheduling packet transmissions at sub-timer 
|  granularity, other than hrtimers.  For example, in response to ack arrival 
|  (would be helpful at low RTTs, where acks arrive quickly; in fact, if this was 
|  helpful, one might even have the CCID3 receiver send more acks than the 
|  minimum required by the spec).  Or in a kernel tasklet that might be scheduled 
|  only when a DCCP connection wants to send at high rates.
|
These may work, but would require further experimentation and testing; meaning
probably multiple experimental code revisions.  

  
|  Many of these have been mentioned at least once in previous emails, and 
|  summarily dismissed.  Time will tell.  It took months for "use the 
|  request/response exchange for an RTT measurement" to filter into the 
|  implementation, whereupon it was, as a predicted, a useful simplification.
Again the quoting is not fair. The "use the request/response exchange for an RTT measurement"
came up when a patch had just been completed to achieve compliance with existing
RFC 3448/4342. At that instance, the erratum suddenly came up, obsoleting the patch:
http://www.mail-archive.com/dccp@vger.kernel.org/msg00848.html

It is not that the erratum is bad, but it shows the whole point - the protocol
is not momentarily implementable -at least here- as if it were in a recipe book. 

There were other occurrences where the specification changes overtook the code.

It may be wiser and time-saving to move it to an experimental tree, concentrate fully on 
the outstanding issues, before submitting a half-finished implementation to the stable 
mainline kernel. This would also increase your freedom to experiment and test.

  
|  - On 4 October 2006 I sent mail to the other DCCP coauthors wondering whether 
|  "a rate as the basic unit of congestion control ...is just too much of a pain 
|  in the ass to implement".  We will keep thinking about this, and there are 
|  alternatives to rate-based CC.  As yet it is too early to tell. 
Thanks for sharing that with us so early.


|  On the other hand, had we been implementing a modern TCP, I bet Gerrit would declare 
|  TCP  unimplementable.
How about a bit more fairness in your argumentation, Dr. Kohler :)
