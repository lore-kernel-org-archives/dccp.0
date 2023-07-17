From: Guillaume Nault <gnault@redhat.com>
Date: Mon, 17 Jul 2023 13:53:24 +0000
Subject: [PATCH net-next 0/3] net: Remove more RTO_ONLINK users.
Message-Id: <cover.1689600901.git.gnault@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Code that initialise a flowi4 structure manually before doing a fib
lookup can easily avoid overloading ->flowi4_tos with the RTO_ONLINK
bit. They can just set ->flowi4_scope correctly instead.

Properly separating the routing scope from ->flowi4_tos will allow to
eventually convert this field to dscp_t (to ensure proper separation
between DSCP and ECN).

Guillaume Nault (3):
  gtp: Set TOS and routing scope independently for fib lookups.
  dccp: Set TOS and routing scope independently for fib lookups.
  sctp: Set TOS and routing scope independently for fib lookups.

 drivers/net/gtp.c   | 3 ++-
 net/dccp/ipv4.c     | 3 ++-
 net/sctp/protocol.c | 3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

-- 
2.39.2
