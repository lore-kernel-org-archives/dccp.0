From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 12 Dec 2005 16:12:43 +0000
Subject: [PATCH 1/1][INET6]: Generalise tcp_v6_hash_connect
Message-Id: <39e6f6c70512120812r5db1dcd8y92a176f0d938aecc@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_7352_11882467.1134403963161"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_7352_11882467.1134403963161
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

  Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

  Later today I'll continue, chunking out the last changeset in my old
dccpv6 tree, removing the TCP specific bits in ip_sockglue, making it
deal with inet_connection_socks and not anymore with tcp_socks, i.e.
not checking SOCK_STREAM, but a bit in inet_sock that will tell if the
sock is a inet_connection_sock (DCCP (SOCK_DCCP), TCP (SOCK_STREAM),
etc), moving sync_mss to inet_connection_sock::icsk_sync_mss, etc.

Best Regards,

- Arnaldo

P.S.: /me itching to dive into SCTP to see how much code can be
ditched using this brave "new" world of inet_connection_socks, etc :-)

P.S/2: I'd be even more delighted if some SCTP guy could assess the
potential for code sharing with TCP and DCCP using this stuff 8-)

------=_Part_7352_11882467.1134403963161
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="1.patch"

tree ee42f43bbd3664a2330b80c274114db19152e9a2
parent f85287378e45fe8dcbbab84e79d263133205f63c
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134402446 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134402446 -0200

[INET6]: Generalise tcp_v6_hash_connect

Renaming it to inet6_hash_connect, making it possible to ditch
dccp_v6_hash_connect and share the same code with TCP instead.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 drivers/char/random.c       |    4 
 include/linux/random.h      |    4 
 include/net/ipv6.h          |    3 
 net/dccp/ipv6.c             |  171 -----------------------------------------
 net/ipv6/inet6_hashtables.c |  183 +++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/tcp_ipv6.c         |  173 -----------------------------------------
 6 files changed, 190 insertions(+), 348 deletions(-)

------------------------------------------------------------------------------

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 79b59d9..bdfdfd2 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1573,7 +1573,7 @@ u32 secure_ipv4_port_ephemeral(__u32 sad
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-u32 secure_tcpv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, __u16 dport)
+u32 secure_ipv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, __u16 dport)
 {
 	struct keydata *keyptr = get_keyptr();
 	u32 hash[12];
@@ -1584,7 +1584,7 @@ u32 secure_tcpv6_port_ephemeral(const __
 
 	return twothirdsMD4Transform(daddr, hash);
 }
-EXPORT_SYMBOL(secure_tcpv6_port_ephemeral);
+EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
diff --git a/include/linux/random.h b/include/linux/random.h
index 01424a8..5d6456b 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -53,8 +53,8 @@ void generate_random_uuid(unsigned char 
 
 extern __u32 secure_ip_id(__u32 daddr);
 extern u32 secure_ipv4_port_ephemeral(__u32 saddr, __u32 daddr, __u16 dport);
-extern u32 secure_tcpv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, 
-				       __u16 dport);
+extern u32 secure_ipv6_port_ephemeral(const __u32 *saddr, const __u32 *daddr, 
+				      __u16 dport);
 extern __u32 secure_tcp_sequence_number(__u32 saddr, __u32 daddr,
 					__u16 sport, __u16 dport);
 extern __u32 secure_tcpv6_sequence_number(__u32 *saddr, __u32 *daddr,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8513761..e3d5d7b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -527,6 +527,9 @@ extern int inet6_getname(struct socket *
 extern int inet6_ioctl(struct socket *sock, unsigned int cmd, 
 		       unsigned long arg);
 
+extern int inet6_hash_connect(struct inet_timewait_death_row *death_row,
+			      struct sock *sk);
+
 /*
  * reassembly.c
  */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4d078f5..71bf04e 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -84,175 +84,6 @@ static __u32 dccp_v6_init_sequence(struc
 						   dh->dccph_sport);
 }
 
-static int __dccp_v6_check_established(struct sock *sk, const __u16 lport,
-				       struct inet_timewait_sock **twp)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-	const struct in6_addr *daddr = &np->rcv_saddr;
-	const struct in6_addr *saddr = &np->daddr;
-	const int dif = sk->sk_bound_dev_if;
-	const u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
-	const unsigned int hash = inet6_ehashfn(daddr, inet->num,
-						saddr, inet->dport);
-	struct inet_ehash_bucket *head = inet_ehash_bucket(&dccp_hashinfo, hash);
-	struct sock *sk2;
-	const struct hlist_node *node;
-	struct inet_timewait_sock *tw;
-
-	prefetch(head->chain.first);
-	write_lock(&head->lock);
-
-	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &(head + dccp_hashinfo.ehash_size)->chain) {
-		const struct inet6_timewait_sock *tw6 = inet6_twsk(sk2);
-
-		tw = inet_twsk(sk2);
-
-		if(*((__u32 *)&(tw->tw_dport))	== ports	 &&
-		   sk2->sk_family		== PF_INET6	 &&
-		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	 &&
-		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr) &&
-		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if)
-			goto not_unique;
-	}
-	tw = NULL;
-
-	/* And established part... */
-	sk_for_each(sk2, node, &head->chain) {
-		if (INET6_MATCH(sk2, hash, saddr, daddr, ports, dif))
-			goto not_unique;
-	}
-
-	BUG_TRAP(sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
-	sk->sk_hash = hash;
-	sock_prot_inc_use(sk->sk_prot);
-	write_unlock(&head->lock);
-
-	if (twp) {
-		*twp = tw;
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-	} else if (tw) {
-		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw, &dccp_death_row);
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
-
-		inet_twsk_put(tw);
-	}
-	return 0;
-
-not_unique:
-	write_unlock(&head->lock);
-	return -EADDRNOTAVAIL;
-}
-
-static inline u32 dccp_v6_port_offset(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-
-	return secure_tcpv6_port_ephemeral(np->rcv_saddr.s6_addr32,
-					   np->daddr.s6_addr32,
-					   inet->dport);
-}
-
-static int dccp_v6_hash_connect(struct sock *sk)
-{
-	const unsigned short snum = inet_sk(sk)->num;
- 	struct inet_bind_hashbucket *head;
- 	struct inet_bind_bucket *tb;
-	int ret;
-
- 	if (snum == 0) {
- 		int low = sysctl_local_port_range[0];
- 		int high = sysctl_local_port_range[1];
-		int range = high - low;
- 		int i;
-		int port;
-		static u32 hint;
-		u32 offset = hint + dccp_v6_port_offset(sk);
-		struct hlist_node *node;
- 		struct inet_timewait_sock *tw = NULL;
-
- 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
- 			head = &dccp_hashinfo.bhash[inet_bhashfn(port,
-						    dccp_hashinfo.bhash_size)];
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
- 					if (!__dccp_v6_check_established(sk,
-									 port,
-									 &tw))
- 						goto ok;
- 					goto next_port;
- 				}
- 			}
-
- 			tb = inet_bind_bucket_create(dccp_hashinfo.bind_bucket_cachep,
-						     head, port);
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
-ok:
-		hint += i;
-
- 		/* Head lock still held and bh's disabled */
- 		inet_bind_hash(sk, tb, port);
-		if (sk_unhashed(sk)) {
- 			inet_sk(sk)->sport = htons(port);
- 			__inet6_hash(&dccp_hashinfo, sk);
- 		}
- 		spin_unlock(&head->lock);
-
- 		if (tw) {
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
-
-	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		__inet6_hash(&dccp_hashinfo, sk);
-		spin_unlock_bh(&head->lock);
-		return 0;
-	} else {
-		spin_unlock(&head->lock);
-		/* No definite answer... Walk to established hash table */
-		ret = __dccp_v6_check_established(sk, snum, NULL);
-out:
-		local_bh_enable();
-		return ret;
-	}
-}
-
 static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr, 
 			   int addr_len)
 {
@@ -403,7 +234,7 @@ static int dccp_v6_connect(struct sock *
 	inet->dport = usin->sin6_port;
 
 	dccp_set_state(sk, DCCP_REQUESTING);
-	err = dccp_v6_hash_connect(sk);
+	err = inet6_hash_connect(&dccp_death_row, sk);
 	if (err)
 		goto late_failure;
 	/* FIXME */
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 01d5f46..4154f3a 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -5,7 +5,8 @@
  *
  *		Generic INET6 transport hashtables
  *
- * Authors:	Lotsa people, from code originally in tcp
+ * Authors:	Lotsa people, from code originally in tcp, generalised here
+ * 		by Arnaldo Carvalho de Melo <acme@mandriva.com>
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -14,12 +15,13 @@
  */
 
 #include <linux/config.h>
-
 #include <linux/module.h>
+#include <linux/random.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
 #include <net/inet6_hashtables.h>
+#include <net/ip.h>
 
 struct sock *inet6_lookup_listener(struct inet_hashinfo *hashinfo,
 				   const struct in6_addr *daddr,
@@ -79,3 +81,180 @@ struct sock *inet6_lookup(struct inet_ha
 }
 
 EXPORT_SYMBOL_GPL(inet6_lookup);
+
+static int __inet6_check_established(struct inet_timewait_death_row *death_row,
+				     struct sock *sk, const __u16 lport,
+				     struct inet_timewait_sock **twp)
+{
+	struct inet_hashinfo *hinfo = death_row->hashinfo;
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct in6_addr *daddr = &np->rcv_saddr;
+	const struct in6_addr *saddr = &np->daddr;
+	const int dif = sk->sk_bound_dev_if;
+	const u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
+	const unsigned int hash = inet6_ehashfn(daddr, inet->num, saddr,
+						inet->dport);
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
+		const struct inet6_timewait_sock *tw6 = inet6_twsk(sk2);
+
+		tw = inet_twsk(sk2);
+
+		if(*((__u32 *)&(tw->tw_dport)) == ports		 &&
+		   sk2->sk_family	       == PF_INET6	 &&
+		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	 &&
+		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr) &&
+		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
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
+		if (INET6_MATCH(sk2, hash, saddr, daddr, ports, dif))
+			goto not_unique;
+	}
+
+unique:
+	BUG_TRAP(sk_unhashed(sk));
+	__sk_add_node(sk, &head->chain);
+	sk->sk_hash = hash;
+	sock_prot_inc_use(sk->sk_prot);
+	write_unlock(&head->lock);
+
+	if (twp != NULL) {
+		*twp = tw;
+		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+	} else if (tw != NULL) {
+		/* Silly. Should hash-dance instead... */
+		inet_twsk_deschedule(tw, death_row);
+		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+
+		inet_twsk_put(tw);
+	}
+	return 0;
+
+not_unique:
+	write_unlock(&head->lock);
+	return -EADDRNOTAVAIL;
+}
+
+static inline u32 inet6_sk_port_offset(const struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
+	return secure_ipv6_port_ephemeral(np->rcv_saddr.s6_addr32,
+					  np->daddr.s6_addr32,
+					  inet->dport);
+}
+
+int inet6_hash_connect(struct inet_timewait_death_row *death_row,
+		       struct sock *sk)
+{
+	struct inet_hashinfo *hinfo = death_row->hashinfo;
+	const unsigned short snum = inet_sk(sk)->num;
+ 	struct inet_bind_hashbucket *head;
+ 	struct inet_bind_bucket *tb;
+	int ret;
+
+ 	if (snum == 0) {
+ 		const int low = sysctl_local_port_range[0];
+ 		const int high = sysctl_local_port_range[1];
+		const int range = high - low;
+ 		int i, port;
+		static u32 hint;
+		const u32 offset = hint + inet6_sk_port_offset(sk);
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
+ 					if (!__inet6_check_established(death_row,
+								       sk, port,
+								       &tw))
+ 						goto ok;
+ 					goto next_port;
+ 				}
+ 			}
+
+ 			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
+						     head, port);
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
+ 			__inet6_hash(hinfo, sk);
+ 		}
+ 		spin_unlock(&head->lock);
+
+ 		if (tw) {
+ 			inet_twsk_deschedule(tw, death_row);
+ 			inet_twsk_put(tw);
+ 		}
+
+		ret = 0;
+		goto out;
+ 	}
+
+ 	head = &hinfo->bhash[inet_bhashfn(snum, hinfo->bhash_size)];
+ 	tb   = inet_csk(sk)->icsk_bind_hash;
+	spin_lock_bh(&head->lock);
+
+	if (sk_head(&tb->owners) == sk && sk->sk_bind_node.next == NULL) {
+		__inet6_hash(hinfo, sk);
+		spin_unlock_bh(&head->lock);
+		return 0;
+	} else {
+		spin_unlock(&head->lock);
+		/* No definite answer... Walk to established hash table */
+		ret = __inet6_check_established(death_row, sk, snum, NULL);
+out:
+		local_bh_enable();
+		return ret;
+	}
+}
+
+EXPORT_SYMBOL_GPL(inet6_hash_connect);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7a077de..1587c35 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -119,177 +119,6 @@ static __u32 tcp_v6_init_sequence(struct
 	}
 }
 
-static int __tcp_v6_check_established(struct sock *sk, const __u16 lport,
-				      struct inet_timewait_sock **twp)
-{
-	struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-	const struct in6_addr *daddr = &np->rcv_saddr;
-	const struct in6_addr *saddr = &np->daddr;
-	const int dif = sk->sk_bound_dev_if;
-	const u32 ports = INET_COMBINED_PORTS(inet->dport, lport);
-	unsigned int hash = inet6_ehashfn(daddr, inet->num, saddr, inet->dport);
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
-		const struct inet6_timewait_sock *tw6 = inet6_twsk(sk2);
-
-		tw = inet_twsk(sk2);
-
-		if(*((__u32 *)&(tw->tw_dport))	== ports	&&
-		   sk2->sk_family		== PF_INET6	&&
-		   ipv6_addr_equal(&tw6->tw_v6_daddr, saddr)	&&
-		   ipv6_addr_equal(&tw6->tw_v6_rcv_saddr, daddr)	&&
-		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
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
-		if (INET6_MATCH(sk2, hash, saddr, daddr, ports, dif))
-			goto not_unique;
-	}
-
-unique:
-	BUG_TRAP(sk_unhashed(sk));
-	__sk_add_node(sk, &head->chain);
-	sk->sk_hash = hash;
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
-	return 0;
-
-not_unique:
-	write_unlock(&head->lock);
-	return -EADDRNOTAVAIL;
-}
-
-static inline u32 tcpv6_port_offset(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-
-	return secure_tcpv6_port_ephemeral(np->rcv_saddr.s6_addr32,
-					   np->daddr.s6_addr32,
-					   inet->dport);
-}
-
-static int tcp_v6_hash_connect(struct sock *sk)
-{
-	unsigned short snum = inet_sk(sk)->num;
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
-		u32 offset = hint + tcpv6_port_offset(sk);
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
- 					if (!__tcp_v6_check_established(sk,
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
- 			__inet6_hash(&tcp_hashinfo, sk);
- 		}
- 		spin_unlock(&head->lock);
-
- 		if (tw) {
- 			inet_twsk_deschedule(tw, &tcp_death_row);
- 			inet_twsk_put(tw);
- 		}
-
-		ret = 0;
-		goto out;
- 	}
-
- 	head = &tcp_hashinfo.bhash[inet_bhashfn(snum, tcp_hashinfo.bhash_size)];
- 	tb   = inet_csk(sk)->icsk_bind_hash;
-	spin_lock_bh(&head->lock);
-
-	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		__inet6_hash(&tcp_hashinfo, sk);
-		spin_unlock_bh(&head->lock);
-		return 0;
-	} else {
-		spin_unlock(&head->lock);
-		/* No definite answer... Walk to established hash table */
-		ret = __tcp_v6_check_established(sk, snum, NULL);
-out:
-		local_bh_enable();
-		return ret;
-	}
-}
-
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr, 
 			  int addr_len)
 {
@@ -450,7 +279,7 @@ static int tcp_v6_connect(struct sock *s
 	inet->dport = usin->sin6_port;
 
 	tcp_set_state(sk, TCP_SYN_SENT);
-	err = tcp_v6_hash_connect(sk);
+	err = inet6_hash_connect(&tcp_death_row, sk);
 	if (err)
 		goto late_failure;
 







------=_Part_7352_11882467.1134403963161--
