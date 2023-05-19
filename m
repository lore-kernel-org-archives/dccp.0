From: Breno Leitao <leitao@debian.org>
Date: Fri, 19 May 2023 13:58:20 +0000
Subject: [PATCH 0/1] net: ioctl: Use kernel buffer on proto ioctl callbacks
Message-Id: <20230519135821.922326-1-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With the implementation of network ioctl on io_uring[1], Willem
suggested[2] that the "struct proto" ioctls functions should be reused,
instead of duplicating the code.
For that, the ioctl callbacks need to be more flexible, and avoid
operating on userspace buffers (doing get/put_user()) directly on the
callbacks. This patch adds this flexibility, so, the io_uring plumbing
becomes more clean, avoiding duplicating code. This may also benefit
BPF.

For that, a wrapper is created, which will copy from/to userspace, and
the ioctl callback will rely on the wrapper to do userspace memory
copies.

I've tested this patch in three different ways:
1) Created a simple testcase for TCP/UDP [3]
2) Run relevant LTP tests, such as: sockioctl, setsockopt, bind, sendto,
				    fanout, ns-udpsender, etc
3) Run basics network selftests

PS: There are some `strcmp()` in the `sock_skprot_ioctl()`, that I was
not able to find a better way to deal with it. Any feedback is
appreciated.

[1] Link: https://lore.kernel.org/all/GV1P193MB200533CC9A694C4066F4807CEA6F9@GV1P193MB2005.EURP193.PROD.OUTLOOK.COM/
[2] Link: https://lore.kernel.org/all/6436c01979c9b_163b6294b4@willemb.c.googlers.com.notmuch/
[3] Link: https://github.com/leitao/liburing/blob/master/test/ioctl.c

Breno Leitao (1):
  net: ioctl: Use kernel memory on protocol ioctl callbacks

 include/linux/mroute.h  |   4 +-
 include/linux/mroute6.h |   4 +-
 include/net/sock.h      |   4 +-
 include/net/tcp.h       |   2 +-
 include/net/udp.h       |   2 +-
 net/core/sock.c         | 107 ++++++++++++++++++++++++++++++++++++++++
 net/dccp/dccp.h         |   2 +-
 net/dccp/proto.c        |  12 ++---
 net/ieee802154/socket.c |  15 +++---
 net/ipv4/af_inet.c      |   2 +-
 net/ipv4/ipmr.c         |  41 +++++++--------
 net/ipv4/raw.c          |  16 +++---
 net/ipv4/tcp.c          |   5 +-
 net/ipv4/udp.c          |  12 ++---
 net/ipv6/af_inet6.c     |   2 +-
 net/ipv6/ip6mr.c        |  43 +++++++---------
 net/ipv6/raw.c          |  16 +++---
 net/l2tp/l2tp_core.h    |   2 +-
 net/l2tp/l2tp_ip.c      |   9 ++--
 net/mptcp/protocol.c    |  11 ++---
 net/phonet/datagram.c   |  11 ++---
 net/phonet/pep.c        |  11 ++---
 net/phonet/socket.c     |   2 +-
 net/sctp/socket.c       |   8 +--
 24 files changed, 214 insertions(+), 129 deletions(-)

-- 
2.34.1
