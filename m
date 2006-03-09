From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:09 +0000
Subject: [PATCH 2/5] [DCCP]: Use sk->sk_prot->max_header consistently for non-data packets
Message-Id: <1141873689179-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Using this also provides opportunities for introducing inet_csk_alloc_skb that
would call alloc_skb, account it to the sock and skb_reserve(max_header), but
I'll leave this for later, for now using sk_prot->max_header consistently is
enough.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c   |   11 ++++++-----
 net/dccp/ipv6.c   |   23 ++++++++---------------
 net/dccp/output.c |   29 ++++++++++++++---------------
 3 files changed, 28 insertions(+), 35 deletions(-)

cfe9553cf5e731460a695519d7f1c75bbd64e670
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7098f10..64b7f8b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -201,7 +201,7 @@ static void dccp_v4_ctl_send_ack(struct 
 {
 	int err;
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
-	const int dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
+	const u32 dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
 				     sizeof(struct dccp_hdr_ext) +
 				     sizeof(struct dccp_hdr_ack_bits);
 	struct sk_buff *skb;
@@ -209,12 +209,12 @@ static void dccp_v4_ctl_send_ack(struct 
 	if (((struct rtable *)rxskb->dst)->rt_type != RTN_LOCAL)
 		return;
 
-	skb = alloc_skb(MAX_DCCP_HEADER + 15, GFP_ATOMIC);
+	skb = alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header, GFP_ATOMIC);
 	if (skb = NULL)
 		return;
 
 	/* Reserve space for headers. */
-	skb_reserve(skb, MAX_DCCP_HEADER);
+	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
 
 	skb->dst = dst_clone(rxskb->dst);
 
@@ -715,12 +715,13 @@ static void dccp_v4_ctl_send_reset(struc
 	if (dst = NULL)
 		return;
 
-	skb = alloc_skb(MAX_DCCP_HEADER + 15, GFP_ATOMIC);
+	skb = alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header,
+			GFP_ATOMIC);
 	if (skb = NULL)
 		goto out;
 
 	/* Reserve space for headers. */
-	skb_reserve(skb, MAX_DCCP_HEADER);
+	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
 	skb->dst = dst_clone(dst);
 
 	skb->h.raw = skb_push(skb, dccp_hdr_reset_len);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index f28f38f..0f328c7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -514,7 +514,7 @@ static void dccp_v6_send_check(struct so
 static void dccp_v6_ctl_send_reset(struct sk_buff *rxskb)
 {
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
-	const int dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
+	const u32 dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
 				       sizeof(struct dccp_hdr_ext) +
 				       sizeof(struct dccp_hdr_reset);
 	struct sk_buff *skb;
@@ -527,18 +527,12 @@ static void dccp_v6_ctl_send_reset(struc
 	if (!ipv6_unicast_destination(rxskb))
 		return;
 
-	/*
-	 * We need to grab some memory, and put together an RST,
-	 * and then put it into the queue to be sent.
-	 */
-
-	skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) +
-			dccp_hdr_reset_len, GFP_ATOMIC);
+	skb = alloc_skb(dccp_v6_ctl_socket->sk->sk_prot->max_header,
+			GFP_ATOMIC);
 	if (skb = NULL)
 	  	return;
 
-	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr) +
-		    dccp_hdr_reset_len);
+	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
 
 	skb->h.raw = skb_push(skb, dccp_hdr_reset_len);
 	dh = dccp_hdr(skb);
@@ -590,18 +584,17 @@ static void dccp_v6_ctl_send_ack(struct 
 {
 	struct flowi fl;
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
-	const int dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
+	const u32 dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
 				     sizeof(struct dccp_hdr_ext) +
 				     sizeof(struct dccp_hdr_ack_bits);
 	struct sk_buff *skb;
 
-	skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) +
-			dccp_hdr_ack_len, GFP_ATOMIC);
+	skb = alloc_skb(dccp_v6_ctl_socket->sk->sk_prot->max_header,
+			GFP_ATOMIC);
 	if (skb = NULL)
 		return;
 
-	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr) +
-			 dccp_hdr_ack_len);
+	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
 
 	skb->h.raw = skb_push(skb, dccp_hdr_ack_len);
 	dh = dccp_hdr(skb);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 6f3a5f0..2975e3d 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -49,7 +49,7 @@ static int dccp_transmit_skb(struct sock
 		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 		struct dccp_hdr *dh;
 		/* XXX For now we're using only 48 bits sequence numbers */
-		const int dccp_header_size = sizeof(*dh) +
+		const u32 dccp_header_size = sizeof(*dh) +
 					     sizeof(struct dccp_hdr_ext) +
 					  dccp_packet_hdr_len(dcb->dccpd_type);
 		int err, set_ack = 1;
@@ -279,17 +279,16 @@ struct sk_buff *dccp_make_response(struc
 {
 	struct dccp_hdr *dh;
 	struct dccp_request_sock *dreq;
-	const int dccp_header_size = sizeof(struct dccp_hdr) +
+	const u32 dccp_header_size = sizeof(struct dccp_hdr) +
 				     sizeof(struct dccp_hdr_ext) +
 				     sizeof(struct dccp_hdr_response);
-	struct sk_buff *skb = sock_wmalloc(sk, MAX_HEADER + DCCP_MAX_OPT_LEN +
-					       dccp_header_size, 1,
+	struct sk_buff *skb = sock_wmalloc(sk, sk->sk_prot->max_header, 1,
 					   GFP_ATOMIC);
 	if (skb = NULL)
 		return NULL;
 
 	/* Reserve space for headers. */
-	skb_reserve(skb, MAX_HEADER + DCCP_MAX_OPT_LEN + dccp_header_size);
+	skb_reserve(skb, sk->sk_prot->max_header);
 
 	skb->dst = dst_clone(dst);
 	skb->csum = 0;
@@ -326,17 +325,16 @@ static struct sk_buff *dccp_make_reset(s
 {
 	struct dccp_hdr *dh;
 	struct dccp_sock *dp = dccp_sk(sk);
-	const int dccp_header_size = sizeof(struct dccp_hdr) +
+	const u32 dccp_header_size = sizeof(struct dccp_hdr) +
 				     sizeof(struct dccp_hdr_ext) +
 				     sizeof(struct dccp_hdr_reset);
-	struct sk_buff *skb = sock_wmalloc(sk, MAX_HEADER + DCCP_MAX_OPT_LEN +
-					       dccp_header_size, 1,
+	struct sk_buff *skb = sock_wmalloc(sk, sk->sk_prot->max_header, 1,
 					   GFP_ATOMIC);
 	if (skb = NULL)
 		return NULL;
 
 	/* Reserve space for headers. */
-	skb_reserve(skb, MAX_HEADER + DCCP_MAX_OPT_LEN + dccp_header_size);
+	skb_reserve(skb, sk->sk_prot->max_header);
 
 	skb->dst = dst_clone(dst);
 	skb->csum = 0;
@@ -426,12 +424,12 @@ int dccp_connect(struct sock *sk)
 
 	dccp_connect_init(sk);
 
-	skb = alloc_skb(MAX_DCCP_HEADER + 15, sk->sk_allocation);
+	skb = alloc_skb(sk->sk_prot->max_header, sk->sk_allocation);
 	if (unlikely(skb = NULL))
 		return -ENOBUFS;
 
 	/* Reserve space for headers. */
-	skb_reserve(skb, MAX_DCCP_HEADER);
+	skb_reserve(skb, sk->sk_prot->max_header);
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 	skb->csum = 0;
@@ -452,7 +450,8 @@ void dccp_send_ack(struct sock *sk)
 {
 	/* If we have been reset, we may not send again. */
 	if (sk->sk_state != DCCP_CLOSED) {
-		struct sk_buff *skb = alloc_skb(MAX_DCCP_HEADER, GFP_ATOMIC);
+		struct sk_buff *skb = alloc_skb(sk->sk_prot->max_header,
+						GFP_ATOMIC);
 
 		if (skb = NULL) {
 			inet_csk_schedule_ack(sk);
@@ -464,7 +463,7 @@ void dccp_send_ack(struct sock *sk)
 		}
 
 		/* Reserve space for headers */
-		skb_reserve(skb, MAX_DCCP_HEADER);
+		skb_reserve(skb, sk->sk_prot->max_header);
 		skb->csum = 0;
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK;
 		dccp_transmit_skb(sk, skb);
@@ -511,14 +510,14 @@ void dccp_send_sync(struct sock *sk, con
 	 * dccp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	struct sk_buff *skb = alloc_skb(MAX_DCCP_HEADER, GFP_ATOMIC);
+	struct sk_buff *skb = alloc_skb(sk->sk_prot->max_header, GFP_ATOMIC);
 
 	if (skb = NULL)
 		/* FIXME: how to make sure the sync is sent? */
 		return;
 
 	/* Reserve space for headers and prepare control bits. */
-	skb_reserve(skb, MAX_DCCP_HEADER);
+	skb_reserve(skb, sk->sk_prot->max_header);
 	skb->csum = 0;
 	DCCP_SKB_CB(skb)->dccpd_type = pkt_type;
 	DCCP_SKB_CB(skb)->dccpd_seq = seq;
-- 
1.2.2.gd27d


