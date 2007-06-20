From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:55:35 +0000
Subject: [PATCH 1/5]: Shorten variable names in dccp_check_seqno
Message-Id: <200706201055.35273@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Shorten variable names in dccp_check_seqno

This patch is in part required by the next patch; it

 * replaces 6 instances of `DCCP_SKB_CB(skb)->dccpd_seq' with `seqno';
 * replaces 7 instances of `DCCP_SKB_CB(skb)->dccpd_ack_seq' with `ackno';
 * replaces 1 use of dccp_inc_seqno() by unfolding `ADD48' macro in place.

No changes in algorithm, all changes are text replacement/substitution.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/input.c |   40 +++++++++++++++++-----------------------
 1 file changed, 17 insertions(+), 23 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -68,7 +68,8 @@ static int dccp_check_seqno(struct sock 
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	struct dccp_sock *dp = dccp_sk(sk);
-	u64 lswl, lawl;
+	u64 lswl, lawl, seqno = DCCP_SKB_CB(skb)->dccpd_seq,
+			ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 
 	/*
 	 *   Step 5: Prepare sequence numbers for Sync
@@ -84,11 +85,9 @@ static int dccp_check_seqno(struct sock 
 	 */
 	if (dh->dccph_type = DCCP_PKT_SYNC ||
 	    dh->dccph_type = DCCP_PKT_SYNCACK) {
-		if (between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			      dp->dccps_awl, dp->dccps_awh) &&
-		    dccp_delta_seqno(dp->dccps_swl,
-				     DCCP_SKB_CB(skb)->dccpd_seq) >= 0)
-			dccp_update_gsr(sk, DCCP_SKB_CB(skb)->dccpd_seq);
+		if (between48(ackno, dp->dccps_awl, dp->dccps_awh) &&
+		    dccp_delta_seqno(dp->dccps_swl, seqno) >= 0)
+			dccp_update_gsr(sk, seqno);
 		else
 			return -1;
 	}
@@ -113,35 +112,30 @@ static int dccp_check_seqno(struct sock 
 	if (dh->dccph_type = DCCP_PKT_CLOSEREQ ||
 	    dh->dccph_type = DCCP_PKT_CLOSE ||
 	    dh->dccph_type = DCCP_PKT_RESET) {
-		lswl = dp->dccps_gsr;
-		dccp_inc_seqno(&lswl);
+		lswl = ADD48(dp->dccps_gsr, 1);
 		lawl = dp->dccps_gar;
 	}
 
-	if (between48(DCCP_SKB_CB(skb)->dccpd_seq, lswl, dp->dccps_swh) &&
-	    (DCCP_SKB_CB(skb)->dccpd_ack_seq = DCCP_PKT_WITHOUT_ACK_SEQ ||
-	     between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
-		       lawl, dp->dccps_awh))) {
-		dccp_update_gsr(sk, DCCP_SKB_CB(skb)->dccpd_seq);
+	if (between48(seqno, lswl, dp->dccps_swh) &&
+	    (ackno = DCCP_PKT_WITHOUT_ACK_SEQ ||
+	     between48(ackno, lawl, dp->dccps_awh))) {
+		dccp_update_gsr(sk, seqno);
 
 		if (dh->dccph_type != DCCP_PKT_SYNC &&
-		    (DCCP_SKB_CB(skb)->dccpd_ack_seq !-		     DCCP_PKT_WITHOUT_ACK_SEQ))
-			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
+		    (ackno != DCCP_PKT_WITHOUT_ACK_SEQ))
+			dp->dccps_gar = ackno;
 	} else {
 		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
 			  "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
 			  "sending SYNC...\n",  dccp_packet_name(dh->dccph_type),
-			  (unsigned long long) lswl,
-			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq,
+			  (unsigned long long) lswl, (unsigned long long) seqno,
 			  (unsigned long long) dp->dccps_swh,
-			  (DCCP_SKB_CB(skb)->dccpd_ack_seq =
-				DCCP_PKT_WITHOUT_ACK_SEQ) ? "doesn't exist" : "exists",
-			  (unsigned long long) lawl,
-			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
+			  (ackno = DCCP_PKT_WITHOUT_ACK_SEQ) ? "doesn't exist"
+							      : "exists",
+			  (unsigned long long) lawl, (unsigned long long) ackno,
 			  (unsigned long long) dp->dccps_awh);
-		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
+		dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
 		return -1;
 	}
 
