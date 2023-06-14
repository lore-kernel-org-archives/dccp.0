From: Breno Leitao <leitao@debian.org>
Date: Wed, 14 Jun 2023 11:07:53 +0000
Subject: [RFC PATCH v2 0/4] add initial io_uring_cmd support for sockets
Message-Id: <20230614110757.3689731-1-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patchset creates the initial plumbing for a io_uring command for
sockets.

For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
and SOCKET_URING_OP_SIOCINQ, which are available in TCP, UDP and RAW
sockets.

In order to test this code, I created a liburing test, which is
currently located at [1], and I will create a pull request once we are
good with this patchset.

V1 submission was sent a while ago[2], but it required more plumbing
that were done in different patch submissions[3][4].

PS: This patchset depends on a commit[4] that is not committed to the
tree yet (but close too, IMO).

[1] Link: https://github.com/leitao/liburing/blob/master/test/socket-io-cmd.c
[2] Link: https://lore.kernel.org/lkml/20230406144330.1932798-1-leitao@debian.org/
[3] Link: https://lore.kernel.org/lkml/0a50fae3-1cf4-475e-48ae-25f41967842f@kernel.dk/
[4] Link: https://lore.kernel.org/lkml/20230609152800.830401-1-leitao@debian.org/

V1->V2:
	* Rely on a generic socket->ioctl infrastructure instead of
	  reimplementing it

Breno Leitao (4):
  net: wire up support for file_operations->uring_cmd()
  net: add uring_cmd callback to UDP
  net: add uring_cmd callback to TCP
  net: add uring_cmd callback to raw "protocol"

 include/linux/net.h      |  2 ++
 include/net/raw.h        |  3 +++
 include/net/sock.h       |  6 ++++++
 include/net/tcp.h        |  2 ++
 include/net/udp.h        |  2 ++
 include/uapi/linux/net.h |  5 +++++
 net/core/sock.c          | 17 +++++++++++++++--
 net/dccp/ipv4.c          |  1 +
 net/ipv4/af_inet.c       |  3 +++
 net/ipv4/raw.c           | 23 +++++++++++++++++++++++
 net/ipv4/tcp.c           | 21 +++++++++++++++++++++
 net/ipv4/tcp_ipv4.c      |  1 +
 net/ipv4/udp.c           | 22 ++++++++++++++++++++++
 net/l2tp/l2tp_ip.c       |  1 +
 net/mptcp/protocol.c     |  1 +
 net/sctp/protocol.c      |  1 +
 net/socket.c             | 13 +++++++++++++
 17 files changed, 122 insertions(+), 2 deletions(-)

-- 
2.34.1
