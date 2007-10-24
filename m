From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 13:32:00 +0000
Subject: Re: systemtap networking tapsets was: Re: [RFC]: field name
Message-Id: <20071024133200.GI6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071022163144.GA15773@ghostprotocols.net>
In-Reply-To: <20071022163144.GA15773@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 24, 2007 at 01:11:18PM +0100, Gerrit Renker escreveu:
> |  > |  perhaps one that could understand types and then could allow developers
> |  > |  to ask questions like "show me all the places where the field foo of
> |  > |  type bar appears"
> |  > Hopefully in the next generation of such things may be possible? I was
>                                         ^
>                                         |
> Indeed! Did you notice the missing word +    ... I meant to write `dwarves' :)
> and wrote `next generation' since there are apparently already 7 in this generation.

:)
 
> |  Ah, I'm working on some systemtap tapsets, i.e. libraries of probe
> |  routines, for networking, starting with TCP, but organized in a way
> |  that can be easily used with DCCP and other net protocols too.

> If you could give a shout on the mailing list once it is ready for testing/deployment,
> that would be good. Last year you had a nice tool which automatically inserted kprobes
> at entry/exit points, it was apparently meant to replace an older tool. I tried it a
> few times but then lost track of the revisions. It is frustrating to test stuff which is
> in the middle of a migration to something else.

I will, what you are talking about is ctracer, that generates kprobes
entry/exit, I'll go to a third revision that will be to generate
systemtap scripts instead of kprobes, leveraging on the systemtap safety
nets.

Yesterday I stopped using _stp_gettimeofday_ns() for the timestamp,
switched to get_cycles_sync() and there was no performance drop when
using lnlat.stp (the local network latency measurement tool), so it
indeed looks promising.
 
> The output looks great and once that is ready, I think it can be of much help to answer
> long pending questions of e.g. how well the packet scheduler really works.

Exactly, I want to have a clear picture of where packets sits, and the
packet scheduler will be one of the next tapsets I'll be working on.
 
> |  And will probably convert net/dccp/dccpprobe.c and tcpprobe to be
> |  just systemtap scripts and not part of the build process, etc.

> I think that dccpprobe.c is the wrong name ... it should really be called ccid3_probe.c ...
> I have been working on printing entries for CCID2, since in ccid2.c there is no probe support,
> and instead ccid2_pr_debug is used for the same purpose all over the place.

Indeed, lemme try converting it right now...

- Arnaldo
