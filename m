From: Brian Haley <brian.haley@hp.com>
Date: Fri, 06 Apr 2007 03:21:05 +0000
Subject: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Message-Id: <4615BCA1.6000608@hp.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add link and site-local scope inline to avoid calls to ipv6_addr_type().

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
  include/net/ipv6.h               |   10 ++++++++++
  net/dccp/ipv6.c                  |    2 +-
  net/ipv6/addrconf.c              |    6 +++---
  net/ipv6/af_inet6.c              |    2 +-
  net/ipv6/datagram.c              |   11 ++++-------
  net/ipv6/inet6_connection_sock.c |    2 +-
  net/ipv6/ip6_output.c            |    2 +-
  net/ipv6/mcast.c                 |    8 +++-----
  net/ipv6/ndisc.c                 |    8 ++++----
  net/ipv6/raw.c                   |    4 ++--
  net/ipv6/tcp_ipv6.c              |    2 +-
  net/ipv6/udp.c                   |    4 ++--
  net/sctp/ipv6.c                  |   16 +++++++---------
  13 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 00328b7..d473789 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -429,6 +429,16 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
  	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
  }

+static inline int ipv6_addr_scope_linklocal(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] & htonl(0xFFC00000)) = htonl(0xFE800000));
+}
+
+static inline int ipv6_addr_scope_sitelocal(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] & htonl(0xFFC00000)) = htonl(0xFEC00000));
+}
+
  /*
   *	Prototypes exported by ipv6
   */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 64eac25..14a0f12 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -476,7 +476,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)

  	/* So that link locals have meaning */
  	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&ireq6->rmt_addr) & IPV6_ADDR_LINKLOCAL)
+	    ipv6_addr_scope_linklocal(&ireq6->rmt_addr))
  		ireq6->iif = inet6_iif(skb);

  	/*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47d3adf..2d4fe24 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2634,7 +2634,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
  	if (ifp->idev->cnf.forwarding = 0 &&
  	    ifp->idev->cnf.rtr_solicits > 0 &&
  	    (dev->flags&IFF_LOOPBACK) = 0 &&
-	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
+	    ipv6_addr_scope_linklocal(&ifp->addr)) {
  		struct in6_addr all_routers;

  		ipv6_addr_all_routers(&all_routers);
@@ -3155,7 +3155,7 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
  	u8 scope = RT_SCOPE_UNIVERSE;
  	int ifindex = ifmca->idev->dev->ifindex;

-	if (ipv6_addr_scope(&ifmca->mca_addr) & IFA_SITE)
+	if (ipv6_addr_scope_sitelocal(&ifmca->mca_addr))
  		scope = RT_SCOPE_SITE;

  	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
@@ -3180,7 +3180,7 @@ static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
  	u8 scope = RT_SCOPE_UNIVERSE;
  	int ifindex = ifaca->aca_idev->dev->ifindex;

-	if (ipv6_addr_scope(&ifaca->aca_addr) & IFA_SITE)
+	if (ipv6_addr_scope_sitelocal(&ifaca->aca_addr))
  		scope = RT_SCOPE_SITE;

  	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index df31cdd..24618cf 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -431,7 +431,7 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,

  		sin->sin6_port = inet->sport;
  	}
-	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+	if (ipv6_addr_scope_linklocal(&sin->sin6_addr))
  		sin->sin6_scope_id = sk->sk_bound_dev_if;
  	*uaddr_len = sizeof(*sin);
  	return(0);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4a355fe..a8612b2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -323,7 +323,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
  				sin->sin6_flowinfo   					(*(__be32 *)(nh + serr->addr_offset - 24) &
  					 IPV6_FLOWINFO_MASK);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			if (ipv6_addr_scope_linklocal(&sin->sin6_addr))
  				sin->sin6_scope_id = IP6CB(skb)->iif;
  		} else {
  			ipv6_addr_set(&sin->sin6_addr, 0, 0,
@@ -343,7 +343,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
  			ipv6_addr_copy(&sin->sin6_addr, &ipv6_hdr(skb)->saddr);
  			if (np->rxopt.all)
  				datagram_recv_ctl(sk, msg, skb);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			if (ipv6_addr_scope_linklocal(&sin->sin6_addr))
  				sin->sin6_scope_id = IP6CB(skb)->iif;
  		} else {
  			struct inet_sock *inet = inet_sk(sk);
@@ -504,7 +504,6 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
  	int err = 0;

  	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		int addr_type;
  		struct net_device *dev = NULL;

  		if (!CMSG_OK(msg, cmsg)) {
@@ -531,12 +530,10 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
  				fl->oif = src_info->ipi6_ifindex;
  			}

-			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
-
-			if (addr_type = IPV6_ADDR_ANY)
+			if (ipv6_addr_any(&src_info->ipi6_addr))
  				break;

-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
+			if (ipv6_addr_scope_linklocal(&src_info->ipi6_addr)) {
  				if (!src_info->ipi6_ifindex)
  					return -EINVAL;
  				else {
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 116f94a..7cefe18 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -133,7 +133,7 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
  	sin6->sin6_flowinfo = 0;
  	sin6->sin6_scope_id = 0;
  	if (sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+	    ipv6_addr_scope_linklocal(&sin6->sin6_addr))
  		sin6->sin6_scope_id = sk->sk_bound_dev_if;
  }

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 78317a4..f6aa338 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -351,7 +351,7 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
  	 * address, so signal the sender and discard the packet. This
  	 * behavior is clarified by the MIPv6 specification.
  	 */
-	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) {
+	if (ipv6_addr_scope_linklocal(&hdr->daddr)) {
  		dst_link_failure(skb);
  		return -1;
  	}
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 6c27589..d2d31a2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1171,7 +1171,7 @@ int igmp6_event_query(struct sk_buff *skb)
  	len -= skb_network_header_len(skb);

  	/* Drop queries with not link local source */
-	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
+	if (!ipv6_addr_scope_linklocal(&ipv6_hdr(skb)->saddr))
  		return -EINVAL;

  	idev = in6_dev_get(skb->dev);
@@ -1286,7 +1286,6 @@ int igmp6_event_report(struct sk_buff *skb)
  	struct in6_addr *addrp;
  	struct inet6_dev *idev;
  	struct icmp6hdr *hdr;
-	int addr_type;

  	/* Our own report looped back. Ignore it. */
  	if (skb->pkt_type = PACKET_LOOPBACK)
@@ -1303,9 +1302,8 @@ int igmp6_event_report(struct sk_buff *skb)
  	hdr = icmp6_hdr(skb);

  	/* Drop reports with not link local source */
-	addr_type = ipv6_addr_type(&ipv6_hdr(skb)->saddr);
-	if (addr_type != IPV6_ADDR_ANY &&
-	    !(addr_type&IPV6_ADDR_LINKLOCAL))
+	if (!ipv6_addr_any(&ipv6_hdr(skb)->saddr) &&
+	    !ipv6_addr_scope_linklocal(&ipv6_hdr(skb)->saddr))
  		return -EINVAL;

  	addrp = (struct in6_addr *) (hdr + 1);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b1cf708..b500011 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1115,7 +1115,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)

  	optlen = (skb->tail - skb->transport_header) - sizeof(struct ra_msg);

-	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
+	if (!ipv6_addr_scope_linklocal(&ipv6_hdr(skb)->saddr)) {
  		ND_PRINTK2(KERN_WARNING
  			   "ICMPv6 RA: source address is not link-local.\n");
  		return;
@@ -1356,7 +1356,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
  	int optlen;
  	u8 *lladdr = NULL;

-	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
+	if (!ipv6_addr_scope_linklocal(&ipv6_hdr(skb)->saddr)) {
  		ND_PRINTK2(KERN_WARNING
  			   "ICMPv6 Redirect: source address is not link-local.\n");
  		return;
@@ -1383,7 +1383,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)

  	if (ipv6_addr_equal(dest, target)) {
  		on_link = 1;
-	} else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	} else if (!ipv6_addr_scope_linklocal(target)) {
  		ND_PRINTK2(KERN_WARNING
  			   "ICMPv6 Redirect: target address is not link-local.\n");
  		return;
@@ -1459,7 +1459,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
  	}

  	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
-	    !(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	    !ipv6_addr_scope_linklocal(target)) {
  		ND_PRINTK2(KERN_WARNING
  			"ICMPv6 Redirect: target address is not link-local.\n");
  		return;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 9592930..771fa0e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -442,7 +442,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
  		ipv6_addr_copy(&sin6->sin6_addr, &ipv6_hdr(skb)->saddr);
  		sin6->sin6_flowinfo = 0;
  		sin6->sin6_scope_id = 0;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		if (ipv6_addr_scope_linklocal(&sin6->sin6_addr))
  			sin6->sin6_scope_id = IP6CB(skb)->iif;
  	}

@@ -750,7 +750,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,

  		if (addr_len >= sizeof(struct sockaddr_in6) &&
  		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    ipv6_addr_scope_linklocal(daddr))
  			fl.oif = sin6->sin6_scope_id;
  	} else {
  		if (sk->sk_state != TCP_ESTABLISHED)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f0f7dc6..537978c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1287,7 +1287,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)

  	/* So that link locals have meaning */
  	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
+	    ipv6_addr_scope_linklocal(&treq->rmt_addr))
  		treq->iif = inet6_iif(skb);

  	if (isn = 0)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index bd2856f..c0b5fe3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -182,7 +182,7 @@ try_again:
  		else {
  			ipv6_addr_copy(&sin6->sin6_addr,
  				       &ipv6_hdr(skb)->saddr);
-			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			if (ipv6_addr_scope_linklocal(&sin6->sin6_addr))
  				sin6->sin6_scope_id = IP6CB(skb)->iif;
  		}

@@ -680,7 +680,7 @@ do_udp_sendmsg:

  		if (addr_len >= sizeof(struct sockaddr_in6) &&
  		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    ipv6_addr_scope_linklocal(daddr))
  			fl.oif = sin6->sin6_scope_id;
  	} else {
  		if (sk->sk_state != TCP_ESTABLISHED)
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 5b0cdda..c1f4a8f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -199,7 +199,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport,

  	fl.fl6_flowlabel = np->flow_label;
  	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	if (ipv6_addr_type(&fl.fl6_src) & IPV6_ADDR_LINKLOCAL)
+	if (ipv6_addr_scope_linklocal(&fl.fl6_src))
  		fl.oif = transport->saddr.v6.sin6_scope_id;
  	else
  		fl.oif = sk->sk_bound_dev_if;
@@ -231,7 +231,7 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,

  	memset(&fl, 0, sizeof(fl));
  	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
-	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+	if (ipv6_addr_scope_linklocal(&daddr->v6.sin6_addr))
  		fl.oif = daddr->v6.sin6_scope_id;


@@ -500,7 +500,7 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
  	if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
  		return 0;
  	/* If this is a linklocal address, compare the scope_id. */
-	if (ipv6_addr_type(&addr1->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+	if (ipv6_addr_scope_linklocal(&addr1->v6.sin6_addr)) {
  		if (addr1->v6.sin6_scope_id && addr2->v6.sin6_scope_id &&
  		    (addr1->v6.sin6_scope_id != addr2->v6.sin6_scope_id)) {
  			return 0;
@@ -749,7 +749,7 @@ static void sctp_inet6_event_msgname(struct sctp_ulpevent *event,

  		sin6from = &asoc->peer.primary_addr.v6;
  		ipv6_addr_copy(&sin6->sin6_addr, &sin6from->sin6_addr);
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		if (ipv6_addr_scope_linklocal(&sin6->sin6_addr))
  			sin6->sin6_scope_id = sin6from->sin6_scope_id;
  	}
  }
@@ -777,7 +777,7 @@ static void sctp_inet6_skb_msgname(struct sk_buff *skb, char *msgname,

  		/* Otherwise, just copy the v6 address. */
  		ipv6_addr_copy(&sin6->sin6_addr, &ipv6_hdr(skb)->saddr);
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+		if (ipv6_addr_scope_linklocal(&sin6->sin6_addr)) {
  			struct sctp_ulpevent *ev = sctp_skb2event(skb);
  			sin6->sin6_scope_id = ev->iif;
  		}
@@ -835,10 +835,9 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
  	if (addr->sa.sa_family != AF_INET6)
  		af = sctp_get_af_specific(addr->sa.sa_family);
  	else {
-		int type = ipv6_addr_type(&addr->v6.sin6_addr);
  		struct net_device *dev;

-		if (type & IPV6_ADDR_LINKLOCAL) {
+		if (ipv6_addr_scope_linklocal(&addr->v6.sin6_addr)) {
  			if (!addr->v6.sin6_scope_id)
  				return 0;
  			dev = dev_get_by_index(addr->v6.sin6_scope_id);
@@ -862,10 +861,9 @@ static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
  	if (addr->sa.sa_family != AF_INET6)
  		af = sctp_get_af_specific(addr->sa.sa_family);
  	else {
-		int type = ipv6_addr_type(&addr->v6.sin6_addr);
  		struct net_device *dev;

-		if (type & IPV6_ADDR_LINKLOCAL) {
+		if (ipv6_addr_scope_linklocal(&addr->v6.sin6_addr)) {
  			if (!addr->v6.sin6_scope_id)
  				return 0;
  			dev = dev_get_by_index(addr->v6.sin6_scope_id);
-- 
1.5.0.3

