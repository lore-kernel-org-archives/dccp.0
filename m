From: Gorry Fairhurst <gorry@erg.abdn.ac.uk>
Date: Tue, 26 Sep 2006 12:19:47 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <45191AE3.2020701@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eddie Kohler wrote:

>> It is actually the opposite of what you say here. If you do the maths
>> and set s large then you can send more packets per second than what
>> you should be able to.
> 
> 
> While this is true, note that the draft explicitly allows 
> implementations to use the maximum segment size (i.e. the largest value 
> possible) for s!  So we are not THAT concerned about this kind of lying.
> 
> The bad case would be using one value of "s" to calculate "X", and then 
> using a DIFFERENT value of "s" to calculate the packet rate from "X".  
> As long as the same value of "s" is used to calculate "X" and to 
> calculate the packet rate from "X", the "s"s cancel out, as Ian points 
> out.  For mostly-fixed-size applications, no problem; the network will 
> provide whatever feedback is appropriate.
> 
> Why do we have "s" at all?  "s" helps account for applications that vary 
> their packet size over the long term.  E.g., 20 RTT of packet size X, 
> alternating with 20 RTT of packet size 3X.  We do not have simulations 
> demonstrating what affect an incorrect "s" value would have in such a 
> situation.  It would be interesting to see some data.
> 
> As Sally points out as well, the draft explicitly allows implementations 
> to cancel out the "s" (by assuming s=MSS), calculating rates in packets 
> per second only.
> 
> Eddie
> 
> 

That is consistent with my understanding.]

Thanks,

Gorry

P.S. I'm going through the TFRC-SP I-D in detail just now (with my WG 
Chair hat on).
