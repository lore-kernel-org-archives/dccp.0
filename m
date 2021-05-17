From: Yejune Deng <yejune.deng@gmail.com>
Date: Mon, 17 May 2021 12:22:05 +0000
Subject: [PATCH] net: Remove the member netns_ok
Message-Id: <1621254125-21588-1-git-send-email-yejunedeng@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Every protocol has the 'netns_ok' member and it is euqal to 1. The
'if (!prot->netns_ok)' always false in inet_add_protocol().

Signed-off-by: Yejune Deng <yejunedeng@gmail.com>
---
 include/net/protocol.h    | 1 -
 net/dccp/ipv4.c           | 1 -
 net/ipv4/af_inet.c        | 4 ----
 net/ipv4/gre_demux.c      | 1 -
 net/ipv4/ipmr.c           | 1 -
 net/ipv4/protocol.c       | 6 ------
 net/ipv4/tunnel4.c        | 3 ---
 net/ipv4/udplite.c        | 1 -
 net/ipv4/xfrm4_protocol.c | 3 ---
 net/l2tp/l2tp_ip.c        | 1 -
 net/sctp/protocol.c       | 1 -
 11 files changed, 23 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 2b778e1..f51c06a 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -43,7 +43,6 @@ struct net_protocol {
 	int			(*err_handler)(struct sk_buff *skb, u32 info);
 
 	unsigned int		no_policy:1,
-				netns_ok:1,
 				/* does the protocol do more stringent
 				 * icmp tag validation than simple
 				 * socket lookup?
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ffc601a..f81c1df 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -977,7 +977,6 @@ static const struct net_protocol dccp_v4_protocol = {
 	.handler	= dccp_v4_rcv,
 	.err_handler	= dccp_v4_err,
 	.no_policy	= 1,
-	.netns_ok	= 1,
 	.icmp_strict_tag_validation = 1,
 };
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f17870e..d9bccad6 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1720,7 +1720,6 @@ EXPORT_SYMBOL_GPL(snmp_fold_field64);
 #ifdef CONFIG_IP_MULTICAST
 static const struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
-	.netns_ok =	1,
 };
 #endif
 
@@ -1733,7 +1732,6 @@ static struct net_protocol tcp_protocol = {
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 	.icmp_strict_tag_validation = 1,
 };
 
@@ -1746,14 +1744,12 @@ static struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.no_policy =	1,
-	.netns_ok =	1,
 };
 
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.err_handler =	icmp_err,
 	.no_policy =	1,
-	.netns_ok =	1,
 };
 
 static __net_init int ipv4_mib_init_net(struct net *net)
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 5d1e6fe..cbb2b4b 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -195,7 +195,6 @@ static int gre_err(struct sk_buff *skb, u32 info)
 static const struct net_protocol net_gre_protocol = {
 	.handler     = gre_rcv,
 	.err_handler = gre_err,
-	.netns_ok    = 1,
 };
 
 static int __init gre_init(void)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 939792a..12b564b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -3007,7 +3007,6 @@ static const struct seq_operations ipmr_mfc_seq_ops = {
 #ifdef CONFIG_IP_PIMSM_V2
 static const struct net_protocol pim_protocol = {
 	.handler	=	pim_rcv,
-	.netns_ok	=	1,
 };
 #endif
 
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 9a8c089..6913979 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -31,12 +31,6 @@ EXPORT_SYMBOL(inet_offloads);
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
-	if (!prot->netns_ok) {
-		pr_err("Protocol %u is not namespace aware, cannot register.\n",
-			protocol);
-		return -EINVAL;
-	}
-
 	return !cmpxchg((const struct net_protocol **)&inet_protos[protocol],
 			NULL, prot) ? 0 : -1;
 }
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index e44aaf4..5048c47 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -218,7 +218,6 @@ static const struct net_protocol tunnel4_protocol = {
 	.handler	=	tunnel4_rcv,
 	.err_handler	=	tunnel4_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -226,7 +225,6 @@ static const struct net_protocol tunnel64_protocol = {
 	.handler	=	tunnel64_rcv,
 	.err_handler	=	tunnel64_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 #endif
 
@@ -235,7 +233,6 @@ static const struct net_protocol tunnelmpls4_protocol = {
 	.handler	=	tunnelmpls4_rcv,
 	.err_handler	=	tunnelmpls4_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 #endif
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index bd8773b..cd1cd68 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -31,7 +31,6 @@ static const struct net_protocol udplite_protocol = {
 	.handler	= udplite_rcv,
 	.err_handler	= udplite_err,
 	.no_policy	= 1,
-	.netns_ok	= 1,
 };
 
 struct proto 	udplite_prot = {
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index ea595c8..2fe5860 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -181,21 +181,18 @@ static const struct net_protocol esp4_protocol = {
 	.handler	=	xfrm4_esp_rcv,
 	.err_handler	=	xfrm4_esp_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 
 static const struct net_protocol ah4_protocol = {
 	.handler	=	xfrm4_ah_rcv,
 	.err_handler	=	xfrm4_ah_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 
 static const struct net_protocol ipcomp4_protocol = {
 	.handler	=	xfrm4_ipcomp_rcv,
 	.err_handler	=	xfrm4_ipcomp_err,
 	.no_policy	=	1,
-	.netns_ok	=	1,
 };
 
 static const struct xfrm_input_afinfo xfrm4_input_afinfo = {
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 97ae125..536c30d 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -635,7 +635,6 @@ static struct inet_protosw l2tp_ip_protosw = {
 
 static struct net_protocol l2tp_ip_protocol __read_mostly = {
 	.handler	= l2tp_ip_recv,
-	.netns_ok	= 1,
 };
 
 static int __init l2tp_ip_init(void)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 6f2bbfe..baa4e77 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1171,7 +1171,6 @@ static const struct net_protocol sctp_protocol = {
 	.handler     = sctp4_rcv,
 	.err_handler = sctp_v4_err,
 	.no_policy   = 1,
-	.netns_ok    = 1,
 	.icmp_strict_tag_validation = 1,
 };
 
-- 
2.7.4
