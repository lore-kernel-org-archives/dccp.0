From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 16 Apr 2010 02:43:08 +0000
Subject: [net-next-2.6 PATCH 2/3 v2] net: replace ipfragok with skb->local_df
Message-Id: <4BC7CEBC.70200@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As Herbert Xu said: we should be able to simply replace ipfragok
with skb->local_df. commit f88037(sctp: Drop ipfargok in sctp_xmit function)
has droped ipfragok and set local_df value properly.

The patch kills the ipfragok parameter of .queue_xmit().


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
Resend the patches with fixed cc list, no content changes.
---
 include/net/inet6_connection_sock.h |    2 +-
 include/net/inet_connection_sock.h  |    2 +-
 include/net/ip.h                    |    2 +-
 include/net/ipv6.h                  |    3 +--
 net/dccp/ipv6.c                     |    4 ++--
 net/dccp/output.c                   |    2 +-
 net/ipv4/ip_output.c                |    4 ++--
 net/ipv4/tcp_output.c               |    2 +-
 net/ipv6/inet6_connection_sock.c    |    4 ++--
 net/ipv6/ip6_output.c               |    2 +-
 net/ipv6/tcp_ipv6.c                 |    4 ++--
 net/l2tp/l2tp_core.c                |    3 ++-
 net/l2tp/l2tp_ip.c                  |    2 +-
 net/sctp/ipv6.c                     |    2 +-
 net/sctp/protocol.c                 |    2 +-
 15 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index f13ddc2..aae08f6 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -38,5 +38,5 @@ extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 
 extern void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-extern int inet6_csk_xmit(struct sk_buff *skb, int ipfragok);
+extern int inet6_csk_xmit(struct sk_buff *skb);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 52c8b8b..b6d3b55 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -36,7 +36,7 @@ struct tcp_congestion_ops;
  * (i.e. things that depend on the address family)
  */
 struct inet_connection_sock_af_ops {
-	int	    (*queue_xmit)(struct sk_buff *skb, int ipfragok);
+	int	    (*queue_xmit)(struct sk_buff *skb);
 	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 503994a..a84ceb6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -101,7 +101,7 @@ extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		__ip_local_out(struct sk_buff *skb);
 extern int		ip_local_out(struct sk_buff *skb);
-extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
+extern int		ip_queue_xmit(struct sk_buff *skb);
 extern void		ip_init(void);
 extern int		ip_append_data(struct sock *sk,
 				       int getfrag(void *from, char *to, int offset, int len,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 033ddd4..b1d8db9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -482,8 +482,7 @@ extern int			ip6_rcv_finish(struct sk_buff *skb);
 extern int			ip6_xmit(struct sock *sk,
 					 struct sk_buff *skb,
 					 struct flowi *fl,
-					 struct ipv6_txoptions *opt,
-					 int ipfragok);
+					 struct ipv6_txoptions *opt);
 
 extern int			ip6_nd_hdr(struct sock *sk,
 					   struct sk_buff *skb,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index ab1ab95..0916988 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -292,7 +292,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 							 &ireq6->loc_addr,
 							 &ireq6->rmt_addr);
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		err = ip6_xmit(sk, skb, &fl, opt, 0);
+		err = ip6_xmit(sk, skb, &fl, opt);
 		err = net_xmit_eval(err);
 	}
 
@@ -347,7 +347,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (!ip6_dst_lookup(ctl_sk, &dst, &fl)) {
 		if (xfrm_lookup(net, &dst, &fl, NULL, 0) >= 0) {
 			skb_dst_set(skb, dst);
-			ip6_xmit(ctl_sk, skb, &fl, NULL, 0);
+			ip6_xmit(ctl_sk, skb, &fl, NULL);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 			return;
diff --git a/net/dccp/output.c b/net/dccp/output.c
index b8d98e3..e98b65e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -136,7 +136,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
-		err = icsk->icsk_af_ops->queue_xmit(skb, 0);
+		err = icsk->icsk_af_ops->queue_xmit(skb);
 		return net_xmit_eval(err);
 	}
 	return -ENOBUFS;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65f18e..512af81 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -311,7 +311,7 @@ int ip_output(struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
+int ip_queue_xmit(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
@@ -370,7 +370,7 @@ packet_routed:
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
 	*((__be16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
-	if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)
+	if (ip_dont_fragment(sk, &rt->u.dst) && !skb->local_df)
 		iph->frag_off = htons(IP_DF);
 	else
 		iph->frag_off = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e468499..2b7d71f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -890,7 +890,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq = tcb->end_seq)
 		TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
-	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
+	err = icsk->icsk_af_ops->queue_xmit(skb);
 	if (likely(err <= 0))
 		return err;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 628db24..0c5e3c3 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -178,7 +178,7 @@ struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 	return dst;
 }
 
-int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
+int inet6_csk_xmit(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
@@ -234,7 +234,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 
-	return ip6_xmit(sk, skb, &fl, np->opt, 0);
+	return ip6_xmit(sk, skb, &fl, np->opt);
 }
 
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f3a847e..141819f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -185,7 +185,7 @@ int ip6_output(struct sk_buff *skb)
  */
 
 int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
-	     struct ipv6_txoptions *opt, int ipfragok)
+	     struct ipv6_txoptions *opt)
 {
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b429dfd..bd5ef7b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -509,7 +509,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-		err = ip6_xmit(sk, skb, &fl, opt, 0);
+		err = ip6_xmit(sk, skb, &fl, opt);
 		err = net_xmit_eval(err);
 	}
 
@@ -1071,7 +1071,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	if (!ip6_dst_lookup(ctl_sk, &dst, &fl)) {
 		if (xfrm_lookup(net, &dst, &fl, NULL, 0) >= 0) {
 			skb_dst_set(buff, dst);
-			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
+			ip6_xmit(ctl_sk, buff, &fl, NULL);
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 			if (rst)
 				TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 98dfcce..ecc7aea 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -954,7 +954,8 @@ int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t dat
 	}
 
 	/* Queue the packet to IP for output */
-	error = ip_queue_xmit(skb, 1);
+	skb->local_df = 1;
+	error = ip_queue_xmit(skb);
 
 	/* Update stats */
 	if (error >= 0) {
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 75bf784..0852512 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -501,7 +501,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	skb_dst_set(skb, dst_clone(&rt->u.dst));
 
 	/* Queue the packet to IP for output */
-	rc = ip_queue_xmit(skb, 0);
+	rc = ip_queue_xmit(skb);
 
 error:
 	/* Update stats */
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 14db568..7326891 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -232,7 +232,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	if (!(transport->param_flags & SPP_PMTUD_ENABLE))
 		skb->local_df = 1;
 
-	return ip6_xmit(sk, skb, &fl, np->opt, 0);
+	return ip6_xmit(sk, skb, &fl, np->opt);
 }
 
 /* Returns the dst cache entry for the given source and destination ip
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a56f98e..704298f 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -854,7 +854,7 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
-	return ip_queue_xmit(skb, 0);
+	return ip_queue_xmit(skb);
 }
 
 static struct sctp_af sctp_af_inet;
-- 
1.6.3.3


