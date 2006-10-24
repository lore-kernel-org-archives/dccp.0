From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:52 +0000
Subject: [PATCH 7/17] [DCCP]: Simplify jump labels in dccp_v{4,6}_rcv
Message-Id: <200610241459.52912@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Simplify jump labels in dccp_v{4,6}_rcv

This is a code simplification and was singled out from 
http://www.mail-archive.com/dccp@vger.kernel.org/msg00600.html

The patch reduces the complexity and number of goto jump labels in
        dccp_v4_rcv
        dccp_v6_rcv
and further makes the code consistent (same handling in both functions).


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/ipv4.c |   21 ++++++---------------
 net/dccp/ipv6.c |   30 +++++++++++++-----------------
 2 files changed, 19 insertions(+), 32 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index aaf8ed0..7690c83 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -911,8 +911,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 		dccp_pr_debug_cat("\n");
 	} else {
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
-		dccp_pr_debug_cat(", ack=%llu\n",
-				  (unsigned long long)
+		dccp_pr_debug_cat(", ack=%llu\n", (unsigned long long)
 				  DCCP_SKB_CB(skb)->dccpd_ack_seq);
 	}
 
@@ -941,11 +940,11 @@ static int dccp_v4_rcv(struct sk_buff *s
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
@@ -986,19 +985,11 @@ no_dccp_socket:
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
index 83d237d..07e0b7f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1072,8 +1072,11 @@ static int dccp_v6_rcv(struct sk_buff **
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
@@ -1081,8 +1084,12 @@ static int dccp_v6_rcv(struct sk_buff **
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
@@ -1118,22 +1125,11 @@ no_dccp_socket:
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
