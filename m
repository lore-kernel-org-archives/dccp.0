From: "vlad.gm@gmail.com" <vlad.gm@gmail.com>
Date: Wed, 18 Apr 2007 18:32:09 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <b13771cc0704181132w39fd5104v30e1a2825c2655a6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Exactly, we encountered some problems also with the KAME
implementation when running over links with very small delays (in the
millisecond range). The problem was that the connection would choke
and require a long time in order to recover. We suspected some
possible bugs in the implementation (arithmetic overflow?), however
later reports by the Linux kernel implementers seemed to be consistent
with our experience.
We must not forget that we all derive our code from the same codebase,
which means that some implementation decisions such as the way in
which the TFRC equation calculations are done are the same for both
implementations.
As a side note, concerning the way the scheduling of sent packets and
timing are done: we set our target rate around 50-100 packets/sec,
typical for voice applications. KAME is based on the FreeBSD 5.4
kernel which was one of the last kernels in which HZ0 was used. In
order to have our implementation running reliably (also with larger
RTTs) we had to increase it to HZ00. I am not sure which part of
the implementation is responsible for this problem. In principle, it
should be possible to implement TFRC with a grainy timer interrupt
rate.

Regards,
Vlad

On 4/18/07, Lars Eggert <lars.eggert@nokia.com> wrote:
> On 2007-4-18, at 19:16, ext Colin Perkins wrote:
> > On 11 Apr 2007, at 23:45, Ian McDonald wrote:
> >> On 4/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> >>> There is no way to stop a Linux CCID3 sender from ramping X up to
> >>> the link bandwidth of 1 Gbit/sec; but the scheduler can only
> >>> control packet pacing up to a rate of s * HZ bytes per second.
> >>
> >> Let's start to think laterally about this. Many of the problems
> >> around
> >> CCID3/TFRC implementation seem to be on local LANs and rtt is less
> >> than t_gran. We get really badly affected by how we do x_recv etc and
> >> the rate is basically all over the show. We get affected by send
> >> credits and numerous other problems.
> >
> > As a data point, we've seen similar stability issues with our user-
> > space TFRC implementation, although at somewhat larger RTTs (order
> > of a few milliseconds or less). We're still checking whether these
> > are bugs in our code, or issues with TFRC, but this may be a
> > broader issue than problems with the Linux DCCP implementation.
>
> I think Vlad saw similar issues with the KAME code when running over
> a local area network. (Vlad?)
>
> Lars
>
>
>
>
