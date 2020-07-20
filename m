From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:18 +0000
Subject: [PATCH 05/24] net: switch sock_setbindtodevice to sockptr_t
Message-Id: <20200720124737.118617-6-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/core/sock.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 91224709869389..bd20fc5cce0850 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -608,8 +608,7 @@ int sock_bindtoindex(struct sock *sk, int ifindex, bool lock_sk)
 }
 EXPORT_SYMBOL(sock_bindtoindex);
 
-static int sock_setbindtodevice(struct sock *sk, char __user *optval,
-				int optlen)
+static int sock_setbindtodevice(struct sock *sk, sockptr_t optval, int optlen)
 {
 	int ret = -ENOPROTOOPT;
 #ifdef CONFIG_NETDEVICES
@@ -631,7 +630,7 @@ static int sock_setbindtodevice(struct sock *sk, char __user *optval,
 	memset(devname, 0, sizeof(devname));
 
 	ret = -EFAULT;
-	if (copy_from_user(devname, optval, optlen))
+	if (copy_from_sockptr(devname, optval, optlen))
 		goto out;
 
 	index = 0;
@@ -839,7 +838,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	 */
 
 	if (optname = SO_BINDTODEVICE)
-		return sock_setbindtodevice(sk, optval, optlen);
+		return sock_setbindtodevice(sk, USER_SOCKPTR(optval), optlen);
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
-- 
2.27.0
