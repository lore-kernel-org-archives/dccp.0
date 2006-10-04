From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 04 Oct 2006 16:20:10 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <4523DF3A.30102@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

Ian McDonald wrote:
> Now change s to 300 bytes we get a Xcalc of 3128 and a t_ipi of 96
> msecs. Put in ANY number for s and you will get the same t_ipi of 96
> msecs.
> 
> This illustrates my point that CCID3 is a packet per second based
> congestion control.
> 
> Now if we specify the s is 300 to the implementation we get the
> desired result, if we average it we get the correct result. However we
> can't switch to a packet based equation because if we do the spec says
> we should use s=MSS. Lets assume MSS60. Now Xcalc is 15221
> bytes/sec. t_ipi is 96 msecs. And we can send the correct rate of
> packets.

You absolutely CAN switch to a packet based equation (assuming s is fixed at 
MSS), because that packet based equation will have ENTIRELY IDENTICAL BEHAVIOR 
to the byte based equation!  Specs talk about observed behavior, that is what 
makes them specs.


> OK Now working through the example shows that my logic was wrong. I
> guess thats what defence of ideas is about - proving it and my idea
> was wrong. I apologise for wasting everybody's time!
> 
> However this does show an application can't cheat by specifying the
> wrong packet size which the spec worries about. Maybe my working
> through this helps resolve this a little...

This is not quite right.  Applications might be able to cause *transient* 
unfairness (in a purely packet-based implementation) by switching to a larger 
packet size after sending small packets for a while.  The unfairness is only 
transient because, if the app keeps sending large packets, eventually the loss 
event rate will catch up with the app's current behavior.

Personally, I do not believe this transient unfairness is a critical issue. 
Preliminary simulations showed apps didn't gain in the long run from doing 
this.  None of the current discussion has changed my mind.  Some real 
experiments could.

Eddie
