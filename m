From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:42 +0000
Subject: dccp-test-tree [PATCH 5/10] net: Mask out ECN bits when setting TOS/TCLASS
Message-Id: <1249847327-6792-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is needed by the AF-independent approach to provide DCCPv4/6
ECN support. Since this approach handles ECN at in the module, the patch
disables user-side manipulation of ECN bits via TOS/TCLASS.

However, it also fixes a bug occurring in SCTPv6: when passing values that
contain 0x1 in the ECN bits, the internal value of ECT(0) gets turned into
0x3 = CE, i.e. it suggests to the other side that congestion was experienced.

I am working on these issues and would greatly appreciate feedback/suggestions.
(NB - not touched datagram_send_ctl(), since it is used only by udpv6/rawv6).

An alternative for modifying ECN bits in user space is in a subsequent patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/ip_sockglue.c   |    7 ++++---
 net/ipv6/ipv6_sockglue.c |    2 ++
 2 files changed, 6 insertions(+), 3 deletions(-)

--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -27,6 +27,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/tcp_states.h>
+#include <net/inet_ecn.h>
 #include <linux/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter.h>
@@ -550,9 +551,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			inet->cmsg_flags &= ~IP_CMSG_ORIGDSTADDR;
 		break;
 	case IP_TOS:	/* This sets both TOS and Precedence */
-		if (sk->sk_type = SOCK_STREAM) {
-			val &= ~3;
-			val |= inet->tos & 3;
+		if (sk->sk_type != SOCK_RAW) {
+			val &= ~INET_ECN_MASK;
+			val |= inet->tos & INET_ECN_MASK;
 		}
 		if (inet->tos != val) {
 			inet->tos = val;
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -318,6 +318,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		/* RFC 3542, 6.5: default traffic class of 0x0 */
 		if (val = -1)
 			val = 0;
+		if (sk->sk_type != SOCK_RAW)
+			val &= ~INET_ECN_MASK;
 		np->tclass = val;
 		retv = 0;
 		break;
-- 
1.6.0.rc2

