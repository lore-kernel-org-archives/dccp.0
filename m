From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 3/7] [DCCP]: Move dccp_[un]hash from ipv4.c to the core
Message-Id: <11407327783344-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As this is used by both ipv4 and ipv6 and is not ipv4 specific.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/dccp.h  |    1 +
 net/dccp/ipv4.c  |   14 +-------------
 net/dccp/ipv6.c  |    2 +-
 net/dccp/proto.c |   14 ++++++++++++++
 4 files changed, 17 insertions(+), 14 deletions(-)

5f50d3a8059644b039b19a43200800783658e130
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 8f3903b..b6ea4cc 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -238,6 +238,7 @@ extern struct sk_buff	*dccp_make_respons
 
 extern int	   dccp_connect(struct sock *sk);
 extern int	   dccp_disconnect(struct sock *sk, int flags);
+extern void	   dccp_hash(struct sock *sk);
 extern void	   dccp_unhash(struct sock *sk);
 extern int	   dccp_getsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int __user *optlen);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b26a4f8..34d1b11 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -44,18 +44,6 @@ static int dccp_v4_get_port(struct sock 
 				 inet_csk_bind_conflict);
 }
 
-static void dccp_v4_hash(struct sock *sk)
-{
-	inet_hash(&dccp_hashinfo, sk);
-}
-
-void dccp_unhash(struct sock *sk)
-{
-	inet_unhash(&dccp_hashinfo, sk);
-}
-
-EXPORT_SYMBOL_GPL(dccp_unhash);
-
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1048,7 +1036,7 @@ struct proto dccp_prot = {
 	.sendmsg		= dccp_sendmsg,
 	.recvmsg		= dccp_recvmsg,
 	.backlog_rcv		= dccp_v4_do_rcv,
-	.hash			= dccp_v4_hash,
+	.hash			= dccp_hash,
 	.unhash			= dccp_unhash,
 	.accept			= inet_csk_accept,
 	.get_port		= dccp_v4_get_port,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 84651bc..904967b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -53,7 +53,7 @@ static void dccp_v6_hash(struct sock *sk
 {
 	if (sk->sk_state != DCCP_CLOSED) {
 		if (inet_csk(sk)->icsk_af_ops = &dccp_ipv6_mapped) {
-			dccp_prot.hash(sk);
+			dccp_hash(sk);
 			return;
 		}
 		local_bh_disable();
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 1f5c92d..7ac935a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -97,6 +97,20 @@ const char *dccp_state_name(const int st
 
 EXPORT_SYMBOL_GPL(dccp_state_name);
 
+void dccp_hash(struct sock *sk)
+{
+	inet_hash(&dccp_hashinfo, sk);
+}
+
+EXPORT_SYMBOL_GPL(dccp_hash);
+
+void dccp_unhash(struct sock *sk)
+{
+	inet_unhash(&dccp_hashinfo, sk);
+}
+
+EXPORT_SYMBOL_GPL(dccp_unhash);
+
 int dccp_init_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-- 
1.2.2.gd27d


