From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 18:31:38 +0000
Subject: [PATCHES 0/6]: Move hashinfo to sk_prot and struct reorgs
Message-Id: <1201804304-28777-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6

Best Regards,

- Arnaldo

 include/linux/dccp.h               |    2 -
 include/linux/tcp.h                |    6 ++-
 include/net/if_inet6.h             |    4 +-
 include/net/inet6_hashtables.h     |    2 -
 include/net/inet_connection_sock.h |    8 +----
 include/net/inet_hashtables.h      |   51 +++++---------------------------
 include/net/inet_timewait_sock.h   |    3 -
 include/net/sock.h                 |    3 +
 net/dccp/dccp.h                    |    2 -
 net/dccp/ipv4.c                    |   18 ++++-------
 net/dccp/ipv6.c                    |   20 +++++-------
 net/dccp/proto.c                   |   18 +----------
 net/ipv4/inet_connection_sock.c    |    8 +----
 net/ipv4/inet_hashtables.c         |   58 ++++++++++++++++++++++++++++++-------
 net/ipv4/tcp.c                     |    2 -
 net/ipv4/tcp_ipv4.c                |   31 +++++--------------
 net/ipv6/inet6_hashtables.c        |    4 +-
 net/ipv6/tcp_ipv6.c                |   19 +++++-------
 18 files changed, 111 insertions(+), 148 deletions(-)
