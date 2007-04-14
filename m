From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sat, 14 Apr 2007 05:51:38 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <46206BEA.1040808@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Putting on my Sally hat:

David Miller wrote:
> Eddie, this is an interesting idea, but would you be amicable to the
> suggestion I made in another email?  Basically if RTT is extremely
> low, don't do any of this limiting.
> 
> What sense is there to doing any of this for very low RTTs?  It is
> a very honest question.
> 
> If we hit some congestion in a switch on the local network, responding
> to that signal is pointless because the congestion event will pass
> before we even get the feedback showing us that there was congestion
> in the first place.

An idea like this is definitely worth exploring.  Of course it would be a 
change to congestion control and would have to be treated as such.  it 
wouldn't be CCID3, or TCP-friendly, since TCP is (according to research & 
such) responding to the RTT, due to ack clocking.  You'd have to worry about 
perhaps rare, but absolutely possible, cases such as persistent LAN 
congestion.  (Maybe a local wireless LAN?)

I wonder in Gerrit's RTT experiments what a TCP connection would achieve, and 
how that would correspond to the TCP throughput equation.

Eddie
