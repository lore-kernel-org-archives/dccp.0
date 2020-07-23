From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:09:05 +0000
Subject: [PATCH 23/26] net/tcp: switch ->md5_parse to sockptr_t
Message-Id: <20200723060908.50081-24-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/net/tcp.h   | 2 +-
 net/ipv4/tcp.c      | 3 ++-
 net/ipv4/tcp_ipv4.c | 4 ++--
 net/ipv6/tcp_ipv6.c | 4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9f7f7c0c110451..e3c8e1d820214c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2002,7 +2002,7 @@ struct tcp_sock_af_ops {
 					 const struct sk_buff *skb);
 	int		(*md5_parse)(struct sock *sk,
 				     int optname,
-				     char __user *optval,
+				     sockptr_t optval,
 				     int optlen);
 #endif
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 58ede3d62b2e2c..49bf15c27deac7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3249,7 +3249,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 	case TCP_MD5SIG_EXT:
-		err = tp->af_specific->md5_parse(sk, optname, optval, optlen);
+		err = tp->af_specific->md5_parse(sk, optname,
+						 USER_SOCKPTR(optval), optlen);
 		break;
 #endif
 	case TCP_USER_TIMEOUT:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index daa39d33702b13..f8913923a6c05e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1195,7 +1195,7 @@ static void tcp_clear_md5_list(struct sock *sk)
 }
 
 static int tcp_v4_parse_md5_keys(struct sock *sk, int optname,
-				 char __user *optval, int optlen)
+				 sockptr_t optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
@@ -1206,7 +1206,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, int optname,
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_sockptr(&cmd, optval, sizeof(cmd)))
 		return -EFAULT;
 
 	if (sin->sin_family != AF_INET)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c34b7834fd84a8..305870a72352d6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -567,7 +567,7 @@ static struct tcp_md5sig_key *tcp_v6_md5_lookup(const struct sock *sk,
 }
 
 static int tcp_v6_parse_md5_keys(struct sock *sk, int optname,
-				 char __user *optval, int optlen)
+				 sockptr_t optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
@@ -577,7 +577,7 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, int optname,
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_sockptr(&cmd, optval, sizeof(cmd)))
 		return -EFAULT;
 
 	if (sin6->sin6_family != AF_INET6)
-- 
2.27.0
