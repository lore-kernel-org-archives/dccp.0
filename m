From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 19 Dec 2017 08:56:55 +0000
Subject: [PATCH -tip v3 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <151367381480.32364.2659143894655716709.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

This series is v3 of the replacement of jprobe usage with trace
events. In this version fix build errors occured by including
events/tcp.h twice, and some updates.

Previous version is here;
https://lkml.org/lkml/2017/12/18/126
Changes from v2:
  [1/6] Fix build errors by removing redundant events/tcp.h
        including in net/core/net-traces.c. And sort out
        include headers.
  [3/6] Check sctp_probe_path event is enabled before iterating
        sctp paths.


Please review it and test it.
Here are examples how to use it.

From https://wiki.linuxfoundation.org/networking/tcpprobe

This example,

 # modprobe tcp_probe portP01
 # cat /proc/net/tcpprobe >/tmp/data.out &
 # pid=$!
 # iperf -c otherhost
 # kill $pid

will be changed as below;

 # cd <debugfs or tracefs>/tracing
 # echo 1 > events/tcp/tcp_probe/enable
 # echo "sport = 5001 || dport = 5001"  > events/tcp/tcp_probe/filter
 # tail -f trace_pipe > /tmp/data.out &
 # pid=$!
 # iperf -c otherhost
 # kill $pid

And it outouts logs lile below;

# tracer: nop
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
          <idle>-0     [000] ..s2  1089.238049: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length7 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(960
          <idle>-0     [000] ..s2  1090.156938: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length7 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(992
          <idle>-0     [000] ..s2  1091.333729: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length8 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(992
          <idle>-0     [000] ..s2  1092.300330: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length7 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(992
          <idle>-0     [000] ..s2  1095.044739: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length6 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(992
          <idle>-0     [000] ..s2  1096.573825: tcp_probe: src=[::ffff:192.168.139.2]:5001 dest=[::ffff:192.168.139.1]:56256 mark=0x0 length2 snd_nxt=0xee4abe9c snd_una=0xee4abe9c snd_cwnd ssthresh!47483647 snd_wnd)312 srttG8 rcv_wnd(992

I need your feedback for this change, like formatting etc.
Also, I need more test for this events by who can setup
DCCP and SCTP, since those are special protocols, I have
no environment to test it.

Thank you,

---

Masami Hiramatsu (6):
      net: tcp: Add trace events for TCP congestion window tracing
      net: tcp: Remove TCP probe module
      net: sctp: Add SCTP ACK tracking trace event
      net: sctp: Remove debug SCTP probe module
      net: dccp: Add DCCP sendmsg trace event
      net: dccp: Remove dccpprobe module


 include/trace/events/sctp.h |   98 ++++++++++++++
 include/trace/events/tcp.h  |   80 +++++++++++
 net/Kconfig                 |   17 --
 net/dccp/Kconfig            |   17 --
 net/dccp/Makefile           |    2 
 net/dccp/probe.c            |  203 -----------------------------
 net/dccp/proto.c            |    5 +
 net/dccp/trace.h            |  105 +++++++++++++++
 net/ipv4/Makefile           |    1 
 net/ipv4/tcp_input.c        |    3 
 net/ipv4/tcp_probe.c        |  301 -------------------------------------------
 net/sctp/Kconfig            |   12 --
 net/sctp/Makefile           |    3 
 net/sctp/probe.c            |  244 -----------------------------------
 net/sctp/sm_statefuns.c     |    5 +
 15 files changed, 296 insertions(+), 800 deletions(-)
 create mode 100644 include/trace/events/sctp.h
 delete mode 100644 net/dccp/probe.c
 create mode 100644 net/dccp/trace.h
 delete mode 100644 net/ipv4/tcp_probe.c
 delete mode 100644 net/sctp/probe.c

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
