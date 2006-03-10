From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 2/9] [ICSK] compat: Introduce inet_csk_compat_[gs]etsockopt
Message-Id: <1142025737600-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 include/net/inet_connection_sock.h |    5 +++++
 net/dccp/proto.c                   |   23 +++++++----------------
 net/ipv4/inet_connection_sock.c    |   30 ++++++++++++++++++++++++++++++
 net/ipv4/tcp.c                     |   26 ++++++--------------------
 4 files changed, 48 insertions(+), 36 deletions(-)

58044045b103c91119a33e3630c9fa5289069422
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 573fbc3..f0ba05b 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -331,4 +331,9 @@ extern int inet_csk_ctl_sock_create(stru
 				    unsigned short family,
 				    unsigned short type,
 				    unsigned char protocol);
+
+extern int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
+				      char __user *optval, int __user *optlen);
+extern int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
+				      char __user *optval, int optlen);
 #endif /* _INET_CONNECTION_SOCK_H */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a8b98be..3e9b710 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -522,14 +522,10 @@ EXPORT_SYMBOL_GPL(dccp_setsockopt);
 int compat_dccp_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int optlen)
 {
-	if (level != SOL_DCCP) {
-		if (inet_csk(sk)->icsk_af_ops->compat_setsockopt)
-			return inet_csk(sk)->icsk_af_ops->compat_setsockopt(sk,
-				level, optname, optval, optlen);
-		else
-			return inet_csk(sk)->icsk_af_ops->setsockopt(sk,
-				level, optname, optval, optlen);
-	}
+	if (level != SOL_DCCP)
+		return inet_csk_compat_setsockopt(sk, level, optname,
+						  optval, optlen);
+
 	return do_dccp_setsockopt(sk, level, optname, optval, optlen);
 }
 EXPORT_SYMBOL_GPL(compat_dccp_setsockopt);
@@ -619,14 +615,9 @@ EXPORT_SYMBOL_GPL(dccp_getsockopt);
 int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
-	if (level != SOL_DCCP) {
-		if (inet_csk(sk)->icsk_af_ops->compat_setsockopt)
-			return inet_csk(sk)->icsk_af_ops->compat_getsockopt(sk,
-				level, optname, optval, optlen);
-		else
-			return inet_csk(sk)->icsk_af_ops->getsockopt(sk,
-				level, optname, optval, optlen);
-	}
+	if (level != SOL_DCCP)
+		return inet_csk_compat_getsockopt(sk, level, optname,
+						  optval, optlen);
 	return do_dccp_getsockopt(sk, level, optname, optval, optlen);
 }
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 359f48c..9f6b44c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -667,3 +667,33 @@ int inet_csk_ctl_sock_create(struct sock
 }
 
 EXPORT_SYMBOL_GPL(inet_csk_ctl_sock_create);
+
+#ifdef CONFIG_COMPAT
+int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
+			       char __user *optval, int __user *optlen)
+{
+	const struct inet_csk *icsk = inet_csk(sk);
+
+	if (icsk->icsk_af_ops->compat_getsockopt != NULL)
+		return icsk->icsk_af_ops->compat_getsockopt(sk, level, optname,
+							    optval, optlen);
+	return icsk->icsk_af_ops->getsockopt(sk, level, optname,
+					     optval, optlen);
+}
+
+EXPORT_SYMBOL_GPL(inet_csk_compat_getsockopt);
+
+int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
+			       char __user *optval, int optlen)
+{
+	const struct inet_csk *icsk = inet_csk(sk);
+
+	if (icsk->icsk_af_ops->compat_setsockopt != NULL)
+		return icsk->icsk_af_ops->compat_setsockopt(sk, level, optname,
+							    optval, optlen);
+	return icsk->icsk_af_ops->setsockopt(sk, level, optname,
+					     optval, optlen);
+}
+
+EXPORT_SYMBOL_GPL(inet_csk_compat_setsockopt);
+#endif
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 31b0123..89da253 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1882,16 +1882,9 @@ int tcp_setsockopt(struct sock *sk, int 
 int compat_tcp_setsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, int optlen)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
-	if (level != SOL_TCP) {
-		if (icsk->icsk_af_ops->compat_setsockopt)
-			return icsk->icsk_af_ops->compat_setsockopt(sk,
-				level, optname, optval, optlen);
-		else
-			return icsk->icsk_af_ops->setsockopt(sk,
-				level, optname, optval, optlen);
-	}
+	if (level != SOL_TCP)
+		return inet_csk_compat_setsockopt(sk, level, optname,
+						  optval, optlen);
 	return do_tcp_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -2061,16 +2054,9 @@ int tcp_getsockopt(struct sock *sk, int 
 int compat_tcp_getsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, int __user *optlen)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
-	if (level != SOL_TCP) {
-		if (icsk->icsk_af_ops->compat_getsockopt)
-			return icsk->icsk_af_ops->compat_getsockopt(sk,
-				level, optname, optval, optlen);
-		else
-			return icsk->icsk_af_ops->getsockopt(sk,
-				level, optname, optval, optlen);
-	}
+	if (level != SOL_TCP)
+		return inet_csk_compat_getsockopt(sk, level, optname,
+						  optval, optlen);
 	return do_tcp_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
-- 
1.2.2.gd27d


