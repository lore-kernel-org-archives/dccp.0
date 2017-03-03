From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Mar 2017 16:00:14 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <1488556814.9415.334.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 2017-03-03 at 07:22 -0800, Eric Dumazet wrote:
> On Fri, Mar 3, 2017 at 7:12 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > The first bot that picked this up started spewing:
> >
> > BUG: spinlock recursion on CPU#1, syz-executor2/9452
> 
> Yes. The bug is not about locking the listener, but protecting fields
> of struct dccp_request_sock
> 
> I will provide a patch, once I reach the office and after the breakfast ;)

OK here is what I suggest to fix the races.

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 61d042bbbf607253033d9948b291cab2322814ba..68449293c4b6233c1a1d4133b1819376a9310225 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -163,6 +163,7 @@ struct dccp_request_sock {
 	__u64			 dreq_isr;
 	__u64			 dreq_gsr;
 	__be32			 dreq_service;
+	spinlock_t		 dreq_lock;
 	struct list_head	 dreq_featneg;
 	__u32			 dreq_timestamp_echo;
 	__u32			 dreq_timestamp_time;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index e267e6f4c9a5566b369a03a600a408e5bd41cbad..abd07a443219853b022bef41cb072e90ff8f07f0 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -142,6 +142,13 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 	bool own_req;
 
+	/* TCP/DCCP listeners became lockless.
+	 * DCCP stores complex state in its request_sock, so we need
+	 * a protection for them, now this code runs without being protected
+	 * by the parent (listener) lock.
+	 */
+	spin_lock_bh(&dreq->dreq_lock);
+
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type = DCCP_PKT_REQUEST) {
 
@@ -156,7 +163,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			inet_rtx_syn_ack(sk, req);
 		}
 		/* Network Duplicate, discard packet */
-		return NULL;
+		goto out;
 	}
 
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_PACKET_ERROR;
@@ -182,20 +189,20 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL,
 							 req, &own_req);
-	if (!child)
-		goto listen_overflow;
-
-	return inet_csk_complete_hashdance(sk, child, req, own_req);
+	if (child) {
+		child = inet_csk_complete_hashdance(sk, child, req, own_req);
+		goto out;
+	}
 
-listen_overflow:
-	dccp_pr_debug("listen_overflow!\n");
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_TOO_BUSY;
 drop:
 	if (dccp_hdr(skb)->dccph_type != DCCP_PKT_RESET)
 		req->rsk_ops->send_reset(sk, skb);
 
 	inet_csk_reqsk_queue_drop(sk, req);
-	return NULL;
+out:
+	spin_unlock_bh(&dreq->dreq_lock);
+	return child;
 }
 
 EXPORT_SYMBOL_GPL(dccp_check_req);
@@ -246,6 +253,7 @@ int dccp_reqsk_init(struct request_sock *req,
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
+	spin_lock_init(&dreq->dreq_lock);
 	inet_rsk(req)->ir_rmt_port = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->ir_num	   = ntohs(dccp_hdr(skb)->dccph_dport);
 	inet_rsk(req)->acked	   = 0;


