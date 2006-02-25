From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sat, 25 Feb 2006 21:16:12 +0000
Subject: [PATCH 2/3] [DCCP]: Uninline some functions
Message-Id: <11409021723274-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ccids/ccid3.c |   10 +++++----
 net/dccp/dccp.h        |   49 ++-------------------------------------------
 net/dccp/input.c       |    7 +++---
 net/dccp/output.c      |    2 +-
 net/dccp/proto.c       |   52 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 63 insertions(+), 57 deletions(-)

c0658f19b2570dfe73979c22dd9030f89b6c2dfd
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c0d2ef7..47660ca 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -46,7 +46,7 @@
  * Reason for maths here is to avoid 32 bit overflow when a is big.
  * With this we get close to the limit.
  */
-static inline u32 usecs_div(const u32 a, const u32 b)
+static u32 usecs_div(const u32 a, const u32 b)
 {
 	const u32 div = a < (UINT_MAX / (USEC_PER_SEC /    10)) ?    10 :
 			a < (UINT_MAX / (USEC_PER_SEC /    50)) ?    50 :
@@ -98,8 +98,8 @@ static const char *ccid3_tx_state_name(e
 }
 #endif
 
-static inline void ccid3_hc_tx_set_state(struct sock *sk,
-					 enum ccid3_hc_tx_states state)
+static void ccid3_hc_tx_set_state(struct sock *sk,
+				  enum ccid3_hc_tx_states state)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	enum ccid3_hc_tx_states oldstate = hctx->ccid3hctx_state;
@@ -708,8 +708,8 @@ static const char *ccid3_rx_state_name(e
 }
 #endif
 
-static inline void ccid3_hc_rx_set_state(struct sock *sk,
-					 enum ccid3_hc_rx_states state)
+static void ccid3_hc_rx_set_state(struct sock *sk,
+				  enum ccid3_hc_rx_states state)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	enum ccid3_hc_rx_states oldstate = hcrx->ccid3hcrx_state;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 46aa481..6fcc9d4 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -138,53 +138,8 @@ extern unsigned int dccp_sync_mss(struct
 extern const char *dccp_packet_name(const int type);
 extern const char *dccp_state_name(const int state);
 
-static inline void dccp_set_state(struct sock *sk, const int state)
-{
-	const int oldstate = sk->sk_state;
-
-	dccp_pr_debug("%s(%p) %-10.10s -> %s\n",
-		      dccp_role(sk), sk,
-		      dccp_state_name(oldstate), dccp_state_name(state));
-	WARN_ON(state = oldstate);
-
-	switch (state) {
-	case DCCP_OPEN:
-		if (oldstate != DCCP_OPEN)
-			DCCP_INC_STATS(DCCP_MIB_CURRESTAB);
-		break;
-
-	case DCCP_CLOSED:
-		if (oldstate = DCCP_CLOSING || oldstate = DCCP_OPEN)
-			DCCP_INC_STATS(DCCP_MIB_ESTABRESETS);
-
-		sk->sk_prot->unhash(sk);
-		if (inet_csk(sk)->icsk_bind_hash != NULL &&
-		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
-			inet_put_port(&dccp_hashinfo, sk);
-		/* fall through */
-	default:
-		if (oldstate = DCCP_OPEN)
-			DCCP_DEC_STATS(DCCP_MIB_CURRESTAB);
-	}
-
-	/* Change state AFTER socket is unhashed to avoid closed
-	 * socket sitting in hash tables.
-	 */
-	sk->sk_state = state;
-}
-
-static inline void dccp_done(struct sock *sk)
-{
-	dccp_set_state(sk, DCCP_CLOSED);
-	dccp_clear_xmit_timers(sk);
-
-	sk->sk_shutdown = SHUTDOWN_MASK;
-
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_state_change(sk);
-	else
-		inet_csk_destroy_sock(sk);
-}
+extern void dccp_set_state(struct sock *sk, const int state);
+extern void dccp_done(struct sock *sk);
 
 static inline void dccp_openreq_init(struct request_sock *req,
 				     struct dccp_sock *dp,
diff --git a/net/dccp/input.c b/net/dccp/input.c
index eac5178..f53e3fc 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -56,7 +56,7 @@ static void dccp_rcv_closereq(struct soc
 	dccp_send_close(sk, 0);
 }
 
-static inline void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
+static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
@@ -151,9 +151,8 @@ static int dccp_check_seqno(struct sock 
 	return 0;
 }
 
-static inline int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-					 const struct dccp_hdr *dh,
-					 const unsigned len)
+static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
+				  const struct dccp_hdr *dh, const unsigned len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 8c83aa5..6f3a5f0 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -27,7 +27,7 @@ static inline void dccp_event_ack_sent(s
 	inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 }
 
-static inline void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
+static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	skb_set_owner_w(skb, sk);
 	WARN_ON(sk->sk_send_head);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d110cdb..c735433 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -53,6 +53,58 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+void dccp_set_state(struct sock *sk, const int state)
+{
+	const int oldstate = sk->sk_state;
+
+	dccp_pr_debug("%s(%p) %-10.10s -> %s\n",
+		      dccp_role(sk), sk,
+		      dccp_state_name(oldstate), dccp_state_name(state));
+	WARN_ON(state = oldstate);
+
+	switch (state) {
+	case DCCP_OPEN:
+		if (oldstate != DCCP_OPEN)
+			DCCP_INC_STATS(DCCP_MIB_CURRESTAB);
+		break;
+
+	case DCCP_CLOSED:
+		if (oldstate = DCCP_CLOSING || oldstate = DCCP_OPEN)
+			DCCP_INC_STATS(DCCP_MIB_ESTABRESETS);
+
+		sk->sk_prot->unhash(sk);
+		if (inet_csk(sk)->icsk_bind_hash != NULL &&
+		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
+			inet_put_port(&dccp_hashinfo, sk);
+		/* fall through */
+	default:
+		if (oldstate = DCCP_OPEN)
+			DCCP_DEC_STATS(DCCP_MIB_CURRESTAB);
+	}
+
+	/* Change state AFTER socket is unhashed to avoid closed
+	 * socket sitting in hash tables.
+	 */
+	sk->sk_state = state;
+}
+
+EXPORT_SYMBOL_GPL(dccp_set_state);
+
+void dccp_done(struct sock *sk)
+{
+	dccp_set_state(sk, DCCP_CLOSED);
+	dccp_clear_xmit_timers(sk);
+
+	sk->sk_shutdown = SHUTDOWN_MASK;
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_state_change(sk);
+	else
+		inet_csk_destroy_sock(sk);
+}
+
+EXPORT_SYMBOL_GPL(dccp_done);
+
 const char *dccp_packet_name(const int type)
 {
 	static const char *dccp_packet_names[] = {
-- 
1.2.2.gd27d


