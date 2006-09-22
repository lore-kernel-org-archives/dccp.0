From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 00:18:57 +0000
Subject: Re: CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <5640c7e00609211718x356a4ccene9e84d2f9f1b568f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609210930.21903@strip-the-willow>
In-Reply-To: <200609210930.21903@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/22/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> On Thu, Sep 21, 2006 at 09:30:21AM +0100, Gerrit Renker wrote:
> >  1/ TX Buffering: set size of TX ring buffer via socket option.
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
>
> Alternatively, there could be an API for managing the TX buffer in the kernel,
> or maybe tagging packets with an expiry time or something.  The bottom line is,
> that other than just regulating the TX buffer size, there might be smarter
> things that we could do and may turn out to be useful.  Giving the application
> the power to control what is sent and when, in accordance with the CCID, will
> allow the application to make use of all of DCCP's benefits.
>
I'm not sure whether Andrea is alluding to my code once again or not here.

In my patches I have online I do deliberate packet reordering and
expiry for experimental purposes. The difference is that mine is done
in kernel space rather than user space.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
