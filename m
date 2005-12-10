From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 10 Dec 2005 19:29:09 +0000
Subject: [PATCH 5/6][DCCP]: Prepare the AF agnostic core for the introduction of DCCPv
Message-Id: <39e6f6c70512101129nd44448dq7c6510108ec95c3c@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22619_8759956.1134242949310"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22619_8759956.1134242949310
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_22619_8759956.1134242949310
Content-Type: text/x-patch; name=5.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="5.patch"

tree 174dd0e88a564eee13135f82726dff9b7cf47ab5
parent cb79764656d2a8308dc7705447f1ea92edc0a297
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134242069 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134242069 -0200

[DCCP]: Prepare the AF agnostic core for the introduction of DCCPv6

Basically exports a similar set of functions as the one exported by the non-AF
specific TCP code.

In the process moved some non-AF specific code from dccp_v4_connect to
dccp_connect_init and moved the checksum verification from dccp_invalid_packet
to dccp_v4_rcv, so as to use it in dccp_v6_rcv too.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 dccp.h      |   22 ++++++++++++++++++
 input.c     |    4 +++
 ipv4.c      |   73 +++++++++++++++++++++++++++---------------------------------
 minisocks.c |    8 ++++++
 output.c    |   27 +++++++++++++---------
 proto.c     |   32 +++++++++++++++++++++++---
 6 files changed, 114 insertions(+), 52 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index e711f85..93f26dd 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -228,6 +228,9 @@ extern int dccp_rcv_state_process(struct
 extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				const struct dccp_hdr *dh, const unsigned len);
 
+extern int dccp_v4_init_sock(struct sock *sk);
+extern int dccp_v4_destroy_sock(struct sock *sk);
+
 extern void		dccp_close(struct sock *sk, long timeout);
 extern struct sk_buff	*dccp_make_response(struct sock *sk,
 					    struct dst_entry *dst,
@@ -238,6 +241,7 @@ extern struct sk_buff	*dccp_make_reset(s
 
 extern int	   dccp_connect(struct sock *sk);
 extern int	   dccp_disconnect(struct sock *sk, int flags);
+extern void	   dccp_unhash(struct sock *sk);
 extern int	   dccp_getsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int __user *optlen);
 extern int	   dccp_setsockopt(struct sock *sk, int level, int optname,
@@ -249,6 +253,13 @@ extern int	   dccp_recvmsg(struct kiocb 
 				struct msghdr *msg, size_t len, int nonblock,
 				int flags, int *addr_len);
 extern void	   dccp_shutdown(struct sock *sk, int how);
+extern int	   inet_dccp_listen(struct socket *sock, int backlog);
+extern unsigned int dccp_poll(struct file *file, struct socket *sock,
+			     poll_table *wait);
+extern void	   dccp_v4_send_check(struct sock *sk, int len,
+				      struct sk_buff *skb);
+extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
+				   int addr_len);
 
 extern int	   dccp_v4_checksum(const struct sk_buff *skb,
 				    const u32 saddr, const u32 daddr);
@@ -256,6 +267,17 @@ extern int	   dccp_v4_checksum(const str
 extern int	   dccp_v4_send_reset(struct sock *sk,
 				      enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
+extern int	   dccp_invalid_packet(struct sk_buff *skb);
+
+static inline int dccp_bad_service_code(const struct sock *sk,
+					const __u32 service)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+
+	if (dp->dccps_service == service)
+		return 0;
+	return !dccp_list_has_service(dp->dccps_service_list, service);
+}
 
 struct dccp_skb_cb {
 	__u8  dccpd_type:4;
diff --git a/net/dccp/input.c b/net/dccp/input.c
index c81488f..9a724ff 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -250,6 +250,8 @@ discard:
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(dccp_rcv_established);
+
 static int dccp_rcv_request_sent_state_process(struct sock *sk,
 					       struct sk_buff *skb,
 					       const struct dccp_hdr *dh,
@@ -567,3 +569,5 @@ discard:
 	}
 	return 0;
 }
+
+EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index fd9fcbd..83ea891 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -46,11 +46,13 @@ static void dccp_v4_hash(struct sock *sk
 	inet_hash(&dccp_hashinfo, sk);
 }
 
-static void dccp_v4_unhash(struct sock *sk)
+void dccp_unhash(struct sock *sk)
 {
 	inet_unhash(&dccp_hashinfo, sk);
 }
 
+EXPORT_SYMBOL_GPL(dccp_unhash);
+
 /* called with local bh disabled */
 static int __dccp_v4_check_established(struct sock *sk, const __u16 lport,
 				      struct inet_timewait_sock **twp)
@@ -209,8 +211,7 @@ out:
 	}
 }
 
-static int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
-			   int addr_len)
+int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -288,16 +289,6 @@ static int dccp_v4_connect(struct sock *
 							    usin->sin_port);
 	dccp_update_gss(sk, dp->dccps_iss);
 
-	/*
-	 * SWL and AWL are initially adjusted so that they are not less than
-	 * the initial Sequence Numbers received and sent, respectively:
-	 *	SWL := max(GSR + 1 - floor(W/4), ISR),
-	 *	AWL := max(GSS - W' + 1, ISS).
-	 * These adjustments MUST be applied only at the beginning of the
-	 * connection.
-	 */
-	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
-
 	inet->id = dp->dccps_iss ^ jiffies;
 
 	err = dccp_connect(sk);
@@ -317,6 +308,8 @@ failure:
 	goto out;
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_connect);
+
 /*
  * This routine does path mtu discovery as defined in RFC1191.
  */
@@ -608,7 +601,7 @@ out:
 }
 
 /* This routine computes an IPv4 DCCP checksum. */
-static void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	struct dccp_hdr *dh = dccp_hdr(skb);
@@ -616,6 +609,8 @@ static void dccp_v4_send_check(struct so
 	dh->dccph_checksum = dccp_v4_checksum(skb, inet->saddr, inet->daddr);
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_send_check);
+
 int dccp_v4_send_reset(struct sock *sk, enum dccp_reset_codes code)
 {
 	struct sk_buff *skb;
@@ -651,16 +646,6 @@ static inline u64 dccp_v4_init_sequence(
 					   dccp_hdr(skb)->dccph_sport);
 }
 
-static inline int dccp_bad_service_code(const struct sock *sk,
-					const __u32 service)
-{
-	const struct dccp_sock *dp = dccp_sk(sk);
-
-	if (dp->dccps_service == service)
-		return 0;
-	return !dccp_list_has_service(dp->dccps_service_list, service);
-}
-
 int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq;
@@ -672,7 +657,6 @@ int dccp_v4_conn_request(struct sock *sk
  	const __u32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
-	struct dst_entry *dst = NULL;
 
 	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
 	if (((struct rtable *)skb->dst)->rt_flags &
@@ -713,7 +697,6 @@ int dccp_v4_conn_request(struct sock *sk
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
-	/* FIXME: Merge Aristeu's option parsing code when ready */
 	req->rcv_wnd	= 100; /* Fake, option parsing will get the
 				  right value */
 	ireq->opt	= NULL;
@@ -731,7 +714,7 @@ int dccp_v4_conn_request(struct sock *sk
 	dreq->dreq_iss	   = dccp_v4_init_sequence(sk, skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v4_send_response(sk, req, dst))
+	if (dccp_v4_send_response(sk, req, NULL))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
@@ -748,6 +731,8 @@ drop:
 	return -1;
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
+
 /*
  * The three way handshake has completed - we got a valid ACK or DATAACK -
  * now create the new socket.
@@ -802,6 +787,8 @@ exit:
 	return NULL;
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_request_recv_sock);
+
 static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
@@ -1021,7 +1008,9 @@ discard:
 	return 0;
 }
 
-static inline int dccp_invalid_packet(struct sk_buff *skb)
+EXPORT_SYMBOL_GPL(dccp_v4_do_rcv);
+
+int dccp_invalid_packet(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
 
@@ -1075,17 +1064,11 @@ static inline int dccp_invalid_packet(st
 		return 1;
 	}
 
-	/* If the header checksum is incorrect, drop packet and return */
-	if (dccp_v4_verify_checksum(skb, skb->nh.iph->saddr,
-				    skb->nh.iph->daddr) < 0) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: header checksum is "
-					    "incorrect\n");
-		return 1;
-	}
-
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(dccp_invalid_packet);
+
 /* this is called when real data arrives */
 int dccp_v4_rcv(struct sk_buff *skb)
 {
@@ -1098,6 +1081,14 @@ int dccp_v4_rcv(struct sk_buff *skb)
 	if (dccp_invalid_packet(skb))
 		goto discard_it;
 
+	/* If the header checksum is incorrect, drop packet and return */
+	if (dccp_v4_verify_checksum(skb, skb->nh.iph->saddr,
+				    skb->nh.iph->daddr) < 0) {
+		LIMIT_NETDEBUG(KERN_WARNING "%s: incorrect header checksum\n",
+			       __FUNCTION__);
+		goto discard_it;
+	}
+
 	dh = dccp_hdr(skb);
 
 	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(skb);
@@ -1217,7 +1208,7 @@ struct inet_connection_sock_af_ops dccp_
 	.sockaddr_len	= sizeof(struct sockaddr_in),
 };
 
-static int dccp_v4_init_sock(struct sock *sk)
+int dccp_v4_init_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	static int dccp_ctl_socket_init = 1;
@@ -1270,7 +1261,9 @@ static int dccp_v4_init_sock(struct sock
 	return 0;
 }
 
-static int dccp_v4_destroy_sock(struct sock *sk)
+EXPORT_SYMBOL_GPL(dccp_v4_init_sock);
+
+int dccp_v4_destroy_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
@@ -1303,6 +1296,8 @@ static int dccp_v4_destroy_sock(struct s
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_destroy_sock);
+
 static void dccp_v4_reqsk_destructor(struct request_sock *req)
 {
 	kfree(inet_rsk(req)->opt);
@@ -1331,7 +1326,7 @@ struct proto dccp_prot = {
 	.recvmsg		= dccp_recvmsg,
 	.backlog_rcv		= dccp_v4_do_rcv,
 	.hash			= dccp_v4_hash,
-	.unhash			= dccp_v4_unhash,
+	.unhash			= dccp_unhash,
 	.accept			= inet_csk_accept,
 	.get_port		= dccp_v4_get_port,
 	.shutdown		= dccp_shutdown,
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index c7ff80c..5c767b5 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -40,6 +40,8 @@ struct inet_timewait_death_row dccp_deat
 					    (unsigned long)&dccp_death_row),
 };
 
+EXPORT_SYMBOL_GPL(dccp_death_row);
+
 void dccp_time_wait(struct sock *sk, int state, int timeo)
 {
 	struct inet_timewait_sock *tw = NULL;
@@ -170,6 +172,8 @@ out_free:
 	return newsk;
 }
 
+EXPORT_SYMBOL_GPL(dccp_create_openreq_child);
+
 /* 
  * Process an incoming packet for RESPOND sockets represented
  * as an request_sock.
@@ -236,6 +240,8 @@ drop:
 	goto out;
 }
 
+EXPORT_SYMBOL_GPL(dccp_check_req);
+
 /*
  *  Queue segment on the new socket if the new socket is active,
  *  otherwise we just shortcircuit this and continue with
@@ -266,3 +272,5 @@ int dccp_child_process(struct sock *pare
 	sock_put(child);
 	return ret;
 }
+
+EXPORT_SYMBOL_GPL(dccp_child_process);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index f358805..c40f7f8 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -135,12 +135,6 @@ static int dccp_transmit_skb(struct sock
 unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	/*
-	 * FIXME: we really should be using the af_specific thing to support
-	 * 	  IPv6.
-	 * mss_now = pmtu - tp->af_specific->net_header_len -
-	 * 	     sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext);
-	 */
 	int mss_now = (pmtu - inet_csk(sk)->icsk_af_ops->net_header_len -
 		       sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext));
 
@@ -164,6 +158,8 @@ unsigned int dccp_sync_mss(struct sock *
 	return mss_now;
 }
 
+EXPORT_SYMBOL_GPL(dccp_sync_mss);
+
 void dccp_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
@@ -319,6 +315,8 @@ struct sk_buff *dccp_make_response(struc
 	return skb;
 }
 
+EXPORT_SYMBOL_GPL(dccp_make_response);
+
 struct sk_buff *dccp_make_reset(struct sock *sk, struct dst_entry *dst,
 				const enum dccp_reset_codes code)
 				   
@@ -375,6 +373,7 @@ struct sk_buff *dccp_make_reset(struct s
  */
 static inline void dccp_connect_init(struct sock *sk)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
@@ -383,10 +382,16 @@ static inline void dccp_connect_init(str
 	
 	dccp_sync_mss(sk, dst_mtu(dst));
 
-	/*
-	 * FIXME: set dp->{dccps_swh,dccps_swl}, with
-	 * something like dccp_inc_seq
-	 */
+	dccp_update_gss(sk, dp->dccps_iss);
+ 	/*
+	 * SWL and AWL are initially adjusted so that they are not less than
+	 * the initial Sequence Numbers received and sent, respectively:
+	 *	SWL := max(GSR + 1 - floor(W/4), ISR),
+	 *	AWL := max(GSS - W' + 1, ISS).
+	 * These adjustments MUST be applied only at the beginning of the
+	 * connection.
+ 	 */
+	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
 
 	icsk->icsk_retransmits = 0;
 }
@@ -418,6 +423,8 @@ int dccp_connect(struct sock *sk)
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(dccp_connect);
+
 void dccp_send_ack(struct sock *sk)
 {
 	/* If we have been reset, we may not send again. */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 9cb2989..51dfacd 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -41,8 +41,12 @@
 
 DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
+EXPORT_SYMBOL_GPL(dccp_statistics);
+
 atomic_t dccp_orphan_count = ATOMIC_INIT(0);
 
+EXPORT_SYMBOL_GPL(dccp_orphan_count);
+
 static struct net_protocol dccp_protocol = {
 	.handler	= dccp_v4_rcv,
 	.err_handler	= dccp_v4_err,
@@ -149,6 +153,8 @@ int dccp_disconnect(struct sock *sk, int
 	return err;
 }
 
+EXPORT_SYMBOL_GPL(dccp_disconnect);
+
 /*
  *	Wait for a DCCP event.
  *
@@ -156,8 +162,8 @@ int dccp_disconnect(struct sock *sk, int
  *	take care of normal races (between the test and the event) and we don't
  *	go look at any of the socket buffers directly.
  */
-static unsigned int dccp_poll(struct file *file, struct socket *sock,
-			      poll_table *wait)
+unsigned int dccp_poll(struct file *file, struct socket *sock,
+		       poll_table *wait)
 {
 	unsigned int mask;
 	struct sock *sk = sock->sk;
@@ -205,12 +211,16 @@ static unsigned int dccp_poll(struct fil
 	return mask;
 }
 
+EXPORT_SYMBOL_GPL(dccp_poll);
+
 int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	dccp_pr_debug("entry\n");
 	return -ENOIOCTLCMD;
 }
 
+EXPORT_SYMBOL_GPL(dccp_ioctl);
+
 static int dccp_setsockopt_service(struct sock *sk, const u32 service,
 				   char __user *optval, int optlen)
 {
@@ -284,6 +294,8 @@ int dccp_setsockopt(struct sock *sk, int
 	return err;
 }
 
+EXPORT_SYMBOL_GPL(dccp_setsockopt);
+
 static int dccp_getsockopt_service(struct sock *sk, int len,
 				   u32 __user *optval,
 				   int __user *optlen)
@@ -357,6 +369,8 @@ int dccp_getsockopt(struct sock *sk, int
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(dccp_getsockopt);
+
 int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 size_t len)
 {
@@ -413,6 +427,8 @@ out_discard:
 	goto out_release;
 }
 
+EXPORT_SYMBOL_GPL(dccp_sendmsg);
+
 int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 size_t len, int nonblock, int flags, int *addr_len)
 {
@@ -510,7 +526,9 @@ out:
 	return len;
 }
 
-static int inet_dccp_listen(struct socket *sock, int backlog)
+EXPORT_SYMBOL_GPL(dccp_recvmsg);
+
+int inet_dccp_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
 	unsigned char old_state;
@@ -546,6 +564,8 @@ out:
 	return err;
 }
 
+EXPORT_SYMBOL_GPL(inet_dccp_listen);
+
 static const unsigned char dccp_new_state[] = {
 	/* current state:   new state:      action:	*/
 	[0]		  = DCCP_CLOSED,
@@ -651,11 +671,15 @@ adjudge_to_death:
 	sock_put(sk);
 }
 
+EXPORT_SYMBOL_GPL(dccp_close);
+
 void dccp_shutdown(struct sock *sk, int how)
 {
 	dccp_pr_debug("entry\n");
 }
 
+EXPORT_SYMBOL_GPL(dccp_shutdown);
+
 static struct proto_ops inet_dccp_ops = {
 	.family		= PF_INET,
 	.owner		= THIS_MODULE,
@@ -763,6 +787,8 @@ MODULE_PARM_DESC(thash_entries, "Number 
 int dccp_debug;
 module_param(dccp_debug, int, 0444);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
+
+EXPORT_SYMBOL_GPL(dccp_debug);
 #endif
 
 static int __init dccp_init(void)

------=_Part_22619_8759956.1134242949310--
