From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Feb 2006 22:09:02 +0000
Subject: [PATCH 1/4] [DCCP] ipv6: cleanups
Message-Id: <11411645423010-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No changes in the logic were made, just removing trailing whitespaces, etc.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv6.c |  256 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 129 insertions(+), 127 deletions(-)

1cb5220969e0f2ceef2ad5f0d280e8a98221ed63
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6bd9979..f28f38f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1,6 +1,6 @@
 /*
  *	DCCP over IPv6
- *	Linux INET6 implementation 
+ *	Linux INET6 implementation
  *
  *	Based on net/dccp6/ipv6.c
  *
@@ -66,8 +66,8 @@ static void dccp_v6_hash(struct sock *sk
 }
 
 static inline u16 dccp_v6_check(struct dccp_hdr *dh, int len,
-				struct in6_addr *saddr, 
-				struct in6_addr *daddr, 
+				struct in6_addr *saddr,
+				struct in6_addr *daddr,
 				unsigned long base)
 {
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_DCCP, base);
@@ -82,17 +82,17 @@ static __u32 dccp_v6_init_sequence(struc
 						    skb->nh.ipv6h->saddr.s6_addr32,
 						    dh->dccph_dport,
 						    dh->dccph_sport);
-	else
-		return secure_dccp_sequence_number(skb->nh.iph->daddr,
-						   skb->nh.iph->saddr,
-						   dh->dccph_dport,
-						   dh->dccph_sport);
+
+	return secure_dccp_sequence_number(skb->nh.iph->daddr,
+					   skb->nh.iph->saddr,
+					   dh->dccph_dport,
+					   dh->dccph_sport);
 }
 
-static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr, 
+static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			   int addr_len)
 {
-	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
+	struct sockaddr_in6 *usin = (struct sockaddr_in6 *)uaddr;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -105,10 +105,10 @@ static int dccp_v6_connect(struct sock *
 
 	dp->dccps_role = DCCP_ROLE_CLIENT;
 
-	if (addr_len < SIN6_LEN_RFC2133) 
+	if (addr_len < SIN6_LEN_RFC2133)
 		return -EINVAL;
 
-	if (usin->sin6_family != AF_INET6) 
+	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
 	memset(&fl, 0, sizeof(fl));
@@ -125,17 +125,15 @@ static int dccp_v6_connect(struct sock *
 			fl6_sock_release(flowlabel);
 		}
 	}
-
 	/*
-  	 *	connect() to INADDR_ANY means loopback (BSD'ism).
-  	 */
-  	
-  	if (ipv6_addr_any(&usin->sin6_addr))
-		usin->sin6_addr.s6_addr[15] = 0x1; 
+	 * connect() to INADDR_ANY means loopback (BSD'ism).
+	 */
+	if (ipv6_addr_any(&usin->sin6_addr))
+		usin->sin6_addr.s6_addr[15] = 1;
 
 	addr_type = ipv6_addr_type(&usin->sin6_addr);
 
-	if(addr_type & IPV6_ADDR_MULTICAST)
+	if (addr_type & IPV6_ADDR_MULTICAST)
 		return -ENETUNREACH;
 
 	if (addr_type & IPV6_ADDR_LINKLOCAL) {
@@ -160,9 +158,8 @@ static int dccp_v6_connect(struct sock *
 	np->flow_label = fl.fl6_flowlabel;
 
 	/*
-	 *	DCCP over IPv4
+	 * DCCP over IPv4
 	 */
-
 	if (addr_type = IPV6_ADDR_MAPPED) {
 		u32 exthdrlen = icsk->icsk_ext_hdr_len;
 		struct sockaddr_in sin;
@@ -180,7 +177,6 @@ static int dccp_v6_connect(struct sock *
 		sk->sk_backlog_rcv = dccp_v4_do_rcv;
 
 		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
-
 		if (err) {
 			icsk->icsk_ext_hdr_len = exthdrlen;
 			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
@@ -206,8 +202,9 @@ static int dccp_v6_connect(struct sock *
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->sport;
 
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+	if (np->opt != NULL && np->opt->srcrt != NULL) {
+		const struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+
 		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		final_p = &final;
@@ -216,10 +213,12 @@ static int dccp_v6_connect(struct sock *
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto failure;
+
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	err = xfrm_lookup(&dst, &fl, sk, 0);
+	if (err < 0)
 		goto failure;
 
 	if (saddr = NULL) {
@@ -234,7 +233,7 @@ static int dccp_v6_connect(struct sock *
 	ip6_dst_store(sk, dst, NULL);
 
 	icsk->icsk_ext_hdr_len = 0;
-	if (np->opt)
+	if (np->opt != NULL)
 		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
 					  np->opt->opt_nflen);
 
@@ -308,7 +307,6 @@ static void dccp_v6_err(struct sk_buff *
 
 		/* icmp should have updated the destination cache entry */
 		dst = __sk_dst_check(sk, np->dst_cookie);
-
 		if (dst = NULL) {
 			struct inet_sock *inet = inet_sk(sk);
 			struct flowi fl;
@@ -325,16 +323,17 @@ static void dccp_v6_err(struct sk_buff *
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
 
-			if ((err = ip6_dst_lookup(sk, &dst, &fl))) {
+			err = ip6_dst_lookup(sk, &dst, &fl);
+			if (err) {
 				sk->sk_err_soft = -err;
 				goto out;
 			}
 
-			if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			err = xfrm_lookup(&dst, &fl, sk, 0);
+			if (err < 0) {
 				sk->sk_err_soft = -err;
 				goto out;
 			}
-
 		} else
 			dst_hold(dst);
 
@@ -358,11 +357,12 @@ static void dccp_v6_err(struct sk_buff *
 		req = inet6_csk_search_req(sk, &prev, dh->dccph_dport,
 					   &hdr->daddr, &hdr->saddr,
 					   inet6_iif(skb));
-		if (!req)
+		if (req = NULL)
 			goto out;
 
-		/* ICMPs are not backlogged, hence we cannot get
-		 * an established socket here.
+		/*
+		 * ICMPs are not backlogged, hence we cannot get an established
+		 * socket here.
 		 */
 		BUG_TRAP(req->sk = NULL);
 
@@ -376,7 +376,7 @@ static void dccp_v6_err(struct sk_buff *
 
 	case DCCP_REQUESTING:
 	case DCCP_RESPOND:  /* Cannot happen.
-			       It can, it SYNs are crossed. --ANK */ 
+			       It can, it SYNs are crossed. --ANK */
 		if (!sock_owned_by_user(sk)) {
 			DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
 			sk->sk_err = err;
@@ -385,7 +385,6 @@ static void dccp_v6_err(struct sk_buff *
 			 * (see connect in sock.c)
 			 */
 			sk->sk_error_report(sk);
-
 			dccp_done(sk);
 		} else
 			sk->sk_err_soft = err;
@@ -431,14 +430,16 @@ static int dccp_v6_send_response(struct 
 		    ireq6->pktopts) {
 			struct sk_buff *pktopts = ireq6->pktopts;
 			struct inet6_skb_parm *rxopt = IP6CB(pktopts);
+
 			if (rxopt->srcrt)
 				opt = ipv6_invert_rthdr(sk,
 					(struct ipv6_rt_hdr *)(pktopts->nh.raw +
 							       rxopt->srcrt));
 		}
 
-		if (opt && opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
+		if (opt != NULL && opt->srcrt != NULL) {
+			const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
+
 			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 			final_p = &final;
@@ -447,15 +448,19 @@ static int dccp_v6_send_response(struct 
 		err = ip6_dst_lookup(sk, &dst, &fl);
 		if (err)
 			goto done;
+
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+
+		err = xfrm_lookup(&dst, &fl, sk, 0);
+		if (err < 0)
 			goto done;
 	}
 
 	skb = dccp_make_response(sk, dst, req);
 	if (skb != NULL) {
 		struct dccp_hdr *dh = dccp_hdr(skb);
+
 		dh->dccph_checksum = dccp_v6_check(dh, skb->len,
 						   &ireq6->loc_addr,
 						   &ireq6->rmt_addr,
@@ -469,7 +474,7 @@ static int dccp_v6_send_response(struct 
 	}
 
 done:
-        if (opt && opt != np->opt)
+	if (opt != NULL && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
 	return err;
@@ -500,7 +505,7 @@ static void dccp_v6_send_check(struct so
 	struct dccp_hdr *dh = dccp_hdr(skb);
 
 	dh->dccph_checksum = csum_ipv6_magic(&np->saddr, &np->daddr,
-					     len, IPPROTO_DCCP, 
+					     len, IPPROTO_DCCP,
 					     csum_partial((char *)dh,
 							  dh->dccph_doff << 2,
 							  skb->csum));
@@ -508,7 +513,7 @@ static void dccp_v6_send_check(struct so
 
 static void dccp_v6_ctl_send_reset(struct sk_buff *rxskb)
 {
-	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh; 
+	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
 	const int dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
 				       sizeof(struct dccp_hdr_ext) +
 				       sizeof(struct dccp_hdr_reset);
@@ -520,7 +525,7 @@ static void dccp_v6_ctl_send_reset(struc
 		return;
 
 	if (!ipv6_unicast_destination(rxskb))
-		return; 
+		return;
 
 	/*
 	 * We need to grab some memory, and put together an RST,
@@ -529,7 +534,7 @@ static void dccp_v6_ctl_send_reset(struc
 
 	skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) +
 			dccp_hdr_reset_len, GFP_ATOMIC);
-	if (skb = NULL) 
+	if (skb = NULL)
 	  	return;
 
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr) +
@@ -608,7 +613,7 @@ static void dccp_v6_ctl_send_ack(struct 
 	dh->dccph_dport = rxdh->dccph_sport;
 	dh->dccph_doff	= dccp_hdr_ack_len / 4;
 	dh->dccph_x	= 1;
-	
+
 	dccp_hdr_set_seq(dh, DCCP_SKB_CB(rxskb)->dccpd_ack_seq);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
 			 DCCP_SKB_CB(rxskb)->dccpd_seq);
@@ -660,7 +665,6 @@ static struct sock *dccp_v6_hnd_req(stru
 					 &iph->saddr, dh->dccph_sport,
 					 &iph->daddr, ntohs(dh->dccph_dport),
 					 inet6_iif(skb));
-
 	if (nsk != NULL) {
 		if (nsk->sk_state != DCCP_TIME_WAIT) {
 			bh_lock_sock(nsk);
@@ -689,17 +693,17 @@ static int dccp_v6_conn_request(struct s
 		return dccp_v4_conn_request(sk, skb);
 
 	if (!ipv6_unicast_destination(skb))
-		goto drop; 
+		goto drop;
 
 	if (dccp_bad_service_code(sk, service)) {
 		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
 		goto drop;
  	}
 	/*
-	 *	There are no SYN attacks on IPv6, yet...	
+	 * There are no SYN attacks on IPv6, yet...
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk))
-		goto drop;		
+		goto drop;
 
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
@@ -733,7 +737,7 @@ static int dccp_v6_conn_request(struct s
 	    ipv6_addr_type(&ireq6->rmt_addr) & IPV6_ADDR_LINKLOCAL)
 		ireq6->iif = inet6_iif(skb);
 
-	/* 
+	/*
 	 * Step 3: Process LISTEN state
 	 *
 	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
@@ -777,9 +781,8 @@ static struct sock *dccp_v6_request_recv
 		/*
 		 *	v6 mapped
 		 */
-
 		newsk = dccp_v4_request_recv_sock(sk, skb, req, dst);
-		if (newsk = NULL) 
+		if (newsk = NULL)
 			return NULL;
 
 		newdp6 = (struct dccp6_sock *)newsk;
@@ -825,9 +828,9 @@ static struct sock *dccp_v6_request_recv
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
 
-	if (np->rxopt.bits.osrcrt = 2 &&
-	    opt = NULL && ireq6->pktopts) {
-		struct inet6_skb_parm *rxopt = IP6CB(ireq6->pktopts);
+	if (np->rxopt.bits.osrcrt = 2 && opt = NULL && ireq6->pktopts) {
+		const struct inet6_skb_parm *rxopt = IP6CB(ireq6->pktopts);
+
 		if (rxopt->srcrt)
 			opt = ipv6_invert_rthdr(sk,
 				(struct ipv6_rt_hdr *)(ireq6->pktopts->nh.raw +
@@ -841,8 +844,9 @@ static struct sock *dccp_v6_request_recv
 		memset(&fl, 0, sizeof(fl));
 		fl.proto = IPPROTO_DCCP;
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		if (opt && opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		if (opt != NULL && opt->srcrt != NULL) {
+			const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
+
 			ipv6_addr_copy(&final, &fl.fl6_dst);
 			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 			final_p = &final;
@@ -860,7 +864,7 @@ static struct sock *dccp_v6_request_recv
 
 		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
 			goto out;
-	} 
+	}
 
 	newsk = dccp_create_openreq_child(sk, req, skb);
 	if (newsk = NULL)
@@ -873,9 +877,8 @@ static struct sock *dccp_v6_request_recv
 	 */
 
 	ip6_dst_store(newsk, dst, NULL);
-	newsk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
-
+	newsk->sk_route_caps = dst->dev->features & ~(NETIF_F_IP_CSUM |
+						      NETIF_F_TSO);
 	newdp6 = (struct dccp6_sock *)newsk;
 	newinet = inet_sk(newsk);
 	newinet->pinet6 = &newdp6->inet6;
@@ -889,7 +892,7 @@ static struct sock *dccp_v6_request_recv
 	ipv6_addr_copy(&newnp->rcv_saddr, &ireq6->loc_addr);
 	newsk->sk_bound_dev_if = ireq6->iif;
 
-	/* Now IPv6 options... 
+	/* Now IPv6 options...
 
 	   First: no IPv4 options.
 	 */
@@ -911,20 +914,20 @@ static struct sock *dccp_v6_request_recv
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = skb->nh.ipv6h->hop_limit;
 
-	/* Clone native IPv6 options from listening socket (if any)
-
-	   Yes, keeping reference count would be much more clever,
-	   but we make one more one thing there: reattach optmem
-	   to newsk.
+	/*
+	 * Clone native IPv6 options from listening socket (if any)
+	 *
+	 * Yes, keeping reference count would be much more clever, but we make
+	 * one more one thing there: reattach optmem to newsk.
 	 */
-	if (opt) {
+	if (opt != NULL) {
 		newnp->opt = ipv6_dup_options(newsk, opt);
 		if (opt != np->opt)
 			sock_kfree_s(sk, opt, opt->tot_len);
 	}
 
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
-	if (newnp->opt)
+	if (newnp->opt != NULL)
 		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
 						     newnp->opt->opt_flen);
 
@@ -941,7 +944,7 @@ out_overflow:
 	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
 out:
 	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
-	if (opt && opt != np->opt)
+	if (opt != NULL && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
 	return NULL;
@@ -975,8 +978,8 @@ static int dccp_v6_do_rcv(struct sock *s
 		goto discard;
 
 	/*
-	 *	socket locking is here for SMP purposes as backlog rcv
-	 *	is currently called with bh processing disabled.
+	 * socket locking is here for SMP purposes as backlog rcv is currently
+	 * called with bh processing disabled.
 	 */
 
 	/* Do Stevens' IPV6_PKTOPTIONS.
@@ -1001,20 +1004,20 @@ static int dccp_v6_do_rcv(struct sock *s
 		return 0;
 	}
 
-	if (sk->sk_state = DCCP_LISTEN) { 
+	if (sk->sk_state = DCCP_LISTEN) {
 		struct sock *nsk = dccp_v6_hnd_req(sk, skb);
-		if (!nsk)
-			goto discard;
 
+		if (nsk = NULL)
+			goto discard;
 		/*
 		 * Queue it on the new socket if the new socket is active,
 		 * otherwise we just shortcircuit this and continue with
 		 * the new socket..
 		 */
- 		if(nsk != sk) {
+ 		if (nsk != sk) {
 			if (dccp_child_process(sk, nsk, skb))
 				goto reset;
-			if (opt_skb)
+			if (opt_skb != NULL)
 				__kfree_skb(opt_skb);
 			return 0;
 		}
@@ -1027,7 +1030,7 @@ static int dccp_v6_do_rcv(struct sock *s
 reset:
 	dccp_v6_ctl_send_reset(skb);
 discard:
-	if (opt_skb)
+	if (opt_skb != NULL)
 		__kfree_skb(opt_skb);
 	kfree_skb(skb);
 	return 0;
@@ -1060,7 +1063,7 @@ static int dccp_v6_rcv(struct sk_buff **
 			    dh->dccph_sport,
 			    &skb->nh.ipv6h->daddr, ntohs(dh->dccph_dport),
 			    inet6_iif(skb));
-	/* 
+	/*
 	 * Step 2:
 	 * 	If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
@@ -1069,15 +1072,14 @@ static int dccp_v6_rcv(struct sk_buff **
 	if (sk = NULL)
 		goto no_dccp_socket;
 
-	/* 
+	/*
 	 * Step 2:
 	 * 	... or S.state = TIMEWAIT,
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	       
 	if (sk->sk_state = DCCP_TIME_WAIT)
-                goto do_time_wait;
+		goto do_time_wait;
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
@@ -1116,32 +1118,32 @@ do_time_wait:
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
-	.queue_xmit	=	inet6_csk_xmit,
-	.send_check	=	dccp_v6_send_check,
-	.rebuild_header	=	inet6_sk_rebuild_header,
-	.conn_request	=	dccp_v6_conn_request,
-	.syn_recv_sock	=	dccp_v6_request_recv_sock,
-	.net_header_len	=	sizeof(struct ipv6hdr),
-	.setsockopt	=	ipv6_setsockopt,
-	.getsockopt	=	ipv6_getsockopt,
-	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
-	.sockaddr_len	=	sizeof(struct sockaddr_in6)
+	.queue_xmit	= inet6_csk_xmit,
+	.send_check	= dccp_v6_send_check,
+	.rebuild_header	= inet6_sk_rebuild_header,
+	.conn_request	= dccp_v6_conn_request,
+	.syn_recv_sock	= dccp_v6_request_recv_sock,
+	.net_header_len	= sizeof(struct ipv6hdr),
+	.setsockopt	= ipv6_setsockopt,
+	.getsockopt	= ipv6_getsockopt,
+	.addr2sockaddr	= inet6_csk_addr2sockaddr,
+	.sockaddr_len	= sizeof(struct sockaddr_in6)
 };
 
 /*
  *	DCCP over IPv4 via INET6 API
  */
 static struct inet_connection_sock_af_ops dccp_ipv6_mapped = {
-	.queue_xmit	=	ip_queue_xmit,
-	.send_check	=	dccp_v4_send_check,
-	.rebuild_header	=	inet_sk_rebuild_header,
-	.conn_request	=	dccp_v6_conn_request,
-	.syn_recv_sock	=	dccp_v6_request_recv_sock,
-	.net_header_len	=	sizeof(struct iphdr),
-	.setsockopt	=	ipv6_setsockopt,
-	.getsockopt	=	ipv6_getsockopt,
-	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
-	.sockaddr_len	=	sizeof(struct sockaddr_in6)
+	.queue_xmit	= ip_queue_xmit,
+	.send_check	= dccp_v4_send_check,
+	.rebuild_header	= inet_sk_rebuild_header,
+	.conn_request	= dccp_v6_conn_request,
+	.syn_recv_sock	= dccp_v6_request_recv_sock,
+	.net_header_len	= sizeof(struct iphdr),
+	.setsockopt	= ipv6_setsockopt,
+	.getsockopt	= ipv6_getsockopt,
+	.addr2sockaddr	= inet6_csk_addr2sockaddr,
+	.sockaddr_len	= sizeof(struct sockaddr_in6)
 };
 
 /* NOTE: A lot of things set to zero explicitly by call to
@@ -1168,35 +1170,35 @@ static int dccp_v6_destroy_sock(struct s
 }
 
 static struct proto dccp_v6_prot = {
-	.name			= "DCCPv6",
-	.owner			= THIS_MODULE,
-	.close			= dccp_close,
-	.connect		= dccp_v6_connect,
-	.disconnect		= dccp_disconnect,
-	.ioctl			= dccp_ioctl,
-	.init			= dccp_v6_init_sock,
-	.setsockopt		= dccp_setsockopt,
-	.getsockopt		= dccp_getsockopt,
-	.sendmsg		= dccp_sendmsg,
-	.recvmsg		= dccp_recvmsg,
-	.backlog_rcv		= dccp_v6_do_rcv,
-	.hash			= dccp_v6_hash,
-	.unhash			= dccp_unhash,
-	.accept			= inet_csk_accept,
-	.get_port		= dccp_v6_get_port,
-	.shutdown		= dccp_shutdown,
-	.destroy		= dccp_v6_destroy_sock,
-	.orphan_count		= &dccp_orphan_count,
-	.max_header		= MAX_DCCP_HEADER,
-	.obj_size		= sizeof(struct dccp6_sock),
-	.rsk_prot		= &dccp6_request_sock_ops,
-	.twsk_prot		= &dccp6_timewait_sock_ops,
+	.name		= "DCCPv6",
+	.owner		= THIS_MODULE,
+	.close		= dccp_close,
+	.connect	= dccp_v6_connect,
+	.disconnect	= dccp_disconnect,
+	.ioctl		= dccp_ioctl,
+	.init		= dccp_v6_init_sock,
+	.setsockopt	= dccp_setsockopt,
+	.getsockopt	= dccp_getsockopt,
+	.sendmsg	= dccp_sendmsg,
+	.recvmsg	= dccp_recvmsg,
+	.backlog_rcv	= dccp_v6_do_rcv,
+	.hash		= dccp_v6_hash,
+	.unhash		= dccp_unhash,
+	.accept		= inet_csk_accept,
+	.get_port	= dccp_v6_get_port,
+	.shutdown	= dccp_shutdown,
+	.destroy	= dccp_v6_destroy_sock,
+	.orphan_count	= &dccp_orphan_count,
+	.max_header	= MAX_DCCP_HEADER,
+	.obj_size	= sizeof(struct dccp6_sock),
+	.rsk_prot	= &dccp6_request_sock_ops,
+	.twsk_prot	= &dccp6_timewait_sock_ops,
 };
 
 static struct inet6_protocol dccp_v6_protocol = {
-	.handler	=	dccp_v6_rcv,
-	.err_handler	=	dccp_v6_err,
-	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
+	.handler	= dccp_v6_rcv,
+	.err_handler	= dccp_v6_err,
+	.flags		= INET6_PROTO_NOPOLICY | INET6_PROTO_FINAL,
 };
 
 static struct proto_ops inet6_dccp_ops = {
-- 
1.2.2.gd27d


