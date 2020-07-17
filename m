From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:25 +0000
Subject: [PATCH 16/22] net/ipv4: factor out mcast join/leave setsockopt helpers
Message-Id: <20200717062331.691152-17-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Factor out one helper each for setting the native and compat
version of the MCAST_MSFILTER option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv4/ip_sockglue.c | 109 +++++++++++++++++++++--------------------
 1 file changed, 56 insertions(+), 53 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b587dee006f882..73bb88fbe54661 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -806,6 +806,60 @@ static int compat_ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
 }
 #endif
 
+static int ip_mcast_join_leave(struct sock *sk, int optname,
+		void __user *optval, int optlen)
+{
+	struct ip_mreqn mreq = { };
+	struct sockaddr_in *psin;
+	struct group_req greq;
+
+	if (optlen < sizeof(struct group_req))
+		return -EINVAL;
+	if (copy_from_user(&greq, optval, sizeof(greq)))
+		return -EFAULT;
+
+	psin = (struct sockaddr_in *)&greq.gr_group;
+	if (psin->sin_family != AF_INET)
+		return -EINVAL;
+	mreq.imr_multiaddr = psin->sin_addr;
+	mreq.imr_ifindex = greq.gr_interface;
+	if (optname = MCAST_JOIN_GROUP)
+		return ip_mc_join_group(sk, &mreq);
+	return ip_mc_leave_group(sk, &mreq);
+}
+
+#ifdef CONFIG_COMPAT
+static int compat_ip_mcast_join_leave(struct sock *sk, int optname,
+		void __user *optval, int optlen)
+{
+	struct compat_group_req greq;
+	struct ip_mreqn mreq = { };
+	struct sockaddr_in *psin;
+	int err;
+
+	if (optlen < sizeof(struct compat_group_req))
+		return -EINVAL;
+	if (copy_from_user(&greq, optval, sizeof(greq)))
+		return -EFAULT;
+
+	psin = (struct sockaddr_in *)&greq.gr_group;
+	if (psin->sin_family != AF_INET)
+		return -EINVAL;
+	mreq.imr_multiaddr = psin->sin_addr;
+	mreq.imr_ifindex = greq.gr_interface;
+
+	rtnl_lock();
+	lock_sock(sk);
+	if (optname = MCAST_JOIN_GROUP)
+		err = ip_mc_join_group(sk, &mreq);
+	else
+		err = ip_mc_leave_group(sk, &mreq);
+	release_sock(sk);
+	rtnl_unlock();
+	return err;
+}
+#endif
+
 static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, unsigned int optlen)
 {
@@ -1211,29 +1265,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	}
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
-	{
-		struct group_req greq;
-		struct sockaddr_in *psin;
-		struct ip_mreqn mreq;
-
-		if (optlen < sizeof(struct group_req))
-			goto e_inval;
-		err = -EFAULT;
-		if (copy_from_user(&greq, optval, sizeof(greq)))
-			break;
-		psin = (struct sockaddr_in *)&greq.gr_group;
-		if (psin->sin_family != AF_INET)
-			goto e_inval;
-		memset(&mreq, 0, sizeof(mreq));
-		mreq.imr_multiaddr = psin->sin_addr;
-		mreq.imr_ifindex = greq.gr_interface;
-
-		if (optname = MCAST_JOIN_GROUP)
-			err = ip_mc_join_group(sk, &mreq);
-		else
-			err = ip_mc_leave_group(sk, &mreq);
+		err = ip_mcast_join_leave(sk, optname, optval, optlen);
 		break;
-	}
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:
@@ -1389,37 +1422,7 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 	switch (optname) {
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
-	{
-		struct compat_group_req __user *gr32 = (void __user *)optval;
-		struct group_req greq;
-		struct sockaddr_in *psin = (struct sockaddr_in *)&greq.gr_group;
-		struct ip_mreqn mreq;
-
-		if (optlen < sizeof(struct compat_group_req))
-			return -EINVAL;
-
-		if (get_user(greq.gr_interface, &gr32->gr_interface) ||
-		    copy_from_user(&greq.gr_group, &gr32->gr_group,
-				sizeof(greq.gr_group)))
-			return -EFAULT;
-
-		if (psin->sin_family != AF_INET)
-			return -EINVAL;
-
-		memset(&mreq, 0, sizeof(mreq));
-		mreq.imr_multiaddr = psin->sin_addr;
-		mreq.imr_ifindex = greq.gr_interface;
-
-		rtnl_lock();
-		lock_sock(sk);
-		if (optname = MCAST_JOIN_GROUP)
-			err = ip_mc_join_group(sk, &mreq);
-		else
-			err = ip_mc_leave_group(sk, &mreq);
-		release_sock(sk);
-		rtnl_unlock();
-		return err;
-	}
+		return compat_ip_mcast_join_leave(sk, optname, optval, optlen);
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:
-- 
2.27.0
