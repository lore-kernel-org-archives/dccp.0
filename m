From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:29 +0000
Subject: [PATCH 20/22] net/ipv6: factor out mcast join/leave setsockopt helpers
Message-Id: <20200717062331.691152-21-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Factor out one helper each for setting the native and compat
version of the MCAST_MSFILTER option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv6/ipv6_sockglue.c | 103 ++++++++++++++++++++-------------------
 1 file changed, 53 insertions(+), 50 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 6aa49495d7bc0b..1ea0cd12beaee9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -252,6 +252,56 @@ static int compat_ipv6_set_mcast_msfilter(struct sock *sk, void __user *optval,
 }
 #endif
 
+static int ipv6_mcast_join_leave(struct sock *sk, int optname,
+		void __user *optval, int optlen)
+{
+	struct sockaddr_in6 *psin6;
+	struct group_req greq;
+
+	if (optlen < sizeof(greq))
+		return -EINVAL;
+	if (copy_from_user(&greq, optval, sizeof(greq)))
+		return -EFAULT;
+
+	if (greq.gr_group.ss_family != AF_INET6)
+		return -EADDRNOTAVAIL;
+	psin6 = (struct sockaddr_in6 *)&greq.gr_group;
+	if (optname = MCAST_JOIN_GROUP)
+		return ipv6_sock_mc_join(sk, greq.gr_interface,
+					 &psin6->sin6_addr);
+	return ipv6_sock_mc_drop(sk, greq.gr_interface, &psin6->sin6_addr);
+}
+
+#ifdef CONFIG_COMPAT
+static int compat_ipv6_mcast_join_leave(struct sock *sk, int optname,
+		void __user *optval, int optlen)
+{
+	struct compat_group_req gr32;
+	struct sockaddr_in6 *psin6;
+	int err;
+
+	if (optlen < sizeof(gr32))
+		return -EINVAL;
+	if (copy_from_user(&gr32, optval, sizeof(gr32)))
+		return -EFAULT;
+
+	if (gr32.gr_group.ss_family != AF_INET6)
+		return -EADDRNOTAVAIL;
+	rtnl_lock();
+	lock_sock(sk);
+	psin6 = (struct sockaddr_in6 *)&gr32.gr_group;
+	if (optname = MCAST_JOIN_GROUP)
+		err = ipv6_sock_mc_join(sk, gr32.gr_interface,
+					&psin6->sin6_addr);
+	else
+		err = ipv6_sock_mc_drop(sk, gr32.gr_interface,
+					&psin6->sin6_addr);
+	release_sock(sk);
+	rtnl_unlock();
+	return err;
+}
+#endif
+
 static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, unsigned int optlen)
 {
@@ -803,29 +853,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
-	{
-		struct group_req greq;
-		struct sockaddr_in6 *psin6;
-
-		if (optlen < sizeof(struct group_req))
-			goto e_inval;
-
-		retv = -EFAULT;
-		if (copy_from_user(&greq, optval, sizeof(struct group_req)))
-			break;
-		if (greq.gr_group.ss_family != AF_INET6) {
-			retv = -EADDRNOTAVAIL;
-			break;
-		}
-		psin6 = (struct sockaddr_in6 *)&greq.gr_group;
-		if (optname = MCAST_JOIN_GROUP)
-			retv = ipv6_sock_mc_join(sk, greq.gr_interface,
-						 &psin6->sin6_addr);
-		else
-			retv = ipv6_sock_mc_drop(sk, greq.gr_interface,
-						 &psin6->sin6_addr);
+		retv = ipv6_mcast_join_leave(sk, optname, optval, optlen);
 		break;
-	}
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:
@@ -975,34 +1004,8 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	switch (optname) {
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
-	{
-		struct compat_group_req __user *gr32 = (void __user *)optval;
-		struct group_req greq;
-		struct sockaddr_in6 *psin6 = (struct sockaddr_in6 *)&greq.gr_group;
-
-		if (optlen < sizeof(struct compat_group_req))
-			return -EINVAL;
-
-		if (get_user(greq.gr_interface, &gr32->gr_interface) ||
-		    copy_from_user(&greq.gr_group, &gr32->gr_group,
-				sizeof(greq.gr_group)))
-			return -EFAULT;
-
-		if (greq.gr_group.ss_family != AF_INET6)
-			return -EADDRNOTAVAIL;
-
-		rtnl_lock();
-		lock_sock(sk);
-		if (optname = MCAST_JOIN_GROUP)
-			err = ipv6_sock_mc_join(sk, greq.gr_interface,
-						 &psin6->sin6_addr);
-		else
-			err = ipv6_sock_mc_drop(sk, greq.gr_interface,
-						 &psin6->sin6_addr);
-		release_sock(sk);
-		rtnl_unlock();
-		return err;
-	}
+		return compat_ipv6_mcast_join_leave(sk, optname, optval,
+						    optlen);
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:
-- 
2.27.0
