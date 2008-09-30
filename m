From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 30 Sep 2008 19:16:41 +0000
Subject: Re: Protocol not attached
Message-Id: <20080930191641.GL15446@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 30, 2008 at 03:32:17PM -0300, Leandro Sales escreveu:
> On Mon, Sep 29, 2008 at 3:37 PM, Arnaldo Carvalho de Melo
> <acme@redhat.com> wrote:
> > Em Mon, Sep 29, 2008 at 03:33:44PM -0300, Leandro Sales escreveu:
> >> Hello folks,
> >>   I'm getting this message while using 2.6.27:
> >>
> >>   Can not create DCCP socket (Protocol driver not attached)
> >
> > What is the source of such messages? VLC? What? Try strace to see what
> > is the syscall that fails just before this message is printed, etc.
> >
> >>   "uname -a" output:
> >>       Linux localhost 2.6.27-rc4-44301-g8269be1 #7 SMP Sun Sep 28 17:02:25
> >>       BRT 2008 i686 AMD Athlon(tm) 64 Processor 3000+ AuthenticAMD GNU/Linux
> >>
> >>   Anything wrong? I tried compile DCCP using both static and module
> >> methods and it produces the same effect.
> >
> > - Arnaldo
> >
> 
> Hello Arnaldo,
>   I'm just running tests with iperf to later use gstreamer plugin that
> I developed. Here it is the output provided by strace while executing
> iperf. I'm sorry for the long message. In addition, I'm providing
> support for a guy from China that wants to use my gstreamer plugin and
> he is facing similar problem, getting a permission denied message
> while using the plugin, even then he run the plugin as root.

iperf is multithreaded, so you need to run strace with -f to trace child
processes, also please try limiting the output to just the networking
syscalls:

strace -f -e trace=network iperf

"net namespaces" blipped in my mind, but it may well be just my brain
needing more coffee...

- Arnaldo
