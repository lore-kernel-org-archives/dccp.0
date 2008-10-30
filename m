From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 30 Oct 2008 18:20:31 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Message-Id: <4909FAEF.8040900@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> | This trivial patch allows qpolicies to be moved to userspace as demonstrated 
> | by attached C# code (requires mono). This way userspace-kernelspace interface 
> | is dead simple allowing for quite a lot flexibility in designing the way 
> | packet buffer is organized.
>  
> 
> | The basic idea is that we set send buffer size so that only one packet fits in 
> | it. Sending second packet while first is inside buffer (has not been sent 
> | yet) causes send() to block until ccid allows the first packet to be 'send'. 
> One difficulty that I see is what to do when the send socket is non-blocking.
> 
But socket doesn't get into non-blocking mode until specifically 
requested by fcntl(soc, F_SETFL, O_NONBLOCK) call, does it?

> | For each real packet we call send() twice: one 'fake' (will be discarded just 
> | before sending) and one 'real' (contains user data). This makes all the 
> | waiting to be done on the 'fake' packet making sending the real one really 
> | fast. This allows for late data choice without difficult to implement ring 
> | buffers shared by user and kernel space or complicated qpolicies code on 
> | kernel side.
> Maybe purists will not like this since the complexity is now shifted to the
> user-kernel interface. But it may well be a start to develop some kind of
> new interface which achieves the same in a cleaner way.
> 
I think that much of the previously written qpolicy code could be 
removed from the kernel so the interface would be really simple. No 
policy switching, no fancy parameters, etc. The only difference from 
standard interface would be that a packet could have a 'drop me' flag 
(priority 65 in my code). Ok, I agree some may consider it tricky but I 
wouldn't call it complicated. The complicated part is meant to be on the 
userspace side. And that in my opinion has many advantages: easier 
debugging, easier to add new (possibly complex) queuing policies.

> | Results on CCID2 are very promising (near ideal), but CCID3 is somewhat 
> | disappointing to the extent I'm starting to think that I'm doing something 
> | seriously wrong while testing it.
> | 
> Can you please narrow down what is happening with CCID-3.  CCID-3 is very
> complicated and sensitive, so it is possible that the problem is within
> CCID-3 and not the qpolicy code - need more detailed information.
> 
On one test it seemed not to work at all in my setup: ccid3 seems not to 
limit traffic at all. But that was just one test so it may well be my fault.

> If a stable interface evolves out of this development work, it would be
> great to integrate it with the existing (C flat) code
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#DCCP_Library
> 
Good point, thanks.


