From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 28 Dec 2017 06:10:00 +0000
Subject: [PATCH net-next v6 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <151444140014.11331.17287122201510506083.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

This series is v6 of the replacement of jprobe usage with trace
events. This version fixes trace/events/tcp.h to avoid sparse
warning, as same as Mat Martineau's patch.

Previous version is here;
 https://www.spinics.net/lists/netdev/msg474057.html

Changes from v5:
  [1/6]: Avoid preprocessor directives in tracepoint macro args

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
 include/trace/events/tcp.h  |   97 ++++++++++++++
 net/Kconfig                 |   17 --
 net/dccp/Kconfig            |   17 --
 net/dccp/Makefile           |    5 -
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
 15 files changed, 317 insertions(+), 800 deletions(-)
 create mode 100644 include/trace/events/sctp.h
 delete mode 100644 net/dccp/probe.c
 create mode 100644 net/dccp/trace.h
 delete mode 100644 net/ipv4/tcp_probe.c
 delete mode 100644 net/sctp/probe.c

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
