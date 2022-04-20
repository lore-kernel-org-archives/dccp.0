From: Guillaume Nault <gnault@redhat.com>
Date: Wed, 20 Apr 2022 23:21:19 +0000
Subject: [PATCH net-next 0/3] ipv4: First steps toward removing RTO_ONLINK
Message-Id: <cover.1650470610.git.gnault@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RTO_ONLINK is a flag that allows to reduce the scope of route lookups.
It's stored in a normally unused bit of the ->flowi4_tos field, in
struct flowi4. However it has several problems:

 * This bit is also used by ECN. Although ECN bits are supposed to be
   cleared before doing a route lookup, it happened that some code
   paths didn't properly sanitise their ->flowi4_tos. So this mechanism
   is fragile and we had bugs in the past where ECN bits slipped in and
   could end up being erroneously interpreted as RTO_ONLINK.

 * A dscp_t type was recently introduced to ensure ECN bits are cleared
   during route lookups. ->flowi4_tos is the most important structure
   field to convert, but RTO_ONLINK prevents such conversion, as dscp_t
   mandates that ECN bits (where RTO_ONLINK is stored) be zero.

Therefore we need to stop using RTO_ONLINK altogether. Fortunately
RTO_ONLINK isn't a necessity. Instead of passing a flag in ->flowi4_tos
to tell the route lookup function to restrict the scope, we can simply
initialise the scope correctly.

Patch 1 does some preparatory work: it stops resetting ->flowi4_scope
automatically before a route lookup, thus allowing callers to set their
desired scope without having to rely on the RTO_ONLINK flag.

Patch 2-3 convert a few code paths to avoid relying on RTO_ONLINK.

More conversions will have to take place before we can eventually
remove this flag.

Guillaume Nault (3):
  ipv4: Don't reset ->flowi4_scope in ip_rt_fix_tos().
  ipv4: Avoid using RTO_ONLINK with ip_route_connect().
  ipv4: Initialise ->flowi4_scope properly in ICMP handlers.

 include/net/route.h | 36 ++++++++++++++++++++++++------------
 net/dccp/ipv4.c     |  5 ++---
 net/ipv4/af_inet.c  |  6 +++---
 net/ipv4/datagram.c |  7 +++----
 net/ipv4/route.c    | 41 +++++++++++++++++++----------------------
 net/ipv4/tcp_ipv4.c |  5 ++---
 6 files changed, 53 insertions(+), 47 deletions(-)

-- 
2.21.3
