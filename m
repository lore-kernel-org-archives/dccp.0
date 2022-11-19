From: Kuniyuki Iwashima <kuniyu@amazon.com>
Date: Sat, 19 Nov 2022 01:49:13 +0000
Subject: [PATCH v4 net 3/4] dccp/tcp: Update saddr under bhash's lock.
Message-Id: <20221119014914.31792-4-kuniyu@amazon.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When we call connect() for a socket bound to a wildcard address, we update
saddr locklessly.  However, it could result in a data race; another thread
iterating over bhash might see a corrupted address.

Let's update saddr under the bhash bucket's lock.

Fixes: 3df80d9320bc ("[DCCP]: Introduce DCCPv6")
Fixes: 7c657876b63c ("[DCCP]: Initial implementation")
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
---
 include/net/inet_hashtables.h |  2 +-
 net/dccp/ipv4.c               | 22 ++++-------------
 net/dccp/ipv6.c               | 23 ++++--------------
 net/ipv4/af_inet.c            | 11 +--------
 net/ipv4/inet_hashtables.c    | 45 ++++++++++++++++++++++++++++++-----
 net/ipv4/tcp_ipv4.c           | 20 ++++------------
 net/ipv6/tcp_ipv6.c           | 19 +++------------
 7 files changed, 56 insertions(+), 86 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 3af1e927247d..ba06e8b52264 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -281,7 +281,7 @@ inet_bhash2_addr_any_hashbucket(const struct sock *sk, const struct net *net, in
  * sk_v6_rcv_saddr (ipv6) changes after it has been binded. The socket's
  * rcv_saddr field should already have been updated when this is called.
  */
-int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct sock *sk);
+int inet_bhash2_update_saddr(struct sock *sk, void *saddr, int family);
 
 void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 		    struct inet_bind2_bucket *tb2, unsigned short port);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 40640c26680e..95e376e3b911 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -45,11 +45,10 @@ static unsigned int dccp_v4_pernet_id __read_mostly;
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	const struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
-	struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
-	__be32 daddr, nexthop, prev_sk_rcv_saddr;
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	__be16 orig_sport, orig_dport;
+	__be32 daddr, nexthop;
 	struct flowi4 *fl4;
 	struct rtable *rt;
 	int err;
@@ -91,26 +90,13 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		daddr = fl4->daddr;
 
 	if (inet->inet_saddr = 0) {
-		if (inet_csk(sk)->icsk_bind2_hash) {
-			prev_addr_hashbucket -				inet_bhashfn_portaddr(&dccp_hashinfo, sk,
-						      sock_net(sk),
-						      inet->inet_num);
-			prev_sk_rcv_saddr = sk->sk_rcv_saddr;
-		}
-		inet->inet_saddr = fl4->saddr;
-	}
-
-	sk_rcv_saddr_set(sk, inet->inet_saddr);
-
-	if (prev_addr_hashbucket) {
-		err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
+		err = inet_bhash2_update_saddr(sk,  &fl4->saddr, AF_INET);
 		if (err) {
-			inet->inet_saddr = 0;
-			sk_rcv_saddr_set(sk, prev_sk_rcv_saddr);
 			ip_rt_put(rt);
 			return err;
 		}
+	} else {
+		sk_rcv_saddr_set(sk, inet->inet_saddr);
 	}
 
 	inet->inet_dport = usin->sin_port;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 626166cb6d7e..94c101ed57a9 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -934,26 +934,11 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	}
 
 	if (saddr = NULL) {
-		struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
-		struct in6_addr prev_v6_rcv_saddr;
-
-		if (icsk->icsk_bind2_hash) {
-			prev_addr_hashbucket = inet_bhashfn_portaddr(&dccp_hashinfo,
-								     sk, sock_net(sk),
-								     inet->inet_num);
-			prev_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
-		}
-
 		saddr = &fl6.saddr;
-		sk->sk_v6_rcv_saddr = *saddr;
-
-		if (prev_addr_hashbucket) {
-			err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
-			if (err) {
-				sk->sk_v6_rcv_saddr = prev_v6_rcv_saddr;
-				goto failure;
-			}
-		}
+
+		err = inet_bhash2_update_saddr(sk, saddr, AF_INET6);
+		if (err)
+			goto failure;
 	}
 
 	/* set the source address */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4728087c42a5..0da679411330 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1230,7 +1230,6 @@ EXPORT_SYMBOL(inet_unregister_protosw);
 
 static int inet_sk_reselect_saddr(struct sock *sk)
 {
-	struct inet_bind_hashbucket *prev_addr_hashbucket;
 	struct inet_sock *inet = inet_sk(sk);
 	__be32 old_saddr = inet->inet_saddr;
 	__be32 daddr = inet->inet_daddr;
@@ -1260,16 +1259,8 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		return 0;
 	}
 
-	prev_addr_hashbucket -		inet_bhashfn_portaddr(tcp_or_dccp_get_hashinfo(sk), sk,
-				      sock_net(sk), inet->inet_num);
-
-	inet->inet_saddr = inet->inet_rcv_saddr = new_saddr;
-
-	err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
+	err = inet_bhash2_update_saddr(sk, &new_saddr, AF_INET);
 	if (err) {
-		inet->inet_saddr = old_saddr;
-		inet->inet_rcv_saddr = old_saddr;
 		ip_rt_put(rt);
 		return err;
 	}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index d745f962745e..18ef370af113 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -858,14 +858,34 @@ inet_bhash2_addr_any_hashbucket(const struct sock *sk, const struct net *net, in
 	return &hinfo->bhash2[hash & (hinfo->bhash_size - 1)];
 }
 
-int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct sock *sk)
+static void inet_update_saddr(struct sock *sk, void *saddr, int family)
+{
+	if (family = AF_INET) {
+		inet_sk(sk)->inet_saddr = *(__be32 *)saddr;
+		sk_rcv_saddr_set(sk, inet_sk(sk)->inet_saddr);
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else {
+		sk->sk_v6_rcv_saddr = *(struct in6_addr *)saddr;
+	}
+#endif
+}
+
+int inet_bhash2_update_saddr(struct sock *sk, void *saddr, int family)
 {
 	struct inet_hashinfo *hinfo = tcp_or_dccp_get_hashinfo(sk);
+	struct inet_bind_hashbucket *head, *head2;
 	struct inet_bind2_bucket *tb2, *new_tb2;
 	int l3mdev = inet_sk_bound_l3mdev(sk);
-	struct inet_bind_hashbucket *head2;
 	int port = inet_sk(sk)->inet_num;
 	struct net *net = sock_net(sk);
+	int bhash;
+
+	if (!inet_csk(sk)->icsk_bind2_hash) {
+		/* Not bind()ed before. */
+		inet_update_saddr(sk, saddr, family);
+		return 0;
+	}
 
 	/* Allocate a bind2 bucket ahead of time to avoid permanently putting
 	 * the bhash2 table in an inconsistent state if a new tb2 bucket
@@ -875,14 +895,25 @@ int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct soc
 	if (!new_tb2)
 		return -ENOMEM;
 
+	bhash = inet_bhashfn(net, port, hinfo->bhash_size);
+	head = &hinfo->bhash[bhash];
 	head2 = inet_bhashfn_portaddr(hinfo, sk, net, port);
 
-	spin_lock_bh(&prev_saddr->lock);
+	/* If we change saddr locklessly, another thread
+	 * iterating over bhash might see corrupted address.
+	 */
+	spin_lock_bh(&head->lock);
+
+	spin_lock(&head2->lock);
 	__sk_del_bind2_node(sk);
 	inet_bind2_bucket_destroy(hinfo->bind2_bucket_cachep, inet_csk(sk)->icsk_bind2_hash);
-	spin_unlock_bh(&prev_saddr->lock);
+	spin_unlock(&head2->lock);
+
+	inet_update_saddr(sk, saddr, family);
 
-	spin_lock_bh(&head2->lock);
+	head2 = inet_bhashfn_portaddr(hinfo, sk, net, port);
+
+	spin_lock(&head2->lock);
 	tb2 = inet_bind2_bucket_find(head2, net, port, l3mdev, sk);
 	if (!tb2) {
 		tb2 = new_tb2;
@@ -890,7 +921,9 @@ int inet_bhash2_update_saddr(struct inet_bind_hashbucket *prev_saddr, struct soc
 	}
 	sk_add_bind2_node(sk, &tb2->owners);
 	inet_csk(sk)->icsk_bind2_hash = tb2;
-	spin_unlock_bh(&head2->lock);
+	spin_unlock(&head2->lock);
+
+	spin_unlock_bh(&head->lock);
 
 	if (tb2 != new_tb2)
 		kmem_cache_free(hinfo->bind2_bucket_cachep, new_tb2);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6a3a732b584d..23dd7e9df2d5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -199,15 +199,14 @@ static int tcp_v4_pre_connect(struct sock *sk, struct sockaddr *uaddr,
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
 	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	struct inet_timewait_death_row *tcp_death_row;
-	__be32 daddr, nexthop, prev_sk_rcv_saddr;
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct ip_options_rcu *inet_opt;
 	struct net *net = sock_net(sk);
 	__be16 orig_sport, orig_dport;
+	__be32 daddr, nexthop;
 	struct flowi4 *fl4;
 	struct rtable *rt;
 	int err;
@@ -251,24 +250,13 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tcp_death_row = &sock_net(sk)->ipv4.tcp_death_row;
 
 	if (!inet->inet_saddr) {
-		if (inet_csk(sk)->icsk_bind2_hash) {
-			prev_addr_hashbucket = inet_bhashfn_portaddr(tcp_death_row->hashinfo,
-								     sk, net, inet->inet_num);
-			prev_sk_rcv_saddr = sk->sk_rcv_saddr;
-		}
-		inet->inet_saddr = fl4->saddr;
-	}
-
-	sk_rcv_saddr_set(sk, inet->inet_saddr);
-
-	if (prev_addr_hashbucket) {
-		err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
+		err = inet_bhash2_update_saddr(sk,  &fl4->saddr, AF_INET);
 		if (err) {
-			inet->inet_saddr = 0;
-			sk_rcv_saddr_set(sk, prev_sk_rcv_saddr);
 			ip_rt_put(rt);
 			return err;
 		}
+	} else {
+		sk_rcv_saddr_set(sk, inet->inet_saddr);
 	}
 
 	if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 81b396e5cf79..2f3ca3190d26 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -292,24 +292,11 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	tcp_death_row = &sock_net(sk)->ipv4.tcp_death_row;
 
 	if (!saddr) {
-		struct inet_bind_hashbucket *prev_addr_hashbucket = NULL;
-		struct in6_addr prev_v6_rcv_saddr;
-
-		if (icsk->icsk_bind2_hash) {
-			prev_addr_hashbucket = inet_bhashfn_portaddr(tcp_death_row->hashinfo,
-								     sk, net, inet->inet_num);
-			prev_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
-		}
 		saddr = &fl6.saddr;
-		sk->sk_v6_rcv_saddr = *saddr;
 
-		if (prev_addr_hashbucket) {
-			err = inet_bhash2_update_saddr(prev_addr_hashbucket, sk);
-			if (err) {
-				sk->sk_v6_rcv_saddr = prev_v6_rcv_saddr;
-				goto failure;
-			}
-		}
+		err = inet_bhash2_update_saddr(sk, saddr, AF_INET6);
+		if (err)
+			goto failure;
 	}
 
 	/* set the source address */
-- 
2.30.2
