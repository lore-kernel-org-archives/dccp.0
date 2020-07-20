From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:28 +0000
Subject: [PATCH 15/24] net/ipv4: switch do_ip_setsockopt to sockptr_t
Message-Id: <20200720124737.118617-16-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv4/ip_sockglue.c | 68 ++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b12f39b52008a3..f7f1507b89fe24 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -683,15 +683,15 @@ static int set_mcast_msfilter(struct sock *sk, int ifindex,
 	return -EADDRNOTAVAIL;
 }
 
-static int copy_group_source_from_user(struct group_source_req *greqs,
-		void __user *optval, int optlen)
+static int copy_group_source_from_sockptr(struct group_source_req *greqs,
+		sockptr_t optval, int optlen)
 {
 	if (in_compat_syscall()) {
 		struct compat_group_source_req gr32;
 
 		if (optlen != sizeof(gr32))
 			return -EINVAL;
-		if (copy_from_user(&gr32, optval, sizeof(gr32)))
+		if (copy_from_sockptr(&gr32, optval, sizeof(gr32)))
 			return -EFAULT;
 		greqs->gsr_interface = gr32.gsr_interface;
 		greqs->gsr_group = gr32.gsr_group;
@@ -699,7 +699,7 @@ static int copy_group_source_from_user(struct group_source_req *greqs,
 	} else {
 		if (optlen != sizeof(*greqs))
 			return -EINVAL;
-		if (copy_from_user(greqs, optval, sizeof(*greqs)))
+		if (copy_from_sockptr(greqs, optval, sizeof(*greqs)))
 			return -EFAULT;
 	}
 
@@ -707,14 +707,14 @@ static int copy_group_source_from_user(struct group_source_req *greqs,
 }
 
 static int do_mcast_group_source(struct sock *sk, int optname,
-		void __user *optval, int optlen)
+		sockptr_t optval, int optlen)
 {
 	struct group_source_req greqs;
 	struct ip_mreq_source mreqs;
 	struct sockaddr_in *psin;
 	int omode, add, err;
 
-	err = copy_group_source_from_user(&greqs, optval, optlen);
+	err = copy_group_source_from_sockptr(&greqs, optval, optlen);
 	if (err)
 		return err;
 
@@ -754,8 +754,7 @@ static int do_mcast_group_source(struct sock *sk, int optname,
 	return ip_mc_source(add, omode, sk, &mreqs, greqs.gsr_interface);
 }
 
-static int ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
-		int optlen)
+static int ip_set_mcast_msfilter(struct sock *sk, sockptr_t optval, int optlen)
 {
 	struct group_filter *gsf = NULL;
 	int err;
@@ -765,7 +764,7 @@ static int ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
 	if (optlen > sysctl_optmem_max)
 		return -ENOBUFS;
 
-	gsf = memdup_user(optval, optlen);
+	gsf = memdup_sockptr(optval, optlen);
 	if (IS_ERR(gsf))
 		return PTR_ERR(gsf);
 
@@ -786,7 +785,7 @@ static int ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
 	return err;
 }
 
-static int compat_ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
+static int compat_ip_set_mcast_msfilter(struct sock *sk, sockptr_t optval,
 		int optlen)
 {
 	const int size0 = offsetof(struct compat_group_filter, gf_slist);
@@ -806,7 +805,7 @@ static int compat_ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
 	gf32 = p + 4; /* we want ->gf_group and ->gf_slist aligned */
 
 	err = -EFAULT;
-	if (copy_from_user(gf32, optval, optlen))
+	if (copy_from_sockptr(gf32, optval, optlen))
 		goto out_free_gsf;
 
 	/* numsrc >= (4G-140)/128 overflow in 32 bits */
@@ -831,7 +830,7 @@ static int compat_ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
 }
 
 static int ip_mcast_join_leave(struct sock *sk, int optname,
-		void __user *optval, int optlen)
+		sockptr_t optval, int optlen)
 {
 	struct ip_mreqn mreq = { };
 	struct sockaddr_in *psin;
@@ -839,7 +838,7 @@ static int ip_mcast_join_leave(struct sock *sk, int optname,
 
 	if (optlen < sizeof(struct group_req))
 		return -EINVAL;
-	if (copy_from_user(&greq, optval, sizeof(greq)))
+	if (copy_from_sockptr(&greq, optval, sizeof(greq)))
 		return -EFAULT;
 
 	psin = (struct sockaddr_in *)&greq.gr_group;
@@ -853,7 +852,7 @@ static int ip_mcast_join_leave(struct sock *sk, int optname,
 }
 
 static int compat_ip_mcast_join_leave(struct sock *sk, int optname,
-		void __user *optval, int optlen)
+		sockptr_t optval, int optlen)
 {
 	struct compat_group_req greq;
 	struct ip_mreqn mreq = { };
@@ -861,7 +860,7 @@ static int compat_ip_mcast_join_leave(struct sock *sk, int optname,
 
 	if (optlen < sizeof(struct compat_group_req))
 		return -EINVAL;
-	if (copy_from_user(&greq, optval, sizeof(greq)))
+	if (copy_from_sockptr(&greq, optval, sizeof(greq)))
 		return -EFAULT;
 
 	psin = (struct sockaddr_in *)&greq.gr_group;
@@ -875,8 +874,8 @@ static int compat_ip_mcast_join_leave(struct sock *sk, int optname,
 	return ip_mc_leave_group(sk, &mreq);
 }
 
-static int do_ip_setsockopt(struct sock *sk, int level,
-			    int optname, char __user *optval, unsigned int optlen)
+static int do_ip_setsockopt(struct sock *sk, int level, int optname,
+		sockptr_t optval, unsigned int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
@@ -910,12 +909,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_RECVFRAGSIZE:
 	case IP_RECVERR_RFC4884:
 		if (optlen >= sizeof(int)) {
-			if (get_user(val, (int __user *) optval))
+			if (copy_from_sockptr(&val, optval, sizeof(val)))
 				return -EFAULT;
 		} else if (optlen >= sizeof(char)) {
 			unsigned char ucval;
 
-			if (get_user(ucval, (unsigned char __user *) optval))
+			if (copy_from_sockptr(&ucval, optval, sizeof(ucval)))
 				return -EFAULT;
 			val = (int) ucval;
 		}
@@ -926,8 +925,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	if (optname = IP_ROUTER_ALERT)
 		return ip_ra_control(sk, val ? 1 : 0, NULL);
 	if (ip_mroute_opt(optname))
-		return ip_mroute_setsockopt(sk, optname, USER_SOCKPTR(optval),
-					    optlen);
+		return ip_mroute_setsockopt(sk, optname, optval, optlen);
 
 	err = 0;
 	if (needs_rtnl)
@@ -941,8 +939,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		if (optlen > 40)
 			goto e_inval;
-		err = ip_options_get(sock_net(sk), &opt, USER_SOCKPTR(optval),
-					      optlen);
+		err = ip_options_get(sock_net(sk), &opt, optval, optlen);
 		if (err)
 			break;
 		old = rcu_dereference_protected(inet->inet_opt,
@@ -1140,17 +1137,17 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq, optval, sizeof(mreq)))
+			if (copy_from_sockptr(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
 			if (optlen >= sizeof(struct ip_mreq)) {
-				if (copy_from_user(&mreq, optval,
-						   sizeof(struct ip_mreq)))
+				if (copy_from_sockptr(&mreq, optval,
+						      sizeof(struct ip_mreq)))
 					break;
 			} else if (optlen >= sizeof(struct in_addr)) {
-				if (copy_from_user(&mreq.imr_address, optval,
-						   sizeof(struct in_addr)))
+				if (copy_from_sockptr(&mreq.imr_address, optval,
+						      sizeof(struct in_addr)))
 					break;
 			}
 		}
@@ -1202,11 +1199,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq, optval, sizeof(mreq)))
+			if (copy_from_sockptr(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
-			if (copy_from_user(&mreq, optval, sizeof(struct ip_mreq)))
+			if (copy_from_sockptr(&mreq, optval,
+					      sizeof(struct ip_mreq)))
 				break;
 		}
 
@@ -1226,7 +1224,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			err = -ENOBUFS;
 			break;
 		}
-		msf = memdup_user(optval, optlen);
+		msf = memdup_sockptr(optval, optlen);
 		if (IS_ERR(msf)) {
 			err = PTR_ERR(msf);
 			break;
@@ -1257,7 +1255,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		if (optlen != sizeof(struct ip_mreq_source))
 			goto e_inval;
-		if (copy_from_user(&mreqs, optval, sizeof(mreqs))) {
+		if (copy_from_sockptr(&mreqs, optval, sizeof(mreqs))) {
 			err = -EFAULT;
 			break;
 		}
@@ -1324,8 +1322,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		err = -EPERM;
 		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			break;
-		err = xfrm_user_policy(sk, optname, USER_SOCKPTR(optval),
-				       optlen);
+		err = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
 
 	case IP_TRANSPARENT:
@@ -1412,7 +1409,8 @@ int ip_setsockopt(struct sock *sk, int level,
 	if (level != SOL_IP)
 		return -ENOPROTOOPT;
 
-	err = do_ip_setsockopt(sk, level, optname, optval, optlen);
+	err = do_ip_setsockopt(sk, level, optname, USER_SOCKPTR(optval),
+			       optlen);
 #if IS_ENABLED(CONFIG_BPFILTER_UMH)
 	if (optname >= BPFILTER_IPT_SO_SET_REPLACE &&
 	    optname < BPFILTER_IPT_SET_MAX)
-- 
2.27.0
