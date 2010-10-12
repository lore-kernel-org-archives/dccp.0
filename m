From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:46 +0000
Subject: [PATCH 1/6] dccp: fix the adjustments to AWL and SWL
Message-Id: <1286860551-6809-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a problem and a potential loophole with regard to seqno/ackno
validity: currently the initial adjustments to AWL/SWL are only performed
once at the begin of the connection, during the handshake.

Since the Sequence Window feature is always greater than Wmin2 (7.5.2),
it is however necessary to perform these adjustments at least for the first
W/W' (variables as per 7.5.1) packets in the lifetime of a connection.

This requirement is complicated by the fact that W/W' can change at any time
during the lifetime of a connection.

Therefore it is better to perform that safety check each time SWL/AWL are
updated, as implemented by the patch.

A second problem solved by this patch is that the remote/local Sequence Window
feature values (which set the bounds for AWL/SWL/SWH) are undefined until the
feature negotiation has completed.

During the initial handshake we have more stringent sequence number protection;
the changes added by this patch effect that {A,S}W{L,H} are within the correct
bounds at the instant that feature negotiation completes (since the SeqWin
feature activation handlers call dccp_update_gsr/gss()).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h      |   20 ++++++++++++++++++++
 net/dccp/input.c     |   18 ++++++------------
 net/dccp/minisocks.c |   30 +++++++++---------------------
 3 files changed, 35 insertions(+), 33 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -414,6 +414,23 @@ static inline void dccp_update_gsr(struct sock *sk, u64 seq)
 	dp->dccps_gsr = seq;
 	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
 	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
+	/*
+	 * Adjust SWL so that it is not below ISR. In contrast to RFC 4340,
+	 * 7.5.1 we perform this check beyond the initial handshake: W/W' are
+	 * always > 32, so for the first W/W' packets in the lifetime of a
+	 * connection we always have to adjust SWL.
+	 * A second reason why we are doing this is that the window depends on
+	 * the feature-remote value of Sequence Window: nothing stops the peer
+	 * from updating this value while we are busy adjusting SWL for the
+	 * first W packets (we would have to count from scratch again then).
+	 * Therefore it is safer to always make sure that the Sequence Window
+	 * is not artificially extended by a peer who grows SWL downwards by
+	 * continually updating the feature-remote Sequence-Window.
+	 * If sequence numbers wrap it is bad luck. But that will take a while
+	 * (48 bit), and this measure prevents Sequence-number attacks.
+	 */
+	if (before48(dp->dccps_swl, dp->dccps_isr))
+		dp->dccps_swl = dp->dccps_isr;
 	dp->dccps_swh = ADD48(dp->dccps_gsr, (3 * dp->dccps_r_seq_win) / 4);
 }
 
@@ -424,6 +441,9 @@ static inline void dccp_update_gss(struct sock *sk, u64 seq)
 	dp->dccps_gss = seq;
 	/* Ack validity window depends on local Sequence Window value (7.5.1) */
 	dp->dccps_awl = SUB48(ADD48(dp->dccps_gss, 1), dp->dccps_l_seq_win);
+	/* Adjust AWL so that it is not below ISS - see comment above for SWL */
+	if (before48(dp->dccps_awl, dp->dccps_iss))
+		dp->dccps_awl = dp->dccps_iss;
 	dp->dccps_awh = dp->dccps_gss;
 }
 
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -441,20 +441,14 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		kfree_skb(sk->sk_send_head);
 		sk->sk_send_head = NULL;
 
-		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
-		dccp_update_gsr(sk, dp->dccps_isr);
 		/*
-		 * SWL and AWL are initially adjusted so that they are not less than
-		 * the initial Sequence Numbers received and sent, respectively:
-		 *	SWL := max(GSR + 1 - floor(W/4), ISR),
-		 *	AWL := max(GSS - W' + 1, ISS).
-		 * These adjustments MUST be applied only at the beginning of the
-		 * connection.
-		 *
-		 * AWL was adjusted in dccp_v4_connect -acme
+		 * Set ISR, GSR from packet. ISS was set in dccp_v{4,6}_connect
+		 * and GSS in dccp_transmit_skb(). Setting AWL/AWH and SWL/SWH
+		 * is done as part of activating the feature values below, since
+		 * these settings depend on the local/remote Sequence Window
+		 * features, which were undefined or not confirmed until now.
 		 */
-		dccp_set_seqno(&dp->dccps_swl,
-			       max48(dp->dccps_swl, dp->dccps_isr));
+		dp->dccps_gsr = dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 
 		dccp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -121,30 +121,18 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		 *
 		 *    Choose S.ISS (initial seqno) or set from Init Cookies
 		 *    Initialize S.GAR := S.ISS
-		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
-		 */
-		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
-		dccp_update_gss(newsk, dreq->dreq_iss);
-
-		newdp->dccps_isr = dreq->dreq_isr;
-		dccp_update_gsr(newsk, dreq->dreq_isr);
-
-		/*
-		 * SWL and AWL are initially adjusted so that they are not less than
-		 * the initial Sequence Numbers received and sent, respectively:
-		 *	SWL := max(GSR + 1 - floor(W/4), ISR),
-		 *	AWL := max(GSS - W' + 1, ISS).
-		 * These adjustments MUST be applied only at the beginning of the
-		 * connection.
+		 *    Set S.ISR, S.GSR from packet (or Init Cookies)
+		 *
+		 *    Setting AWL/AWH and SWL/SWH happens as part of the feature
+		 *    activation below, as these windows all depend on the local
+		 *    and remote Sequence Window feature values (7.5.2).
 		 */
-		dccp_set_seqno(&newdp->dccps_swl,
-			       max48(newdp->dccps_swl, newdp->dccps_isr));
-		dccp_set_seqno(&newdp->dccps_awl,
-			       max48(newdp->dccps_awl, newdp->dccps_iss));
+		newdp->dccps_gss = newdp->dccps_iss = dreq->dreq_iss;
+		newdp->dccps_gar = newdp->dccps_iss;
+		newdp->dccps_gsr = newdp->dccps_isr = dreq->dreq_isr;
 
 		/*
-		 * Activate features after initialising the sequence numbers,
-		 * since CCID initialisation may depend on GSS, ISR, ISS etc.
+		 * Activate features: initialise CCIDs, sequence windows etc.
 		 */
 		if (dccp_feat_activate_values(newsk, &dreq->dreq_featneg)) {
 			/* It is still raw copy of parent, so invalidate
