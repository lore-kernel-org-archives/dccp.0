From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Mon, 17 Nov 2008 19:27:29 +0000
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Message-Id: <4921C5A1.5030609@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> I would appreciate some advice and insights regarding the use of
> high-resolution timers within a transport protocol, specifically
> DCCP with CCID-3 (RFC 5348).
> 
 > ...
 >
> Summing up, I have doubts that basing CCID-3 will bring advantages and
> would much rather go the other way and (consistently) use lower resolution.
> 
> Thoughts?

I agree.  If one way must be chosen, then choose lower resolution timers.

The biggest potential problem with lower-resolution timers is that a sender's 
rate might be limited, not by network characteristics, but by timer 
resolution.  But DCCP allows a fair amount of burstiness already.  And there 
may be ways to avoid rate limitation in common cases without resorting to 
hrtimers.  For example, a sending application could use a mixture of 
non-blocking system calls, allowing the sending application to "poke" the DCCP 
implementation on every scheduling.

At any rate, it seems worth trying.

Eddie

