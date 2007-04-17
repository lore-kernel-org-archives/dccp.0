From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Tue, 17 Apr 2007 13:42:04 +0000
Subject: Re: RTT measurement, CCID3 implementability
Message-Id: <4624CEAC.2080700@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <46229A62.9010805@cs.ucla.edu>
In-Reply-To: <46229A62.9010805@cs.ucla.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> |  - The DCCP specification does not require RTT measurements on every packet 
> |  exchange.
> |  
> |  - It should be possible to use coarse grained timestamps (even jiffies) for 
> |  most packets, with finer grained timestamps used on occasion, to improve the 
> |  current estimate; for example, getting the time of day once per RTT.
> This is not easily possible without at the same time revising the spec. If you e.g.
> allow jiffie-based round-trip times, then you will need to set the minimum RTT value
> to 1 jiffie, since otherwise divide-by-zero will be likely.

Can you point to where in the specification it requires fine grained 
timestamps on all packets?

Eddie
