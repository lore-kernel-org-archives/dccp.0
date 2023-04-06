From: Breno Leitao <leitao@debian.org>
Date: Thu, 06 Apr 2023 14:43:26 +0000
Subject: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <20230406144330.1932798-1-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Breno Leitao <leit@fb.com>

This patchset creates the initial plumbing for a io_uring command for
sockets.

For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
heavily based on the ioctl operations.

In order to test this code, I created a liburing test, which is
currently located at [1], and I will create a pull request once we are
good with this patch.

I've also run test/io_uring_passthrough to make sure the first patch
didn't regressed the NVME passthrough path.

This patchset is a RFC for two different reasons:
  * It changes slighlty on how IO uring command operates. I.e, we are
    now passing the whole SQE to the io_uring_cmd callback (instead of
    an opaque buffer). This seems to be more palatable instead of
    creating some custom structure just to fit small parameters, as in
    SOCKET_URING_OP_SIOC{IN,OUT}Q. Is this OK?

  * Pavel has some ideas about the SQE->cmd_op field, so, we can start
    discussing it here.

This work is heavily inspired by Jens Axboe's initial implementation.

[1] https://github.com/leitao/liburing/blob/master/test/socket-io-cmd.c

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
 net/ipv4/raw.c           | 26 ++++++++++++++++++++++++++
 net/ipv4/tcp.c           | 34 ++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c      |  1 +
 net/ipv4/udp.c           | 18 ++++++++++++++++++
 net/l2tp/l2tp_ip.c       |  1 +
 net/mptcp/protocol.c     |  1 +
 net/sctp/protocol.c      |  1 +
 net/socket.c             | 13 +++++++++++++
 17 files changed, 134 insertions(+), 2 deletions(-)

-- 
2.34.1


