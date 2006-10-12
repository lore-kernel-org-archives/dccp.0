From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Oct 2006 11:02:13 +0000
Subject: Re: [Patch 3/3]: dccp: resolve putative recursive lock
Message-Id: <200610121202.13793@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610111627.06571@strip-the-willow>
In-Reply-To: <200610111627.06571@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Please do not use the previous version. An updated
version is below: in the previous posting, a statement
(skb->dev = NULL) was missing. 

I have decided not to use an inlined function, since 
 * the code is applicable only to the special case where
   a child socket is created while the lock is held on the
   parent, i.e. single-level locking. 
 * this means that the use of enums as pointed out earlier
   by Ingo Molnar does not seem necessary
 * this case and its conditions are special and are intended
   to aid the useful locking validator do its job better
   
This patch also adds some minor formatting changes which 
simplify the code and align the v4/v6 counterparts.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---

 ipv4.c |   42 ++++++++++++++++++++++++++----------------
 ipv6.c |   51 +++++++++++++++++++++++++++++++++------------------
 2 files changed, 59 insertions(+), 34 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7e746c4..6866496 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -881,6 +881,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -913,8 +914,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 		dccp_pr_debug_cat("\n");
 	} else {
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
-		dccp_pr_debug_cat(", ack=%llu\n",
-				  (unsigned long long)
+		dccp_pr_debug_cat(", ack=%llu\n", (unsigned long long)
 				  DCCP_SKB_CB(skb)->dccpd_ack_seq);
 	}
 
@@ -943,18 +943,36 @@ static int dccp_v4_rcv(struct sk_buff *s
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	       
 	if (sk->sk_state = DCCP_TIME_WAIT) {
 		dccp_pr_debug("sk->sk_state = DCCP_TIME_WAIT: "
 			      "do_time_wait\n");
-                goto do_time_wait;
+		inet_twsk_put(inet_twsk(sk));
+		goto no_dccp_socket;
 	}
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	return sk_receive_skb(sk, skb);
+	if (sk_filter(sk, skb))
+		goto discard_and_relse;
+
+	skb->dev = NULL;
+
+	bh_lock_sock_nested(sk);    /* sk might be cloned later */
+	if (!sock_owned_by_user(sk)) {
+		/*
+		 * lock semantics stolen from sk_receive_skb
+		 */
+		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
+		ret = dccp_v4_do_rcv(sk, skb);
+		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
+	} else
+		sk_add_backlog(sk, skb);
+	bh_unlock_sock(sk);
+
+	sock_put(sk);
+	return ret? -1 : 0;
 
 no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
@@ -969,19 +987,11 @@ no_dccp_socket:
 					DCCP_RESET_CODE_NO_CONNECTION;
 		dccp_v4_ctl_send_reset(skb);
 	}
-
-discard_it:
-	/* Discard frame. */
-	kfree_skb(skb);
-	return 0;
-
 discard_and_relse:
 	sock_put(sk);
-	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
+discard_it:
+	kfree_skb(skb);
+	return ret;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7171a78..5450b85 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1037,6 +1037,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	const struct dccp_hdr *dh;
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -1065,8 +1066,11 @@ static int dccp_v6_rcv(struct sk_buff **
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	if (sk = NULL)
+	if (sk = NULL) {
+		dccp_pr_debug("failed to look up flow ID in table and "
+			      "get corresponding socket\n");
 		goto no_dccp_socket;
+	}
 
 	/*
 	 * Step 2:
@@ -1074,13 +1078,35 @@ static int dccp_v6_rcv(struct sk_buff **
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	if (sk->sk_state = DCCP_TIME_WAIT)
-		goto do_time_wait;
+	if (sk->sk_state = DCCP_TIME_WAIT) {
+		dccp_pr_debug("sk->sk_state = DCCP_TIME_WAIT: "
+			      "do_time_wait\n");
+		inet_twsk_put(inet_twsk(sk));
+		goto no_dccp_socket;
+	}
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	return sk_receive_skb(sk, skb) ? -1 : 0;
+	if (sk_filter(sk, skb))
+		goto discard_and_relse;
+
+	skb->dev = NULL;
+
+	bh_lock_sock_nested(sk);    /* sk might be cloned later */
+	if (!sock_owned_by_user(sk)) {
+		/*
+		 * lock semantics stolen from sk_receive_skb
+		 */
+		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
+		ret = dccp_v6_do_rcv(sk, skb);
+		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
+	} else
+		sk_add_backlog(sk, skb);
+	bh_unlock_sock(sk);
+
+	sock_put(sk);
+	return ret? -1 : 0;
 
 no_dccp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
@@ -1095,22 +1121,11 @@ no_dccp_socket:
 					DCCP_RESET_CODE_NO_CONNECTION;
 		dccp_v6_ctl_send_reset(skb);
 	}
-discard_it:
-
-	/*
-	 *	Discard frame
-	 */
-
-	kfree_skb(skb);
-	return 0;
-
 discard_and_relse:
 	sock_put(sk);
-	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
+discard_it:
+	kfree_skb(skb);
+	return ret;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
