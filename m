From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 11 Dec 2005 13:57:08 +0000
Subject: [PATCH 3/4][TWSK]: Introduce struct timewait_sock_ops
Message-Id: <39e6f6c70512110557oea9e566u7d1b7e4fda9ab9d2@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_29639_8226470.1134309428764"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_29639_8226470.1134309428764
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_29639_8226470.1134309428764
Content-Type: text/x-patch; name=3.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="3.patch"

tree a2bd0ce30e3dd56e9605fe508af4dc18eac9445f
parent 384beca5393a67bab83c2825fe354791b6a27052
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134307585 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134307585 -0200

[TWSK]: Introduce struct timewait_sock_ops

So that we can share several timewait sockets related functions and make the
timewait mini sockets infrastructure closer to the request mini sockets one.

Next changesets will take advantage of this, moving more code out of TCP and
DCCP v4 and v6 to common infrastructure.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/linux/ipv6.h             |    3 +
 include/net/inet_timewait_sock.h |    3 +
 include/net/sock.h               |    4 +-
 include/net/tcp.h                |    3 +
 include/net/timewait_sock.h      |   31 +++++++++++++++++
 net/core/sock.c                  |   21 ++++++-----
 net/dccp/ipv4.c                  |    9 ++++
 net/dccp/ipv6.c                  |    6 ++-
 net/ipv4/inet_timewait_sock.c    |    5 +-
 net/ipv4/tcp_ipv4.c              |   71 +++++++++++++++++++++++----------------
 net/ipv6/tcp_ipv6.c              |   25 ++++---------
 11 files changed, 118 insertions(+), 63 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7d39085..a0d0489 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -360,7 +360,8 @@ struct tcp6_timewait_sock {
 
 static inline u16 inet6_tw_offset(const struct proto *prot)
 {
-	return prot->twsk_obj_size - sizeof(struct inet6_timewait_sock);
+	return prot->twsk_prot->twsk_obj_size -
+			sizeof(struct inet6_timewait_sock);
 }
 
 static inline struct inet6_timewait_sock *inet6_twsk(const struct sock *sk)
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index ca240f8..e396a65 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -26,6 +26,7 @@
 
 #include <net/sock.h>
 #include <net/tcp_states.h>
+#include <net/timewait_sock.h>
 
 #include <asm/atomic.h>
 
@@ -200,7 +201,7 @@ static inline void inet_twsk_put(struct 
 		printk(KERN_DEBUG "%s timewait_sock %p released\n",
 		       tw->tw_prot->name, tw);
 #endif
-		kmem_cache_free(tw->tw_prot->twsk_slab, tw);
+		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 		module_put(owner);
 	}
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index 6036340..d7910e7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -493,6 +493,7 @@ extern void sk_stream_kill_queues(struct
 extern int sk_wait_data(struct sock *sk, long *timeo);
 
 struct request_sock_ops;
+struct timewait_sock_ops;
 
 /* Networking protocol blocks we attach to sockets.
  * socket layer -> transport layer interface
@@ -557,11 +558,10 @@ struct proto {
 	kmem_cache_t		*slab;
 	unsigned int		obj_size;
 
-	kmem_cache_t		*twsk_slab;
-	unsigned int		twsk_obj_size;
 	atomic_t		*orphan_count;
 
 	struct request_sock_ops	*rsk_prot;
+	struct timewait_sock_ops *twsk_prot;
 
 	struct module		*owner;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 83b117a..176221c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -287,6 +287,9 @@ extern int			tcp_rcv_established(struct 
 
 extern void			tcp_rcv_space_adjust(struct sock *sk);
 
+extern int			tcp_twsk_unique(struct sock *sk,
+						struct sock *sktw, void *twp);
+
 static inline void tcp_dec_quickack_mode(struct sock *sk,
 					 const unsigned int pkts)
 {
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
new file mode 100644
index 0000000..2544281
--- /dev/null
+++ b/include/net/timewait_sock.h
@@ -0,0 +1,31 @@
+/*
+ * NET		Generic infrastructure for Network protocols.
+ *
+ * Authors:	Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+#ifndef _TIMEWAIT_SOCK_H
+#define _TIMEWAIT_SOCK_H
+
+#include <linux/slab.h>
+#include <net/sock.h>
+
+struct timewait_sock_ops {
+	kmem_cache_t	*twsk_slab;
+	unsigned int	twsk_obj_size;
+	int		(*twsk_unique)(struct sock *sk,
+				       struct sock *sktw, void *twp);
+};
+
+static inline int twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
+{
+	if (sk->sk_prot->twsk_prot->twsk_unique != NULL)
+		return sk->sk_prot->twsk_prot->twsk_unique(sk, sktw, twp);
+	return 0;
+}
+
+#endif /* _TIMEWAIT_SOCK_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 13cc3be..6465b0e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1488,7 +1488,7 @@ int proto_register(struct proto *prot, i
 			}
 		}
 
-		if (prot->twsk_obj_size) {
+		if (prot->twsk_prot != NULL) {
 			static const char mask[] = "tw_sock_%s";
 
 			timewait_sock_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
@@ -1497,11 +1497,12 @@ int proto_register(struct proto *prot, i
 				goto out_free_request_sock_slab;
 
 			sprintf(timewait_sock_slab_name, mask, prot->name);
-			prot->twsk_slab = kmem_cache_create(timewait_sock_slab_name,
-							    prot->twsk_obj_size,
-							    0, SLAB_HWCACHE_ALIGN,
-							    NULL, NULL);
-			if (prot->twsk_slab == NULL)
+			prot->twsk_prot->twsk_slab =
+				kmem_cache_create(timewait_sock_slab_name,
+						  prot->twsk_prot->twsk_obj_size,
+						  0, SLAB_HWCACHE_ALIGN,
+						  NULL, NULL);
+			if (prot->twsk_prot->twsk_slab == NULL)
 				goto out_free_timewait_sock_slab_name;
 		}
 	}
@@ -1548,12 +1549,12 @@ void proto_unregister(struct proto *prot
 		prot->rsk_prot->slab = NULL;
 	}
 
-	if (prot->twsk_slab != NULL) {
-		const char *name = kmem_cache_name(prot->twsk_slab);
+	if (prot->twsk_prot != NULL && prot->twsk_prot->twsk_slab != NULL) {
+		const char *name = kmem_cache_name(prot->twsk_prot->twsk_slab);
 
-		kmem_cache_destroy(prot->twsk_slab);
+		kmem_cache_destroy(prot->twsk_prot->twsk_slab);
 		kfree(name);
-		prot->twsk_slab = NULL;
+		prot->twsk_prot->twsk_slab = NULL;
 	}
 }
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index acdd96c..f8c6a15 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -20,6 +20,7 @@
 #include <net/icmp.h>
 #include <net/inet_hashtables.h>
 #include <net/sock.h>
+#include <net/timewait_sock.h>
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
 
@@ -1309,6 +1310,10 @@ static struct request_sock_ops dccp_requ
 	.send_reset	= dccp_v4_ctl_send_reset,
 };
 
+static struct timewait_sock_ops dccp_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
+};
+
 struct proto dccp_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
@@ -1332,5 +1337,7 @@ struct proto dccp_prot = {
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp_sock),
 	.rsk_prot		= &dccp_request_sock_ops,
-	.twsk_obj_size		= sizeof(struct inet_timewait_sock),
+	.twsk_prot		= &dccp_timewait_sock_ops,
 };
+
+EXPORT_SYMBOL_GPL(dccp_prot);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 23058dc..34e7f64 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -652,6 +652,10 @@ static struct request_sock_ops dccp6_req
 	.send_reset	= dccp_v6_ctl_send_reset,
 };
 
+static struct timewait_sock_ops dccp6_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct dccp6_timewait_sock),
+};
+
 static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1361,7 +1365,7 @@ static struct proto dccp_v6_prot = {
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp6_sock),
 	.rsk_prot		= &dccp6_request_sock_ops,
-	.twsk_obj_size		= sizeof(struct dccp6_timewait_sock),
+	.twsk_prot		= &dccp6_timewait_sock_ops,
 };
 
 static struct inet6_protocol dccp_v6_protocol = {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a010e9a..417f126 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -90,8 +90,9 @@ EXPORT_SYMBOL_GPL(__inet_twsk_hashdance)
 
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int state)
 {
-	struct inet_timewait_sock *tw = kmem_cache_alloc(sk->sk_prot_creator->twsk_slab,
-							 SLAB_ATOMIC);
+	struct inet_timewait_sock *tw =
+		kmem_cache_alloc(sk->sk_prot_creator->twsk_prot->twsk_slab,
+				 SLAB_ATOMIC);
 	if (tw != NULL) {
 		const struct inet_sock *inet = inet_sk(sk);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0b5ab04..6728772 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -69,6 +69,7 @@
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 #include <net/inet_common.h>
+#include <net/timewait_sock.h>
 #include <net/xfrm.h>
 
 #include <linux/inet.h>
@@ -118,6 +119,39 @@ static inline __u32 tcp_v4_init_sequence
 					  skb->h.th->source);
 }
 
+int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
+{
+	const struct tcp_timewait_sock *tcptw = tcp_twsk(sktw);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* With PAWS, it is safe from the viewpoint
+	   of data integrity. Even without PAWS it is safe provided sequence
+	   spaces do not overlap i.e. at data rates <= 80Mbit/sec.
+
+	   Actually, the idea is close to VJ's one, only timestamp cache is
+	   held not per host, but per port pair and TW bucket is used as state
+	   holder.
+
+	   If TW bucket has been already destroyed we fall back to VJ's scheme
+	   and use initial timestamp retrieved from peer table.
+	 */
+	if (tcptw->tw_ts_recent_stamp &&
+	    (twp == NULL || (sysctl_tcp_tw_reuse &&
+			     xtime.tv_sec - tcptw->tw_ts_recent_stamp > 1))) {
+		tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
+		if (tp->write_seq == 0)
+			tp->write_seq = 1;
+		tp->rx_opt.ts_recent	   = tcptw->tw_ts_recent;
+		tp->rx_opt.ts_recent_stamp = tcptw->tw_ts_recent_stamp;
+		sock_hold(sktw);
+		return 1;
+	}
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(tcp_twsk_unique);
+
 /* called with local bh disabled */
 static int __tcp_v4_check_established(struct sock *sk, __u16 lport,
 				      struct inet_timewait_sock **twp)
@@ -142,35 +176,9 @@ static int __tcp_v4_check_established(st
 		tw = inet_twsk(sk2);
 
 		if (INET_TW_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif)) {
-			const struct tcp_timewait_sock *tcptw = tcp_twsk(sk2);
-			struct tcp_sock *tp = tcp_sk(sk);
-
-			/* With PAWS, it is safe from the viewpoint
-			   of data integrity. Even without PAWS it
-			   is safe provided sequence spaces do not
-			   overlap i.e. at data rates <= 80Mbit/sec.
-
-			   Actually, the idea is close to VJ's one,
-			   only timestamp cache is held not per host,
-			   but per port pair and TW bucket is used
-			   as state holder.
-
-			   If TW bucket has been already destroyed we
-			   fall back to VJ's scheme and use initial
-			   timestamp retrieved from peer table.
-			 */
-			if (tcptw->tw_ts_recent_stamp &&
-			    (!twp || (sysctl_tcp_tw_reuse &&
-				      xtime.tv_sec -
-				      tcptw->tw_ts_recent_stamp > 1))) {
-				tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
-				if (tp->write_seq == 0)
-					tp->write_seq = 1;
-				tp->rx_opt.ts_recent	   = tcptw->tw_ts_recent;
-				tp->rx_opt.ts_recent_stamp = tcptw->tw_ts_recent_stamp;
-				sock_hold(sk2);
+			if (twsk_unique(sk, sk2, twp))
 				goto unique;
-			} else
+			else
 				goto not_unique;
 		}
 	}
@@ -869,6 +877,11 @@ struct request_sock_ops tcp_request_sock
 	.send_reset	=	tcp_v4_send_reset,
 };
 
+static struct timewait_sock_ops tcp_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
+	.twsk_unique	= tcp_twsk_unique,
+};
+
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq;
@@ -1979,7 +1992,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
-	.twsk_obj_size		= sizeof(struct tcp_timewait_sock),
+	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4c4983c..7a077de 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -60,6 +60,7 @@
 #include <net/addrconf.h>
 #include <net/snmp.h>
 #include <net/dsfield.h>
+#include <net/timewait_sock.h>
 
 #include <asm/uaccess.h>
 
@@ -147,22 +148,9 @@ static int __tcp_v6_check_established(st
 		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	&&
 		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr)	&&
 		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
-			const struct tcp_timewait_sock *tcptw = tcp_twsk(sk2);
-			struct tcp_sock *tp = tcp_sk(sk);
-
-			if (tcptw->tw_ts_recent_stamp &&
-			    (!twp ||
-			     (sysctl_tcp_tw_reuse &&
-			      xtime.tv_sec - tcptw->tw_ts_recent_stamp > 1))) {
-				/* See comment in tcp_ipv4.c */
-				tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
-				if (!tp->write_seq)
-					tp->write_seq = 1;
-				tp->rx_opt.ts_recent	   = tcptw->tw_ts_recent;
-				tp->rx_opt.ts_recent_stamp = tcptw->tw_ts_recent_stamp;
-				sock_hold(sk2);
+			if (twsk_unique(sk, sk2, twp))
 				goto unique;
-			} else
+			else
 				goto not_unique;
 		}
 	}
@@ -711,6 +699,11 @@ static struct request_sock_ops tcp6_requ
 	.send_reset	=	tcp_v6_send_reset
 };
 
+static struct timewait_sock_ops tcp6_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
+	.twsk_unique	= tcp_twsk_unique,
+};
+
 static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1753,7 +1746,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
-	.twsk_obj_size		= sizeof(struct tcp6_timewait_sock),
+	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 };
 

------=_Part_29639_8226470.1134309428764--
