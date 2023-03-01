From: Madhu Koriginja <madhu.koriginja@nxp.com>
Date: Wed, 01 Mar 2023 14:56:01 +0000
Subject: [PATCH] [NETFILTER]: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <20230301145534.421569-1-madhu.koriginja@nxp.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Keep the conntrack reference until policy checks have been performed for
IPsec V6 NAT support. The reference needs to be dropped before a packet is
queued to avoid having the conntrack module unloadable.

Signed-off-by: Madhu Koriginja <madhu.koriginja@nxp.com>
---
 net/dccp/ipv6.c      |  1 +
 net/ipv6/ip6_input.c | 14 +++++++-------
 net/ipv6/raw.c       |  2 +-
 net/ipv6/tcp_ipv6.c  |  2 ++
 net/ipv6/udp.c       |  2 ++
 5 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 58a401e9cf09..eb503096db6c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -771,6 +771,7 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	return __sk_receive_skb(sk, skb, 1, dh->dccph_doff * 4,
 				refcounted) ? -1 : 0;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index acf0749ee5bb..7dc295b7af8f 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -374,10 +374,6 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
 			/* Only do this once for first final protocol */
 			have_final = true;
 
-			/* Free reference early: we don't need it any more,
-			   and it may hold ip_conntrack module loaded
-			   indefinitely. */
-			nf_reset(skb);
 
 			skb_postpull_rcsum(skb, skb_network_header(skb),
 					   skb_network_header_len(skb));
@@ -388,9 +384,13 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
 			    !ipv6_is_mld(skb, nexthdr, skb_network_header_len(skb)))
 				goto discard;
 		}
-		if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
-		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-			goto discard;
+
+		if (!ipprot->flags & INET6_PROTO_NOPOLICY) {
+			if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
+				goto discard;
+
+			nf_reset(skb);
+		}
 
 		ret = ipprot->handler(skb);
 		if (ret > 0) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4856d9320b28..cf68c9418897 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -220,7 +220,6 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 
 			/* Not releasing hash table! */
 			if (clone) {
-				nf_reset(clone);
 				rawv6_rcv(sk, clone);
 			}
 		}
@@ -428,6 +427,7 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset(skb);
 
 	if (!rp->checksum)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9a117a79af65..0bc959cfbea4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1534,6 +1534,8 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
 
+	nf_reset(skb);
+
 	if (tcp_filter(sk, skb))
 		goto discard_and_relse;
 	th = (const struct tcphdr *)skb->data;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 72b2e7809af6..aacb48e977cb 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -567,6 +567,7 @@ static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset(skb);
 
 	if (static_branch_unlikely(&udpv6_encap_needed_key) && up->encap_type) {
 		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
@@ -860,6 +861,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard;
+	nf_reset(skb);
 
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
-- 
2.25.1
