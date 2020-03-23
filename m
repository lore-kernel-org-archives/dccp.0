From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Mon, 23 Mar 2020 18:18:13 +0000
Subject: [PATCH net-next 1/2] tcp/dccp: Move initialisation of refcounted into if block.
Message-Id: <20200323181814.87661-2-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The refcounted is initialised at most three times.

  - __inet_lookup_skb() sets it true.
  - skb_steal_sock() is false and __inet_lookup() sets it true.
  - __inet_lookup_established() is false and __inet_lookup() sets it false.

We do not need to initialise refcounted again and again, so we should do
it just before return.

Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
---
 include/net/inet6_hashtables.h | 11 +++++++----
 include/net/inet_hashtables.h  | 11 +++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index fe96bf247aac..9b6c97100d54 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -70,9 +70,11 @@ static inline struct sock *__inet6_lookup(struct net *net,
 	struct sock *sk = __inet6_lookup_established(net, hashinfo, saddr,
 						     sport, daddr, hnum,
 						     dif, sdif);
-	*refcounted = true;
-	if (sk)
+	if (sk) {
+		*refcounted = true;
 		return sk;
+	}
+
 	*refcounted = false;
 	return inet6_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
 				     daddr, hnum, dif, sdif);
@@ -87,9 +89,10 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 {
 	struct sock *sk = skb_steal_sock(skb);
 
-	*refcounted = true;
-	if (sk)
+	if (sk) {
+		*refcounted = true;
 		return sk;
+	}
 
 	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
 			      doff, &ipv6_hdr(skb)->saddr, sport,
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d0019d3395cf..aa859bf8607b 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -345,9 +345,11 @@ static inline struct sock *__inet_lookup(struct net *net,
 
 	sk = __inet_lookup_established(net, hashinfo, saddr, sport,
 				       daddr, hnum, dif, sdif);
-	*refcounted = true;
-	if (sk)
+	if (sk) {
+		*refcounted = true;
 		return sk;
+	}
+
 	*refcounted = false;
 	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr,
 				      sport, daddr, hnum, dif, sdif);
@@ -382,9 +384,10 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 	struct sock *sk = skb_steal_sock(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 
-	*refcounted = true;
-	if (sk)
+	if (sk) {
+		*refcounted = true;
 		return sk;
+	}
 
 	return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
 			     doff, iph->saddr, sport,
-- 
2.17.2 (Apple Git-113)
