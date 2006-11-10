From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 15:30:07 +0000
Subject: [PATCH 8/10][DCCPv6]: remove forward declarations in ipv6.c
Message-Id: <20061110153006.GL23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This does the same for ipv6.c as the preceding one does for ipv4.c: Only the
inet_connection_sock_af_ops forward declarations remain, since at least
dccp_ipv6_mapped has a circular dependency to dccp_v6_request_recv_sock.

No code change, merely re-ordering.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv6.c |  385 ++++++++++++++++++++++++++++++++---------------------------------
 1 file changed, 190 insertions(+), 195 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 89b2113..4966369 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -36,11 +36,6 @@ #include "feat.h"
 /* Socket used for sending RSTs and ACKs */
 static struct socket *dccp_v6_ctl_socket;
 
-static void dccp_v6_ctl_send_reset(struct sk_buff *skb);
-static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb);
-
-static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
-
 static struct inet_connection_sock_af_ops dccp_ipv6_mapped;
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
 
@@ -87,183 +82,6 @@ static __u32 dccp_v6_init_sequence(struc
 					   dh->dccph_sport);
 }
 
-static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
-			   int addr_len)
-{
-	struct sockaddr_in6 *usin = (struct sockaddr_in6 *)uaddr;
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct in6_addr *saddr = NULL, *final_p = NULL, final;
-	struct flowi fl;
-	struct dst_entry *dst;
-	int addr_type;
-	int err;
-
-	dp->dccps_role = DCCP_ROLE_CLIENT;
-
-	if (addr_len < SIN6_LEN_RFC2133)
-		return -EINVAL;
-
-	if (usin->sin6_family != AF_INET6)
-		return -EAFNOSUPPORT;
-
-	memset(&fl, 0, sizeof(fl));
-
-	if (np->sndflow) {
-		fl.fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
-		IP6_ECN_flow_init(fl.fl6_flowlabel);
-		if (fl.fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
-			struct ip6_flowlabel *flowlabel;
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
-			if (flowlabel = NULL)
-				return -EINVAL;
-			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
-			fl6_sock_release(flowlabel);
-		}
-	}
-	/*
-	 * connect() to INADDR_ANY means loopback (BSD'ism).
-	 */
-	if (ipv6_addr_any(&usin->sin6_addr))
-		usin->sin6_addr.s6_addr[15] = 1;
-
-	addr_type = ipv6_addr_type(&usin->sin6_addr);
-
-	if (addr_type & IPV6_ADDR_MULTICAST)
-		return -ENETUNREACH;
-
-	if (addr_type & IPV6_ADDR_LINKLOCAL) {
-		if (addr_len >= sizeof(struct sockaddr_in6) &&
-		    usin->sin6_scope_id) {
-			/* If interface is set while binding, indices
-			 * must coincide.
-			 */
-			if (sk->sk_bound_dev_if &&
-			    sk->sk_bound_dev_if != usin->sin6_scope_id)
-				return -EINVAL;
-
-			sk->sk_bound_dev_if = usin->sin6_scope_id;
-		}
-
-		/* Connect to link-local address requires an interface */
-		if (!sk->sk_bound_dev_if)
-			return -EINVAL;
-	}
-
-	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
-	np->flow_label = fl.fl6_flowlabel;
-
-	/*
-	 * DCCP over IPv4
-	 */
-	if (addr_type = IPV6_ADDR_MAPPED) {
-		u32 exthdrlen = icsk->icsk_ext_hdr_len;
-		struct sockaddr_in sin;
-
-		SOCK_DEBUG(sk, "connect: ipv4 mapped\n");
-
-		if (__ipv6_only_sock(sk))
-			return -ENETUNREACH;
-
-		sin.sin_family = AF_INET;
-		sin.sin_port = usin->sin6_port;
-		sin.sin_addr.s_addr = usin->sin6_addr.s6_addr32[3];
-
-		icsk->icsk_af_ops = &dccp_ipv6_mapped;
-		sk->sk_backlog_rcv = dccp_v4_do_rcv;
-
-		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
-		if (err) {
-			icsk->icsk_ext_hdr_len = exthdrlen;
-			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
-			sk->sk_backlog_rcv = dccp_v6_do_rcv;
-			goto failure;
-		} else {
-			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->saddr);
-			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->rcv_saddr);
-		}
-
-		return err;
-	}
-
-	if (!ipv6_addr_any(&np->rcv_saddr))
-		saddr = &np->rcv_saddr;
-
-	fl.proto = IPPROTO_DCCP;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
-	fl.oif = sk->sk_bound_dev_if;
-	fl.fl_ip_dport = usin->sin6_port;
-	fl.fl_ip_sport = inet->sport;
-	security_sk_classify_flow(sk, &fl);
-
-	if (np->opt != NULL && np->opt->srcrt != NULL) {
-		const struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
-
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
-
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
-		goto failure;
-
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	err = xfrm_lookup(&dst, &fl, sk, 0);
-	if (err < 0)
-		goto failure;
-
-	if (saddr = NULL) {
-		saddr = &fl.fl6_src;
-		ipv6_addr_copy(&np->rcv_saddr, saddr);
-	}
-
-	/* set the source address */
-	ipv6_addr_copy(&np->saddr, saddr);
-	inet->rcv_saddr = LOOPBACK4_IPV6;
-
-	__ip6_dst_store(sk, dst, NULL, NULL);
-
-	icsk->icsk_ext_hdr_len = 0;
-	if (np->opt != NULL)
-		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
-					  np->opt->opt_nflen);
-
-	inet->dport = usin->sin6_port;
-
-	dccp_set_state(sk, DCCP_REQUESTING);
-	err = inet6_hash_connect(&dccp_death_row, sk);
-	if (err)
-		goto late_failure;
-	/* FIXME */
-#if 0
-	dp->dccps_gar = secure_dccp_v6_sequence_number(np->saddr.s6_addr32,
-						       np->daddr.s6_addr32,
-						       inet->sport,
-						       inet->dport);
-#endif
-	err = dccp_connect(sk);
-	if (err)
-		goto late_failure;
-
-	return 0;
-
-late_failure:
-	dccp_set_state(sk, DCCP_CLOSED);
-	__sk_dst_reset(sk);
-failure:
-	inet->dport = 0;
-	sk->sk_route_caps = 0;
-	return err;
-}
-
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			int type, int code, int offset, __be32 info)
 {
@@ -487,19 +305,6 @@ static void dccp_v6_reqsk_destructor(str
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
 
-static struct request_sock_ops dccp6_request_sock_ops = {
-	.family		= AF_INET6,
-	.obj_size	= sizeof(struct dccp6_request_sock),
-	.rtx_syn_ack	= dccp_v6_send_response,
-	.send_ack	= dccp_reqsk_send_ack,
-	.destructor	= dccp_v6_reqsk_destructor,
-	.send_reset	= dccp_v6_ctl_send_reset,
-};
-
-static struct timewait_sock_ops dccp6_timewait_sock_ops = {
-	.twsk_obj_size	= sizeof(struct dccp6_timewait_sock),
-};
-
 static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -580,6 +385,15 @@ static void dccp_v6_ctl_send_reset(struc
 	kfree_skb(skb);
 }
 
+static struct request_sock_ops dccp6_request_sock_ops = {
+	.family		= AF_INET6,
+	.obj_size	= sizeof(struct dccp6_request_sock),
+	.rtx_syn_ack	= dccp_v6_send_response,
+	.send_ack	= dccp_reqsk_send_ack,
+	.destructor	= dccp_v6_reqsk_destructor,
+	.send_reset	= dccp_v6_ctl_send_reset,
+};
+
 static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
@@ -1062,6 +876,183 @@ discard_and_relse:
 	goto discard_it;
 }
 
+static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
+			   int addr_len)
+{
+	struct sockaddr_in6 *usin = (struct sockaddr_in6 *)uaddr;
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct in6_addr *saddr = NULL, *final_p = NULL, final;
+	struct flowi fl;
+	struct dst_entry *dst;
+	int addr_type;
+	int err;
+
+	dp->dccps_role = DCCP_ROLE_CLIENT;
+
+	if (addr_len < SIN6_LEN_RFC2133)
+		return -EINVAL;
+
+	if (usin->sin6_family != AF_INET6)
+		return -EAFNOSUPPORT;
+
+	memset(&fl, 0, sizeof(fl));
+
+	if (np->sndflow) {
+		fl.fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
+		IP6_ECN_flow_init(fl.fl6_flowlabel);
+		if (fl.fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
+			struct ip6_flowlabel *flowlabel;
+			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			if (flowlabel = NULL)
+				return -EINVAL;
+			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
+			fl6_sock_release(flowlabel);
+		}
+	}
+	/*
+	 * connect() to INADDR_ANY means loopback (BSD'ism).
+	 */
+	if (ipv6_addr_any(&usin->sin6_addr))
+		usin->sin6_addr.s6_addr[15] = 1;
+
+	addr_type = ipv6_addr_type(&usin->sin6_addr);
+
+	if (addr_type & IPV6_ADDR_MULTICAST)
+		return -ENETUNREACH;
+
+	if (addr_type & IPV6_ADDR_LINKLOCAL) {
+		if (addr_len >= sizeof(struct sockaddr_in6) &&
+		    usin->sin6_scope_id) {
+			/* If interface is set while binding, indices
+			 * must coincide.
+			 */
+			if (sk->sk_bound_dev_if &&
+			    sk->sk_bound_dev_if != usin->sin6_scope_id)
+				return -EINVAL;
+
+			sk->sk_bound_dev_if = usin->sin6_scope_id;
+		}
+
+		/* Connect to link-local address requires an interface */
+		if (!sk->sk_bound_dev_if)
+			return -EINVAL;
+	}
+
+	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
+	np->flow_label = fl.fl6_flowlabel;
+
+	/*
+	 * DCCP over IPv4
+	 */
+	if (addr_type = IPV6_ADDR_MAPPED) {
+		u32 exthdrlen = icsk->icsk_ext_hdr_len;
+		struct sockaddr_in sin;
+
+		SOCK_DEBUG(sk, "connect: ipv4 mapped\n");
+
+		if (__ipv6_only_sock(sk))
+			return -ENETUNREACH;
+
+		sin.sin_family = AF_INET;
+		sin.sin_port = usin->sin6_port;
+		sin.sin_addr.s_addr = usin->sin6_addr.s6_addr32[3];
+
+		icsk->icsk_af_ops = &dccp_ipv6_mapped;
+		sk->sk_backlog_rcv = dccp_v4_do_rcv;
+
+		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
+		if (err) {
+			icsk->icsk_ext_hdr_len = exthdrlen;
+			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
+			sk->sk_backlog_rcv = dccp_v6_do_rcv;
+			goto failure;
+		} else {
+			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000FFFF),
+				      inet->saddr);
+			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000FFFF),
+				      inet->rcv_saddr);
+		}
+
+		return err;
+	}
+
+	if (!ipv6_addr_any(&np->rcv_saddr))
+		saddr = &np->rcv_saddr;
+
+	fl.proto = IPPROTO_DCCP;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
+	fl.oif = sk->sk_bound_dev_if;
+	fl.fl_ip_dport = usin->sin6_port;
+	fl.fl_ip_sport = inet->sport;
+	security_sk_classify_flow(sk, &fl);
+
+	if (np->opt != NULL && np->opt->srcrt != NULL) {
+		const struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+
+		ipv6_addr_copy(&final, &fl.fl6_dst);
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
+	}
+
+	err = ip6_dst_lookup(sk, &dst, &fl);
+	if (err)
+		goto failure;
+
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+	err = xfrm_lookup(&dst, &fl, sk, 0);
+	if (err < 0)
+		goto failure;
+
+	if (saddr = NULL) {
+		saddr = &fl.fl6_src;
+		ipv6_addr_copy(&np->rcv_saddr, saddr);
+	}
+
+	/* set the source address */
+	ipv6_addr_copy(&np->saddr, saddr);
+	inet->rcv_saddr = LOOPBACK4_IPV6;
+
+	__ip6_dst_store(sk, dst, NULL, NULL);
+
+	icsk->icsk_ext_hdr_len = 0;
+	if (np->opt != NULL)
+		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
+					  np->opt->opt_nflen);
+
+	inet->dport = usin->sin6_port;
+
+	dccp_set_state(sk, DCCP_REQUESTING);
+	err = inet6_hash_connect(&dccp_death_row, sk);
+	if (err)
+		goto late_failure;
+	/* FIXME */
+#if 0
+	dp->dccps_gar = secure_dccp_v6_sequence_number(np->saddr.s6_addr32,
+						       np->daddr.s6_addr32,
+						       inet->sport,
+						       inet->dport);
+#endif
+	err = dccp_connect(sk);
+	if (err)
+		goto late_failure;
+
+	return 0;
+
+late_failure:
+	dccp_set_state(sk, DCCP_CLOSED);
+	__sk_dst_reset(sk);
+failure:
+	inet->dport = 0;
+	sk->sk_route_caps = 0;
+	return err;
+}
+
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = dccp_v6_send_check,
@@ -1122,6 +1113,10 @@ static int dccp_v6_destroy_sock(struct s
 	return inet6_destroy_sock(sk);
 }
 
+static struct timewait_sock_ops dccp6_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct dccp6_timewait_sock),
+};
+
 static struct proto dccp_v6_prot = {
 	.name		   = "DCCPv6",
 	.owner		   = THIS_MODULE,
