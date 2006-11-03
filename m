From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Nov 2006 14:32:35 +0000
Subject: [PATCH 6/6] dccp: Support for partial checksums (RFC 4340, sec. 9.2)
Message-Id: <200611031432.35826@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support for partial checksums (RFC 4340, sec. 9.2)

This patch does the following:
  a) introduces variable-length checksums as specified in [RFC 4340, sec. 9.2]
  b) provides necessary socket options and documentation as to how to use them
  c) basic support and infrastructure for the Minimum Checksum Coverage feature
     [RFC 4340, sec. 9.2.1]: acceptability tests, user notification and user
     interface

In addition, it
 (1) fixes two bugs in the DCCPv4 checksum computation:
        * pseudo-header used checksum_len instead of skb->len
        * incorrect checksum coverage calculation based on dccph_x
 (2) removes dccp_v4_verify_checksum() since it reduplicates code of the
     checksum computation; code calling this function is updated accordingly.
 (3) now uses skb_checksum(), which is safer than checksum_partial() if the
     sk_buff has is a non-linear buffer (has pages attached to it).
 (4) fixes an outstanding TODO item:
        * If P.CsCov is too large for the packet size, drop packet and return.

The code has been tested with applications, the latest version of tcpdump now
comes with support for partial DCCP checksums.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   16 +++++
 include/linux/dccp.h              |    8 ++
 net/dccp/dccp.h                   |   28 ++++++++-
 net/dccp/ipv4.c                   |  107 ++++++++++++++++++--------------------
 net/dccp/ipv6.c                   |   75 ++++++++++++++++----------
 net/dccp/output.c                 |   13 +---
 net/dccp/proto.c                  |   27 +++++++++
 7 files changed, 174 insertions(+), 100 deletions(-)


--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -47,6 +47,22 @@ the socket will fall back to 0 (which me
 is present). Connecting sockets set at most one service option; for
 listening sockets, multiple service codes can be specified.
 
+DCCP_SOCKOPT_SEND_CSCOV and DCCP_SOCKOPT_RECV_CSCOV are used for setting the
+partial checksum coverage (RFC 4340, sec. 9.2). The default is that checksums
+always cover the entire packet and that only fully covered application data
+is accepted by the receiver. Hence, when using this feature on the sender,
+it must be enabled at the receiver, too with suitable choice of CsCov.
+
+DCCP_SOCKOPT_SEND_CSCOV sets the sender checksum coverage. Values in the
+	range 0..15 are acceptable. The default setting is 0 (full coverage),
+	values between 1..15 indicate partial coverage.
+DCCP_SOCKOPT_SEND_CSCOV is for the receiver and has a different meaning: it
+	sets a threshold, where again values 0..15 are acceptable. The default
+	of 0 means that all packets with a partial coverage will be discarded.
+	Values in the range 1..15 indicate that packets with minimally such a
+	coverage value are also acceptable. The higher the number, the more
+	restrictive this setting (see [RFC 4340, sec. 9.2.1]).
+
 Notes
 == 
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -185,7 +185,7 @@ enum {
 	DCCPF_ACK_RATIO = 5,
 	DCCPF_SEND_ACK_VECTOR = 6,
 	DCCPF_SEND_NDP_COUNT = 7,
-	DCCPF_MIN_CSUM_COVER = 8,	/* XXX: not yet implemented */
+	DCCPF_MIN_CSUM_COVER = 8,
 	DCCPF_DATA_CHECKSUM = 9,	/* XXX: not yet implemented */
 	/* 10-127 reserved */
 	DCCPF_MIN_CCID_SPECIFIC = 128,
@@ -204,6 +204,8 @@ struct dccp_so_feat {
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
+#define DCCP_SOCKOPT_SEND_CSCOV		10
+#define DCCP_SOCKOPT_RECV_CSCOV		11
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
@@ -461,6 +463,8 @@ struct dccp_ackvec;
  * @dccps_packet_size - Set thru setsockopt
  * @dccps_l_ack_ratio -
  * @dccps_r_ack_ratio -
+ * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
+ * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_mss_cache -
  * @dccps_minisock -
@@ -494,6 +498,8 @@ struct dccp_sock {
 	__u32				dccps_packet_size;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
+	__u16				dccps_pcslen;
+	__u16				dccps_pcrlen;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
 	struct dccp_minisock		dccps_minisock;
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -137,6 +137,29 @@ DECLARE_SNMP_STAT(struct dccp_mib, dccp_
 #define DCCP_ADD_STATS_USER(field, val)	\
 			SNMP_ADD_STATS_USER(dccp_statistics, field, val)
 
+/*
+ * 	Checksumming routines
+ */
+static inline int dccp_csum_coverage(const struct sk_buff *skb)
+{
+	const struct dccp_hdr* dh = dccp_hdr(skb);
+
+	if (dh->dccph_cscov = 0)
+		return skb->len;
+	return (dh->dccph_doff + dh->dccph_cscov - 1) * sizeof(u32);
+}
+
+static inline void dccp_csum_outgoing(struct sk_buff *skb)
+{
+	int cov = dccp_csum_coverage(skb);
+
+	if (cov >= skb->len)
+		dccp_hdr(skb)->dccph_cscov = 0;
+
+	skb->csum = skb_checksum(skb, 0, (cov > skb->len)? skb->len : cov, 0);
+}
+extern void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
+
 extern int  dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb);
 
 extern void dccp_send_ack(struct sock *sk);
@@ -233,14 +256,9 @@ extern void	   dccp_shutdown(struct sock
 extern int	   inet_dccp_listen(struct socket *sock, int backlog);
 extern unsigned int dccp_poll(struct file *file, struct socket *sock,
 			     poll_table *wait);
-extern void	   dccp_v4_send_check(struct sock *sk, int len,
-				      struct sk_buff *skb);
 extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
 				   int addr_len);
 
-extern int	   dccp_v4_checksum(const struct sk_buff *skb,
-				    const __be32 saddr, const __be32 daddr);
-
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -348,13 +348,19 @@ out:
 	sock_put(sk);
 }
 
-/* This routine computes an IPv4 DCCP checksum. */
-void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+static __inline__ u16 dccp_v4_csum_finish(struct sk_buff *skb, __be32 src,
+							       __be32 dst)
 {
-	const struct inet_sock *inet = inet_sk(sk);
+	return csum_tcpudp_magic(src, dst, skb->len, IPPROTO_DCCP, skb->csum);
+}
+
+inline void dccp_v4_send_check(struct sock *sk, int unused, struct sk_buff *skb)
+{
+	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_hdr *dh = dccp_hdr(skb);
 
-	dh->dccph_checksum = dccp_v4_checksum(skb, inet->saddr, inet->daddr);
+	dccp_csum_outgoing(skb);
+	dh->dccph_checksum = dccp_v4_csum_finish(skb, inet->saddr, inet->daddr);
 }
 
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
@@ -444,47 +450,6 @@ static struct sock *dccp_v4_hnd_req(stru
 	return sk;
 }
 
-int dccp_v4_checksum(const struct sk_buff *skb, const __be32 saddr,
-		     const __be32 daddr)
-{
-	const struct dccp_hdr* dh = dccp_hdr(skb);
-	int checksum_len;
-	u32 tmp;
-
-	if (dh->dccph_cscov = 0)
-		checksum_len = skb->len;
-	else {
-		checksum_len = (dh->dccph_cscov + dh->dccph_x) * sizeof(u32);
-		checksum_len = checksum_len < skb->len ? checksum_len :
-							 skb->len;
-	}
-
-	tmp = csum_partial((unsigned char *)dh, checksum_len, 0);
-	return csum_tcpudp_magic(saddr, daddr, checksum_len,
-				 IPPROTO_DCCP, tmp);
-}
-
-EXPORT_SYMBOL_GPL(dccp_v4_checksum);
-
-static int dccp_v4_verify_checksum(struct sk_buff *skb,
-				   const __be32 saddr, const __be32 daddr)
-{
-	struct dccp_hdr *dh = dccp_hdr(skb);
-	int checksum_len;
-	u32 tmp;
-
-	if (dh->dccph_cscov = 0)
-		checksum_len = skb->len;
-	else {
-		checksum_len = (dh->dccph_cscov + dh->dccph_x) * sizeof(u32);
-		checksum_len = checksum_len < skb->len ? checksum_len :
-							 skb->len;
-	}
-	tmp = csum_partial((unsigned char *)dh, checksum_len, 0);
-	return csum_tcpudp_magic(saddr, daddr, checksum_len,
-				 IPPROTO_DCCP, tmp) = 0 ? 0 : -1;
-}
-
 static struct dst_entry* dccp_v4_route_skb(struct sock *sk,
 					   struct sk_buff *skb)
 {
@@ -526,8 +491,9 @@ static int dccp_v4_send_response(struct 
 		const struct inet_request_sock *ireq = inet_rsk(req);
 		struct dccp_hdr *dh = dccp_hdr(skb);
 
-		dh->dccph_checksum = dccp_v4_checksum(skb, ireq->loc_addr,
-						      ireq->rmt_addr);
+		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
+							      ireq->rmt_addr);
+
 		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
@@ -594,8 +560,9 @@ static void dccp_v4_ctl_send_reset(struc
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
 
-	dh->dccph_checksum = dccp_v4_checksum(skb, rxskb->nh.iph->saddr,
-					      rxskb->nh.iph->daddr);
+	dccp_csum_outgoing(skb);
+	dh->dccph_checksum = dccp_v4_csum_finish(skb, rxskb->nh.iph->saddr,
+						      rxskb->nh.iph->daddr);
 
 	bh_lock_sock(dccp_v4_ctl_socket->sk);
 	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
@@ -770,6 +737,7 @@ EXPORT_SYMBOL_GPL(dccp_v4_do_rcv);
 int dccp_invalid_packet(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
+	unsigned int cscov;
 
 	if (skb->pkt_type != PACKET_HOST)
 		return 1;
@@ -817,6 +785,20 @@ int dccp_invalid_packet(struct sk_buff *
 		return 1;
 	}
 
+	/* If P.CsCov is too large for the packet size, drop packet and return.
+	 * This must come _before_ checksumming (not as RFC 4340 suggests). */
+	cscov = dccp_csum_coverage(skb);
+	if (cscov > skb->len) {
+		LIMIT_NETDEBUG(KERN_WARNING
+			       "DCCP: P.CsCov %u exceeds packet length %d\n",
+			       dh->dccph_cscov, skb->len);
+		return 1;
+	}
+
+	/* If header checksum is incorrect, drop packet and return.
+	 * (This step is completed in the AF-dependent functions.) */
+	skb->csum = skb_checksum(skb, 0, cscov, 0);
+
 	return 0;
 }
 
@@ -827,17 +809,16 @@ static int dccp_v4_rcv(struct sk_buff *s
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
-	int ret = 0;
-
-	/* Step 1: Check header basics: */
+	int ret = 0, min_cov;
 
+	/* Step 1: Check header basics */
 	if (dccp_invalid_packet(skb))
 		goto discard_it;
 
-	/* If the header checksum is incorrect, drop packet and return */
-	if (dccp_v4_verify_checksum(skb, skb->nh.iph->saddr,
-				    skb->nh.iph->daddr) < 0) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: incorrect header checksum\n",
+	/* Step 1: If header checksum is incorrect, drop packet and return. */
+	if (dccp_v4_csum_finish(skb, skb->nh.iph->saddr, skb->nh.iph->daddr)) {
+		LIMIT_NETDEBUG(KERN_WARNING
+			       "%s: dropped packet with invalid checksum\n",
 			       __FUNCTION__);
 		goto discard_it;
 	}
@@ -891,6 +872,20 @@ static int dccp_v4_rcv(struct sk_buff *s
 		goto no_dccp_socket;
 	}
 
+	/* RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
+	 * 	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
+	 * 	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
+	 */
+	min_cov = dccp_sk(sk)->dccps_pcrlen;
+	if (dh->dccph_cscov  &&  (min_cov = 0 || dh->dccph_cscov < min_cov))  {
+		dccp_pr_debug("Packet CsCov %d does not satisfy MinCsCov %d\n",
+			      dh->dccph_cscov, min_cov);
+		/* FIXME: "Such packets SHOULD be reported using Data Dropped
+		 *         options (Section 11.7) with Drop Code 0, Protocol
+		 *         Constraints."                                     */
+		goto discard_and_relse;
+	}
+
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 	nf_reset(skb);
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -57,12 +57,22 @@ static void dccp_v6_hash(struct sock *sk
 	}
 }
 
-static inline u16 dccp_v6_check(struct dccp_hdr *dh, int len,
-				struct in6_addr *saddr,
-				struct in6_addr *daddr,
-				unsigned long base)
+/* add pseudo-header to DCCP checksum stored in skb->csum */
+static __inline__ u16 dccp_v6_csum_finish(struct sk_buff  *skb,
+					  struct in6_addr *src,
+					  struct in6_addr *dst)
 {
-	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_DCCP, base);
+	return csum_ipv6_magic(src, dst, skb->len, IPPROTO_DCCP, skb->csum);
+}
+
+static inline void dccp_v6_send_check(struct sock *sk, int unused_value,
+				      struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct dccp_hdr *dh = dccp_hdr(skb);
+
+	dccp_csum_outgoing(skb);
+	dh->dccph_checksum = dccp_v6_csum_finish(skb, &np->saddr, &np->daddr);
 }
 
 static inline __u32 dccp_v6_init_sequence(struct sock *sk, struct sk_buff *skb)
@@ -276,12 +286,9 @@ static int dccp_v6_send_response(struct 
 	if (skb != NULL) {
 		struct dccp_hdr *dh = dccp_hdr(skb);
 
-		dh->dccph_checksum = dccp_v6_check(dh, skb->len,
-						   &ireq6->loc_addr,
-						   &ireq6->rmt_addr,
-						   csum_partial((char *)dh,
-								skb->len,
-								skb->csum));
+		dh->dccph_checksum = dccp_v6_csum_finish(skb, &ireq6->loc_addr,
+							      &ireq6->rmt_addr);
+
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt, 0);
 		err = net_xmit_eval(err);
@@ -300,18 +307,6 @@ static void dccp_v6_reqsk_destructor(str
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
 
-static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct dccp_hdr *dh = dccp_hdr(skb);
-
-	dh->dccph_checksum = csum_ipv6_magic(&np->saddr, &np->daddr,
-					     len, IPPROTO_DCCP,
-					     csum_partial((char *)dh,
-							  dh->dccph_doff << 2,
-							  skb->csum));
-}
-
 static void dccp_v6_ctl_send_reset(struct sk_buff *rxskb)
 {
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
@@ -353,12 +348,14 @@ static void dccp_v6_ctl_send_reset(struc
 	dccp_hdr_set_seq(dh, seqno);
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
 
+	dccp_csum_outgoing(skb);
+	dh->dccph_checksum = dccp_v6_csum_finish(skb, &rxskb->nh.ipv6h->saddr,
+				   		      &rxskb->nh.ipv6h->daddr);
+
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &rxskb->nh.ipv6h->saddr);
 	ipv6_addr_copy(&fl.fl6_src, &rxskb->nh.ipv6h->daddr);
-	dh->dccph_checksum = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
-					     sizeof(*dh), IPPROTO_DCCP,
-					     skb->csum);
+
 	fl.proto = IPPROTO_DCCP;
 	fl.oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dh->dccph_dport;
@@ -818,13 +815,21 @@ static int dccp_v6_rcv(struct sk_buff **
 	const struct dccp_hdr *dh;
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
-	int ret = 0;
-
-	/* Step 1: Check header basics: */
+	int ret = 0, min_cov;
 
+	/* Step 1: Check header basics */
 	if (dccp_invalid_packet(skb))
 		goto discard_it;
 
+	/* Step 1: If header checksum is incorrect, drop packet and return. */
+	if (dccp_v6_csum_finish(skb, &skb->nh.ipv6h->saddr,
+				     &skb->nh.ipv6h->daddr)) {
+		LIMIT_NETDEBUG(KERN_WARNING
+			       "%s: dropped packet with invalid checksum\n",
+			       __FUNCTION__);
+		goto discard_it;
+	}
+
 	dh = dccp_hdr(skb);
 
 	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(skb);
@@ -862,6 +867,18 @@ static int dccp_v6_rcv(struct sk_buff **
 		goto no_dccp_socket;
 	}
 
+	/* RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
+	 * 	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
+	 * 	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
+	 */
+	min_cov = dccp_sk(sk)->dccps_pcrlen;
+	if (dh->dccph_cscov  &&  (min_cov = 0 || dh->dccph_cscov < min_cov))  {
+		dccp_pr_debug("Packet CsCov %d does not satisfy MinCsCov %d\n",
+			      dh->dccph_cscov, min_cov);
+		/* FIXME: send Data Dropped option (see also dccp_v4_rcv) */
+		goto discard_and_relse;
+	}
+
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -96,6 +96,7 @@ static int dccp_transmit_skb(struct sock
 		dh->dccph_dport	= inet->dport;
 		dh->dccph_doff	= (dccp_header_size + dcb->dccpd_opt_len) / 4;
 		dh->dccph_ccval	= dcb->dccpd_ccval;
+		dh->dccph_cscov = dp->dccps_pcslen;
 		/* XXX For now we're using only 48 bits sequence numbers */
 		dh->dccph_x	= 1;
 
@@ -115,7 +116,7 @@ static int dccp_transmit_skb(struct sock
 			break;
 		}
 
-		icsk->icsk_af_ops->send_check(sk, skb->len, skb);
+		icsk->icsk_af_ops->send_check(sk, 0, skb);
 
 		if (set_ack)
 			dccp_event_ack_sent(sk);
@@ -320,7 +321,6 @@ struct sk_buff *dccp_make_response(struc
 	skb_reserve(skb, sk->sk_prot->max_header);
 
 	skb->dst = dst_clone(dst);
-	skb->csum = 0;
 
 	dreq = dccp_rsk(req);
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
@@ -344,6 +344,8 @@ struct sk_buff *dccp_make_response(struc
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
 	dccp_hdr_response(skb)->dccph_resp_service = dreq->dreq_service;
 
+	dccp_csum_outgoing(skb);
+
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
 }
@@ -368,7 +370,6 @@ static struct sk_buff *dccp_make_reset(s
 	skb_reserve(skb, sk->sk_prot->max_header);
 
 	skb->dst = dst_clone(dst);
-	skb->csum = 0;
 
 	dccp_inc_seqno(&dp->dccps_gss);
 
@@ -393,7 +394,7 @@ static struct sk_buff *dccp_make_reset(s
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dp->dccps_gsr);
 
 	dccp_hdr_reset(skb)->dccph_reset_code = code;
-	inet_csk(sk)->icsk_af_ops->send_check(sk, skb->len, skb);
+	inet_csk(sk)->icsk_af_ops->send_check(sk, 0, skb);
 
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
@@ -466,7 +467,6 @@ int dccp_connect(struct sock *sk)
 	skb_reserve(skb, sk->sk_prot->max_header);
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
-	skb->csum = 0;
 
 	dccp_skb_entail(sk, skb);
 	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
@@ -498,7 +498,6 @@ void dccp_send_ack(struct sock *sk)
 
 		/* Reserve space for headers */
 		skb_reserve(skb, sk->sk_prot->max_header);
-		skb->csum = 0;
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK;
 		dccp_transmit_skb(sk, skb);
 	}
@@ -552,7 +551,6 @@ void dccp_send_sync(struct sock *sk, con
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, sk->sk_prot->max_header);
-	skb->csum = 0;
 	DCCP_SKB_CB(skb)->dccpd_type = pkt_type;
 	DCCP_SKB_CB(skb)->dccpd_seq = seq;
 
@@ -578,7 +576,6 @@ void dccp_send_close(struct sock *sk, co
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, sk->sk_prot->max_header);
-	skb->csum = 0;
 	DCCP_SKB_CB(skb)->dccpd_type = dp->dccps_role = DCCP_ROLE_CLIENT ?
 					DCCP_PKT_CLOSE : DCCP_PKT_CLOSEREQ;
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -487,11 +487,28 @@ static int do_dccp_setsockopt(struct soc
 						     optval);
 		break;
 
+	case DCCP_SOCKOPT_SEND_CSCOV:	/* sender side, RFC 4340, sec. 9.2 */
+		if (val < 0 || val > 15)
+			err = -EINVAL;
+		else
+			dp->dccps_pcslen = val;
+		break;
+
+	case DCCP_SOCKOPT_RECV_CSCOV:	/* receiver side, RFC 4340 sec. 9.2.1 */
+		if (val < 0 || val > 15)
+			err = -EINVAL;
+		else {
+			dp->dccps_pcrlen = val;
+			/* FIXME: add feature negotiation,
+			 * ChangeL(MinimumChecksumCoverage, val) */
+		}
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
 	}
-	
+
 	release_sock(sk);
 	return err;
 }
@@ -571,6 +588,14 @@ static int do_dccp_getsockopt(struct soc
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);
+	case DCCP_SOCKOPT_SEND_CSCOV:
+		val = dp->dccps_pcslen;
+		break;
+
+	case DCCP_SOCKOPT_RECV_CSCOV:
+		val = dp->dccps_pcrlen;
+		break;
+
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);
