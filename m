From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 11 Dec 2005 13:57:21 +0000
Subject: [PATCH 4/4][INET]: Generalise tcp_v4_hash_connect
Message-Id: <39e6f6c70512110557k61a27d81jfca4ff18bdf5fc1d@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_29647_21974546.1134309441498"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_29647_21974546.1134309441498
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_29647_21974546.1134309441498
Content-Type: text/x-patch; name=4.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="4.patch"

tree d1285f31fef358cf1b30deb4bdc0723c006e64e5
parent 96ba4b224c010ad590ff1206f4f6d1cec1389ebf
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134308990 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134308990 -0200

[INET]: Generalise tcp_v4_hash_connect

Renaming it to inet_hash_connect, making it possible to ditch
dccp_v4_hash_connect and share the same code with TCP instead.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 drivers/char/random.c         |    6 -
 include/linux/random.h        |    2 
 include/net/inet_hashtables.h |    3 
 net/dccp/ipv4.c               |  160 -------------------------------------
 net/ipv4/inet_hashtables.c    |  178 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c           |  173 ----------------------------------------
 6 files changed, 186 insertions(+), 336 deletions(-)

------------------------------------------------------------------------------

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 7999da2..79b59d9 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1554,10 +1554,8 @@ __u32 secure_tcp_sequence_number(__u32 s
 
 EXPORT_SYMBOL(secure_tcp_sequence_number);
 
-
-
-/* Generate secure starting point for ephemeral TCP port search */
-u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
+/* Generate secure starting point for ephemeral IPV4 transport port search */
+u32 secure_ipv4_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport)
 {
 	struct keydata *keyptr = get_keyptr();
 	u32 hash[4];
diff --git a/include/linux/random.h b/include/linux/random.h
index 7b2adb3..01424a8 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -52,7 +52,7 @@ extern void get_random_bytes(void *buf, 
 void generate_random_uuid(unsigned char uuid_out[16]);
 
 extern __u32 secure_ip_id(__u32 daddr);
-extern u32 secure_tcp_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
+extern u32 secure_ipv4_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
 extern u32 secure_tcpv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, 
 				       __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 07840ba..c83baa7 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -434,4 +434,7 @@ static inline struct sock *inet_lookup(s
 
 	return sk;
 }
+
+extern int inet_hash_connect(struct inet_timewait_death_row *death_row,
+			     struct sock *sk);
 #endif /* _INET_HASHTABLES_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f8c6a15..2702094 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -54,164 +54,6 @@ void dccp_unhash(struct sock *sk)
 
 EXPORT_SYMBOL_GPL(dccp_unhash);
 
-/* called with local bh disabled */
-static int __dccp_v4_check_established(struct sock *sk, const __u16 lport,
-				      struct inet_timewait_sock **twp)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	const u32 daddr = inet->rcv_saddr;
-	const u32 saddr = inet->daddr;
-	const int dif = sk->sk_bound_dev_if;
-	INET_ADDR_COOKIE(acookie, saddr, daddr)
-	const __u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
-	unsigned int hash = inet_ehashfn(daddr, lport, saddr, inet->dport);
-	struct inet_ehash_bucket *head = inet_ehash_bucket(&dccp_hashinfo, hash);
-	const struct sock *sk2;
-	const struct hlist_node *node;
-	struct inet_timewait_sock *tw;
-
-	prefetch(head->chain.first);
-	write_lock(&head->lock);
-
-	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &(head + dccp_hashinfo.ehash_size)->chain) {
-		tw = inet_twsk(sk2);
-
-		if (INET_TW_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif))
-			goto not_unique;
-	}
-	tw = NULL;
-
-	/* And established part... */
-	sk_for_each(sk2, node, &head->chain) {
-		if (INET_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif))
-			goto not_unique;
-	}
-
-	/* Must record num and sport now. Otherwise we will see
-	 * in hash table socket with a funny identity. */
-	inet->num = lport;
-	inet->sport = htons(lport);
-	sk->sk_hash = hash;
-	BUG_TRAP(sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
-	sock_prot_inc_use(sk->sk_prot);
-	write_unlock(&head->lock);
-
-	if (twp != NULL) {
-		*twp = tw;
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-	} else if (tw != NULL) {
-		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw, &dccp_death_row);
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-
-		inet_twsk_put(tw);
-	}
-
-	return 0;
-
-not_unique:
-	write_unlock(&head->lock);
-	return -EADDRNOTAVAIL;
-}
-
-/*
- * Bind a port for a connect operation and hash it.
- */
-static int dccp_v4_hash_connect(struct sock *sk)
-{
-	const unsigned short snum = inet_sk(sk)->num;
- 	struct inet_bind_hashbucket *head;
- 	struct inet_bind_bucket *tb;
-	int ret;
-
- 	if (snum == 0) {
- 		int low = sysctl_local_port_range[0];
- 		int high = sysctl_local_port_range[1];
- 		int remaining = (high - low) + 1;
- 		int rover = net_random() % (high - low) + low;
-		struct hlist_node *node;
- 		struct inet_timewait_sock *tw = NULL;
-
- 		local_bh_disable();
- 		do {
- 			head = &dccp_hashinfo.bhash[inet_bhashfn(rover,
-						    dccp_hashinfo.bhash_size)];
- 			spin_lock(&head->lock);
-
- 			/* Does not bother with rcv_saddr checks,
- 			 * because the established check is already
- 			 * unique enough.
- 			 */
-			inet_bind_bucket_for_each(tb, node, &head->chain) {
- 				if (tb->port == rover) {
- 					BUG_TRAP(!hlist_empty(&tb->owners));
- 					if (tb->fastreuse >= 0)
- 						goto next_port;
- 					if (!__dccp_v4_check_established(sk,
-									 rover,
-									 &tw))
- 						goto ok;
- 					goto next_port;
- 				}
- 			}
-
- 			tb = inet_bind_bucket_create(dccp_hashinfo.bind_bucket_cachep,
-						     head, rover);
- 			if (tb == NULL) {
- 				spin_unlock(&head->lock);
- 				break;
- 			}
- 			tb->fastreuse = -1;
- 			goto ok;
-
- 		next_port:
- 			spin_unlock(&head->lock);
- 			if (++rover > high)
- 				rover = low;
- 		} while (--remaining > 0);
-
- 		local_bh_enable();
-
- 		return -EADDRNOTAVAIL;
-
-ok:
- 		/* All locks still held and bhs disabled */
- 		inet_bind_hash(sk, tb, rover);
-		if (sk_unhashed(sk)) {
- 			inet_sk(sk)->sport = htons(rover);
- 			__inet_hash(&dccp_hashinfo, sk, 0);
- 		}
- 		spin_unlock(&head->lock);
-
- 		if (tw != NULL) {
- 			inet_twsk_deschedule(tw, &dccp_death_row);
- 			inet_twsk_put(tw);
- 		}
-
-		ret = 0;
-		goto out;
- 	}
-
- 	head = &dccp_hashinfo.bhash[inet_bhashfn(snum,
-						 dccp_hashinfo.bhash_size)];
- 	tb   = inet_csk(sk)->icsk_bind_hash;
-	spin_lock_bh(&head->lock);
-	if (sk_head(&tb->owners) == sk && sk->sk_bind_node.next == NULL) {
-		__inet_hash(&dccp_hashinfo, sk, 0);
-		spin_unlock_bh(&head->lock);
-		return 0;
-	} else {
-		spin_unlock(&head->lock);
-		/* No definite answer... Walk to established hash table */
-		ret = __dccp_v4_check_established(sk, snum, NULL);
-out:
-		local_bh_enable();
-		return ret;
-	}
-}
-
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -272,7 +114,7 @@ int dccp_v4_connect(struct sock *sk, str
 	 * complete initialization after this.
 	 */
 	dccp_set_state(sk, DCCP_REQUESTING);
-	err = dccp_v4_hash_connect(sk);
+	err = inet_hash_connect(&dccp_death_row, sk);
 	if (err != 0)
 		goto failure;
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index e8d29fe..3322811 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -15,12 +15,14 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/random.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/wait.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
+#include <net/ip.h>
 
 /*
  * Allocate and initialize a new local port bind bucket.
@@ -163,3 +165,179 @@ struct sock *__inet_lookup_listener(cons
 }
 
 EXPORT_SYMBOL_GPL(__inet_lookup_listener);
+
+/* called with local bh disabled */
+static int __inet_check_established(struct inet_timewait_death_row *death_row,
+				    struct sock *sk, __u16 lport,
+				    struct inet_timewait_sock **twp)
+{
+	struct inet_hashinfo *hinfo = death_row->hashinfo;
+	struct inet_sock *inet = inet_sk(sk);
+	u32 daddr = inet->rcv_saddr;
+	u32 saddr = inet->daddr;
+	int dif = sk->sk_bound_dev_if;
+	INET_ADDR_COOKIE(acookie, saddr, daddr)
+	const __u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
+	unsigned int hash = inet_ehashfn(daddr, lport, saddr, inet->dport);
+	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
+	struct sock *sk2;
+	const struct hlist_node *node;
+	struct inet_timewait_sock *tw;
+
+	prefetch(head->chain.first);
+	write_lock(&head->lock);
+
+	/* Check TIME-WAIT sockets first. */
+	sk_for_each(sk2, node, &(head + hinfo->ehash_size)->chain) {
+		tw = inet_twsk(sk2);
+
+		if (INET_TW_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif)) {
+			if (twsk_unique(sk, sk2, twp))
+				goto unique;
+			else
+				goto not_unique;
+		}
+	}
+	tw = NULL;
+
+	/* And established part... */
+	sk_for_each(sk2, node, &head->chain) {
+		if (INET_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif))
+			goto not_unique;
+	}
+
+unique:
+	/* Must record num and sport now. Otherwise we will see
+	 * in hash table socket with a funny identity. */
+	inet->num = lport;
+	inet->sport = htons(lport);
+	sk->sk_hash = hash;
+	BUG_TRAP(sk_unhashed(sk));
+	__sk_add_node(sk, &head->chain);
+	sock_prot_inc_use(sk->sk_prot);
+	write_unlock(&head->lock);
+
+	if (twp) {
+		*twp = tw;
+		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+	} else if (tw) {
+		/* Silly. Should hash-dance instead... */
+		inet_twsk_deschedule(tw, death_row);
+		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+
+		inet_twsk_put(tw);
+	}
+
+	return 0;
+
+not_unique:
+	write_unlock(&head->lock);
+	return -EADDRNOTAVAIL;
+}
+
+static inline u32 inet_sk_port_offset(const struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	return secure_ipv4_port_ephemeral(inet->rcv_saddr, inet->daddr, 
+					  inet->dport);
+}
+
+/*
+ * Bind a port for a connect operation and hash it.
+ */
+int inet_hash_connect(struct inet_timewait_death_row *death_row,
+		      struct sock *sk)
+{
+	struct inet_hashinfo *hinfo = death_row->hashinfo;
+	const unsigned short snum = inet_sk(sk)->num;
+ 	struct inet_bind_hashbucket *head;
+ 	struct inet_bind_bucket *tb;
+	int ret;
+
+ 	if (!snum) {
+ 		int low = sysctl_local_port_range[0];
+ 		int high = sysctl_local_port_range[1];
+		int range = high - low;
+ 		int i;
+		int port;
+		static u32 hint;
+		u32 offset = hint + inet_sk_port_offset(sk);
+		struct hlist_node *node;
+ 		struct inet_timewait_sock *tw = NULL;
+
+ 		local_bh_disable();
+		for (i = 1; i <= range; i++) {
+			port = low + (i + offset) % range;
+ 			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
+ 			spin_lock(&head->lock);
+
+ 			/* Does not bother with rcv_saddr checks,
+ 			 * because the established check is already
+ 			 * unique enough.
+ 			 */
+			inet_bind_bucket_for_each(tb, node, &head->chain) {
+ 				if (tb->port == port) {
+ 					BUG_TRAP(!hlist_empty(&tb->owners));
+ 					if (tb->fastreuse >= 0)
+ 						goto next_port;
+ 					if (!__inet_check_established(death_row,
+								      sk, port,
+								      &tw))
+ 						goto ok;
+ 					goto next_port;
+ 				}
+ 			}
+
+ 			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep, head, port);
+ 			if (!tb) {
+ 				spin_unlock(&head->lock);
+ 				break;
+ 			}
+ 			tb->fastreuse = -1;
+ 			goto ok;
+
+ 		next_port:
+ 			spin_unlock(&head->lock);
+ 		}
+ 		local_bh_enable();
+
+ 		return -EADDRNOTAVAIL;
+
+ok:
+		hint += i;
+
+ 		/* Head lock still held and bh's disabled */
+ 		inet_bind_hash(sk, tb, port);
+		if (sk_unhashed(sk)) {
+ 			inet_sk(sk)->sport = htons(port);
+ 			__inet_hash(hinfo, sk, 0);
+ 		}
+ 		spin_unlock(&head->lock);
+
+ 		if (tw) {
+ 			inet_twsk_deschedule(tw, death_row);;
+ 			inet_twsk_put(tw);
+ 		}
+
+		ret = 0;
+		goto out;
+ 	}
+
+ 	head = &hinfo->bhash[inet_bhashfn(snum, hinfo->bhash_size)];
+ 	tb  = inet_csk(sk)->icsk_bind_hash;
+	spin_lock_bh(&head->lock);
+	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
+		__inet_hash(hinfo, sk, 0);
+		spin_unlock_bh(&head->lock);
+		return 0;
+	} else {
+		spin_unlock(&head->lock);
+		/* No definite answer... Walk to established hash table */
+		ret = __inet_check_established(death_row, sk, snum, NULL);
+out:
+		local_bh_enable();
+		return ret;
+	}
+}
+
+EXPORT_SYMBOL_GPL(inet_hash_connect);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6728772..c2fe61b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -152,177 +152,6 @@ int tcp_twsk_unique(struct sock *sk, str
 
 EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 
-/* called with local bh disabled */
-static int __tcp_v4_check_established(struct sock *sk, __u16 lport,
-				      struct inet_timewait_sock **twp)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	u32 daddr = inet->rcv_saddr;
-	u32 saddr = inet->daddr;
-	int dif = sk->sk_bound_dev_if;
-	INET_ADDR_COOKIE(acookie, saddr, daddr)
-	const __u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
-	unsigned int hash = inet_ehashfn(daddr, lport, saddr, inet->dport);
-	struct inet_ehash_bucket *head = inet_ehash_bucket(&tcp_hashinfo, hash);
-	struct sock *sk2;
-	const struct hlist_node *node;
-	struct inet_timewait_sock *tw;
-
-	prefetch(head->chain.first);
-	write_lock(&head->lock);
-
-	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &(head + tcp_hashinfo.ehash_size)->chain) {
-		tw = inet_twsk(sk2);
-
-		if (INET_TW_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif)) {
-			if (twsk_unique(sk, sk2, twp))
-				goto unique;
-			else
-				goto not_unique;
-		}
-	}
-	tw = NULL;
-
-	/* And established part... */
-	sk_for_each(sk2, node, &head->chain) {
-		if (INET_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif))
-			goto not_unique;
-	}
-
-unique:
-	/* Must record num and sport now. Otherwise we will see
-	 * in hash table socket with a funny identity. */
-	inet->num = lport;
-	inet->sport = htons(lport);
-	sk->sk_hash = hash;
-	BUG_TRAP(sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
-	sock_prot_inc_use(sk->sk_prot);
-	write_unlock(&head->lock);
-
-	if (twp) {
-		*twp = tw;
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-	} else if (tw) {
-		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw, &tcp_death_row);
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-
-		inet_twsk_put(tw);
-	}
-
-	return 0;
-
-not_unique:
-	write_unlock(&head->lock);
-	return -EADDRNOTAVAIL;
-}
-
-static inline u32 connect_port_offset(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-
-	return secure_tcp_port_ephemeral(inet->rcv_saddr, inet->daddr, 
-					 inet->dport);
-}
-
-/*
- * Bind a port for a connect operation and hash it.
- */
-static inline int tcp_v4_hash_connect(struct sock *sk)
-{
-	const unsigned short snum = inet_sk(sk)->num;
- 	struct inet_bind_hashbucket *head;
- 	struct inet_bind_bucket *tb;
-	int ret;
-
- 	if (!snum) {
- 		int low = sysctl_local_port_range[0];
- 		int high = sysctl_local_port_range[1];
-		int range = high - low;
- 		int i;
-		int port;
-		static u32 hint;
-		u32 offset = hint + connect_port_offset(sk);
-		struct hlist_node *node;
- 		struct inet_timewait_sock *tw = NULL;
-
- 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
- 			head = &tcp_hashinfo.bhash[inet_bhashfn(port, tcp_hashinfo.bhash_size)];
- 			spin_lock(&head->lock);
-
- 			/* Does not bother with rcv_saddr checks,
- 			 * because the established check is already
- 			 * unique enough.
- 			 */
-			inet_bind_bucket_for_each(tb, node, &head->chain) {
- 				if (tb->port == port) {
- 					BUG_TRAP(!hlist_empty(&tb->owners));
- 					if (tb->fastreuse >= 0)
- 						goto next_port;
- 					if (!__tcp_v4_check_established(sk,
-									port,
-									&tw))
- 						goto ok;
- 					goto next_port;
- 				}
- 			}
-
- 			tb = inet_bind_bucket_create(tcp_hashinfo.bind_bucket_cachep, head, port);
- 			if (!tb) {
- 				spin_unlock(&head->lock);
- 				break;
- 			}
- 			tb->fastreuse = -1;
- 			goto ok;
-
- 		next_port:
- 			spin_unlock(&head->lock);
- 		}
- 		local_bh_enable();
-
- 		return -EADDRNOTAVAIL;
-
-ok:
-		hint += i;
-
- 		/* Head lock still held and bh's disabled */
- 		inet_bind_hash(sk, tb, port);
-		if (sk_unhashed(sk)) {
- 			inet_sk(sk)->sport = htons(port);
- 			__inet_hash(&tcp_hashinfo, sk, 0);
- 		}
- 		spin_unlock(&head->lock);
-
- 		if (tw) {
- 			inet_twsk_deschedule(tw, &tcp_death_row);;
- 			inet_twsk_put(tw);
- 		}
-
-		ret = 0;
-		goto out;
- 	}
-
- 	head = &tcp_hashinfo.bhash[inet_bhashfn(snum, tcp_hashinfo.bhash_size)];
- 	tb  = inet_csk(sk)->icsk_bind_hash;
-	spin_lock_bh(&head->lock);
-	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		__inet_hash(&tcp_hashinfo, sk, 0);
-		spin_unlock_bh(&head->lock);
-		return 0;
-	} else {
-		spin_unlock(&head->lock);
-		/* No definite answer... Walk to established hash table */
-		ret = __tcp_v4_check_established(sk, snum, NULL);
-out:
-		local_bh_enable();
-		return ret;
-	}
-}
-
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -403,7 +232,7 @@ int tcp_v4_connect(struct sock *sk, stru
 	 * complete initialization after this.
 	 */
 	tcp_set_state(sk, TCP_SYN_SENT);
-	err = tcp_v4_hash_connect(sk);
+	err = inet_hash_connect(&tcp_death_row, sk);
 	if (err)
 		goto failure;
 


------=_Part_29647_21974546.1134309441498--
