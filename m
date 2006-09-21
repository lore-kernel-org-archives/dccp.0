From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 21 Sep 2006 12:20:23 +0000
Subject: Re: CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <20060921122023.GA1936@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <200609210930.21903@strip-the-willow>
In-Reply-To: <200609210930.21903@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Sep 21, 2006 at 09:30:21AM +0100, Gerrit Renker wrote:
>  1/ TX Buffering: set size of TX ring buffer via socket option.

The size of the TX buffer is interesting in applications which want to do their
own queue management.  That is, real-time applications that would prefer
dropping certain packets and re-order other packets based on the state of the
session.  We are used to the standard UNIX "push" model where you shove stuff in
the kernel via write.  Perhaps a different architecture would be for the TX
buffer to be in user-land and the kernel to pull from it.  There is a lot of
overhead [context-switch] added, but there might be a good way of coding this.
By doing so, the application chooses exactly what to send and when.  Perhaps
this is equivalent to a 0 TX buffer size.

Alternatively, there could be an API for managing the TX buffer in the kernel,
or maybe tagging packets with an expiry time or something.  The bottom line is,
that other than just regulating the TX buffer size, there might be smarter
things that we could do and may turn out to be useful.  Giving the application
the power to control what is sent and when, in accordance with the CCID, will
allow the application to make use of all of DCCP's benefits.

>  5/ Feature negotiation: the feature negotiation code also depends on current CCID value.

Feature negotiation is somewhat there.  Currently, you can setsockopt features.
What needs to be hooked up is the getsockopt on features in order to poll the
state of the feater [i.e. what is the outcome of the negotiation].  There is
kernel code for this, it just needs to be hooked up, tested and used.
