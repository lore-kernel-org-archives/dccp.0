From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Oct 2006 15:27:06 +0000
Subject: [Patch 3/3]: dccp: resolve putative recursive lock
Message-Id: <200610111627.06571@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a problem which was first pointed out on
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00354.html

The problem occurs when a listening DCCPv4/6 socket has sent a Response in
reply to a Request and happens at the time the ACK is received. 

The problem occurs since sk_receive_skb locks sk, then calls the AF-specific backlog
function (dccp_v{4,6}_do_rcv). This ends up calling dccp_v{4,6}_request_recv_sock, 
which calls dccp_create_openreq_child, from there to sk_clone via inet_sk_clone. 
In sk_clone, a lock is placed on newsk, which makes the lock mechanism think that 
the same lock was applied twice.

Call graph:
**********
    dccp_v4_rcv(skb)
        |
        sk_receive_skb(sk, skb)
          |
          bh_lock_sock(sk)
          rc = sk->backlog_rcv(sk, skb)
                    |
                    dccp_v4_do_rcv(sk, skb) /* state = LISTEN */
                      |
                      dccp_v4_hdn_req(sk, skb)
                       |
                       dccp_check_req(sk, skb, req, prev)
                        |
                        child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
                              |        /* syn_recv_sock translates to the following: */
                        child = dccp_v4_request_recv_sock(sk, skb, req, NULL);
                                |     /* contains the following code: */
                                newsk = dccp_create_openreq_child(sk, req, skb)
                                      |      /* calls: */
                                newsk = inet_csk_clone(sk, req, GFP_ATOMIC)
                                      |      /* in turn calls: */
                                newsk = sk_clone(sk, priority)      /* newsk != NULL */
                                         |   /* has this code segment */
                                         sk_node_init(&newsk->sk_node)
                                         sock_lock_init(newsk)
                                         bh_lock_sock(newsk)        /* <== putative recursive lock */
          /* ..... returns here ..... */
          bh_unlock_sock(sk)
     /* return of dccp_v4_skb(): sk is unlocked, whereas newsk is still locked  */

This patch fixes the problem by using relevant code from net/ipv?/tcp_ipv?.c, applied
with some thinking.

Effectively, the code of the short sk_receive_skb function is unfolded in-place
and the bh_nested_lock indicator is used instead of bh_lock.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 ipv4.c |   22 +++++++++++++++++++---
 ipv6.c |   27 ++++++++++++++++++++-------
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f87b0c0..f86ebcc 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -897,6 +897,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -970,7 +971,23 @@ static int dccp_v4_rcv(struct sk_buff *s
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	return sk_receive_skb(sk, skb);
+	if (sk_filter(sk, skb))
+		goto discard_and_relse;
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
+	return ret;
 
 no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
@@ -987,9 +1004,8 @@ no_dccp_socket:
 	}
 
 discard_it:
-	/* Discard frame. */
 	kfree_skb(skb);
-	return 0;
+	return ret;
 
 discard_and_relse:
 	sock_put(sk);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 91e7b12..49690ee 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1035,6 +1035,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	const struct dccp_hdr *dh;
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -1078,7 +1079,23 @@ static int dccp_v6_rcv(struct sk_buff **
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	return sk_receive_skb(sk, skb) ? -1 : 0;
+	if (sk_filter(sk, skb))
+		goto discard_and_relse;
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
@@ -1093,14 +1110,10 @@ no_dccp_socket:
 					DCCP_RESET_CODE_NO_CONNECTION;
 		dccp_v6_ctl_send_reset(skb);
 	}
-discard_it:
-
-	/*
-	 *	Discard frame
-	 */
 
+discard_it:
 	kfree_skb(skb);
-	return 0;
+	return ret;
 
 discard_and_relse:
 	sock_put(sk);
