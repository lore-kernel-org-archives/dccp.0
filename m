From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 22 Oct 2007 16:31:44 +0000
Subject: systemtap networking tapsets was: Re: [RFC]: field name identifier
Message-Id: <20071022163144.GA15773@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

CCing dccp@vger.kernel.org, since I wrote a nice description about
this new toy :)

Em Mon, Oct 22, 2007 at 03:24:41PM +0100, Gerrit Renker escreveu:
> |  perhaps one that could understand types and then could allow developers
> |  to ask questions like "show me all the places where the field foo of
> |  type bar appears"
> Hopefully in the next generation of such things may be possible? I was
> once stunned by a screenshot of some form of (k)gdb which took a large nested
> struct apart into the nested components.

This is my baby I guess :) pahole can do just that:

http://oops.ghostprotocols.net:81/acme/dwarves/pahole--expand_types-struct-tcp6_sock.txt
 
> So far very happy with "make cscope" and the excellent support that vim offers,
> also tried Red Hat's sourcenav once (but took ages).o

I use ctags, but I agree that cscope has more features.

Ah, I'm working on some systemtap tapsets, i.e. libraries of probe
routines, for networking, starting with TCP, but organized in a way
that can be easily used with DCCP and other net protocols too.

You need to build the kernel with CONFIG_DEBUG_INFO so that systemtap
gets the required symbols (tcp_v4_rcv, etc, look in the tapsets).

Take a look, I had to manually sort the output, will fix that, and
there are some bugs yet as you can see with some negative nanosecond
deltas, but its getting useful.

Ah, the times are in nanoseconds from userspace all the way to the
network device driver ("dev_out" lines), and from netif_rx or
netif_receive_skb (i.e. right when the network device driver creates the
packet and hands it up the network stack) to ip_rcv ("ip_in"),
tcp_v4_rcv ("tcp_in") and to userspace via skb_copy_datagram_iovec
("user_in"). I'm using skb->tstamp to mark when the journey begins,
so don't use it at the same time with tcpdump.

I intend to record more entries, so that we can understand where the
skbs are sitting.

And will probably convert net/dccp/dccpprobe.c and tcpprobe to be
just systemtap scripts and not part of the build process, etc.

http://oops.ghostprotocols.net:81/acme/nettaps.tar.bz2

[root@doppio nettaps]# stap -I tapset/ lnlat.stp
                                                                 latency(ns)        buffer size
   entry   local address  port  remote address  port      avg     min       max   avg   min   max
-
user_in      192.168.1.9 48366  216.239.51.125  5222   737982  724188    751776   195     5   386
tcp_in       192.168.1.9 48366  216.239.51.125  5222    40176   40176     40176   411   411   411
ip_in        192.168.1.9 48366  216.239.51.125  5222    13968   13968     13968   431   431   431
dev_out      192.168.1.9 48366  216.239.51.125  5222    37884   21588     54180    63    54    72
-
user_in      192.168.1.9 43391     192.168.1.6    22   283830  216216    346140    56    48    64
tcp_in       192.168.1.9 43391     192.168.1.6    22    34221   24492     65232    88    80    96
ip_in        192.168.1.9 43391     192.168.1.6    22    11620    9744     14052   108   100   116
dev_out      192.168.1.9 43391     192.168.1.6    22    -2943 -870508    229992    93    66   148
-
user_in      192.168.1.9 49886   207.46.108.27  1863   247464  247464    247464     8     8     8
tcp_in       192.168.1.9 49886   207.46.108.27  1863    18150   18150     18150    40    40    40
ip_in        192.168.1.9 49886   207.46.108.27  1863     5718    5718      5718    60    60    60
dev_out      192.168.1.9 49886   207.46.108.27  1863    54475    9714    146004    77    66    89
-
user_in     10.11.15.126 40517     10.10.36.72  6667    60596   30912     90280    65    52    79
tcp_in      10.11.15.126 40517     10.10.36.72  6667     9258    9258      9258   111   111   111
ip_in       10.11.15.126 40517     10.10.36.72  6667     2736    2736      2736   131   131   131
dev_out     10.11.15.126 40517     10.10.36.72  6667    10026   10026     10026    52    52    52
-
user_in      192.168.1.9 57815     192.168.1.2    22   401277  209832    778728    57    48    64
tcp_in       192.168.1.9 57815     192.168.1.2    22    37165   24720     72444    89    80    96
ip_in        192.168.1.9 57815     192.168.1.2    22    11777    9720     14868   109   100   116
dev_out      192.168.1.9 57815     192.168.1.2    22    60789   14052    216828    93    66   148
-
user_in      192.168.1.9 44572     192.168.1.8    22   128581 -509484    451092    56    48    64
tcp_in       192.168.1.9 44572     192.168.1.8    22    31453   23088     58008    88    80    96
ip_in        192.168.1.9 44572     192.168.1.8    22    10946    9300     14256   108   100   116
dev_out      192.168.1.9 44572     192.168.1.8    22    54194   16404    215784    88    66   148
-

- Arnaldo
