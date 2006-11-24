From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:19 +0000
Subject: [PATCH 2/10]: Remove redundant statements in ccid3_hc_tx_packet_sent
Message-Id: <200611241619.19478@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Remove redundant statements in ccid3_hc_tx_packet_sent

This patch removes a switch statement which is redundant since,
 * nothing is done in states TFRC_SSTATE_NO_SENT/TFRC_SSTATE_NO_FBACK
 * it is impossible that the function is called in the state TFRC_SSTATE_TERM, since 
       --the function is called, in dccp_write_xmit, after ccid3_hc_tx_send_packet
       --if ccid3_hc_tx_send_packet is called in state TFRC_SSTATE_TERM, it returns
         -EINVAL, which means that ccid3_hc_tx_packet_sent will not be called
	 (compare dccp_write_xmit)
       --> therefore, this case is logically impossible
 * the remaining state is TFRC_SSTATE_FBACK which conditionally updates t_ipi, t_nom,
   and t_delta. This is a no-op, since 
       --t_ipi only changes when feedback is received
       --however, when feedback arrives via ccid3_hc_tx_packet_recv, there is an identical
         code block which performs the same set of operations
       --performing the same set of operations again in ccid3_hc_tx_packet_sent therefore
         does not change anything, since between the time of receiving the last feedback
	 (and therefore update of t_ipi, t_nom, and t_delta), the value of t_ipi has not 
	 changed
       --since t_ipi has not changed, the values of t_delta and t_nom also do not change,
         they depend fully on t_ipi

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	 
---
 net/dccp/ccids/ccid3.c |   21 ---------------------
 1 file changed, 21 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -408,27 +408,6 @@ static void ccid3_hc_tx_packet_sent(stru
 	} else
 		ccid3_pr_debug("%s, sk=%p, seqno=%llu NOT inserted!\n",
 			       dccp_role(sk), sk, dp->dccps_gss);
-
-	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_SENT:
-		/* fall through */
-	case TFRC_SSTATE_NO_FBACK:
-		/* t_nom, t_ipi, delta do not change until feedback arrives */
-		return;
-	case TFRC_SSTATE_FBACK:
-		if (len > 0) {
-			timeval_sub_usecs(&hctx->ccid3hctx_t_nom,
-				  hctx->ccid3hctx_t_ipi);
-			ccid3_calc_new_t_ipi(hctx);
-			ccid3_calc_new_delta(hctx);
-			timeval_add_usecs(&hctx->ccid3hctx_t_nom,
-					  hctx->ccid3hctx_t_ipi);
-		}
-		break;
-	case TFRC_SSTATE_TERM:
-		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
-		break;
-	}
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
