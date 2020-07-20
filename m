From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:19 +0000
Subject: [PATCH 06/24] net: switch sock_set_timeout to sockptr_t
Message-Id: <20200720124737.118617-7-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/core/sock.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index bd20fc5cce0850..d45bb1c2c36abf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -360,7 +360,8 @@ static int sock_get_timeout(long timeo, void *optval, bool old_timeval)
 	return sizeof(tv);
 }
 
-static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool old_timeval)
+static int sock_set_timeout(long *timeo_p, sockptr_t optval, int optlen,
+			    bool old_timeval)
 {
 	struct __kernel_sock_timeval tv;
 
@@ -370,7 +371,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool
 		if (optlen < sizeof(tv32))
 			return -EINVAL;
 
-		if (copy_from_user(&tv32, optval, sizeof(tv32)))
+		if (copy_from_sockptr(&tv32, optval, sizeof(tv32)))
 			return -EFAULT;
 		tv.tv_sec = tv32.tv_sec;
 		tv.tv_usec = tv32.tv_usec;
@@ -379,14 +380,14 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool
 
 		if (optlen < sizeof(old_tv))
 			return -EINVAL;
-		if (copy_from_user(&old_tv, optval, sizeof(old_tv)))
+		if (copy_from_sockptr(&old_tv, optval, sizeof(old_tv)))
 			return -EFAULT;
 		tv.tv_sec = old_tv.tv_sec;
 		tv.tv_usec = old_tv.tv_usec;
 	} else {
 		if (optlen < sizeof(tv))
 			return -EINVAL;
-		if (copy_from_user(&tv, optval, sizeof(tv)))
+		if (copy_from_sockptr(&tv, optval, sizeof(tv)))
 			return -EFAULT;
 	}
 	if (tv.tv_usec < 0 || tv.tv_usec >= USEC_PER_SEC)
@@ -1050,12 +1051,14 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 	case SO_RCVTIMEO_OLD:
 	case SO_RCVTIMEO_NEW:
-		ret = sock_set_timeout(&sk->sk_rcvtimeo, optval, optlen, optname = SO_RCVTIMEO_OLD);
+		ret = sock_set_timeout(&sk->sk_rcvtimeo, USER_SOCKPTR(optval),
+				       optlen, optname = SO_RCVTIMEO_OLD);
 		break;
 
 	case SO_SNDTIMEO_OLD:
 	case SO_SNDTIMEO_NEW:
-		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen, optname = SO_SNDTIMEO_OLD);
+		ret = sock_set_timeout(&sk->sk_sndtimeo, USER_SOCKPTR(optval),
+				       optlen, optname = SO_SNDTIMEO_OLD);
 		break;
 
 	case SO_ATTACH_FILTER: {
-- 
2.27.0
