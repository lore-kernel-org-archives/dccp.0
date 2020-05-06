From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Wed, 06 May 2020 12:55:03 +0000
Subject: [PATCH bpf-next 07/17] inet6: Run SK_LOOKUP BPF program on socket lookup
Message-Id: <20200506125514.1020829-8-jakub@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Following ipv4 stack changes, run a BPF program attached to netns before
looking up a listening socket. Program can return a listening socket to use
as result of socket lookup, fail the lookup, or take no action.

Suggested-by: Marek Majkowski <marek@cloudflare.com>
Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
---
 include/net/inet6_hashtables.h | 20 ++++++++++++++++++++
 net/ipv6/inet6_hashtables.c    | 15 ++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 81b965953036..8b8c0cb92ea8 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -21,6 +21,7 @@
 
 #include <net/ipv6.h>
 #include <net/netns/hash.h>
+#include <net/inet_hashtables.h>
 
 struct inet_hashinfo;
 
@@ -103,6 +104,25 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  const int dif);
 
 int inet6_hash(struct sock *sk);
+
+static inline struct sock *inet6_lookup_run_bpf(struct net *net, u8 protocol,
+						const struct in6_addr *saddr,
+						__be16 sport,
+						const struct in6_addr *daddr,
+						u16 dport)
+{
+	struct bpf_sk_lookup_kern ctx = {
+		.family		= AF_INET6,
+		.protocol	= protocol,
+		.v6.saddr	= *saddr,
+		.v6.daddr	= *daddr,
+		.sport		= sport,
+		.dport		= dport,
+	};
+
+	return bpf_sk_lookup_run(net, &ctx);
+}
+
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif, __sdif) \
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 03942eef8ab6..6d91de89fd2b 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -167,9 +167,22 @@ struct sock *inet6_lookup_listener(struct net *net,
 		const unsigned short hnum, const int dif, const int sdif)
 {
 	struct inet_listen_hashbucket *ilb2;
-	struct sock *result = NULL;
+	struct sock *result, *reuse_sk;
 	unsigned int hash2;
 
+	/* Lookup redirect from BPF */
+	result = inet6_lookup_run_bpf(net, hashinfo->protocol,
+				      saddr, sport, daddr, hnum);
+	if (IS_ERR(result))
+		return NULL;
+	if (result) {
+		reuse_sk = lookup_reuseport(net, result, skb, doff,
+					    saddr, sport, daddr, hnum);
+		if (reuse_sk)
+			result = reuse_sk;
+		goto done;
+	}
+
 	hash2 = ipv6_portaddr_hash(net, daddr, hnum);
 	ilb2 = inet_lhash2_bucket(hashinfo, hash2);
 
-- 
2.25.3
