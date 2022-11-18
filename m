From: Kuniyuki Iwashima <kuniyu@amazon.com>
Date: Fri, 18 Nov 2022 20:58:35 +0000
Subject: [PATCH v3 net 0/4] dccp/tcp: Fix bhash2 issues related to WARN_ON() in inet_csk_get_port().
Message-Id: <20221118205839.14312-1-kuniyu@amazon.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

syzkaller was hitting a WARN_ON() in inet_csk_get_port() in the 4th patch,
which was because we forgot to fix up bhash2 bucket when connect() for a
socket bound to a wildcard address fails in __inet_stream_connect().

There was a similar report [0], but its repro does not fire the WARN_ON() due
to inconsistent error handling.

When connect() for a socket bound to a wildcard address fails, saddr may or
may not be reset depending on where the failure happens.  When we fail in
__inet_stream_connect(), sk->sk_prot->disconnect() resets saddr.  OTOH, in
(dccp|tcp)_v[46]_connect(), if we fail after inet_hash6?_connect(), we
forget to reset saddr.

We fix this inconsistent error handling in the 1st patch, and then we'll
fix the bhash2 WARN_ON() issue.

Note that there is still an issue in that we reset saddr without checking
if there are conflicting sockets in bhash and bhash2, but this should be
another series.

See [1][2] for the previous discussion.

[0]: https://lore.kernel.org/netdev/0000000000003f33bc05dfaf44fe@google.com/
[1]: https://lore.kernel.org/netdev/20221029001249.86337-1-kuniyu@amazon.com/
[2]: https://lore.kernel.org/netdev/20221103172419.20977-1-kuniyu@amazon.com/
[3]: https://lore.kernel.org/netdev/20221118081906.053d5231@kernel.org/T/#m00aafedb29ff0b55d5e67aef0252ef1baaf4b6ee

Changes:
  v3:
    * Patch 3
      * Update saddr under the bhash's lock
      * Correct Fixes tag
      * Change #ifdef in inet_update_saddr() along the recent
        discussion [3]

  v2: https://lore.kernel.org/netdev/20221116222805.64734-1-kuniyu@amazon.com/
    * Add patch 2-4

  v1: [2]


Kuniyuki Iwashima (4):
  dccp/tcp: Reset saddr on failure after inet6?_hash_connect().
  dccp/tcp: Remove NULL check for prev_saddr in
    inet_bhash2_update_saddr().
  dccp/tcp: Update saddr under bhash's lock.
  dccp/tcp: Fixup bhash2 bucket when connect() fails.

 include/net/inet_hashtables.h |  3 +-
 net/dccp/ipv4.c               | 23 ++-------
 net/dccp/ipv6.c               | 24 ++-------
 net/dccp/proto.c              |  3 +-
 net/ipv4/af_inet.c            | 11 +----
 net/ipv4/inet_hashtables.c    | 91 +++++++++++++++++++++++++++++------
 net/ipv4/tcp.c                |  3 +-
 net/ipv4/tcp_ipv4.c           | 21 ++------
 net/ipv6/tcp_ipv6.c           | 20 ++------
 9 files changed, 101 insertions(+), 98 deletions(-)

-- 
2.30.2
