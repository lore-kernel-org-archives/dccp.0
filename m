From: Joanne Koong <joannelkoong@gmail.com>
Date: Mon, 22 Aug 2022 18:10:20 +0000
Subject: [PATCH RESEND net-next v4 0/3] Add a second bind table hashed by port and address
Message-Id: <20220822181023.3979645-1-joannelkoong@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Currently, there is one bind hashtable (bhash) that hashes by port only.
This patchset adds a second bind table (bhash2) that hashes by port and
address.

The motivation for adding bhash2 is to expedite bind requests in situations
where the port has many sockets in its bhash table entry (eg a large number
of sockets bound to different addresses on the same port), which makes checking
bind conflicts costly especially given that we acquire the table entry spinlock
while doing so, which can cause softirq cpu lockups and can prevent new tcp
connections.

We ran into this problem at Meta where the traffic team binds a large number
of IPs to port 443 and the bind() call took a significant amount of time
which led to cpu softirq lockups, which caused packet drops and other failures
on the machine.

When experimentally testing this on a local server for ~24k sockets bound to
the port, the results seen were:

ipv4:
before - 0.002317 seconds
with bhash2 - 0.000020 seconds

ipv6:
before - 0.002431 seconds
with bhash2 - 0.000021 seconds

The additions to the initial bhash2 submission [0] are:
* Updating bhash2 in the cases where a socket's rcv saddr changes after it has
* been bound
* Adding locks for bhash2 hashbuckets

[0] https://lore.kernel.org/netdev/20220520001834.2247810-1-kuba@kernel.org/

---
Changelog

v3 -> v4
v3: https://lore.kernel.org/netdev/20220722195406.1304948-2-joannelkoong@gmail.com/
  * Address kernel test robot bad page map:
    - only update the bhash2 table in connect() on addr 0, if the socket is bound

v2 -> v3
v2: https://lore.kernel.org/netdev/20220712235310.1935121-1-joannelkoong@gmail.com/
  * Address Paolo's feedback
    1/3:
        - Move inet_bhashfn_portaddr down in inet_csk_find_open_port()
        - Remove unused "head" in inet_bhash2_update_saddr
    2/3:
        - Make tests work for ipv4, make address configurable from command line
        - Use 'nodad' option for ip addr add in script
    3/3:
        - Add sk_bind_sendto_listen to Makefile for it to run automatically

  * Check if the icsk_bind2_hash was set before finding the prev_addr_hashbucket.
    If the icsk_bind2_hash wasn't set, this means the prev address was never
    added to the bhash2, so pass in NULL "prev_saddr" to inet_bhash2_update_saddr().
    This addresses the kernel_NULL_pointer_dereference report [1].

  * Add sk_connect_zero_addr test (tests that the kernel_NULL_pointer_dereference bug
    is fixed).

  [1] https://lore.kernel.org/netdev/YtLJMxChUupbAa+U@xsang-OptiPlex-9020/

v1 -> v2
v1: https://lore.kernel.org/netdev/20220623234242.2083895-2-joannelkoong@gmail.com/
  * Drop formatting change to sk_add_bind_node()

Joanne Koong (3):
  net: Add a bhash2 table hashed by port + address
  selftests/net: Add test for timing a bind request to a port with a
    populated bhash entry
  selftests/net: Add sk_bind_sendto_listen and sk_connect_zero_addr

 include/net/inet_connection_sock.h            |   3 +
 include/net/inet_hashtables.h                 |  80 ++++-
 include/net/sock.h                            |  14 +
 net/dccp/ipv4.c                               |  25 +-
 net/dccp/ipv6.c                               |  18 ++
 net/dccp/proto.c                              |  34 ++-
 net/ipv4/af_inet.c                            |  26 +-
 net/ipv4/inet_connection_sock.c               | 275 ++++++++++++++----
 net/ipv4/inet_hashtables.c                    | 268 ++++++++++++++++-
 net/ipv4/tcp.c                                |  11 +-
 net/ipv4/tcp_ipv4.c                           |  23 +-
 net/ipv6/tcp_ipv6.c                           |  17 ++
 tools/testing/selftests/net/.gitignore        |   5 +-
 tools/testing/selftests/net/Makefile          |   5 +
 tools/testing/selftests/net/bind_bhash.c      | 144 +++++++++
 tools/testing/selftests/net/bind_bhash.sh     |  66 +++++
 .../selftests/net/sk_bind_sendto_listen.c     |  80 +++++
 .../selftests/net/sk_connect_zero_addr.c      |  62 ++++
 18 files changed, 1061 insertions(+), 95 deletions(-)
 create mode 100644 tools/testing/selftests/net/bind_bhash.c
 create mode 100755 tools/testing/selftests/net/bind_bhash.sh
 create mode 100644 tools/testing/selftests/net/sk_bind_sendto_listen.c
 create mode 100644 tools/testing/selftests/net/sk_connect_zero_addr.c

-- 
2.30.2
