From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 15:28:04 +0000
Subject: [PATCH 4/10][DCCP]: Simplify jump labels in dccp_v{4,6}_rcv
Message-Id: <20061110152803.GH23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a code simplification and was singled out from the
DCCPv6 Oops patch on
http://www.mail-archive.com/dccp@vger.kernel.org/msg00600.html

It mainly makes the code consistent between ipv{4,6}.c for the functions
        dccp_v4_rcv
        dccp_v6_rcv
and removes the do_time_wait label to simplify code somewhat.

Commiter note: fixed up a compile problem, trivial.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv4.c |   15 ++++-----------
 ipv6.c |   22 ++++++++++------------
 2 files changed, 14 insertions(+), 23 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ce8eed3..7107885 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -910,8 +910,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 		dccp_pr_debug_cat("\n");
 	} else {
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
-		dccp_pr_debug_cat(", ack=%llu\n",
-				  (unsigned long long)
+		dccp_pr_debug_cat(", ack=%llu\n", (unsigned long long)
 				  DCCP_SKB_CB(skb)->dccpd_ack_seq);
 	}
 
@@ -940,11 +939,10 @@ static int dccp_v4_rcv(struct sk_buff *s
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	       
 	if (sk->sk_state = DCCP_TIME_WAIT) {
-		dccp_pr_debug("sk->sk_state = DCCP_TIME_WAIT: "
-			      "do_time_wait\n");
-                goto do_time_wait;
+		dccp_pr_debug("sk->sk_state = DCCP_TIME_WAIT: do_time_wait\n");
+		inet_twsk_put(inet_twsk(sk));
+		goto no_dccp_socket;
 	}
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
@@ -968,17 +966,12 @@ no_dccp_socket:
 	}
 
 discard_it:
-	/* Discard frame. */
 	kfree_skb(skb);
 	return 0;
 
 discard_and_relse:
 	sock_put(sk);
 	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index a4e1dd9..96a2480 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1071,8 +1071,11 @@ static int dccp_v6_rcv(struct sk_buff **
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
@@ -1080,8 +1083,11 @@ static int dccp_v6_rcv(struct sk_buff **
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
-	if (sk->sk_state = DCCP_TIME_WAIT)
-		goto do_time_wait;
+	if (sk->sk_state = DCCP_TIME_WAIT) {
+		dccp_pr_debug("sk->sk_state = DCCP_TIME_WAIT: do_time_wait\n");
+		inet_twsk_put(inet_twsk(sk));
+		goto no_dccp_socket;
+	}
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
@@ -1101,22 +1107,14 @@ no_dccp_socket:
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
 	return 0;
 
 discard_and_relse:
 	sock_put(sk);
 	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
