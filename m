From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 07 May 2018 18:43:32 +0000
Subject: [PATCH net-next  v3 1/2] inet: add bound ports statistic
Message-Id: <20180507184333.32688-2-sthemmin@microsoft.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds a number of bound ports which fixes socket summary
command.  The ss -s has been broken since changes to slab info
and this is one way to recover the missing value by adding a
field onto /proc/net/sockstat.

Since this is an informational value only, there is no need
for locking.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/net/inet_hashtables.h    |  3 +++
 include/net/inet_timewait_sock.h |  2 ++
 net/dccp/proto.c                 |  1 +
 net/ipv4/inet_hashtables.c       | 22 +++++++++++++++++++---
 net/ipv4/inet_timewait_sock.c    |  8 +++++---
 net/ipv4/proc.c                  |  5 +++--
 net/ipv4/tcp.c                   |  1 +
 7 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 9141e95529e7..b02524e2571e 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -103,6 +103,7 @@ static inline struct net *ib_net(struct inet_bind_bucket *ib)
 
 struct inet_bind_hashbucket {
 	spinlock_t		lock;
+	unsigned int		count;
 	struct hlist_head	chain;
 };
 
@@ -193,7 +194,9 @@ inet_bind_bucket_create(struct kmem_cache *cachep, struct net *net,
 			struct inet_bind_hashbucket *head,
 			const unsigned short snum);
 void inet_bind_bucket_destroy(struct kmem_cache *cachep,
+			      struct inet_bind_hashbucket *head,
 			      struct inet_bind_bucket *tb);
+unsigned int inet_bind_bucket_count(const struct proto *prot);
 
 static inline u32 inet_bhashfn(const struct net *net, const __u16 lport,
 			       const u32 bhash_size)
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index c7be1ca8e562..4cdb8034ad80 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -87,7 +87,9 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 void inet_twsk_free(struct inet_timewait_sock *tw);
 void inet_twsk_put(struct inet_timewait_sock *tw);
 
+struct inet_bind_hashbucket;
 void inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
+			   struct inet_bind_hashbucket *head,
 			   struct inet_hashinfo *hashinfo);
 
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 84cd4e3fd01b..25f03e62cfea 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1208,6 +1208,7 @@ static int __init dccp_init(void)
 	for (i = 0; i < dccp_hashinfo.bhash_size; i++) {
 		spin_lock_init(&dccp_hashinfo.bhash[i].lock);
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
+		dccp_hashinfo.bhash[i].count = 0;
 	}
 
 	rc = dccp_mib_init();
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 31ff46daae97..8ba6b17d95d5 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -58,6 +58,18 @@ static u32 sk_ehashfn(const struct sock *sk)
 			    sk->sk_daddr, sk->sk_dport);
 }
 
+/* Count how many any entries are in the bind hash table */
+unsigned int inet_bind_bucket_count(const struct proto *prot)
+{
+	const struct inet_hashinfo *hinfo = prot->h.hashinfo;
+	unsigned int i, ports = 0;
+
+	for (i = 0; i < hinfo->bhash_size; i++)
+		ports += hinfo->bhash[i].count;
+
+	return ports;
+}
+
 /*
  * Allocate and initialize a new local port bind bucket.
  * The bindhash mutex for snum's hash chain must be held here.
@@ -76,6 +88,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		tb->fastreuseport = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
+		++head->count;
 	}
 	return tb;
 }
@@ -83,10 +96,13 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 /*
  * Caller must hold hashbucket lock for this tb with local BH disabled
  */
-void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb)
+void inet_bind_bucket_destroy(struct kmem_cache *cachep,
+			      struct inet_bind_hashbucket *head,
+			      struct inet_bind_bucket *tb)
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
+		--head->count;
 		kmem_cache_free(cachep, tb);
 	}
 }
@@ -115,7 +131,7 @@ static void __inet_put_port(struct sock *sk)
 	__sk_del_bind_node(sk);
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, head, tb);
 	spin_unlock(&head->lock);
 }
 
@@ -756,7 +772,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		inet_ehash_nolisten(sk, (struct sock *)tw);
 	}
 	if (tw)
-		inet_twsk_bind_unhash(tw, hinfo);
+		inet_twsk_bind_unhash(tw, head, hinfo);
 	spin_unlock(&head->lock);
 	if (tw)
 		inet_twsk_deschedule_put(tw);
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 88c5069b5d20..dd888c52f958 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -26,7 +26,8 @@
  *	Returns 1 if caller should call inet_twsk_put() after lock release.
  */
 void inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
-			  struct inet_hashinfo *hashinfo)
+			   struct inet_bind_hashbucket *head,
+			   struct inet_hashinfo *hashinfo)
 {
 	struct inet_bind_bucket *tb = tw->tw_tb;
 
@@ -35,7 +36,8 @@ void inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 
 	__hlist_del(&tw->tw_bind_node);
 	tw->tw_tb = NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep,
+				 head, tb);
 	__sock_put((struct sock *)tw);
 }
 
@@ -55,7 +57,7 @@ static void inet_twsk_kill(struct inet_timewait_sock *tw)
 			hashinfo->bhash_size)];
 
 	spin_lock(&bhead->lock);
-	inet_twsk_bind_unhash(tw, hashinfo);
+	inet_twsk_bind_unhash(tw, bhead, hashinfo);
 	spin_unlock(&bhead->lock);
 
 	atomic_dec(&tw->tw_dr->tw_count);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 261b71d0ccc5..83bc9a0f2785 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -60,10 +60,11 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	sockets = proto_sockets_allocated_sum_positive(&tcp_prot);
 
 	socket_seq_show(seq);
-	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
+	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld ports %u\n",
 		   sock_prot_inuse_get(net, &tcp_prot), orphans,
 		   atomic_read(&net->ipv4.tcp_death_row.tw_count), sockets,
-		   proto_memory_allocated(&tcp_prot));
+		   proto_memory_allocated(&tcp_prot),
+		   inet_bind_bucket_count(&tcp_prot));
 	seq_printf(seq, "UDP: inuse %d mem %ld\n",
 		   sock_prot_inuse_get(net, &udp_prot),
 		   proto_memory_allocated(&udp_prot));
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 868ed74a76a8..f62e2fb02fdf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3836,6 +3836,7 @@ void __init tcp_init(void)
 	for (i = 0; i < tcp_hashinfo.bhash_size; i++) {
 		spin_lock_init(&tcp_hashinfo.bhash[i].lock);
 		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
+		tcp_hashinfo.bhash[i].count = 0;
 	}
 
 
-- 
2.17.0

