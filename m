From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 13 Apr 2007 19:52:32 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <5640c7e00704131252v5cc5e417l97ab85b12e4e0664@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/14/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The comment by Dave brought me back to check what a change of
> a factor of 10 does to the throughput in TFRC.
>
> RFC 3448 gives in section 8 the following alternative format
> of the throughput equation (which is directly responsible for
> the alllowed sending rate X):
>
>               s
>       X =  --------
>            R * f(p)
>
Which comes into play when we have loss. When we have no loss, or a
long period of non-loss we can send as fast as we want according to
the spec. This should normally be the case on LANs where the RTT makes
a far bigger difference.

So you will have this on very low latency, lossly links potentially.
How realistic is this? Another thing is that TFRC is designed to
respond to loss in a different way than TCP (more smoothly). This is
the attraction of TFRC. Remember this is an unreliable protocol so it
is not designed for high speed file transfer etc. Do we actually need
to chase every last bit of performance (I'm not saying we should be
lazy)?

As an aside I use a network testing with two machines at 1 GHz or so
and the receiver used to hit 100% when testing with iperf on a 100
Mbit LAN (TCP uses around 40%). The sender used far less CPU. Funnily
enough under this scenario the rate used to drop.... I shut down a few
other bits and pieces and then got full rate and just under 100% CPU.
Now my machines/NICs aren't particularly powerful and I haven't tested
with latest code (which replaces linked lists with arrays etc) but I
think if we want to ensure high performance on low RTT links we need
to check this also.
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
