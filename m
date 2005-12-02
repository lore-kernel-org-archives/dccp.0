From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 02 Dec 2005 01:13:12 +0000
Subject: [PATCH 6/6][DCCP]: Introduce dccp_ipv4_af_ops
Message-Id: <39e6f6c70512011713h5ea5a5acga42e50d9a8fe8175@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37586_15011503.1133485992732"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37586_15011503.1133485992732
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

     Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_37586_15011503.1133485992732
Content-Type: text/x-patch; name=6.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="6.patch"

tree 123eb3b4b48c74759e83249eebf9d5e0897ade9c
parent c31a8d1bb087e6f7b231f00dc611bd505d96d9c6
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1133484923 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1133484923 -0200

[DCCP]: Introduce dccp_ipv4_af_ops

And make the core DCCP code AF agnostic, just like TCP, now its time to work
on net/dccp/ipv6.c, we are close to the end!

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 input.c     |    5 +++--
 ipv4.c      |   23 +++++++++++++++++++++++
 minisocks.c |    2 +-
 output.c    |   14 ++++++--------
 proto.c     |    9 ++++++---
 5 files changed, 39 insertions(+), 14 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 3454d59..c81488f 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -329,7 +329,7 @@ static int dccp_rcv_request_sent_state_p
 		dccp_set_state(sk, DCCP_PARTOPEN);
 
 		/* Make sure socket is routed, for correct metrics. */
-		inet_sk_rebuild_header(sk);
+		icsk->icsk_af_ops->rebuild_header(sk);
 
 		if (!sock_flag(sk, SOCK_DEAD)) {
 			sk->sk_state_change(sk);
@@ -444,7 +444,8 @@ int dccp_rcv_state_process(struct sock *
 	 */
 	if (sk->sk_state == DCCP_LISTEN) {
 		if (dh->dccph_type == DCCP_PKT_REQUEST) {
-			if (dccp_v4_conn_request(sk, skb) < 0)
+			if (inet_csk(sk)->icsk_af_ops->conn_request(sk,
+								    skb) < 0)
 				return 1;
 
 			/* FIXME: do congestion control initialization */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 6a9f5c7..da11758 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -607,6 +607,15 @@ out:
 	sock_put(sk);
 }
 
+/* This routine computes an IPv4 DCCP checksum. */
+static void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	struct dccp_hdr *dh = dccp_hdr(skb);
+
+	dh->dccph_checksum = dccp_v4_checksum(skb, inet->saddr, inet->daddr);
+}
+
 int dccp_v4_send_reset(struct sock *sk, enum dccp_reset_codes code)
 {
 	struct sk_buff *skb;
@@ -1195,6 +1204,19 @@ do_time_wait:
 	goto no_dccp_socket;
 }
 
+struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
+	.queue_xmit	= ip_queue_xmit,
+	.send_check	= dccp_v4_send_check,
+	.rebuild_header	= inet_sk_rebuild_header,
+	.conn_request	= dccp_v4_conn_request,
+	.syn_recv_sock	= dccp_v4_request_recv_sock,
+	.net_header_len	= sizeof(struct iphdr),
+	.setsockopt	= ip_setsockopt,
+	.getsockopt	= ip_getsockopt,
+	.addr2sockaddr	= inet_csk_addr2sockaddr,
+	.sockaddr_len	= sizeof(struct sockaddr_in),
+};
+
 static int dccp_v4_init_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -1240,6 +1262,7 @@ static int dccp_v4_init_sock(struct sock
 	inet_csk(sk)->icsk_rto = DCCP_TIMEOUT_INIT;
 	sk->sk_state = DCCP_CLOSED;
 	sk->sk_write_space = dccp_write_space;
+	inet_csk(sk)->icsk_af_ops = &dccp_ipv4_af_ops;
 	dp->dccps_mss_cache = 536;
 	dp->dccps_role = DCCP_ROLE_UNDEFINED;
 	dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 1393461..c7ff80c 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -214,7 +214,7 @@ struct sock *dccp_check_req(struct sock 
 		goto drop;
 	}
 
-	child = dccp_v4_request_recv_sock(sk, skb, req, NULL);
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
 	if (child == NULL)
 		goto listen_overflow;
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 74ff870..f358805 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -43,6 +43,7 @@ static int dccp_transmit_skb(struct sock
 {
 	if (likely(skb != NULL)) {
 		const struct inet_sock *inet = inet_sk(sk);
+		const struct inet_connection_sock *icsk = inet_csk(sk);
 		struct dccp_sock *dp = dccp_sk(sk);
 		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 		struct dccp_hdr *dh;
@@ -108,8 +109,7 @@ static int dccp_transmit_skb(struct sock
 			break;
 		}
 
-		dh->dccph_checksum = dccp_v4_checksum(skb, inet->saddr,
-						      inet->daddr);
+		icsk->icsk_af_ops->send_check(sk, skb->len, skb);
 
 		if (set_ack)
 			dccp_event_ack_sent(sk);
@@ -117,7 +117,7 @@ static int dccp_transmit_skb(struct sock
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 
 		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-		err = ip_queue_xmit(skb, 0);
+		err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 		if (err <= 0)
 			return err;
 
@@ -135,16 +135,14 @@ static int dccp_transmit_skb(struct sock
 unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	int mss_now;
-
 	/*
 	 * FIXME: we really should be using the af_specific thing to support
 	 * 	  IPv6.
 	 * mss_now = pmtu - tp->af_specific->net_header_len -
 	 * 	     sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext);
 	 */
-	mss_now = pmtu - sizeof(struct iphdr) - sizeof(struct dccp_hdr) -
-		  sizeof(struct dccp_hdr_ext);
+	int mss_now = (pmtu - inet_csk(sk)->icsk_af_ops->net_header_len -
+		       sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext));
 
 	/* Now subtract optional transport overhead */
 	mss_now -= dp->dccps_ext_header_len;
@@ -266,7 +264,7 @@ int dccp_write_xmit(struct sock *sk, str
 
 int dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
-	if (inet_sk_rebuild_header(sk) != 0)
+	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk) != 0)
 		return -EHOSTUNREACH; /* Routing failure or similar. */
 
 	return dccp_transmit_skb(sk, (skb_cloned(skb) ?
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e0ace7c..f7f3511 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -253,7 +253,9 @@ int dccp_setsockopt(struct sock *sk, int
 	int val;
 
 	if (level != SOL_DCCP)
-		return ip_setsockopt(sk, level, optname, optval, optlen);
+		return inet_csk(sk)->icsk_af_ops->setsockopt(sk, level,
+							     optname, optval,
+							     optlen);
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -319,8 +321,9 @@ int dccp_getsockopt(struct sock *sk, int
 	int val, len;
 
 	if (level != SOL_DCCP)
-		return ip_getsockopt(sk, level, optname, optval, optlen);
-
+		return inet_csk(sk)->icsk_af_ops->getsockopt(sk, level,
+							     optname, optval,
+							     optlen);
 	if (get_user(len, optlen))
 		return -EFAULT;
 

------=_Part_37586_15011503.1133485992732--
