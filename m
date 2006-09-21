From: Gorry Fairhurst <gorry@erg.abdn.ac.uk>
Date: Thu, 21 Sep 2006 16:19:40 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <C1387A2C.5DDF%gorry@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Let, me add a few more thoughts, and see what others think...

* I also have a problem with how to find "s" when thinking about an
"unknown" application. I'm not really sure how this is intended to work for
variable-sized packets. Calculating an average value for an application that
naturally varies the size doesn't seem to me to be straight-forward.

One value of "s" that makes sense, is possibly the largest segment size sent
by the session. This is at least conservative - for fixed-sized flows it is
identical to the optimum "s". For bursty flows, it is safe.

* The second part to your question seems to suggest a different method for
finding a safe transmission rate. That's something that has been interesting
us too, and is worthy of more thought.

Gorry 

On 21/9/06 04:22, "Ian McDonald" <ian.mcdonald@jandi.co.nz> wrote:

> I have been discussing the packet size s for CCID3 (TFRC) with my
> supervisor and also been discussing related issues with Gerrit and I
> am wondering why we have this?
> 
> CCID3 is datagram based and the whole point of s is to keep packets at
> a certain rate per second. In effect provided s is calculated
> correctly it cancels out of the equation but it becomes more
> complicated in the code! If it is miscalculated (accidentally or
> deliberately) it becomes worse because you are either starved or send
> too much.
> 
> Why not just calculate a packet rate per second? Or am I missing
> something obvious?
> 
> I'm looking to apply this in other areas of implementation as well -
> for example packet buffering in TCP is traditional done with a limit
> of bytes where DCCP would make more sense to limit this on number of
> packets - and the code would be much easier too.
> 
> Calculating on packets per second also has the effect that it is
> visible to application designers potentially who will put more data in
> a datagram to increase throughput.
> 
> Comments?
> 
> Regards,
> 
> Ian


