From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jan 2008 10:16:14 +0000
Subject: [PATCH 4/6] [DCCP]: Fix the adjustments to AWL and SWL
Message-Id: <1201515376-8280-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a problem and a potential loophole with regard to seqno/ackno
validity: the problem is that the initial adjustments to AWL/SWL were
only performed at the begin of the connection, during the handshake.

Since the Sequence Window feature is always greater than Wmin2 (7.5.2),
it is however necessary to perform these adjustments at least for the first
W/W' (variables as per 7.5.1) packets in the lifetime of a connection.

This requirement is complicated by the fact that W/W' can change at any time
during the lifetime of a connection.

Therefore the consequence is to perform this safety check each time SWL/AWL
are updated.

A second problem solved by this patch is that the remote/local Sequence Window
feature values (which set the bounds for AWL/SWL/SWH) are undefined until the
feature negotiation has completed.

During the initial handshake we have more stringent sequence number protection,
the changes added by this patch effect that {A,S}W{L,H} are within the correct
bounds at the instant that feature negotiation completes (since the SeqWin
feature activation handlers call dccp_update_gsr/gss()).

A detailed rationale is below -- can be removed from the commit message.


1. Server sequence number checks during initial handshake
---------------------------------------------------------
The server can not use the fields of the listening socket for seqno/ackno checks
and thus needs to store all relevant information on a per-connection basis on
the dccp_request socket. This is a size-constrained structure and has currently
only ISS (dreq_iss) and ISR (dreq_isr) defined.
Adding further fields (SW{L,H}, AW{L,H}) would increase the size of the struct
and it is questionable whether this will have any practical gain. The currently
implemented solution is as follows.
 * receiving first Request: dccp_v{4,6}_conn_request sets
                            ISR := P.seqno, ISS := dccp_v{4,6}_init_sequence()

 * sending first Response:  dccp_v{4,6}_send_response via dccp_make_response()
                            sets P.seqno := ISS, sets P.ackno := ISR

 * receiving retransmitted Request: dccp_check_req() overrides ISR := P.seqno

 * answering retransmitted Request: dccp_make_response() sets ISS += 1,
                                    otherwise as per first Response

 * completing the handshake: succeeds in dccp_check_req() for the first Ack
                             where P.ackno = ISS (P.seqno is not tested)

 * creating child socket: ISS, ISR are copied from the request_sock

This solution will succeed whenever the server can receive the Request and the
subsequent Ack in succession, without retransmissions. If there is packet loss,
the client needs to retransmit until this condition succeeds; it will otherwise
eventually give up. Adding further fields to the request_sock could increase
the robustness a bit, in that it would make possible to let a reordered Ack
(from a retransmitted Response) pass. The argument against such a solution is
that if the packet loss is not persistent and an Ack gets through, why not
wait for the one answering the original response: if the loss is persistent, it
is probably better to not start the connection in the first place.

Long story short: the present design (by Arnaldo) is simple and will likely work
just as well as a more complicated solution. As a consequence, {A,S}W{L,H} are
not needed until the moment the request_sock is cloned into the accept queue.

At that stage feature negotiation has completed, so that the values for the local
and remote Sequence Window feature (7.5.2) are known, i.e. we are now in a better
position to compute {A,S}W{L,H}.


2. Client sequence number checks during initial handshake
---------------------------------------------------------
Until entering PARTOPEN the client does not need the adjustments, since it
constrains the Ack window to the packet it sent.

 * sending first Request: dccp_v{4,6}_connect() choose ISS,
                          dccp_connect() then sets GAR := ISS (as per 8.5),
			  dccp_transmit_skb() (with the previous bug fix) sets
			         GSS := ISS, AWL := ISS, AWH := GSS
 * n-th retransmitted Request (with previous patch):
	                  dccp_retransmit_skb() via timer calls
			  dccp_transmit_skb(), which sets GSS := ISS+n
                          and then AWL := ISS, AWH := ISS+n

 * receiving any Response: dccp_rcv_request_sent_state_process()
	                   -- accepts packet if AWL <= P.ackno <= AWH;
			   -- sets GSR = ISR = P.seqno

 * sending the Ack completing the handshake: dccp_send_ack() calls
                           dccp_transmit_skb(), which sets GSS += 1
			   and AWL := ISS, AWH := GSS


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h      |   20 ++++++++++++++++++++
 net/dccp/input.c     |   18 ++++++------------
 net/dccp/minisocks.c |   30 +++++++++---------------------
 3 files changed, 35 insertions(+), 33 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -392,6 +392,23 @@ static inline void dccp_update_gsr(struct sock *sk, u64 seq)
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
 
@@ -402,6 +419,9 @@ static inline void dccp_update_gss(struct sock *sk, u64 seq)
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
@@ -440,20 +440,14 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 			dp->dccps_syn_rtt = dccp_sample_rtt(sk, 10 * (tstamp -
 			    dp->dccps_options_received.dccpor_timestamp_echo));
 
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
@@ -120,30 +120,18 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
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
-		 * Activate features after initialising the sequence numbers since
-		 * CCID initialisation may depend on GSS, ISR, ISS etc.
+		 * Activate features: initialise CCIDs, sequence windows etc.
 		 */
 		if (dccp_feat_activate_values(newsk, &dreq->dreq_featneg)) {
 			/* It is still raw copy of parent, so invalidate
