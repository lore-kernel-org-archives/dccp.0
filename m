From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 2/7] [DCCP]: Move dccp_v4_{init,destroy}_sock to the core
Message-Id: <11407327783176-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Removing one more ipv6 uses ipv4 stuff case in dccp land.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/dccp.h  |    4 +-
 net/dccp/ipv4.c  |  106 +++---------------------------------------------------
 net/dccp/ipv6.c  |    4 +-
 net/dccp/proto.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 112 insertions(+), 104 deletions(-)

8f62e07749b62f28242dc9fb7db5c0531d33401e
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index cd7c5d0..8f3903b 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -228,8 +228,8 @@ extern int dccp_rcv_state_process(struct
 extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				const struct dccp_hdr *dh, const unsigned len);
 
-extern int dccp_v4_init_sock(struct sock *sk);
-extern int dccp_v4_destroy_sock(struct sock *sk);
+extern int dccp_init_sock(struct sock *sk);
+extern int dccp_destroy_sock(struct sock *sk);
 
 extern void		dccp_close(struct sock *sk, long timeout);
 extern struct sk_buff	*dccp_make_response(struct sock *sk,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 766b619..b26a4f8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1008,109 +1008,15 @@ struct inet_connection_sock_af_ops dccp_
 	.sockaddr_len	= sizeof(struct sockaddr_in),
 };
 
-int dccp_v4_init_sock(struct sock *sk)
+static int dccp_v4_init_sock(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	static int dccp_ctl_socket_init = 1;
-
-	dccp_options_init(&dp->dccps_options);
-	do_gettimeofday(&dp->dccps_epoch);
-
-	/*
-	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
-	 * the listening (master) sock get CCID control blocks, which is not
-	 * necessary, but for now, to not mess with the test userspace apps,
-	 * lets leave it here, later the real solution is to do this in a
-	 * setsockopt(CCIDs-I-want/accept). -acme
-	 */
-	if (likely(!dccp_ctl_socket_init)) {
-		int rc = dccp_feat_init(sk);
-
-		if (rc)
-			return rc;
-
-		if (dp->dccps_options.dccpo_send_ack_vector) {
-			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
-			if (dp->dccps_hc_rx_ackvec = NULL)
-				return -ENOMEM;
-		}
-		dp->dccps_hc_rx_ccid -				ccid_hc_rx_new(dp->dccps_options.dccpo_rx_ccid,
-					       sk, GFP_KERNEL);
-		dp->dccps_hc_tx_ccid -				ccid_hc_tx_new(dp->dccps_options.dccpo_tx_ccid,
-					       sk, GFP_KERNEL);
-	    	if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
-			     dp->dccps_hc_tx_ccid = NULL)) {
-			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-			if (dp->dccps_options.dccpo_send_ack_vector) {
-				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
-				dp->dccps_hc_rx_ackvec = NULL;
-			}
-			dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
-			return -ENOMEM;
-		}
-	} else {
-		/* control socket doesn't need feat nego */
-		INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
-		INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
-		dccp_ctl_socket_init = 0;
-	}	
-
-	dccp_init_xmit_timers(sk);
-	icsk->icsk_rto = DCCP_TIMEOUT_INIT;
-	sk->sk_state = DCCP_CLOSED;
-	sk->sk_write_space = dccp_write_space;
-	icsk->icsk_af_ops = &dccp_ipv4_af_ops;
-	icsk->icsk_sync_mss = dccp_sync_mss;
-	dp->dccps_mss_cache = 536;
-	dp->dccps_role = DCCP_ROLE_UNDEFINED;
-	dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
-	dp->dccps_l_ack_ratio = dp->dccps_r_ack_ratio = 1;
+	const int err = dccp_init_sock(sk);
 
-	return 0;
+	if (err = 0)
+		inet_csk(sk)->icsk_af_ops = &dccp_ipv4_af_ops;
+	return err;
 }
 
-EXPORT_SYMBOL_GPL(dccp_v4_init_sock);
-
-int dccp_v4_destroy_sock(struct sock *sk)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	/*
-	 * DCCP doesn't use sk_write_queue, just sk_send_head
-	 * for retransmissions
-	 */
-	if (sk->sk_send_head != NULL) {
-		kfree_skb(sk->sk_send_head);
-		sk->sk_send_head = NULL;
-	}
-
-	/* Clean up a referenced DCCP bind bucket. */
-	if (inet_csk(sk)->icsk_bind_hash != NULL)
-		inet_put_port(&dccp_hashinfo, sk);
-
-	kfree(dp->dccps_service_list);
-	dp->dccps_service_list = NULL;
-
-	if (dp->dccps_options.dccpo_send_ack_vector) {
-		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
-		dp->dccps_hc_rx_ackvec = NULL;
-	}
-	ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-	ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
-
-	/* clean up feature negotiation state */
-	dccp_feat_clean(sk);
-
-	return 0;
-}
-
-EXPORT_SYMBOL_GPL(dccp_v4_destroy_sock);
-
 static void dccp_v4_reqsk_destructor(struct request_sock *req)
 {
 	kfree(inet_rsk(req)->opt);
@@ -1147,7 +1053,7 @@ struct proto dccp_prot = {
 	.accept			= inet_csk_accept,
 	.get_port		= dccp_v4_get_port,
 	.shutdown		= dccp_shutdown,
-	.destroy		= dccp_v4_destroy_sock,
+	.destroy		= dccp_destroy_sock,
 	.orphan_count		= &dccp_orphan_count,
 	.max_header		= MAX_DCCP_HEADER,
 	.obj_size		= sizeof(struct dccp_sock),
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index ad5a1c6..84651bc 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1146,7 +1146,7 @@ static struct inet_connection_sock_af_op
  */
 static int dccp_v6_init_sock(struct sock *sk)
 {
-	int err = dccp_v4_init_sock(sk);
+	int err = dccp_init_sock(sk);
 
 	if (err = 0)
 		inet_csk(sk)->icsk_af_ops = &dccp_ipv6_af_ops;
@@ -1156,7 +1156,7 @@ static int dccp_v6_init_sock(struct sock
 
 static int dccp_v6_destroy_sock(struct sock *sk)
 {
-	dccp_v4_destroy_sock(sk);
+	dccp_destroy_sock(sk);
 	return inet6_destroy_sock(sk);
 }
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 04315c3..1f5c92d 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -97,6 +97,108 @@ const char *dccp_state_name(const int st
 
 EXPORT_SYMBOL_GPL(dccp_state_name);
 
+int dccp_init_sock(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	static int dccp_ctl_socket_init = 1;
+
+	dccp_options_init(&dp->dccps_options);
+	do_gettimeofday(&dp->dccps_epoch);
+
+	/*
+	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
+	 * the listening (master) sock get CCID control blocks, which is not
+	 * necessary, but for now, to not mess with the test userspace apps,
+	 * lets leave it here, later the real solution is to do this in a
+	 * setsockopt(CCIDs-I-want/accept). -acme
+	 */
+	if (likely(!dccp_ctl_socket_init)) {
+		int rc = dccp_feat_init(sk);
+
+		if (rc)
+			return rc;
+
+		if (dp->dccps_options.dccpo_send_ack_vector) {
+			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
+			if (dp->dccps_hc_rx_ackvec = NULL)
+				return -ENOMEM;
+		}
+		dp->dccps_hc_rx_ccid +				ccid_hc_rx_new(dp->dccps_options.dccpo_rx_ccid,
+					       sk, GFP_KERNEL);
+		dp->dccps_hc_tx_ccid +				ccid_hc_tx_new(dp->dccps_options.dccpo_tx_ccid,
+					       sk, GFP_KERNEL);
+	    	if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
+			     dp->dccps_hc_tx_ccid = NULL)) {
+			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
+			if (dp->dccps_options.dccpo_send_ack_vector) {
+				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
+				dp->dccps_hc_rx_ackvec = NULL;
+			}
+			dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
+			return -ENOMEM;
+		}
+	} else {
+		/* control socket doesn't need feat nego */
+		INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
+		INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
+		dccp_ctl_socket_init = 0;
+	}	
+
+	dccp_init_xmit_timers(sk);
+	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
+	sk->sk_state		= DCCP_CLOSED;
+	sk->sk_write_space	= dccp_write_space;
+	icsk->icsk_sync_mss	= dccp_sync_mss;
+	dp->dccps_mss_cache	= 536;
+	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
+	dp->dccps_service	= DCCP_SERVICE_INVALID_VALUE;
+	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(dccp_init_sock);
+
+int dccp_destroy_sock(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	/*
+	 * DCCP doesn't use sk_write_queue, just sk_send_head
+	 * for retransmissions
+	 */
+	if (sk->sk_send_head != NULL) {
+		kfree_skb(sk->sk_send_head);
+		sk->sk_send_head = NULL;
+	}
+
+	/* Clean up a referenced DCCP bind bucket. */
+	if (inet_csk(sk)->icsk_bind_hash != NULL)
+		inet_put_port(&dccp_hashinfo, sk);
+
+	kfree(dp->dccps_service_list);
+	dp->dccps_service_list = NULL;
+
+	if (dp->dccps_options.dccpo_send_ack_vector) {
+		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
+		dp->dccps_hc_rx_ackvec = NULL;
+	}
+	ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+	ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
+	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
+
+	/* clean up feature negotiation state */
+	dccp_feat_clean(sk);
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(dccp_destroy_sock);
+
 static inline int dccp_listen_start(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-- 
1.2.2.gd27d


