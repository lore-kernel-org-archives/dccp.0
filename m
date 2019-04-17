From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 17 Apr 2019 20:51:48 +0000
Subject: [PATCH v3 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <20190417205404.1877560-1-arnd@arndb.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The SIOCGSTAMP/SIOCGSTAMPNS ioctl commands are implemented by many
socket protocol handlers, and all of those end up calling the same
sock_get_timestamp()/sock_get_timestampns() helper functions, which
results in a lot of duplicate code.

With the introduction of 64-bit time_t on 32-bit architectures, this
gets worse, as we then need four different ioctl commands in each
socket protocol implementation.

To simplify that, let's add a new .gettstamp() operation in
struct proto_ops, and move ioctl implementation into the common
sock_ioctl()/compat_sock_ioctl_trans() functions that these all go
through.

We can reuse the sock_get_timestamp() implementation, but generalize
it so it can deal with both native and compat mode, as well as
timeval and timespec structures.

Acked-by: Stefan Schmidt <stefan@datenfreihafen.org>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
Link: https://lore.kernel.org/lkml/CAK8P3a038aDQQotzua_QtKGhq8O9n+rdiz2=WDCp82ys8eUT+A@mail.gmail.com/
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v3: add back sock_read_timestamp() that was accidentally dropped
v2: reworked to not break sparc64 support
---
 include/linux/net.h          |  2 ++
 include/net/compat.h         |  3 --
 include/net/sock.h           |  4 +--
 net/appletalk/ddp.c          |  7 +----
 net/atm/ioctl.c              | 16 ----------
 net/atm/pvc.c                |  1 +
 net/atm/svc.c                |  1 +
 net/ax25/af_ax25.c           |  9 +-----
 net/bluetooth/af_bluetooth.c |  8 -----
 net/bluetooth/l2cap_sock.c   |  1 +
 net/bluetooth/rfcomm/sock.c  |  1 +
 net/bluetooth/sco.c          |  1 +
 net/can/af_can.c             |  6 ----
 net/can/bcm.c                |  1 +
 net/can/raw.c                |  1 +
 net/compat.c                 | 57 ------------------------------------
 net/core/sock.c              | 51 +++++++++++++++++---------------
 net/dccp/ipv4.c              |  1 +
 net/dccp/ipv6.c              |  1 +
 net/ieee802154/socket.c      |  6 ++--
 net/ipv4/af_inet.c           |  9 ++----
 net/ipv6/af_inet6.c          |  8 ++---
 net/ipv6/raw.c               |  1 +
 net/l2tp/l2tp_ip.c           |  1 +
 net/l2tp/l2tp_ip6.c          |  1 +
 net/netrom/af_netrom.c       | 14 +--------
 net/packet/af_packet.c       |  7 ++---
 net/qrtr/qrtr.c              |  4 +--
 net/rose/af_rose.c           |  7 +----
 net/sctp/ipv6.c              |  1 +
 net/sctp/protocol.c          |  1 +
 net/socket.c                 | 48 +++++++++---------------------
 net/x25/af_x25.c             | 27 +----------------
 33 files changed, 75 insertions(+), 232 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index c606c72311d0..50bf5206ead6 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -161,6 +161,8 @@ struct proto_ops {
 	int	 	(*compat_ioctl) (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
 #endif
+	int		(*gettstamp) (struct socket *sock, void __user *userstamp,
+				      bool timeval, bool time32);
 	int		(*listen)    (struct socket *sock, int len);
 	int		(*shutdown)  (struct socket *sock, int flags);
 	int		(*setsockopt)(struct socket *sock, int level,
diff --git a/include/net/compat.h b/include/net/compat.h
index 4c6d75612b6c..f277653c7e17 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -30,9 +30,6 @@ struct compat_cmsghdr {
 	compat_int_t	cmsg_type;
 };
 
-int compat_sock_get_timestamp(struct sock *, struct timeval __user *);
-int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
-
 #else /* defined(CONFIG_COMPAT) */
 /*
  * To avoid compiler warnings:
diff --git a/include/net/sock.h b/include/net/sock.h
index 8de5ee258b93..d1fe105dcf42 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1607,6 +1607,8 @@ int sock_setsockopt(struct socket *sock, int level, int op,
 
 int sock_getsockopt(struct socket *sock, int level, int op,
 		    char __user *optval, int __user *optlen);
+int sock_gettstamp(struct socket *sock, void __user *userstamp,
+		   bool timeval, bool time32);
 struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 				    int noblock, int *errcode);
 struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
@@ -2493,8 +2495,6 @@ static inline bool sk_listener(const struct sock *sk)
 }
 
 void sock_enable_timestamp(struct sock *sk, int flag);
-int sock_get_timestamp(struct sock *, struct timeval __user *);
-int sock_get_timestampns(struct sock *, struct timespec __user *);
 int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len, int level,
 		       int type);
 
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 709d2542f729..e2511027d19b 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1806,12 +1806,6 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		rc = put_user(amount, (int __user *)argp);
 		break;
 	}
-	case SIOCGSTAMP:
-		rc = sock_get_timestamp(sk, argp);
-		break;
-	case SIOCGSTAMPNS:
-		rc = sock_get_timestampns(sk, argp);
-		break;
 	/* Routing */
 	case SIOCADDRT:
 	case SIOCDELRT:
@@ -1871,6 +1865,7 @@ static const struct proto_ops atalk_dgram_ops = {
 	.getname	= atalk_getname,
 	.poll		= datagram_poll,
 	.ioctl		= atalk_ioctl,
+	.gettstamp	= sock_gettstamp,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= atalk_compat_ioctl,
 #endif
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 2ff0e5e470e3..d955b683aa7c 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -81,22 +81,6 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
 				 (int __user *)argp) ? -EFAULT : 0;
 		goto done;
 	}
-	case SIOCGSTAMP: /* borrowed from IP */
-#ifdef CONFIG_COMPAT
-		if (compat)
-			error = compat_sock_get_timestamp(sk, argp);
-		else
-#endif
-			error = sock_get_timestamp(sk, argp);
-		goto done;
-	case SIOCGSTAMPNS: /* borrowed from IP */
-#ifdef CONFIG_COMPAT
-		if (compat)
-			error = compat_sock_get_timestampns(sk, argp);
-		else
-#endif
-			error = sock_get_timestampns(sk, argp);
-		goto done;
 	case ATM_SETSC:
 		net_warn_ratelimited("ATM_SETSC is obsolete; used by %s:%d\n",
 				     current->comm, task_pid_nr(current));
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index 2cb10af16afc..02bd2a436bdf 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -118,6 +118,7 @@ static const struct proto_ops pvc_proto_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = vcc_compat_ioctl,
 #endif
+	.gettstamp =	sock_gettstamp,
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
 	.setsockopt =	pvc_setsockopt,
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 2f91b766ac42..908cbb8654f5 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -641,6 +641,7 @@ static const struct proto_ops svc_proto_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	svc_compat_ioctl,
 #endif
+	.gettstamp =	sock_gettstamp,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
 	.setsockopt =	svc_setsockopt,
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 5d01edf8d819..449e7b7190c1 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1714,14 +1714,6 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		break;
 	}
 
-	case SIOCGSTAMP:
-		res = sock_get_timestamp(sk, argp);
-		break;
-
-	case SIOCGSTAMPNS:
-		res = sock_get_timestampns(sk, argp);
-		break;
-
 	case SIOCAX25ADDUID:	/* Add a uid to the uid/call map table */
 	case SIOCAX25DELUID:	/* Delete a uid from the uid/call map table */
 	case SIOCAX25GETUID: {
@@ -1950,6 +1942,7 @@ static const struct proto_ops ax25_proto_ops = {
 	.getname	= ax25_getname,
 	.poll		= datagram_poll,
 	.ioctl		= ax25_ioctl,
+	.gettstamp	= sock_gettstamp,
 	.listen		= ax25_listen,
 	.shutdown	= ax25_shutdown,
 	.setsockopt	= ax25_setsockopt,
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 8d12198eaa94..94ddf19998c7 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -521,14 +521,6 @@ int bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		err = put_user(amount, (int __user *) arg);
 		break;
 
-	case SIOCGSTAMP:
-		err = sock_get_timestamp(sk, (struct timeval __user *) arg);
-		break;
-
-	case SIOCGSTAMPNS:
-		err = sock_get_timestampns(sk, (struct timespec __user *) arg);
-		break;
-
 	default:
 		err = -ENOIOCTLCMD;
 		break;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index a3a2cd55e23a..dcb14abebeba 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1655,6 +1655,7 @@ static const struct proto_ops l2cap_sock_ops = {
 	.recvmsg	= l2cap_sock_recvmsg,
 	.poll		= bt_sock_poll,
 	.ioctl		= bt_sock_ioctl,
+	.gettstamp	= sock_gettstamp,
 	.mmap		= sock_no_mmap,
 	.socketpair	= sock_no_socketpair,
 	.shutdown	= l2cap_sock_shutdown,
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index b1f49fcc0478..90bb53aa4bee 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -1039,6 +1039,7 @@ static const struct proto_ops rfcomm_sock_ops = {
 	.setsockopt	= rfcomm_sock_setsockopt,
 	.getsockopt	= rfcomm_sock_getsockopt,
 	.ioctl		= rfcomm_sock_ioctl,
+	.gettstamp	= sock_gettstamp,
 	.poll		= bt_sock_poll,
 	.socketpair	= sock_no_socketpair,
 	.mmap		= sock_no_mmap
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 9a580999ca57..d894406a5c3b 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -1190,6 +1190,7 @@ static const struct proto_ops sco_sock_ops = {
 	.recvmsg	= sco_sock_recvmsg,
 	.poll		= bt_sock_poll,
 	.ioctl		= bt_sock_ioctl,
+	.gettstamp	= sock_gettstamp,
 	.mmap		= sock_no_mmap,
 	.socketpair	= sock_no_socketpair,
 	.shutdown	= sco_sock_shutdown,
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 1684ba5b51eb..e8fd5dc1780a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -89,13 +89,7 @@ static atomic_t skbcounter = ATOMIC_INIT(0);
 
 int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
-	struct sock *sk = sock->sk;
-
 	switch (cmd) {
-
-	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *)arg);
-
 	default:
 		return -ENOIOCTLCMD;
 	}
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 79bb8afa9c0c..a34ee52f19ea 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1689,6 +1689,7 @@ static const struct proto_ops bcm_ops = {
 	.getname       = sock_no_getname,
 	.poll          = datagram_poll,
 	.ioctl         = can_ioctl,	/* use can_ioctl() from af_can.c */
+	.gettstamp     = sock_gettstamp,
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = sock_no_setsockopt,
diff --git a/net/can/raw.c b/net/can/raw.c
index c70207537488..afcbff063a67 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -846,6 +846,7 @@ static const struct proto_ops raw_ops = {
 	.getname       = raw_getname,
 	.poll          = datagram_poll,
 	.ioctl         = can_ioctl,	/* use can_ioctl() from af_can.c */
+	.gettstamp     = sock_gettstamp,
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = raw_setsockopt,
diff --git a/net/compat.c b/net/compat.c
index eeea5eb71639..a031bd333092 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -395,63 +395,6 @@ COMPAT_SYSCALL_DEFINE5(setsockopt, int, fd, int, level, int, optname,
 	return __compat_sys_setsockopt(fd, level, optname, optval, optlen);
 }
 
-int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
-{
-	struct compat_timeval __user *ctv;
-	int err;
-	struct timeval tv;
-
-	if (COMPAT_USE_64BIT_TIME)
-		return sock_get_timestamp(sk, userstamp);
-
-	ctv = (struct compat_timeval __user *) userstamp;
-	err = -ENOENT;
-	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sock_read_timestamp(sk));
-
-	if (tv.tv_sec = -1)
-		return err;
-	if (tv.tv_sec = 0) {
-		ktime_t kt = ktime_get_real();
-		sock_write_timestamp(sk, kt);
-		tv = ktime_to_timeval(kt);
-	}
-	err = 0;
-	if (put_user(tv.tv_sec, &ctv->tv_sec) ||
-			put_user(tv.tv_usec, &ctv->tv_usec))
-		err = -EFAULT;
-	return err;
-}
-EXPORT_SYMBOL(compat_sock_get_timestamp);
-
-int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
-{
-	struct compat_timespec __user *ctv;
-	int err;
-	struct timespec ts;
-
-	if (COMPAT_USE_64BIT_TIME)
-		return sock_get_timestampns (sk, userstamp);
-
-	ctv = (struct compat_timespec __user *) userstamp;
-	err = -ENOENT;
-	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sock_read_timestamp(sk));
-	if (ts.tv_sec = -1)
-		return err;
-	if (ts.tv_sec = 0) {
-		ktime_t kt = ktime_get_real();
-		sock_write_timestamp(sk, kt);
-		ts = ktime_to_timespec(kt);
-	}
-	err = 0;
-	if (put_user(ts.tv_sec, &ctv->tv_sec) ||
-			put_user(ts.tv_nsec, &ctv->tv_nsec))
-		err = -EFAULT;
-	return err;
-}
-EXPORT_SYMBOL(compat_sock_get_timestampns);
-
 static int __compat_sys_getsockopt(int fd, int level, int optname,
 				   char __user *optval,
 				   int __user *optlen)
diff --git a/net/core/sock.c b/net/core/sock.c
index 782343bb925b..22f7d3e3c34e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2977,39 +2977,44 @@ bool lock_sock_fast(struct sock *sk)
 }
 EXPORT_SYMBOL(lock_sock_fast);
 
-int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
+int sock_gettstamp(struct socket *sock, void __user *userstamp,
+		   bool timeval, bool time32)
 {
-	struct timeval tv;
+	struct sock *sk = sock->sk;
+	struct timespec64 ts;
 
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sock_read_timestamp(sk));
-	if (tv.tv_sec = -1)
+	ts = ktime_to_timespec64(sock_read_timestamp(sk));
+	if (ts.tv_sec = -1)
 		return -ENOENT;
-	if (tv.tv_sec = 0) {
+	if (ts.tv_sec = 0) {
 		ktime_t kt = ktime_get_real();
-		sock_write_timestamp(sk, kt);
-		tv = ktime_to_timeval(kt);
+		sock_write_timestamp(sk, kt);;
+		ts = ktime_to_timespec64(kt);
 	}
-	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
-}
-EXPORT_SYMBOL(sock_get_timestamp);
 
-int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
-{
-	struct timespec ts;
+	if (timeval)
+		ts.tv_nsec /= 1000;
 
-	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sock_read_timestamp(sk));
-	if (ts.tv_sec = -1)
-		return -ENOENT;
-	if (ts.tv_sec = 0) {
-		ktime_t kt = ktime_get_real();
-		sock_write_timestamp(sk, kt);
-		ts = ktime_to_timespec(sk->sk_stamp);
+#ifdef CONFIG_COMPAT_32BIT_TIME
+	if (time32)
+		return put_old_timespec32(&ts, userstamp);
+#endif
+#ifdef CONFIG_SPARC64
+	/* beware of padding in sparc64 timeval */
+	if (timeval && !in_compat_syscall()) {
+		struct __kernel_old_timeval __user tv = {
+			.tv_sec = ts.tv_sec;
+			.tv_usec = ts.tv_nsec;
+		};
+		if (copy_to_user(userstamp, &tv, sizeof(tv))
+			return -EFAULT;
+		return 0;
 	}
-	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
+#endif
+	return put_timespec64(&ts, userstamp);
 }
-EXPORT_SYMBOL(sock_get_timestampns);
+EXPORT_SYMBOL(sock_gettstamp);
 
 void sock_enable_timestamp(struct sock *sk, int flag)
 {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 26a21d97b6b0..004535e4c070 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -991,6 +991,7 @@ static const struct proto_ops inet_dccp_ops = {
 	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
 	.poll		   = dccp_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	/* FIXME: work on inet_listen to rename it to sock_common_listen */
 	.listen		   = inet_dccp_listen,
 	.shutdown	   = inet_shutdown,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 57d84e9b7b6f..c4e4d1301062 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1075,6 +1075,7 @@ static const struct proto_ops inet6_dccp_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = dccp_poll,
 	.ioctl		   = inet6_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = inet_dccp_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index bc6b912603f1..ce2dfb997537 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -164,10 +164,6 @@ static int ieee802154_sock_ioctl(struct socket *sock, unsigned int cmd,
 	struct sock *sk = sock->sk;
 
 	switch (cmd) {
-	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *)arg);
-	case SIOCGSTAMPNS:
-		return sock_get_timestampns(sk, (struct timespec __user *)arg);
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 		return ieee802154_dev_ioctl(sk, (struct ifreq __user *)arg,
@@ -426,6 +422,7 @@ static const struct proto_ops ieee802154_raw_ops = {
 	.getname	   = sock_no_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = ieee802154_sock_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = sock_no_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
@@ -988,6 +985,7 @@ static const struct proto_ops ieee802154_dgram_ops = {
 	.getname	   = sock_no_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = ieee802154_sock_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = sock_no_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index eab3ebde981e..0f46d87715aa 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -911,12 +911,6 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct rtentry rt;
 
 	switch (cmd) {
-	case SIOCGSTAMP:
-		err = sock_get_timestamp(sk, (struct timeval __user *)arg);
-		break;
-	case SIOCGSTAMPNS:
-		err = sock_get_timestampns(sk, (struct timespec __user *)arg);
-		break;
 	case SIOCADDRT:
 	case SIOCDELRT:
 		if (copy_from_user(&rt, p, sizeof(struct rtentry)))
@@ -988,6 +982,7 @@ const struct proto_ops inet_stream_ops = {
 	.getname	   = inet_getname,
 	.poll		   = tcp_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = inet_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
@@ -1023,6 +1018,7 @@ const struct proto_ops inet_dgram_ops = {
 	.getname	   = inet_getname,
 	.poll		   = udp_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
@@ -1055,6 +1051,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.getname	   = inet_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2f45d2a3e3a3..6d1133fd89f6 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -546,12 +546,6 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct net *net = sock_net(sk);
 
 	switch (cmd) {
-	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *)arg);
-
-	case SIOCGSTAMPNS:
-		return sock_get_timestampns(sk, (struct timespec __user *)arg);
-
 	case SIOCADDRT:
 	case SIOCDELRT:
 
@@ -584,6 +578,7 @@ const struct proto_ops inet6_stream_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = tcp_poll,			/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = inet_listen,		/* ok		*/
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
@@ -617,6 +612,7 @@ const struct proto_ops inet6_dgram_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = udp_poll,			/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,		/* ok		*/
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5a426226c762..84dbe21b71e5 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1356,6 +1356,7 @@ const struct proto_ops inet6_sockraw_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = datagram_poll,		/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,		/* ok		*/
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index d4c60523c549..2cac910c1cd4 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -618,6 +618,7 @@ static const struct proto_ops l2tp_ip_ops = {
 	.getname	   = l2tp_ip_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 37a69df17cab..4ec546cc1dd6 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -752,6 +752,7 @@ static const struct proto_ops l2tp_ip6_ops = {
 	.getname	   = l2tp_ip6_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet6_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 1d3144d19903..4e97bbbf1916 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1199,7 +1199,6 @@ static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	void __user *argp = (void __user *)arg;
-	int ret;
 
 	switch (cmd) {
 	case TIOCOUTQ: {
@@ -1225,18 +1224,6 @@ static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return put_user(amount, (int __user *)argp);
 	}
 
-	case SIOCGSTAMP:
-		lock_sock(sk);
-		ret = sock_get_timestamp(sk, argp);
-		release_sock(sk);
-		return ret;
-
-	case SIOCGSTAMPNS:
-		lock_sock(sk);
-		ret = sock_get_timestampns(sk, argp);
-		release_sock(sk);
-		return ret;
-
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
@@ -1362,6 +1349,7 @@ static const struct proto_ops nr_proto_ops = {
 	.getname	=	nr_getname,
 	.poll		=	datagram_poll,
 	.ioctl		=	nr_ioctl,
+	.gettstamp	=	sock_gettstamp,
 	.listen		=	nr_listen,
 	.shutdown	=	sock_no_shutdown,
 	.setsockopt	=	nr_setsockopt,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9419c5cf4de5..b012dc5ffb6e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4077,11 +4077,6 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		return put_user(amount, (int __user *)arg);
 	}
-	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *)arg);
-	case SIOCGSTAMPNS:
-		return sock_get_timestampns(sk, (struct timespec __user *)arg);
-
 #ifdef CONFIG_INET
 	case SIOCADDRT:
 	case SIOCDELRT:
@@ -4457,6 +4452,7 @@ static const struct proto_ops packet_ops_spkt = {
 	.getname =	packet_getname_spkt,
 	.poll =		datagram_poll,
 	.ioctl =	packet_ioctl,
+	.gettstamp =	sock_gettstamp,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	sock_no_setsockopt,
@@ -4478,6 +4474,7 @@ static const struct proto_ops packet_ops = {
 	.getname =	packet_getname,
 	.poll =		packet_poll,
 	.ioctl =	packet_ioctl,
+	.gettstamp =	sock_gettstamp,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	packet_setsockopt,
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index b37e6e0a1026..7c5e8292cc0a 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -968,9 +968,6 @@ static int qrtr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			break;
 		}
 		break;
-	case SIOCGSTAMP:
-		rc = sock_get_timestamp(sk, argp);
-		break;
 	case SIOCADDRT:
 	case SIOCDELRT:
 	case SIOCSIFADDR:
@@ -1033,6 +1030,7 @@ static const struct proto_ops qrtr_proto_ops = {
 	.recvmsg	= qrtr_recvmsg,
 	.getname	= qrtr_getname,
 	.ioctl		= qrtr_ioctl,
+	.gettstamp	= sock_gettstamp,
 	.poll		= datagram_poll,
 	.shutdown	= sock_no_shutdown,
 	.setsockopt	= sock_no_setsockopt,
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index c96f63ffe31e..e274bc6e1458 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1301,12 +1301,6 @@ static int rose_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return put_user(amount, (unsigned int __user *) argp);
 	}
 
-	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *) argp);
-
-	case SIOCGSTAMPNS:
-		return sock_get_timestampns(sk, (struct timespec __user *) argp);
-
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
@@ -1474,6 +1468,7 @@ static const struct proto_ops rose_proto_ops = {
 	.getname	=	rose_getname,
 	.poll		=	datagram_poll,
 	.ioctl		=	rose_ioctl,
+	.gettstamp	=	sock_gettstamp,
 	.listen		=	rose_listen,
 	.shutdown	=	sock_no_shutdown,
 	.setsockopt	=	rose_setsockopt,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 6200cd2b4b99..188c47eb206e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -1030,6 +1030,7 @@ static const struct proto_ops inet6_seqpacket_ops = {
 	.getname	   = sctp_getname,
 	.poll		   = sctp_poll,
 	.ioctl		   = inet6_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sctp_inet_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 951afdeea5e9..f0631bf486b6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1026,6 +1026,7 @@ static const struct proto_ops inet_seqpacket_ops = {
 	.getname	   = inet_getname,	/* Semantics are different.  */
 	.poll		   = sctp_poll,
 	.ioctl		   = inet_ioctl,
+	.gettstamp	   = sock_gettstamp,
 	.listen		   = sctp_inet_listen,
 	.shutdown	   = inet_shutdown,	/* Looks harmless.  */
 	.setsockopt	   = sock_common_setsockopt, /* IP_SOL IP_OPTION is a problem */
diff --git a/net/socket.c b/net/socket.c
index 8255f5bda0aa..ab624d42ead5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1164,6 +1164,15 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 
 			err = open_related_ns(&net->ns, get_net_ns);
 			break;
+		case SIOCGSTAMP:
+		case SIOCGSTAMPNS:
+			if (!sock->ops->gettstamp) {
+				err = -ENOIOCTLCMD;
+				break;
+			}
+			err = sock->ops->gettstamp(sock, argp,
+						   cmd = SIOCGSTAMP, false);
+			break;
 		default:
 			err = sock_do_ioctl(net, sock, cmd, arg);
 			break;
@@ -2916,38 +2925,6 @@ void socket_seq_show(struct seq_file *seq)
 #endif				/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_COMPAT
-static int do_siocgstamp(struct net *net, struct socket *sock,
-			 unsigned int cmd, void __user *up)
-{
-	mm_segment_t old_fs = get_fs();
-	struct timeval ktv;
-	int err;
-
-	set_fs(KERNEL_DS);
-	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&ktv);
-	set_fs(old_fs);
-	if (!err)
-		err = compat_put_timeval(&ktv, up);
-
-	return err;
-}
-
-static int do_siocgstampns(struct net *net, struct socket *sock,
-			   unsigned int cmd, void __user *up)
-{
-	mm_segment_t old_fs = get_fs();
-	struct timespec kts;
-	int err;
-
-	set_fs(KERNEL_DS);
-	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&kts);
-	set_fs(old_fs);
-	if (!err)
-		err = compat_put_timespec(&kts, up);
-
-	return err;
-}
-
 static int compat_dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 {
 	struct compat_ifconf ifc32;
@@ -3348,9 +3325,12 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCDELRT:
 		return routing_ioctl(net, sock, cmd, argp);
 	case SIOCGSTAMP:
-		return do_siocgstamp(net, sock, cmd, argp);
 	case SIOCGSTAMPNS:
-		return do_siocgstampns(net, sock, cmd, argp);
+		if (!sock->ops->gettstamp)
+			return -ENOIOCTLCMD;
+		return sock->ops->gettstamp(sock, argp, cmd = SIOCGSTAMP,
+					    !COMPAT_USE_64BIT_TIME);
+
 	case SIOCBONDSLAVEINFOQUERY:
 	case SIOCBONDINFOQUERY:
 	case SIOCSHWTSTAMP:
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 20a511398389..0ea48a52ce79 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1398,18 +1398,6 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		break;
 	}
 
-	case SIOCGSTAMP:
-		rc = -EINVAL;
-		if (sk)
-			rc = sock_get_timestamp(sk,
-						(struct timeval __user *)argp);
-		break;
-	case SIOCGSTAMPNS:
-		rc = -EINVAL;
-		if (sk)
-			rc = sock_get_timestampns(sk,
-					(struct timespec __user *)argp);
-		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
@@ -1681,8 +1669,6 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 				unsigned long arg)
 {
 	void __user *argp = compat_ptr(arg);
-	struct sock *sk = sock->sk;
-
 	int rc = -ENOIOCTLCMD;
 
 	switch(cmd) {
@@ -1690,18 +1676,6 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 	case TIOCINQ:
 		rc = x25_ioctl(sock, cmd, (unsigned long)argp);
 		break;
-	case SIOCGSTAMP:
-		rc = -EINVAL;
-		if (sk)
-			rc = compat_sock_get_timestamp(sk,
-					(struct timeval __user*)argp);
-		break;
-	case SIOCGSTAMPNS:
-		rc = -EINVAL;
-		if (sk)
-			rc = compat_sock_get_timestampns(sk,
-					(struct timespec __user*)argp);
-		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
@@ -1765,6 +1739,7 @@ static const struct proto_ops x25_proto_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_x25_ioctl,
 #endif
+	.gettstamp =	sock_gettstamp,
 	.listen =	x25_listen,
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	x25_setsockopt,
-- 
2.20.0
