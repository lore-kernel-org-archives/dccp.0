From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 12 Jan 2007 16:33:13 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <45A7B849.5080501@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> |  For what it's worth, it's as close to in the RFC as it can get without a 
> |  revision.  The authors of the RFC agree that we meant the initial 
> |  Request-Response RTT to be usable as an initial RTT estimate; the 
> |  working group agreed; errata has been sent.
> So we are RFC-compliant for the moment. One point which remains unresolved is,
> the above is about RTTs, but what about the initial sending rate of 1 packet
> per second, which implies an initial t_ipi of 1 second?

"Therefore, in contrast to [RFC3448], the initial CCID 3 sending rate is 
allowed to be at least two packets per RTT, and at most four packets per 
RTT, depending on the packet size. ..." [RFC4342, Sec 5]

Since CCID3 always has an estimate of the round trip time when it sends 
packets, there is no such thing as an initial sending rate of 1 packet 
per second.  The initial sending rate, after the Response arrives (thus 
providing an initial estimate of the round trip time), is 2-4 packets 
per RTT, depending on s.

Eddie
