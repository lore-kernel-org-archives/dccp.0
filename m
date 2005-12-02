From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 02 Dec 2005 01:12:38 +0000
Subject: [PATCH 5/6][ICSK]: Move v4_addr2sockaddr from TCP to icsk
Message-Id: <39e6f6c70512011712p7c4db686ob904556cac128456@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37574_30047521.1133485958406"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37574_30047521.1133485958406
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

     Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_37574_30047521.1133485958406
Content-Type: text/x-patch; name=5.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="5.patch"

tree 3f70eeccfa29ead14246583618a038d29c579a60
parent f52bb940239fc4078639e598da06c42f0c9add16
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1133483850 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1133483850 -0200

[ICSK]: Move v4_addr2sockaddr from TCP to icsk

Renaming it to inet_csk_addr2sockaddr.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/net/inet_connection_sock.h |    2 ++
 net/ipv4/inet_connection_sock.c    |   12 ++++++++++++
 net/ipv4/tcp_ipv4.c                |   12 +-----------
 3 files changed, 15 insertions(+), 11 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 9e20d20..e50e2b8 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -303,4 +303,6 @@ static inline unsigned int inet_csk_list
 extern int  inet_csk_listen_start(struct sock *sk, const int nr_table_entries);
 extern void inet_csk_listen_stop(struct sock *sk);
 
+extern void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
+
 #endif /* _INET_CONNECTION_SOCK_H */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index e2bf508..ae20281 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -636,3 +636,15 @@ void inet_csk_listen_stop(struct sock *s
 }
 
 EXPORT_SYMBOL_GPL(inet_csk_listen_stop);
+
+void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)uaddr;
+	const struct inet_sock *inet = inet_sk(sk);
+
+	sin->sin_family		= AF_INET;
+	sin->sin_addr.s_addr	= inet->daddr;
+	sin->sin_port		= inet->dport;
+}
+
+EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 704cf21..0b5ab04 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1314,16 +1314,6 @@ do_time_wait:
 	goto discard_it;
 }
 
-static void v4_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
-{
-	struct sockaddr_in *sin = (struct sockaddr_in *) uaddr;
-	struct inet_sock *inet = inet_sk(sk);
-
-	sin->sin_family		= AF_INET;
-	sin->sin_addr.s_addr	= inet->daddr;
-	sin->sin_port		= inet->dport;
-}
-
 /* VJ's idea. Save last timestamp seen from this destination
  * and hold it at least for normal timewait interval to use for duplicate
  * segment detection in subsequent connections, before they enter synchronized
@@ -1392,7 +1382,7 @@ struct inet_connection_sock_af_ops ipv4_
 	.net_header_len	=	sizeof(struct iphdr),
 	.setsockopt	=	ip_setsockopt,
 	.getsockopt	=	ip_getsockopt,
-	.addr2sockaddr	=	v4_addr2sockaddr,
+	.addr2sockaddr	=	inet_csk_addr2sockaddr,
 	.sockaddr_len	=	sizeof(struct sockaddr_in),
 };
 

------=_Part_37574_30047521.1133485958406--
