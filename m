From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:34 +0000
Subject: [PATCH 21/24] net/udp: switch udp_lib_setsockopt to sockptr_t
Message-Id: <20200720124737.118617-22-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/net/udp.h | 2 +-
 net/ipv4/udp.c    | 7 ++++---
 net/ipv6/udp.c    | 3 ++-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 17a9e86a807638..295d52a7359827 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -306,7 +306,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, int __user *optlen);
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, unsigned int optlen,
+		       sockptr_t optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *));
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d4be4471c424e3..641303aa17d3dd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2532,7 +2532,7 @@ void udp_destroy_sock(struct sock *sk)
  *	Socket option code for UDP
  */
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, unsigned int optlen,
+		       sockptr_t optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -2543,7 +2543,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
-	if (get_user(val, (int __user *)optval))
+	if (copy_from_sockptr(&val, optval, sizeof(val)))
 		return -EFAULT;
 
 	valbool = val ? 1 : 0;
@@ -2651,7 +2651,8 @@ int udp_setsockopt(struct sock *sk, int level, int optname,
 		   char __user *optval, unsigned int optlen)
 {
 	if (level = SOL_UDP  ||  level = SOL_UDPLITE)
-		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+		return udp_lib_setsockopt(sk, level, optname,
+					  USER_SOCKPTR(optval), optlen,
 					  udp_push_pending_frames);
 	return ip_setsockopt(sk, level, optname, optval, optlen);
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5aff0856a05b44..05353b31fa07bc 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1565,7 +1565,8 @@ int udpv6_setsockopt(struct sock *sk, int level, int optname,
 		     char __user *optval, unsigned int optlen)
 {
 	if (level = SOL_UDP  ||  level = SOL_UDPLITE)
-		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+		return udp_lib_setsockopt(sk, level, optname,
+					  USER_SOCKPTR(optval), optlen,
 					  udp_v6_push_pending_frames);
 	return ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
-- 
2.27.0
