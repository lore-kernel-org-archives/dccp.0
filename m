From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 22 Sep 2006 04:11:49 +0000
Subject: Re: CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <45136285.2070301@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609210930.21903@strip-the-willow>
In-Reply-To: <200609210930.21903@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi, a short note;

Andrea Bittau wrote:
> On Thu, Sep 21, 2006 at 09:30:21AM +0100, Gerrit Renker wrote:
>>  1/ TX Buffering: set size of TX ring buffer via socket option.
> 
> The size of the TX buffer is interesting in applications which want to do their
> own queue management.  That is, real-time applications that would prefer
> dropping certain packets and re-order other packets based on the state of the
> session.  We are used to the standard UNIX "push" model where you shove stuff in
> the kernel via write.  Perhaps a different architecture would be for the TX
> buffer to be in user-land and the kernel to pull from it.  There is a lot of
> overhead [context-switch] added, but there might be a good way of coding this.
> By doing so, the application chooses exactly what to send and when.  Perhaps
> this is equivalent to a 0 TX buffer size.

Junwen Lai and I designed and built an API very much like this --  a transmit 
ring in user space.  Gerrit referred to the paper.  It's actually similar to 
the design Xen uses for its virtual network drivers.

Eddie
