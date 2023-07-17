From: Guillaume Nault <gnault@redhat.com>
Date: Mon, 17 Jul 2023 13:53:35 +0000
Subject: [PATCH net-next 2/3] dccp: Set TOS and routing scope independently for fib lookups.
Message-Id: <d316b3692ee6ef6c91bfcf246aeae45c0e104dd0.1689600901.git.gnault@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There's no reason for setting the RTO_ONLINK flag in ->flowi4_tos as
RT_CONN_FLAGS() does. We can easily set ->flowi4_scope properly
instead. This makes the code more explicit and will allow to convert
->flowi4_tos to dscp_t in the future.

Signed-off-by: Guillaume Nault <gnault@redhat.com>
---
 net/dccp/ipv4.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index fa8079303cb0..8e919cfe6e23 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -474,7 +474,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		.flowi4_oif = inet_iif(skb),
 		.daddr = iph->saddr,
 		.saddr = iph->daddr,
-		.flowi4_tos = RT_CONN_FLAGS(sk),
+		.flowi4_tos = ip_sock_rt_tos(sk),
+		.flowi4_scope = ip_sock_rt_scope(sk),
 		.flowi4_proto = sk->sk_protocol,
 		.fl4_sport = dccp_hdr(skb)->dccph_dport,
 		.fl4_dport = dccp_hdr(skb)->dccph_sport,
-- 
2.39.2
