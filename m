From: David Miller <davem@davemloft.net>
Date: Fri, 13 Apr 2007 20:58:16 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <20070413.135816.43860951.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 13 Apr 2007 13:37:57 -0700

> Gerrit.  I know the implementation is broken for high rates.  But you are 
> saying that it is impossible to implement CCID3 congestion control at high 
> rates.  I am not convinced.  Among other things, CCID3's t_gran section gives 
> the implementation EXACTLY the flexibility required to smoothly transition 
> from a purely rate-based, packet-at-a-time sending algorithm to a hybrid 
> algorithm where periodic bursts provide a rate that is on average X.
> 
> Your examples repeatedly demonstrate that the current implementation is 
> broken.  Cool.
> 
> If you were to just say this was an interim fix it would be easier, but I'd 
> still be confused, since fixing tihs issue does not seem hard.  Just limit the 
> accumulated send credit to something greater than 0, such as the RTT.

Eddie, this is an interesting idea, but would you be amicable to the
suggestion I made in another email?  Basically if RTT is extremely
low, don't do any of this limiting.

What sense is there to doing any of this for very low RTTs?  It is
a very honest question.

If we hit some congestion in a switch on the local network, responding
to that signal is pointless because the congestion event will pass
before we even get the feedback showing us that there was congestion
in the first place.
