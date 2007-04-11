From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 11 Apr 2007 22:45:32 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <5640c7e00704111545w19f0ba21t50fbcca50c6ef882@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> There is no way to stop a Linux CCID3 sender from ramping X up to the link bandwidth of 1 Gbit/sec;
> but the scheduler can only control packet pacing up to a rate of s * HZ bytes per second.

Let's start to think laterally about this. Many of the problems around
CCID3/TFRC implementation seem to be on local LANs and rtt is less
than t_gran. We get really badly affected by how we do x_recv etc and
the rate is basically all over the show. We get affected by send
credits and numerous other problems.

What got me thinking about this was a comment by Dave Miller recently
saying something like congestion control on a LAN is basically
meaningless. By the time you've detected any congestion (and I would
add in my case "perceived" congestion) it has gone and you're better
having no congestion control and use Ethernet flow control.

I'm not 100% sure I agree with him totally but there are some very
valid thoughts there. And he was referring to TCP which is window
based and less problematic in this regard than rate based congestion
control I think.

Do we need to do some sanity checks on the rtt and adapt based on
that? I don't actually have the answers yet as just started thinking
about this and thought worthwhile kicking off a discussion as a real
implementation issue for CCID3 in Linux.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
