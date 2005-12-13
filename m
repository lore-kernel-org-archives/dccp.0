From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 00:03:15 +0000
Subject: [PATCH 2/2][IP_SOCKGLUE]: Remove most of the tcp specific calls
Message-Id: <39e6f6c70512121603k4fa2a924k3ee75c1fb6a0fa4e@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_17714_30351596.1134432195356"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_17714_30351596.1134432195356
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

  Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_17714_30351596.1134432195356
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="2.patch"

tree 99f9e56a48a5a7a783875df630e84c91fd06488a
parent 793a36f474b6d9991f6c1c218041e350cda57195
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134430852 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134430852 -0200

[IP_SOCKGLUE]: Remove most of the tcp specific calls

As DCCP needs to be called in the same spots.

Now we have a member in inet_sock (is_icsk), set at sock creation time from
struct inet_protosw->flags (if INET_PROTOSW_ICSK is set, like for TCP and
DCCP) to see if a struct sock instance is a inet_connection_sock for places
like the ones in ip_sockglue.c (v4 and v6) where we previously were looking if
sk_type was SOCK_STREAM, that is insufficient because we now use the same code
for DCCP, that has sk_type SOCK_DCCP.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/linux/dccp.h               |    4 ----
 include/linux/ip.h                 |    1 +
 include/linux/tcp.h                |    3 +--
 include/net/inet_connection_sock.h |    6 +++++-
 include/net/protocol.h             |    1 +
 net/dccp/diag.c                    |    2 +-
 net/dccp/input.c                   |    2 +-
 net/dccp/ipv4.c                    |   12 +++++++-----
 net/dccp/ipv6.c                    |   26 ++++++++++++++------------
 net/dccp/output.c                  |    7 ++++---
 net/dccp/proto.c                   |    2 +-
 net/ipv4/af_inet.c                 |    4 +++-
 net/ipv4/ip_sockglue.c             |   13 ++++++-------
 net/ipv4/tcp.c                     |    2 +-
 net/ipv4/tcp_input.c               |   10 ++++------
 net/ipv4/tcp_ipv4.c                |   12 ++++++------
 net/ipv4/tcp_output.c              |   18 ++++++++++--------
 net/ipv6/af_inet6.c                |    1 +
 net/ipv6/ipv6_sockglue.c           |   24 +++++++++++++-----------
 net/ipv6/tcp_ipv6.c                |   30 +++++++++++++++++-------------
 20 files changed, 97 insertions(+), 83 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 71fab43..d0bdb49 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -408,8 +408,6 @@ struct dccp_ackvec;
  * @dccps_gar - greatest valid ack number received on a non-Sync; initialized to %dccps_iss
  * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
- * @dccps_ext_header_len - network protocol overhead (IP/IPv6 options)
- * @dccps_pmtu_cookie - Last pmtu seen by socket
  * @dccps_packet_size - Set thru setsockopt
  * @dccps_role - Role of this sock, one of %dccp_role
  * @dccps_ndp_count - number of Non Data Packets since last data packet
@@ -434,8 +432,6 @@ struct dccp_sock {
 	__u32				dccps_timestamp_echo;
 	__u32				dccps_packet_size;
 	unsigned long			dccps_ndp_count;
-	__u16				dccps_ext_header_len;
-	__u32				dccps_pmtu_cookie;
 	__u32				dccps_mss_cache;
 	struct dccp_options		dccps_options;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
diff --git a/include/linux/ip.h b/include/linux/ip.h
index 5a560da..6ccc596 100644
--- a/include/linux/ip.h
+++ b/include/linux/ip.h
@@ -155,6 +155,7 @@ struct inet_sock {
 	__u8			mc_ttl;		/* Multicasting TTL */
 	__u8			pmtudisc;
 	unsigned		recverr : 1,
+				is_icsk : 1,	/* inet_connection_sock? */
 				freebind : 1,
 				hdrincl : 1,
 				mc_loop : 1;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index da38eea..f2bb239 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -238,10 +238,9 @@ struct tcp_sock {
 	__u32	snd_wl1;	/* Sequence for window update		*/
 	__u32	snd_wnd;	/* The window we expect to receive	*/
 	__u32	max_window;	/* Maximal window ever seen from peer	*/
-	__u32	pmtu_cookie;	/* Last pmtu seen by socket		*/
 	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
 	__u16	xmit_size_goal;	/* Goal for segmenting output packets	*/
-	__u16	ext_header_len;	/* Network protocol overhead (IP/IPv6 options) */
+	/* XXX Two bytes hole, try to pack */
 
 	__u32	window_clamp;	/* Maximal window to advertise		*/
 	__u32	rcv_ssthresh;	/* Current window clamp			*/
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index e50e2b8..9188896 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -60,6 +60,7 @@ struct inet_connection_sock_af_ops {
  * @icsk_timeout:	   Timeout
  * @icsk_retransmit_timer: Resend (no ack)
  * @icsk_rto:		   Retransmit timeout
+ * @icsk_pmtu_cookie	   Last pmtu seen by socket
  * @icsk_ca_ops		   Pluggable congestion control hook
  * @icsk_af_ops		   Operations which are AF_INET{4,6} specific
  * @icsk_ca_state:	   Congestion control state
@@ -68,6 +69,7 @@ struct inet_connection_sock_af_ops {
  * @icsk_backoff:	   Backoff
  * @icsk_syn_retries:      Number of allowed SYN (or equivalent) retries
  * @icsk_probes_out:	   unanswered 0 window probes
+ * @icsk_ext_hdr_len:	   Network protocol overhead (IP/IPv6 options)
  * @icsk_ack:		   Delayed ACK control data
  */
 struct inet_connection_sock {
@@ -79,15 +81,17 @@ struct inet_connection_sock {
  	struct timer_list	  icsk_retransmit_timer;
  	struct timer_list	  icsk_delack_timer;
 	__u32			  icsk_rto;
+	__u32			  icsk_pmtu_cookie;
 	struct tcp_congestion_ops *icsk_ca_ops;
 	struct inet_connection_sock_af_ops *icsk_af_ops;
+	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
 	__u8			  icsk_ca_state;
 	__u8			  icsk_retransmits;
 	__u8			  icsk_pending;
 	__u8			  icsk_backoff;
 	__u8			  icsk_syn_retries;
 	__u8			  icsk_probes_out;
-	/* 2 BYTES HOLE, TRY TO PACK! */
+	__u16			  icsk_ext_hdr_len;
 	struct {
 		__u8		  pending;	 /* ACK is pending			   */
 		__u8		  quick;	 /* Scheduled number of quick acks	   */
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 357691f..a29cb29 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -76,6 +76,7 @@ struct inet_protosw {
 };
 #define INET_PROTOSW_REUSE 0x01	     /* Are ports automatically reusable? */
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovable. */
+#define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
 
 extern struct net_protocol *inet_protocol_base;
 extern struct net_protocol *inet_protos[MAX_INET_PROTOS];
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index f675d8e..3f78c00 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -28,7 +28,7 @@ static void dccp_get_info(struct sock *s
 	info->tcpi_retransmits	= icsk->icsk_retransmits;
 	info->tcpi_probes	= icsk->icsk_probes_out;
 	info->tcpi_backoff	= icsk->icsk_backoff;
-	info->tcpi_pmtu		= dp->dccps_pmtu_cookie;
+	info->tcpi_pmtu		= icsk->icsk_pmtu_cookie;
 
 	if (dp->dccps_options.dccpo_send_ack_vector)
 		info->tcpi_options |= TCPI_OPT_SACK;
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 9a724ff..55e921b 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -311,7 +311,7 @@ static int dccp_rcv_request_sent_state_p
 			goto out_invalid_packet;
 		}
 
-		dccp_sync_mss(sk, dp->dccps_pmtu_cookie);
+		dccp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 
 		/*
 		 *    Step 10: Process REQUEST state (second part)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2702094..f935659 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -104,9 +104,9 @@ int dccp_v4_connect(struct sock *sk, str
 	inet->dport = usin->sin_port;
 	inet->daddr = daddr;
 
-	dp->dccps_ext_header_len = 0;
+	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet->opt != NULL)
-		dp->dccps_ext_header_len = inet->opt->optlen;
+		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
 	/*
 	 * Socket identity is still unknown (sport may be zero).
 	 * However we set state to DCCP_REQUESTING and not releasing socket
@@ -191,7 +191,7 @@ static inline void dccp_do_pmtu_discover
 	mtu = dst_mtu(dst);
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
-	    dp->dccps_pmtu_cookie > mtu) {
+	    inet_csk(sk)->icsk_pmtu_cookie > mtu) {
 		dccp_sync_mss(sk, mtu);
 
 		/*
@@ -1051,6 +1051,7 @@ struct inet_connection_sock_af_ops dccp_
 int dccp_v4_init_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	static int dccp_ctl_socket_init = 1;
 
 	dccp_options_init(&dp->dccps_options);
@@ -1090,10 +1091,11 @@ int dccp_v4_init_sock(struct sock *sk)
 		dccp_ctl_socket_init = 0;
 
 	dccp_init_xmit_timers(sk);
-	inet_csk(sk)->icsk_rto = DCCP_TIMEOUT_INIT;
+	icsk->icsk_rto = DCCP_TIMEOUT_INIT;
 	sk->sk_state = DCCP_CLOSED;
 	sk->sk_write_space = dccp_write_space;
-	inet_csk(sk)->icsk_af_ops = &dccp_ipv4_af_ops;
+	icsk->icsk_af_ops = &dccp_ipv4_af_ops;
+	icsk->icsk_sync_mss = dccp_sync_mss;
 	dp->dccps_mss_cache = 536;
 	dp->dccps_role = DCCP_ROLE_UNDEFINED;
 	dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 71bf04e..599b0be 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -88,6 +88,7 @@ static int dccp_v6_connect(struct sock *
 			   int addr_len)
 {
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -158,7 +159,7 @@ static int dccp_v6_connect(struct sock *
 	 */
 
 	if (addr_type == IPV6_ADDR_MAPPED) {
-		u32 exthdrlen = dp->dccps_ext_header_len;
+		u32 exthdrlen = icsk->icsk_ext_hdr_len;
 		struct sockaddr_in sin;
 
 		SOCK_DEBUG(sk, "connect: ipv4 mapped\n");
@@ -170,14 +171,14 @@ static int dccp_v6_connect(struct sock *
 		sin.sin_port = usin->sin6_port;
 		sin.sin_addr.s_addr = usin->sin6_addr.s6_addr32[3];
 
-		inet_csk(sk)->icsk_af_ops = &dccp_ipv6_mapped;
+		icsk->icsk_af_ops = &dccp_ipv6_mapped;
 		sk->sk_backlog_rcv = dccp_v4_do_rcv;
 
 		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
 
 		if (err) {
-			dp->dccps_ext_header_len = exthdrlen;
-			inet_csk(sk)->icsk_af_ops = &dccp_ipv6_af_ops;
+			icsk->icsk_ext_hdr_len = exthdrlen;
+			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
 			sk->sk_backlog_rcv = dccp_v6_do_rcv;
 			goto failure;
 		} else {
@@ -227,9 +228,10 @@ static int dccp_v6_connect(struct sock *
 
 	ip6_dst_store(sk, dst, NULL);
 
-	dp->dccps_ext_header_len = 0;
+	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
-		dp->dccps_ext_header_len = np->opt->opt_flen + np->opt->opt_nflen;
+		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
+					  np->opt->opt_nflen);
 
 	inet->dport = usin->sin6_port;
 
@@ -292,7 +294,6 @@ static void dccp_v6_err(struct sk_buff *
 	np = inet6_sk(sk);
 
 	if (type == ICMPV6_PKT_TOOBIG) {
-		struct dccp_sock *dp = dccp_sk(sk);
 		struct dst_entry *dst = NULL;
 
 		if (sock_owned_by_user(sk))
@@ -332,7 +333,7 @@ static void dccp_v6_err(struct sk_buff *
 		} else
 			dst_hold(dst);
 
-		if (dp->dccps_pmtu_cookie > dst_mtu(dst)) {
+		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
 			dccp_sync_mss(sk, dst_mtu(dst));
 		} /* else let the usual retransmit timer handle it */
 		dst_release(dst);
@@ -808,7 +809,7 @@ static struct sock *dccp_v6_request_recv
 		   worked with IPv6 icsk.icsk_af_ops.
 		   Sync it now.
 		 */
-		dccp_sync_mss(newsk, newdp->dccps_pmtu_cookie);
+		dccp_sync_mss(newsk, inet_csk(newsk)->icsk_pmtu_cookie);
 
 		return newsk;
 	}
@@ -916,10 +917,10 @@ static struct sock *dccp_v6_request_recv
 			sock_kfree_s(sk, opt, opt->tot_len);
 	}
 
-	newdp->dccps_ext_header_len = 0;
+	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newnp->opt)
-		newdp->dccps_ext_header_len = newnp->opt->opt_nflen +
-					      newnp->opt->opt_flen;
+		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
+						     newnp->opt->opt_flen);
 
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
@@ -1230,6 +1231,7 @@ static struct inet_protosw dccp_v6_proto
 	.prot		= &dccp_v6_prot,
 	.ops		= &inet6_dccp_ops,
 	.capability	= -1,
+	.flags		= INET_PROTOSW_ICSK,
 };
 
 static int __init dccp_v6_init(void)
diff --git a/net/dccp/output.c b/net/dccp/output.c
index c40f7f8..95a3c2c 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -134,12 +134,13 @@ static int dccp_transmit_skb(struct sock
 
 unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 {
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	int mss_now = (pmtu - inet_csk(sk)->icsk_af_ops->net_header_len -
+	int mss_now = (pmtu - icsk->icsk_af_ops->net_header_len -
 		       sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext));
 
 	/* Now subtract optional transport overhead */
-	mss_now -= dp->dccps_ext_header_len;
+	mss_now -= icsk->icsk_ext_hdr_len;
 
 	/*
 	 * FIXME: this should come from the CCID infrastructure, where, say,
@@ -152,7 +153,7 @@ unsigned int dccp_sync_mss(struct sock *
 	mss_now -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
 
 	/* And store cached results */
-	dp->dccps_pmtu_cookie = pmtu;
+	icsk->icsk_pmtu_cookie = pmtu;
 	dp->dccps_mss_cache = mss_now;
 
 	return mss_now;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 51dfacd..40a4c68 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -712,7 +712,7 @@ static struct inet_protosw dccp_v4_proto
 	.ops		= &inet_dccp_ops,
 	.capability	= -1,
 	.no_check	= 0,
-	.flags		= 0,
+	.flags		= INET_PROTOSW_ICSK,
 };
 
 /*
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d368cf2..617e858 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -302,6 +302,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
+	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;
@@ -869,7 +870,8 @@ static struct inet_protosw inetsw_array[
                 .ops =        &inet_stream_ops,
                 .capability = -1,
                 .no_check =   0,
-                .flags =      INET_PROTOSW_PERMANENT,
+                .flags =      INET_PROTOSW_PERMANENT |
+			      INET_PROTOSW_ICSK,
         },
 
         {
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 4f2d872..add019c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -29,8 +29,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/tcp.h>
-#include <linux/tcp.h>
+#include <net/tcp_states.h>
 #include <linux/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter.h>
@@ -427,8 +426,8 @@ int ip_setsockopt(struct sock *sk, int l
 			err = ip_options_get_from_user(&opt, optval, optlen);
 			if (err)
 				break;
-			if (sk->sk_type == SOCK_STREAM) {
-				struct tcp_sock *tp = tcp_sk(sk);
+			if (inet->is_icsk) {
+				struct inet_connection_sock *icsk = inet_csk(sk);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 				if (sk->sk_family == PF_INET ||
 				    (!((1 << sk->sk_state) &
@@ -436,10 +435,10 @@ int ip_setsockopt(struct sock *sk, int l
 				     inet->daddr != LOOPBACK4_IPV6)) {
 #endif
 					if (inet->opt)
-						tp->ext_header_len -= inet->opt->optlen;
+						icsk->icsk_ext_hdr_len -= inet->opt->optlen;
 					if (opt)
-						tp->ext_header_len += opt->optlen;
-					tcp_sync_mss(sk, tp->pmtu_cookie);
+						icsk->icsk_ext_hdr_len += opt->optlen;
+					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 				}
 #endif
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eacfe6a..00aa80e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1914,7 +1914,7 @@ void tcp_get_info(struct sock *sk, struc
 	info->tcpi_last_data_recv = jiffies_to_msecs(now - icsk->icsk_ack.lrcvtime);
 	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
 
-	info->tcpi_pmtu = tp->pmtu_cookie;
+	info->tcpi_pmtu = icsk->icsk_pmtu_cookie;
 	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
 	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
 	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7de6184..981d120 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2342,7 +2342,7 @@ static int tcp_ack_update_window(struct 
 
 			if (nwin > tp->max_window) {
 				tp->max_window = nwin;
-				tcp_sync_mss(sk, tp->pmtu_cookie);
+				tcp_sync_mss(sk, inet_csk(sk)->icsk_pmtu_cookie);
 			}
 		}
 	}
@@ -3967,12 +3967,12 @@ static int tcp_rcv_synsent_state_process
 					 struct tcphdr *th, unsigned len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
 	tcp_parse_options(skb, &tp->rx_opt, 0);
 
 	if (th->ack) {
-		struct inet_connection_sock *icsk;
 		/* rfc793:
 		 * "If the state is SYN-SENT then
 		 *    first check the ACK bit
@@ -4061,7 +4061,7 @@ static int tcp_rcv_synsent_state_process
 		if (tp->rx_opt.sack_ok && sysctl_tcp_fack)
 			tp->rx_opt.sack_ok |= 2;
 
-		tcp_sync_mss(sk, tp->pmtu_cookie);
+		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
 
 		/* Remember, tcp_poll() does not lock socket!
@@ -4071,8 +4071,6 @@ static int tcp_rcv_synsent_state_process
 		mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
-		icsk = inet_csk(sk);
-
 		/* Make sure socket is routed, for correct metrics.  */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
@@ -4173,7 +4171,7 @@ discard:
 		if (tp->ecn_flags&TCP_ECN_OK)
 			sock_set_flag(sk, SOCK_NO_LARGESEND);
 
-		tcp_sync_mss(sk, tp->pmtu_cookie);
+		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
 
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c2fe61b..9b62d80 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -220,9 +220,9 @@ int tcp_v4_connect(struct sock *sk, stru
 	inet->dport = usin->sin_port;
 	inet->daddr = daddr;
 
-	tp->ext_header_len = 0;
+	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet->opt)
-		tp->ext_header_len = inet->opt->optlen;
+		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
 
 	tp->rx_opt.mss_clamp = 536;
 
@@ -275,7 +275,6 @@ static inline void do_pmtu_discovery(str
 {
 	struct dst_entry *dst;
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* We are not interested in TCP_LISTEN and open_requests (SYN-ACKs
 	 * send out by Linux are always <576bytes so they should go through
@@ -304,7 +303,7 @@ static inline void do_pmtu_discovery(str
 	mtu = dst_mtu(dst);
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
-	    tp->pmtu_cookie > mtu) {
+	    inet_csk(sk)->icsk_pmtu_cookie > mtu) {
 		tcp_sync_mss(sk, mtu);
 
 		/* Resend the TCP packet because it's
@@ -895,9 +894,9 @@ struct sock *tcp_v4_syn_recv_sock(struct
 	ireq->opt	      = NULL;
 	newinet->mc_index     = inet_iif(skb);
 	newinet->mc_ttl	      = skb->nh.iph->ttl;
-	newtp->ext_header_len = 0;
+	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newinet->opt)
-		newtp->ext_header_len = newinet->opt->optlen;
+		inet_csk(newsk)->icsk_ext_hdr_len = newinet->opt->optlen;
 	newinet->id = newtp->write_seq ^ jiffies;
 
 	tcp_sync_mss(newsk, dst_mtu(dst));
@@ -1266,6 +1265,7 @@ static int tcp_v4_init_sock(struct sock 
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	icsk->icsk_af_ops = &ipv4_specific;
+	icsk->icsk_sync_mss = tcp_sync_mss;
 
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index af1946c..3a0a914 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -621,7 +621,7 @@ int tcp_trim_head(struct sock *sk, struc
    It is minimum of user_mss and mss received with SYN.
    It also does not include TCP options.
 
-   tp->pmtu_cookie is last pmtu, seen by this function.
+   inet_csk(sk)->icsk_pmtu_cookie is last pmtu, seen by this function.
 
    tp->mss_cache is current effective sending mss, including
    all tcp options except for SACKs. It is evaluated,
@@ -631,17 +631,18 @@ int tcp_trim_head(struct sock *sk, struc
    NOTE1. rfc1122 clearly states that advertised MSS
    DOES NOT include either tcp or ip options.
 
-   NOTE2. tp->pmtu_cookie and tp->mss_cache are READ ONLY outside
-   this function.			--ANK (980731)
+   NOTE2. inet_csk(sk)->icsk_pmtu_cookie and tp->mss_cache
+   are READ ONLY outside this function.		--ANK (980731)
  */
 
 unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	/* Calculate base mss without TCP options:
 	   It is MMS_S - sizeof(tcphdr) of rfc1122
 	 */
-	int mss_now = (pmtu - inet_csk(sk)->icsk_af_ops->net_header_len -
+	int mss_now = (pmtu - icsk->icsk_af_ops->net_header_len -
 		       sizeof(struct tcphdr));
 
 	/* Clamp it (mss_clamp does not include tcp options) */
@@ -649,7 +650,7 @@ unsigned int tcp_sync_mss(struct sock *s
 		mss_now = tp->rx_opt.mss_clamp;
 
 	/* Now subtract optional transport overhead */
-	mss_now -= tp->ext_header_len;
+	mss_now -= icsk->icsk_ext_hdr_len;
 
 	/* Then reserve room for full set of TCP options and 8 bytes of data */
 	if (mss_now < 48)
@@ -663,7 +664,7 @@ unsigned int tcp_sync_mss(struct sock *s
 		mss_now = max((tp->max_window>>1), 68U - tp->tcp_header_len);
 
 	/* And store cached results */
-	tp->pmtu_cookie = pmtu;
+	icsk->icsk_pmtu_cookie = pmtu;
 	tp->mss_cache = mss_now;
 
 	return mss_now;
@@ -693,7 +694,7 @@ unsigned int tcp_current_mss(struct sock
 
 	if (dst) {
 		u32 mtu = dst_mtu(dst);
-		if (mtu != tp->pmtu_cookie)
+		if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
@@ -706,7 +707,8 @@ unsigned int tcp_current_mss(struct sock
 	if (doing_tso) {
 		xmit_size_goal = (65535 -
 				  inet_csk(sk)->icsk_af_ops->net_header_len -
-				  tp->ext_header_len - tp->tcp_header_len);
+				  inet_csk(sk)->icsk_ext_hdr_len -
+				  tp->tcp_header_len);
 
 		if (tp->max_window &&
 		    (xmit_size_goal > (tp->max_window >> 1)))
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bf17aab..70a510f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -167,6 +167,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
+	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index b6b63fa..c63868d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -163,17 +163,17 @@ int ipv6_setsockopt(struct sock *sk, int
 			sk_refcnt_debug_dec(sk);
 
 			if (sk->sk_protocol == IPPROTO_TCP) {
-				struct tcp_sock *tp = tcp_sk(sk);
+				struct inet_connection_sock *icsk = inet_csk(sk);
 
 				local_bh_disable();
 				sock_prot_dec_use(sk->sk_prot);
 				sock_prot_inc_use(&tcp_prot);
 				local_bh_enable();
 				sk->sk_prot = &tcp_prot;
-				inet_csk(sk)->icsk_af_ops = &ipv4_specific;
+				icsk->icsk_af_ops = &ipv4_specific;
 				sk->sk_socket->ops = &inet_stream_ops;
 				sk->sk_family = PF_INET;
-				tcp_sync_mss(sk, tp->pmtu_cookie);
+				tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 			} else {
 				local_bh_disable();
 				sock_prot_dec_use(sk->sk_prot);
@@ -317,14 +317,15 @@ int ipv6_setsockopt(struct sock *sk, int
 		}
 
 		retv = 0;
-		if (sk->sk_type == SOCK_STREAM) {
+		if (inet_sk(sk)->is_icsk) {
 			if (opt) {
-				struct tcp_sock *tp = tcp_sk(sk);
+				struct inet_connection_sock *icsk = inet_csk(sk);
 				if (!((1 << sk->sk_state) &
 				      (TCPF_LISTEN | TCPF_CLOSE))
 				    && inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
-					tp->ext_header_len = opt->opt_flen + opt->opt_nflen;
-					tcp_sync_mss(sk, tp->pmtu_cookie);
+					icsk->icsk_ext_hdr_len =
+						opt->opt_flen + opt->opt_nflen;
+					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 				}
 			}
 			opt = xchg(&np->opt, opt);
@@ -380,14 +381,15 @@ sticky_done:
 			goto done;
 update:
 		retv = 0;
-		if (sk->sk_type == SOCK_STREAM) {
+		if (inet_sk(sk)->is_icsk) {
 			if (opt) {
-				struct tcp_sock *tp = tcp_sk(sk);
+				struct inet_connection_sock *icsk = inet_csk(sk);
 				if (!((1 << sk->sk_state) &
 				      (TCPF_LISTEN | TCPF_CLOSE))
 				    && inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
-					tp->ext_header_len = opt->opt_flen + opt->opt_nflen;
-					tcp_sync_mss(sk, tp->pmtu_cookie);
+					icsk->icsk_ext_hdr_len =
+						opt->opt_flen + opt->opt_nflen;
+					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 				}
 			}
 			opt = xchg(&np->opt, opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1587c35..1cc6f4e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -123,7 +123,8 @@ static int tcp_v6_connect(struct sock *s
 			  int addr_len)
 {
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
-	struct inet_sock *inet = inet_sk(sk);
+ 	struct inet_sock *inet = inet_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p = NULL, final;
@@ -198,7 +199,7 @@ static int tcp_v6_connect(struct sock *s
 	 */
 
 	if (addr_type == IPV6_ADDR_MAPPED) {
-		u32 exthdrlen = tp->ext_header_len;
+		u32 exthdrlen = icsk->icsk_ext_hdr_len;
 		struct sockaddr_in sin;
 
 		SOCK_DEBUG(sk, "connect: ipv4 mapped\n");
@@ -210,14 +211,14 @@ static int tcp_v6_connect(struct sock *s
 		sin.sin_port = usin->sin6_port;
 		sin.sin_addr.s_addr = usin->sin6_addr.s6_addr32[3];
 
-		inet_csk(sk)->icsk_af_ops = &ipv6_mapped;
+		icsk->icsk_af_ops = &ipv6_mapped;
 		sk->sk_backlog_rcv = tcp_v4_do_rcv;
 
 		err = tcp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
 
 		if (err) {
-			tp->ext_header_len = exthdrlen;
-			inet_csk(sk)->icsk_af_ops = &ipv6_specific;
+			icsk->icsk_ext_hdr_len = exthdrlen;
+			icsk->icsk_af_ops = &ipv6_specific;
 			sk->sk_backlog_rcv = tcp_v6_do_rcv;
 			goto failure;
 		} else {
@@ -270,9 +271,10 @@ static int tcp_v6_connect(struct sock *s
 	sk->sk_route_caps = dst->dev->features &
 		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
-	tp->ext_header_len = 0;
+	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
-		tp->ext_header_len = np->opt->opt_flen + np->opt->opt_nflen;
+		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
+					  np->opt->opt_nflen);
 
 	tp->rx_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 
@@ -385,7 +387,7 @@ static void tcp_v6_err(struct sk_buff *s
 		} else
 			dst_hold(dst);
 
-		if (tp->pmtu_cookie > dst_mtu(dst)) {
+		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
 			tcp_sync_mss(sk, dst_mtu(dst));
 			tcp_simple_retransmit(sk);
 		} /* else let the usual retransmit timer handle it */
@@ -870,7 +872,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		   worked with IPv6 icsk.icsk_af_ops.
 		   Sync it now.
 		 */
-		tcp_sync_mss(newsk, newtp->pmtu_cookie);
+		tcp_sync_mss(newsk, inet_csk(sk)->icsk_pmtu_cookie);
 
 		return newsk;
 	}
@@ -977,10 +979,10 @@ static struct sock * tcp_v6_syn_recv_soc
 			sock_kfree_s(sk, opt, opt->tot_len);
 	}
 
-	newtp->ext_header_len = 0;
+	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newnp->opt)
-		newtp->ext_header_len = newnp->opt->opt_nflen +
-					newnp->opt->opt_flen;
+		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
+						     newnp->opt->opt_flen);
 
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
@@ -1362,6 +1364,7 @@ static int tcp_v6_init_sock(struct sock 
 
 	icsk->icsk_af_ops = &ipv6_specific;
 	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
+	icsk->icsk_sync_mss = tcp_sync_mss;
 	sk->sk_write_space = sk_stream_write_space;
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
@@ -1592,7 +1595,8 @@ static struct inet_protosw tcpv6_protosw
 	.ops		=	&inet6_stream_ops,
 	.capability	=	-1,
 	.no_check	=	0,
-	.flags		=	INET_PROTOSW_PERMANENT,
+	.flags		=	INET_PROTOSW_PERMANENT |
+				INET_PROTOSW_ICSK,
 };
 
 void __init tcpv6_init(void)


------=_Part_17714_30351596.1134432195356--
