From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Dec 2008 16:40:52 +0000
Subject: [PATCH 2/7] dccp: Integration of dynamic feature activation - part 2 (server side)
Message-Id: <1228581657-6724-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch integrates the activation of features at the end of negotiation
into the server-side code.

Note regarding the removal of 'const':
--------------------------------------
 The 'const' attribute has been removed from 'dreq' since dccp_activate_values()
 needs to operate on dreq's feature list. Part of the activation is to remove
 those options from the list that have already been confirmed, hence it is not
 purely read-only.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/minisocks.c |   42 ++++++++++++------------------------------
 1 files changed, 12 insertions(+), 30 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -111,7 +111,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
 
 	if (newsk != NULL) {
-		const struct dccp_request_sock *dreq = dccp_rsk(req);
+		struct dccp_request_sock *dreq = dccp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
 		struct dccp_minisock *newdmsk = dccp_msk(newsk);
@@ -125,35 +125,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		newicsk->icsk_rto	    = DCCP_TIMEOUT_INIT;
 
 		INIT_LIST_HEAD(&newdp->dccps_featneg);
-		if (dccp_feat_clone(sk, newsk))
-			goto out_free;
-
-		if (newdmsk->dccpms_send_ack_vector) {
-			newdp->dccps_hc_rx_ackvec -						dccp_ackvec_alloc(GFP_ATOMIC);
-			if (unlikely(newdp->dccps_hc_rx_ackvec = NULL))
-				goto out_free;
-		}
-
-		newdp->dccps_hc_rx_ccid -			    ccid_hc_rx_new(newdmsk->dccpms_rx_ccid,
-					   newsk, GFP_ATOMIC);
-		newdp->dccps_hc_tx_ccid -			    ccid_hc_tx_new(newdmsk->dccpms_tx_ccid,
-					   newsk, GFP_ATOMIC);
-		if (unlikely(newdp->dccps_hc_rx_ccid = NULL ||
-			     newdp->dccps_hc_tx_ccid = NULL)) {
-			dccp_ackvec_free(newdp->dccps_hc_rx_ackvec);
-			ccid_hc_rx_delete(newdp->dccps_hc_rx_ccid, newsk);
-			ccid_hc_tx_delete(newdp->dccps_hc_tx_ccid, newsk);
-out_free:
-			/* It is still raw copy of parent, so invalidate
-			 * destructor and make plain sk_free() */
-			newsk->sk_destruct = NULL;
-			sk_free(newsk);
-			return NULL;
-		}
-
 		/*
 		 * Step 3: Process LISTEN state
 		 *
@@ -184,6 +155,17 @@ out_free:
 		dccp_set_seqno(&newdp->dccps_awl,
 			       max48(newdp->dccps_awl, newdp->dccps_iss));
 
+		/*
+		 * Activate features after initialising the sequence numbers,
+		 * since CCID initialisation may depend on GSS, ISR, ISS etc.
+		 */
+		if (dccp_feat_activate_values(newsk, &dreq->dreq_featneg)) {
+			/* It is still raw copy of parent, so invalidate
+			 * destructor and make plain sk_free() */
+			newsk->sk_destruct = NULL;
+			sk_free(newsk);
+			return NULL;
+		}
 		dccp_init_xmit_timers(newsk);
 
 		DCCP_INC_STATS_BH(DCCP_MIB_PASSIVEOPENS);
