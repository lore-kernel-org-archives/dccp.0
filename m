From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 29 Dec 2017 02:45:20 +0000
Subject: [PATCH net-next v7 0/6] net: tcp: sctp: dccp: Replace jprobe usage with trace events
Message-Id: <151451552014.17912.11834170408829155608.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

This series is v7 of the replacement of jprobe usage with trace
events. This version fixes net/dccp/trace.h to avoid sparse
warning. Since the TP_STORE_ADDR_PORTS macro can be shared
with trace/events/tcp.h, it also introduce a new common header
file and move the definition of that macro.

Previous version is here;
 https://lkml.org/lkml/2017/12/28/7

Changes from v6:
  [5/6]: Avoid preprocessor directives in tracepoint macro args

Thank you,

---

Masami Hiramatsu (6):
      net: tcp: Add trace events for TCP congestion window tracing
      net: tcp: Remove TCP probe module
      net: sctp: Add SCTP ACK tracking trace event
      net: sctp: Remove debug SCTP probe module
      net: dccp: Add DCCP sendmsg trace event
      net: dccp: Remove dccpprobe module


 include/trace/events/net_probe_common.h |   44 +++++
 include/trace/events/sctp.h             |   99 ++++++++++
 include/trace/events/tcp.h              |   60 ++++++
 net/Kconfig                             |   17 --
 net/dccp/Kconfig                        |   17 --
 net/dccp/Makefile                       |    5 -
 net/dccp/probe.c                        |  203 ---------------------
 net/dccp/proto.c                        |    5 +
 net/dccp/trace.h                        |   84 +++++++++
 net/ipv4/Makefile                       |    1 
 net/ipv4/tcp_input.c                    |    3 
 net/ipv4/tcp_probe.c                    |  301 -------------------------------
 net/sctp/Kconfig                        |   12 -
 net/sctp/Makefile                       |    3 
 net/sctp/probe.c                        |  244 -------------------------
 net/sctp/sm_statefuns.c                 |    5 +
 16 files changed, 303 insertions(+), 800 deletions(-)
 create mode 100644 include/trace/events/net_probe_common.h
 create mode 100644 include/trace/events/sctp.h
 delete mode 100644 net/dccp/probe.c
 create mode 100644 net/dccp/trace.h
 delete mode 100644 net/ipv4/tcp_probe.c
 delete mode 100644 net/sctp/probe.c

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
