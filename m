From: Madhu Koriginja <madhu.koriginja@nxp.com>
Date: Fri, 03 Mar 2023 09:54:21 +0000
Subject: [PATCH net-next] net: netfilter: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <20230303094221.1501961-1-madhu.koriginja@nxp.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Keep the conntrack reference until policy checks have been performed for
IPsec V6 NAT support. The reference needs to be dropped before a packet is
queued to avoid having the conntrack module unloadable.

Signed-off-by: Madhu Koriginja <madhu.koriginja@nxp.com>
	V1-V2: added missing () in ip6_input.c in below condition
	if (!(ipprot->flags & INET6_PROTO_NOPOLICY))
	V2-V3: replaced nf_reset with nf_reset_ct
---
 net/dccp/ipv6.c      |  1 +
 net/ipv6/ip6_input.c | 12 +++++-------
 net/ipv6/raw.c       |  2 +-
 net/ipv6/tcp_ipv6.c  |  2 ++
 net/ipv6/udp.c       |  2 ++
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1e5e08cc0..5a3104c7a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -771,6 +771,7 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset_ct(skb);
 
 	return __sk_receive_skb(sk, skb, 1, dh->dccph_doff * 4,
 				refcounted) ? -1 : 0;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 3d71c7d61..25ff89d9f 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -378,10 +378,6 @@ void ip6_protocol_deliver_rcu(struct net *net, struct sk_buff *skb, int nexthdr,
 			/* Only do this once for first final protocol */
 			have_final = true;
 
-			/* Free reference early: we don't need it any more,
-			   and it may hold ip_conntrack module loaded
-			   indefinitely. */
-			nf_reset_ct(skb);
 
 			skb_postpull_rcsum(skb, skb_network_header(skb),
 					   skb_network_header_len(skb));
@@ -402,10 +398,12 @@ void ip6_protocol_deliver_rcu(struct net *net, struct sk_buff *skb, int nexthdr,
 			    !ipv6_is_mld(skb, nexthdr, skb_network_header_len(skb)))
 				goto discard;
 		}
-		if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
-		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-			goto discard;
+		if (!(ipprot->flags & INET6_PROTO_NOPOLICY)) {
+			if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
+				goto discard;
 
+			nf_reset_ct(skb);
+		}
 		ret = INDIRECT_CALL_2(ipprot->handler, tcp_v6_rcv, udpv6_rcv,
 				      skb);
 		if (ret > 0) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dfe5e603f..c13b8e0c4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -215,7 +215,6 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 
 			/* Not releasing hash table! */
 			if (clone) {
-				nf_reset_ct(clone);
 				rawv6_rcv(sk, clone);
 			}
 		}
@@ -423,6 +422,7 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset_ct(skb);
 
 	if (!rp->checksum)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b42fa41cf..820aa9767 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1586,6 +1586,8 @@ INDIRECT_CALLABLE_SCOPE int tcp_v6_rcv(struct sk_buff *skb)
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
 
+	nf_reset_ct(skb);
+
 	if (tcp_filter(sk, skb))
 		goto discard_and_relse;
 	th = (const struct tcphdr *)skb->data;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d56698517..2be1364d0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -604,6 +604,7 @@ static int udpv6_queue_rcv_one_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset_ct(skb);
 
 	if (static_branch_unlikely(&udpv6_encap_needed_key) && up->encap_type) {
 		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
@@ -920,6 +921,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard;
+	nf_reset_ct(skb);
 
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
-- 
2.25.1
