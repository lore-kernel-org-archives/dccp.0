From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 22:39:24 +0000
Subject: Re: About pluggable congestion control infrastructure in DCCP
Message-Id: <20070819223924.GC24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
In-Reply-To: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Aug 20, 2007 at 10:22:40AM +1200, Ian McDonald escreveu:
> On 8/20/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> > Em Mon, Aug 20, 2007 at 08:53:15AM +1200, Ian McDonald escreveu:
> > > On 8/20/07, Shahiduzzaman <shahid21st@gmail.com> wrote:
> > > > Hi all,
> > > >
> > > > This may be a redundant or very naive question - sorry in advance for
> > > > that. Can anybody tell me, whether the current Linux kernel DCCP
> > > > implementation is done in a fashion like TCP pluggable congestion
> > > > avoidance modules infrastructure (http://lwn.net/Articles/128681/) ?
> > >
> > > The short answer is yes and no!
> >
> > I think the answer is just "yes"
> >
> > The CCID infrastructure in the Linux kernel is done in a fashion like
> > the TCP pluggable congestion avoidances modules infrastructure. One can
> > write a new CCID and load, making it available for userspace programs to
> > use without changing a line of code in what is already in the kernel.
> >
> > > No that the in-tree version does not support it.
> >
> > The question was if it was done "in a fashion like", not "exactly as". I
> > may be confused with your answer as english is not my first language tho
> > :-)
> >
> 
> I think my answer may have been confusing then...
> 
> To clarify the CCID code is modular in that you don't need to write
> the code from the ground up for a new CCID. It has callback functions
> for implementing various protocol requirements.
> 
> The part where it is not modular (in the tree anywhere) is if you want
> to change just the very small part of how the congestion control is
> done for any particular CCID.

That needs improvements, yes, but even in this area we have separated a
good number of routines in the tfrc library:

[acme@mica net-2.6.24]$ l net/dccp/ccids/lib/
total 64
drwxr-xr-x 2 acme acme  4096 Aug 19 19:25 ./
drwxr-xr-x 3 acme acme  4096 Aug 19 19:26 ../
-rw-r--r-- 1 acme acme  7391 Aug 19 19:25 loss_interval.c
-rw-r--r-- 1 acme acme  1019 Aug 19 19:25 loss_interval.h
-rw-r--r-- 1 acme acme   119 Aug 19 19:25 Makefile
-rw-r--r-- 1 acme acme  7806 Aug 19 19:25 packet_history.c
-rw-r--r-- 1 acme acme  5853 Aug 19 19:25 packet_history.h
-rw-r--r-- 1 acme acme 18708 Aug 19 19:25 tfrc_equation.c
-rw-r--r-- 1 acme acme  1171 Aug 19 19:25 tfrc.h
[acme@mica net-2.6.24]$
 
> I hope this clarifies a little. I get confused even though English is
> my first language!

Yes, it clarifies, and the discussion should provide the information
that Shahiduzzaman is looking for.

Ok, back to preparing a batch of patches for upstream submission, in my
glacial pace, but hey, global warming will eventually reach my feets!
:-)

- Arnaldo
