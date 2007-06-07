From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Thu, 07 Jun 2007 10:24:16 +0000
Subject: Re: [BUG] Fwd: segfault : modprobe dccp_probe/tcp_probe
Message-Id: <fca78b970706070324i23b4f6d7n3da88507e0840400@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00706061347v42c9ecbahb5354f6687a70a78@mail.gmail.com>
In-Reply-To: <5640c7e00706061347v42c9ecbahb5354f6687a70a78@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Ian,

Not sure it's still useful after patch provide by Prasanna...
But I tried to turn off CONFIG_DEBUG_RODATA and both `tcp_probe' and
`dccp_probe' can be load properly.
I also ran iperf test (for dccp) and it works.

Patrick.

On 07/06/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 6/7/07, Chuck Ebbert <cebbert@redhat.com> wrote:
> > On 06/06/2007 04:47 PM, Ian McDonald wrote:
> > > Hi there,
> > >
> > > We've seen a report of a problem with dccp_probe as shown below. The
> > > user has also verified that it occurs in tcp_probe as well. This is on
> > > Dave Miller's tree but that currently tracks Linus' tree quite
> > > closely. I do note that it is around 2.6.22-rc2 timeframe so there is
> > > a possibility fixes may have gone in since.
> > >
> >
> > It faulted when it tried to write the breakpoint instruction into the
> > running kernel's executable code. Apparently the kernel code is now mar=
ked
> > read-only?
> >
> >
> Yes it would appear to be the case as user has CONFIG_DEBUG_RODATA
> set. Patrick - can you turn this off and retest? It's under Kernel
> Hacking, Write protect kernel read only data structures.
>
> The list of commits that I see around this are at:
> http://git.kernel.org/?p=3Dlinux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.gi=
t&a=3Dsearch&h=3DHEAD&st=3Dcommit&s=DEBUG_RODATA
>
> I suspect it's probably one of the latter ones giving the timing.
>
> I guess there are a couple of solutions here - either make kprobes
> conflict with CONFIG_DEBUG_RODATA so you can do one or the other, or
> look into more detail what access kprobes need.
>
> Ian
> --
> Web: http://wand.net.nz/~iam4/
> Blog: http://iansblog.jandi.co.nz
> WAND Network Research Group
>
