From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 13 Apr 2007 21:45:50 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <5640c7e00704131445t500791f5yd18d38328fda83fb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/14/07, David Miller <davem@davemloft.net> wrote:
> From: Eddie Kohler <kohler@cs.ucla.edu>
> Date: Fri, 13 Apr 2007 13:37:57 -0700
>
> > Gerrit.  I know the implementation is broken for high rates.  But you are
> > saying that it is impossible to implement CCID3 congestion control at high
> > rates.  I am not convinced.  Among other things, CCID3's t_gran section gives
> > the implementation EXACTLY the flexibility required to smoothly transition
> > from a purely rate-based, packet-at-a-time sending algorithm to a hybrid
> > algorithm where periodic bursts provide a rate that is on average X.
> >
> > Your examples repeatedly demonstrate that the current implementation is
> > broken.  Cool.
> >
> > If you were to just say this was an interim fix it would be easier, but I'd
> > still be confused, since fixing tihs issue does not seem hard.  Just limit the
> > accumulated send credit to something greater than 0, such as the RTT.
>
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

It's not totally pointless Dave because it is a rate based protocol
not a window based protocol and you've got the real issue of slow
receivers especially when we use a whole lot of CPU... It's not
network congestion but still should be dealt with. There's probably
other scenarios too - e.g. I can think of a 10 Mbit radio link between
two buildings that run on 100 Mbit internally. TCP works fine as no
acks will stop transmission but a rate based one will keep on
trying.... Although this isn't a local switch as you mention but it is
low RTT.

Eddie - I would like to work on this more in answer to your question.
I'll see what I can do over the next weeks once I get a paper out of
the way (or when I get bored with it!). Gerrit's work is nearly there.
What I'd like to do is work on this whole granularity/out of control
thing he keeps referring to. I am not convinced but I need to put up
or shut up by replicating some of his work and fixing the bugs or
admitting I'm wrong.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
