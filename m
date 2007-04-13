From: David Miller <davem@davemloft.net>
Date: Fri, 13 Apr 2007 20:54:28 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <20070413.135428.78483878.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 21:27:54 +0100

> I wished someone could tell me that. Ian is right, the formula is used
> after the first loss, but the idea is that the sender `overshoots' and then
> reduces after the first loss due to overestimating the bandwidth.
> 
> So it would try to see the pipe as 20Gbit, experience some loss, and then
> reduce proportionally to RTT and f(p). 
> 
> We have more problems of the same nature as with using interface timestamps.
> 
> I am really not sure that CCID3 can be implemented well without a lot of
> real-time and system load requirements - if you have any suggestions or
> know of similar problem areas, input would be very welcome.

I wonder what a DCCP implementation on old BSD would do with it's
super-coarse timers :-)

Perhaps the algorithm can get tweaked such that, just like TCP, we
lower bound the RTT and for RTTs seen at or below that minimum we do
not do the sender rate capping.

In this sense coarseness of timers actually helps weed out the
noise of scheduling, the queue that exists between the network
link and the driver actually feeding packets to the stack, etc.

Because I sense that even with the global timestamping, the same
problem will reoccur during high forwarding loads where one network
card competes with another in the NAPI poll processing loops.

So my primary suggstion is to accept that there is a limit to
how accurate you can get timestamps, there is also a specific
regime under which fine-RTT measurements matter, and therefore
the algorithm chosen has to match that reality.
