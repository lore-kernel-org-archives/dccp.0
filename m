From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 1/7] [DCCP]: Generalize dccp_v4_send_reset
Message-Id: <11407327783950-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Renaming it to dccp_send_reset and moving it from the ipv4 specific code to the
core dccp code.

This fixes some bugs in IPV6 where timers would send v4 resets, etc.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/dccp.h   |    6 +-----
 net/dccp/input.c  |    2 +-
 net/dccp/ipv4.c   |   26 --------------------------
 net/dccp/output.c |   30 +++++++++++++++++++++++++-----
 net/dccp/timer.c  |    2 +-
 5 files changed, 28 insertions(+), 38 deletions(-)

f6d02dcee746dd116bcdf3902d40eeab21e3b517
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f059541..cd7c5d0 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -235,9 +235,6 @@ extern void		dccp_close(struct sock *sk,
 extern struct sk_buff	*dccp_make_response(struct sock *sk,
 					    struct dst_entry *dst,
 					    struct request_sock *req);
-extern struct sk_buff	*dccp_make_reset(struct sock *sk,
-					 struct dst_entry *dst,
-					 enum dccp_reset_codes code);
 
 extern int	   dccp_connect(struct sock *sk);
 extern int	   dccp_disconnect(struct sock *sk, int flags);
@@ -264,8 +261,7 @@ extern int	   dccp_v4_connect(struct soc
 extern int	   dccp_v4_checksum(const struct sk_buff *skb,
 				    const __be32 saddr, const __be32 daddr);
 
-extern int	   dccp_v4_send_reset(struct sock *sk,
-				      enum dccp_reset_codes code);
+extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
 
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 67691a0..eac5178 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -32,7 +32,7 @@ static void dccp_fin(struct sock *sk, st
 
 static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
-	dccp_v4_send_reset(sk, DCCP_RESET_CODE_CLOSED);
+	dccp_send_reset(sk, DCCP_RESET_CODE_CLOSED);
 	dccp_fin(sk, skb);
 	dccp_set_state(sk, DCCP_CLOSED);
 	sk_wake_async(sk, 1, POLL_HUP);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4a2ce1c..766b619 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -457,32 +457,6 @@ void dccp_v4_send_check(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
 
-int dccp_v4_send_reset(struct sock *sk, enum dccp_reset_codes code)
-{
-	struct sk_buff *skb;
-	/*
-	 * FIXME: what if rebuild_header fails?
-	 * Should we be doing a rebuild_header here?
-	 */
-	int err = inet_sk_rebuild_header(sk);
-
-	if (err != 0)
-		return err;
-
-	skb = dccp_make_reset(sk, sk->sk_dst_cache, code);
-	if (skb != NULL) {
-		const struct inet_sock *inet = inet_sk(sk);
-
-		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-		err = ip_build_and_send_pkt(skb, sk,
-					    inet->saddr, inet->daddr, NULL);
-		if (err = NET_XMIT_CN)
-			err = 0;
-	}
-
-	return err;
-}
-
 static inline u64 dccp_v4_init_sequence(const struct sock *sk,
 					const struct sk_buff *skb)
 {
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 0cc2bcf..9922d26 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -323,8 +323,8 @@ struct sk_buff *dccp_make_response(struc
 
 EXPORT_SYMBOL_GPL(dccp_make_response);
 
-struct sk_buff *dccp_make_reset(struct sock *sk, struct dst_entry *dst,
-				const enum dccp_reset_codes code)
+static struct sk_buff *dccp_make_reset(struct sock *sk, struct dst_entry *dst,
+				       const enum dccp_reset_codes code)
 				   
 {
 	struct dccp_hdr *dh;
@@ -366,14 +366,34 @@ struct sk_buff *dccp_make_reset(struct s
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dp->dccps_gsr);
 
 	dccp_hdr_reset(skb)->dccph_reset_code = code;
-
-	dh->dccph_checksum = dccp_v4_checksum(skb, inet_sk(sk)->saddr,
-					      inet_sk(sk)->daddr);
+	inet_csk(sk)->icsk_af_ops->send_check(sk, skb->len, skb);
 
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
 }
 
+int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
+{
+	/*
+	 * FIXME: what if rebuild_header fails?
+	 * Should we be doing a rebuild_header here?
+	 */
+	int err = inet_sk_rebuild_header(sk);
+
+	if (err = 0) {
+		struct sk_buff *skb = dccp_make_reset(sk, sk->sk_dst_cache,
+						      code);
+		if (skb != NULL) {
+			memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+			err = inet_csk(sk)->icsk_af_ops->queue_xmit(skb, 0);
+			if (err = NET_XMIT_CN)
+				err = 0;
+		}
+	}
+
+	return err;
+}
+
 /*
  * Do all connect socket setups that can be done AF independent.
  */
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index d7c7866..5244415 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -31,7 +31,7 @@ static void dccp_write_err(struct sock *
 	sk->sk_err = sk->sk_err_soft ? : ETIMEDOUT;
 	sk->sk_error_report(sk);
 
-	dccp_v4_send_reset(sk, DCCP_RESET_CODE_ABORTED);
+	dccp_send_reset(sk, DCCP_RESET_CODE_ABORTED);
 	dccp_done(sk);
 	DCCP_INC_STATS_BH(DCCP_MIB_ABORTONTIMEOUT);
 }
-- 
1.2.2.gd27d


