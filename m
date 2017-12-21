From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 21 Dec 2017 13:16:51 +0000
Subject: Re: [PATCH net-next v4 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <20171221221651.fe8f18d4b8c63b1afdb821f4@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <151374325126.2497.6934744693865165386.stgit@devbox>
In-Reply-To: <151374325126.2497.6934744693865165386.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 20 Dec 2017 22:12:38 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu, 21 Dec 2017 11:36:57 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > On Wed, 20 Dec 2017 14:24:24 -0500 (EST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: David Miller <davem@davemloft.net>
> > > Date: Wed, 20 Dec 2017 14:20:40 -0500 (EST)
> > >   
> > > > From: Masami Hiramatsu <mhiramat@kernel.org>
> > > > Date: Wed, 20 Dec 2017 13:14:11 +0900
> > > >   
> > > >> This series is v4 of the replacement of jprobe usage with trace
> > > >> events. This version is rebased on net-next, fixes a build warning
> > > >> and moves a temporal variable definition in a block.
> > > >> 
> > > >> Previous version is here;
> > > >> https://lkml.org/lkml/2017/12/19/153
> > > >> 
> > > >> Changes from v3:
> > > >>   All: Rebased on net-next
> > > >>   [3/6]: fixes a build warning for i386 by casting pointer unsigned
> > > >>         long instead of __u64, and moves a temporal variable
> > > >>          definition in a block.  
> > > > 
> > > > Looks good, series applied to net-next, thanks.  
> > > 
> > > Actually, this doesn't even compile, so I've reverted:
> > > 
> > > [davem@dhcp-10-15-49-227 net-next]$ make -s -j16
> > > In file included from net/dccp/trace.h:105:0,
> > >                  from net/dccp/proto.c:42:
> > > ./include/trace/define_trace.h:89:42: fatal error: ./trace.h: No such file or directory
> > >  #include TRACE_INCLUDE(TRACE_INCLUDE_FILE)
> > >                                           ^
> > > compilation terminated.  
> > 
> > Hi David,
> > 
> > Could you share your .config file? I would like to reproduce it.
> > When I tried with attached kconfig, I could not reproduce this issue,
> > and could run it.
> >
> 
> Hi Masami,
> 
> Are you sure you committed everything in this change set? I don't see a
> modification of the Makefile to get the trace.h file you created.
> Shouldn't there be something like:
> 
> CFLAGS_proto.o := -I$(src)
> 
> in the Makefile?

Oops, I didn't do that, but also I had committed all in this changeset.
Hmm, strange, because I don't see same issue... At first I will try to
reproduce it and try above flags again.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
