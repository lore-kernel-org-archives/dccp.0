From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 11 Sep 2008 14:02:10 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080911140210.GE8078@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Sep 10, 2008 at 10:51:00PM -0700, David Miller escreveu:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Thu, 11 Sep 2008 07:41:04 +0200
> 
> > Meanwhile I had contacted you and Arnaldo privately to ask what to do
> > with DCCP in general. I had emailed you twice, there was no reply,
> > instead the tree was pulled without further discussion. 
> 
> I simply had nothing to add to that discussion.
> 
> I don't know what I could possibly say above and beyond what Arnaldo
> did.  There is nobody in the wings to take over and you don't have the
> time.  The only logical conclusion is that DCCP just sits and rots
> until someone suitably capable and who has the time shows up.   And,
> that's exactly what Arnaldo said.

I was afraid that at some point I would lose the energy or the free time
needed to get DCCP to a conclusion, if there is ever a conclusion in the
life of such a complex piece of software as is a transport protocol.
That is why I worked hard to share as much code with TCP as possible,
and I think there are still opportunities to share even more code.

But right now I think that the situation is way better than when I was
mostly alone working on it, Ian and Andrea contributed lots of code,
Gerrit came up and did lots, lots more, Leandro worked on it, Tommi as
well, there is the work that Tomasz did on policies and now Wei is
testing it and providing analisys, so its not how, say, IPv6 stayed for
a long time.

So don't worry too much, at some point things will get to a better
shape.

The time it takes for a new protocol to get in shape and used is indeed
long.
 
- Arnaldo
