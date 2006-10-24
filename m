From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:00:00 +0000
Subject: [PATCH 8/17] [DCCP]: resolve problem with locking validator
Message-Id: <200610241500.00584@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: resolve problem with locking validator

This is a tidied-up re-send from 
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00599.html

and aligns the DCCP code with that of net/ipv{4,6}/tcp_ipv{4,6}.c
where a similar problem of a putative recursive lock exists.

Commit message:
---------------
This patch fixes a problem of putative recursive locking. The problem occurs
when a listening DCCPv4/6 socket has sent a Response in reply to a Request and
happens at the time the ACK is received. The problem occurs since sk_receive_skb
locks sk, then calls the AF-specific backlog function (dccp_v{4,6}_do_rcv). This
ends up calling dccp_v{4,6}_request_recv_sock, which calls dccp_create_openreq_child,
from there to sk_clone via inet_sk_clone. In sk_clone, a lock is placed on newsk,
which makes the lock mechanism think that the same lock was applied twice.
This patch fixes the problem by using bh_nested_lock instead of bh_lock, which is
justified since there really only is one nesting level.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/ipv4.c |   22 +++++++++++++++++++++-
 net/dccp/ipv6.c |   19 ++++++++++++++++++-
 2 files changed, 39 insertions(+), 2 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 842d3d1..aaf8ed0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -878,6 +878,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -951,7 +952,26 @@ static int dccp_v4_rcv(struct sk_buff *s
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	return sk_receive_skb(sk, skb);
+	/* code from sk_receive_skb */
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
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index a4e1dd9..83d237d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1043,6 +1043,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	const struct dccp_hdr *dh;
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
+	int ret = 0;
 
 	/* Step 1: Check header basics: */
 
@@ -1086,7 +1087,23 @@ static int dccp_v6_rcv(struct sk_buff **
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	return sk_receive_skb(sk, skb) ? -1 : 0;
+	/* code from sk_receive_skb */
+	if (sk_filter(sk, skb))
+		goto discard_and_relse;
+
+	skb->dev = NULL;
+
+	bh_lock_sock_nested(sk);
+	if (!sock_owned_by_user(sk)) {
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

