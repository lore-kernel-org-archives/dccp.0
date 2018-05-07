From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 07 May 2018 18:43:31 +0000
Subject: [PATCH net-next v3 0/2] socket statistics for ss
Message-Id: <20180507184333.32688-1-sthemmin@microsoft.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The eventual goal is to remove all accesses to slab statistics
by iproute2 ss command. This are preliminary steps to add two
statistics which are not working now, because of slab merging
and changes that were done years ago to allow for common inet_hash
tables.

Stephen Hemminger (2):
  inet: add bound ports statistic
  socket: keep track of the number of sockets allocated

v3
  - fix build :-(
  - add allocated sockets statistic

 include/net/inet_hashtables.h    |  3 +++
 include/net/inet_timewait_sock.h |  2 ++
 net/dccp/proto.c                 |  1 +
 net/ipv4/inet_hashtables.c       | 22 +++++++++++++++++++---
 net/ipv4/inet_timewait_sock.c    |  8 +++++---
 net/ipv4/proc.c                  |  5 +++--
 net/ipv4/tcp.c                   |  1 +
 net/socket.c                     | 21 +++++++++++++++++++--
 8 files changed, 53 insertions(+), 10 deletions(-)

-- 
2.17.0

