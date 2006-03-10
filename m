From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 0/9] Build Fixes, cleanups and some DCCP trivial patches
Message-Id: <11420257373367-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

 b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    2
 b/include/linux/dccp.h                           |   43 ++++---
 b/include/net/inet_connection_sock.h             |    5
 b/net/802/psnap.c                                |    2
 b/net/core/skbuff.c                              |    3
 b/net/core/sock.c                                |   20 +--
 b/net/dccp/dccp.h                                |   11 -
 b/net/dccp/diag.c                                |    2
 b/net/dccp/feat.c                                |   81 ++++++-------
 b/net/dccp/feat.h                                |    7 -
 b/net/dccp/input.c                               |    8 -
 b/net/dccp/ipv4.c                                |   72 ++++++------
 b/net/dccp/ipv6.c                                |  138 +++++++++++------------
 b/net/dccp/minisocks.c                           |    9 -
 b/net/dccp/options.c                             |   30 ++---
 b/net/dccp/proto.c                               |   23 +--
 b/net/ipv4/af_inet.c                             |  120 ++++++++++----------
 b/net/ipv4/inet_connection_sock.c                |   30 +++++
 b/net/ipv4/ip_sockglue.c                         |   35 ++---
 b/net/ipv4/raw.c                                 |   46 +++----
 b/net/ipv4/tcp.c                                 |   27 +---
 b/net/ipv4/tcp_ipv4.c                            |   34 ++---
 b/net/ipv4/udp.c                                 |   48 +++-----
 b/net/ipv6/af_inet6.c                            |  120 ++++++++++----------
 b/net/ipv6/ipv6_sockglue.c                       |   40 +++---
 b/net/ipv6/ipv6_syms.c                           |    4
 b/net/ipv6/raw.c                                 |   94 +++++++--------
 b/net/ipv6/tcp_ipv6.c                            |   64 +++++-----
 b/net/ipv6/udp.c                                 |   48 ++++----
 b/net/netfilter/nf_sockopt.c                     |    2
 b/net/sctp/ipv6.c                                |   92 +++++++--------
 b/net/sctp/protocol.c                            |   95 +++++++--------
 b/security/dummy.c                               |    4
 b/security/selinux/include/xfrm.h                |   11 +
 net/dccp/feat.c                                  |   30 ++---
 net/dccp/proto.c                                 |   45 +++----
 net/ipv4/tcp.c                                   |   16 +-
 37 files changed, 730 insertions(+), 731 deletions(-)

