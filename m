From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Mon, 23 Mar 2020 18:18:14 +0000
Subject: [PATCH net-next 2/2] tcp/dccp: Remove unnecessary initialization of refcounted.
Message-Id: <20200323181814.87661-3-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When we get a TCP_NEW_SYN_RECV/DCCP_NEW_SYN_RECV socket by
__inet_lookup_skb(), refcounted is already set true, so it is not
necessary to do it again.

Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
---
 net/dccp/ipv4.c     | 1 -
 net/dccp/ipv6.c     | 1 -
 net/ipv4/tcp_ipv4.c | 1 -
 net/ipv6/tcp_ipv6.c | 1 -
 4 files changed, 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d19557c6d04b..c63b6bd68284 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -838,7 +838,6 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 			goto lookup;
 		}
 		sock_hold(sk);
-		refcounted = true;
 		nsk = dccp_check_req(sk, skb, req);
 		if (!nsk) {
 			reqsk_put(req);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1e5e08cc0bfc..b3ca9b1ef32a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -740,7 +740,6 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 			goto lookup;
 		}
 		sock_hold(sk);
-		refcounted = true;
 		nsk = dccp_check_req(sk, skb, req);
 		if (!nsk) {
 			reqsk_put(req);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index df1166b76126..b59a89d8fa69 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1931,7 +1931,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		 * as we might lose it too soon.
 		 */
 		sock_hold(sk);
-		refcounted = true;
 		nsk = NULL;
 		if (!tcp_filter(sk, skb)) {
 			th = (const struct tcphdr *)skb->data;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index eaf09e6b7844..3a587c40ca52 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1603,7 +1603,6 @@ INDIRECT_CALLABLE_SCOPE int tcp_v6_rcv(struct sk_buff *skb)
 			goto lookup;
 		}
 		sock_hold(sk);
-		refcounted = true;
 		nsk = NULL;
 		if (!tcp_filter(sk, skb)) {
 			th = (const struct tcphdr *)skb->data;
-- 
2.17.2 (Apple Git-113)
