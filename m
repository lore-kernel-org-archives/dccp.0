From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 25 Oct 2006 15:51:40 +0000
Subject: Re: [PATCH 7/17] [DCCP]: Simplify jump labels in dccp_v{4,6}_rcv
Message-Id: <200610251651.40865@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Mg4PFCKc/bSbYnM"
List-Id: <dccp.vger.kernel.org>
References: <200610241459.52912@strip-the-willow>
In-Reply-To: <200610241459.52912@strip-the-willow>
To: dccp@vger.kernel.org

--Boundary-00=_Mg4PFCKc/bSbYnM
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have verified this patch again and discovered a stupid mistake/bug
in the posting:
	* control goes from: no_dccp_socket: => discard_and_relse: => sock_put(sk)
	* BOOM! (no socket)

I therefore re-send the corrected patch, put it online as
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/07a_1_simplify_vX_rcv.diff

Apart from the bug fix, the patch is now
	* much smaller therefore easier to read/review
	* effectively boils down to format changes / removal of do_time_wait label

I have updated the repository on http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/,
all other patches have been refreshed relative to this one.

Gerrit



--Boundary-00=_Mg4PFCKc/bSbYnM
Content-Type: text/x-diff;
  charset="us-ascii";
  name="07a_1_simplify_vX_rcv.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="07a_1_simplify_vX_rcv.diff"

[DCCP]: Simplify jump labels in dccp_v{4,6}_rcv

This is a code simplification and was singled out from the
DCCPv6 Oops patch on
http://www.mail-archive.com/dccp@vger.kernel.org/msg00600.html

It mainly makes the code consistent between ipv{4,6}.c for the functions
        dccp_v4_rcv
        dccp_v6_rcv
and removes the do_time_wait label to simplify code somewhat.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

---
 net/dccp/ipv4.c |   17 +++++------------
 net/dccp/ipv6.c |   24 +++++++++++-------------
 2 files changed, 16 insertions(+), 25 deletions(-)

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
 	 *		Generate Reset(No Connection) unless P.type == Reset
 	 *		Drop packet and return
 	 */
-	       
 	if (sk->sk_state == DCCP_TIME_WAIT) {
-		dccp_pr_debug("sk->sk_state == DCCP_TIME_WAIT: "
-			      "do_time_wait\n");
-                goto do_time_wait;
+		dccp_pr_debug("sk->sk_state == DCCP_TIME_WAIT: do_time_wait\n");
+		inet_twsk_put(inet_twsk(sk));
+		goto no_dccp_socket;
 	}
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
@@ -968,17 +966,12 @@ no_dccp_socket:
 	}
 
 discard_it:
-	/* Discard frame. */
 	kfree_skb(skb);
-	return 0;
+	return ret;
 
 discard_and_relse:
 	sock_put(sk);
 	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1071,8 +1071,11 @@ static int dccp_v6_rcv(struct sk_buff **
 	 *		Generate Reset(No Connection) unless P.type == Reset
 	 *		Drop packet and return
 	 */
-	if (sk == NULL)
+	if (sk == NULL) {
+		dccp_pr_debug("failed to look up flow ID in table and "
+			      "get corresponding socket\n");
 		goto no_dccp_socket;
+	}
 
 	/*
 	 * Step 2:
@@ -1080,8 +1083,11 @@ static int dccp_v6_rcv(struct sk_buff **
 	 *		Generate Reset(No Connection) unless P.type == Reset
 	 *		Drop packet and return
 	 */
-	if (sk->sk_state == DCCP_TIME_WAIT)
-		goto do_time_wait;
+	if (sk->sk_state == DCCP_TIME_WAIT) {
+		dccp_pr_debug("sk->sk_state == DCCP_TIME_WAIT: do_time_wait\n");
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
-	return 0;
+	return ret;
 
 discard_and_relse:
 	sock_put(sk);
 	goto discard_it;
-
-do_time_wait:
-	inet_twsk_put(inet_twsk(sk));
-	goto no_dccp_socket;
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {

--Boundary-00=_Mg4PFCKc/bSbYnM--
