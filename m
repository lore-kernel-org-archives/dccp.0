From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Wed, 20 Dec 2017 04:14:11 +0000
Subject: [PATCH net-next v4 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <151374325126.2497.6934744693865165386.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

This series is v4 of the replacement of jprobe usage with trace
events. This version is rebased on net-next, fixes a build warning
and moves a temporal variable definition in a block.

Previous version is here;
https://lkml.org/lkml/2017/12/19/153

Changes from v3:
  All: Rebased on net-next
  [3/6]: fixes a build warning for i386 by casting pointer unsigned
        long instead of __u64, and moves a temporal variable
         definition in a block.

Thank you,

---

Masami Hiramatsu (6):
      net: tcp: Add trace events for TCP congestion window tracing
      net: tcp: Remove TCP probe module
      net: sctp: Add SCTP ACK tracking trace event
      net: sctp: Remove debug SCTP probe module
      net: dccp: Add DCCP sendmsg trace event
      net: dccp: Remove dccpprobe module


 include/trace/events/sctp.h |   99 ++++++++++++++
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
 15 files changed, 297 insertions(+), 800 deletions(-)
 create mode 100644 include/trace/events/sctp.h
 delete mode 100644 net/dccp/probe.c
 create mode 100644 net/dccp/trace.h
 delete mode 100644 net/ipv4/tcp_probe.c
 delete mode 100644 net/sctp/probe.c

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
