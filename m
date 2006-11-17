From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:05:28 +0000
Subject: [PATCH 6/7]: DCCP_WARN() wrapper
Message-Id: <200611171805.28687@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: DCCP_WARN() wrapper

This introduces a rate-limited DCCP_WARN() wrapper for
non-critical DCCP warning messages.

For CCID 3/TFRC it also adds warning messages whenever the RTT 
is estimated at 0.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |   67 ++++++++++++++++---------------------
 net/dccp/ccids/lib/loss_interval.c |    2 -
 net/dccp/ccids/lib/tfrc_equation.c |    4 +-
 net/dccp/feat.c                    |    8 ++--
 net/dccp/input.c                   |   25 ++++++-------
 net/dccp/ipv4.c                    |   24 ++++---------
 net/dccp/ipv6.c                    |    4 --
 net/dccp/minisocks.c               |    3 -
 net/dccp/options.c                 |    5 +-
 9 files changed, 62 insertions(+), 80 deletions(-)

 
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -109,7 +109,7 @@ u32 dccp_li_hist_calc_i_mean(struct list
 	i_tot = max(i_tot0, i_tot1);
 
 	if (!w_tot) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: w_tot = 0\n", __FUNCTION__);
+		DCCP_WARN("w_tot = 0\n");
 		return 1;
 	}
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -281,9 +281,8 @@ static int ccid3_hc_tx_send_packet(struc
 
 		rc = -ENOBUFS;
 		if (unlikely(new_packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, not enough "
-				       "mem to add to history, send refused\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, not enough mem to add to history,"
+				  "send refused\n", dccp_role(sk), sk);
 			goto out;
 		}
 
@@ -352,13 +351,11 @@ static void ccid3_hc_tx_packet_sent(stru
 
 		packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 		if (unlikely(packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: packet doesn't "
-				       "exists in history!\n", __FUNCTION__);
+			DCCP_WARN("packet doesn't exist in history!\n");
 			return;
 		}
 		if (unlikely(packet->dccphtx_sent)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: no unsent packet in "
-				       "history!\n", __FUNCTION__);
+			DCCP_WARN("no unsent packet in history!\n");
 			return;
 		}
 		packet->dccphtx_tstamp = now;
@@ -451,11 +448,10 @@ static void ccid3_hc_tx_packet_recv(stru
 		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
 						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
 		if (unlikely(packet = NULL)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, seqno "
-				       "%llu(%s) does't exist in history!\n",
-				       __FUNCTION__, dccp_role(sk), sk,
+			DCCP_WARN("%s, sk=%p, seqno %llu(%s) does't exist "
+				  "in history!\n",  dccp_role(sk), sk,
 			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
 			return;
 		}
 
@@ -463,9 +459,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		dccp_timestamp(sk, &now);
 		r_sample = timeval_delta(&now, &packet->dccphtx_tstamp);
 		if (unlikely(r_sample <= t_elapsed))
-			LIMIT_NETDEBUG(KERN_WARNING "%s: r_sample=%uus, "
-				       "t_elapsed=%uus\n",
-				       __FUNCTION__, r_sample, t_elapsed);
+			DCCP_WARN("r_sample=%uus,t_elapsed=%uus\n",
+				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
 
@@ -591,9 +586,9 @@ static int ccid3_hc_tx_parse_options(str
 	switch (option) {
 	case TFRC_OPT_LOSS_EVENT_RATE:
 		if (unlikely(len != 4)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, invalid "
-				       "len for TFRC_OPT_LOSS_EVENT_RATE\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, invalid len %d "
+				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
+				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_loss_event_rate = ntohl(*(__be32 *)value);
@@ -612,9 +607,9 @@ static int ccid3_hc_tx_parse_options(str
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
-			LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, invalid "
-				       "len for TFRC_OPT_RECEIVE_RATE\n",
-				       __FUNCTION__, dccp_role(sk), sk);
+			DCCP_WARN("%s, sk=%p, invalid len %d "
+				  "for TFRC_OPT_RECEIVE_RATE\n",
+				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_receive_rate = ntohl(*(__be32 *)value);
@@ -724,9 +719,8 @@ static void ccid3_hc_rx_send_feedback(st
 
 	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
 	if (unlikely(packet = NULL)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, no data packet "
-			       "in history!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, no data packet in history!\n",
+			  dccp_role(sk), sk);
 		return;
 	}
 
@@ -814,16 +808,14 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	}
 
 	if (unlikely(step = 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, packet history "
-			       "contains no data packets!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, packet history has no data packets!\n",
+			  dccp_role(sk), sk);
 		return ~0;
 	}
 
 	if (unlikely(interval = 0)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, Could not find a "
-			       "win_count interval > 0. Defaulting to 1\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, Could not find a win_count interval > 0."
+			  "Defaulting to 1\n", dccp_role(sk), sk);
 		interval = 1;
 	}
 found:
@@ -834,8 +826,11 @@ found:
 	rtt = timeval_delta(&tstamp, &tail->dccphrx_tstamp) * 4 / interval;
 	ccid3_pr_debug("%s, sk=%p, approximated RTT to %uus\n",
 		       dccp_role(sk), sk, rtt);
-	if (rtt = 0)
-		rtt = 1;
+
+	if (rtt = 0) {
+		DCCP_WARN("RTT=0, setting to 1\n");
+ 		rtt = 1;
+	}
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
@@ -992,9 +987,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		t_elapsed = opt_recv->dccpor_elapsed_time * 10;
 
 		if (unlikely(r_sample <= t_elapsed))
-			LIMIT_NETDEBUG(KERN_WARNING "%s: r_sample=%uus, "
-				       "t_elapsed=%uus\n",
-				       __FUNCTION__, r_sample, t_elapsed);
+			DCCP_WARN("r_sample=%uus, t_elapsed=%uus\n",
+				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
 
@@ -1018,9 +1012,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
 					skb, SLAB_ATOMIC);
 	if (unlikely(packet = NULL)) {
-		LIMIT_NETDEBUG(KERN_WARNING "%s: %s, sk=%p, Not enough mem to "
-				"add rx packet to history, consider it lost!\n",
-			       __FUNCTION__, dccp_role(sk), sk);
+		DCCP_WARN("%s, sk=%p, Not enough mem to add rx packet "
+			  "to history, consider it lost!\n", dccp_role(sk), sk);
 		return;
 	}
 
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -25,11 +25,11 @@ int dccp_feat_change(struct dccp_minisoc
 	dccp_feat_debug(type, feature, *val);
 
 	if (!dccp_feat_is_valid_type(type)) {
-		pr_info("option type %d invalid in negotiation\n", type);
+		DCCP_WARN("option type %d invalid in negotiation\n", type);
 		return 1;
 	}
 	if (!dccp_feat_is_valid_length(type, feature, len)) {
-		pr_info("invalid length %d\n", len);
+		DCCP_WARN("invalid length %d\n", len);
 		return 1;
 	}
 	/* XXX add further sanity checks */
@@ -330,7 +330,7 @@ static void dccp_feat_empty_confirm(stru
 	switch (type) {
 	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
 	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
-	default: 	     pr_info("invalid type %d\n", type); return;
+	default: 	     DCCP_WARN("invalid type %d\n", type); return;
 
 	}
 	opt->dccpop_feat = feature;
@@ -428,7 +428,7 @@ int dccp_feat_confirm_recv(struct sock *
 	switch (type) {
 	case DCCPO_CONFIRM_L: t = DCCPO_CHANGE_R; break;
 	case DCCPO_CONFIRM_R: t = DCCPO_CHANGE_L; break;
-	default: 	      pr_info("invalid type %d\n", type);
+	default: 	      DCCP_WARN("invalid type %d\n", type);
 			      return 1;
 
 	}
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -128,21 +128,18 @@ static int dccp_check_seqno(struct sock 
 		     DCCP_PKT_WITHOUT_ACK_SEQ))
 			dp->dccps_gar = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	} else {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: Step 6 failed for %s packet, "
-					    "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
-					    "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
-					    "sending SYNC...\n",
-			       dccp_packet_name(dh->dccph_type),
-			       (unsigned long long) lswl,
-			       (unsigned long long)
-			       DCCP_SKB_CB(skb)->dccpd_seq,
-			       (unsigned long long) dp->dccps_swh,
-			       (DCCP_SKB_CB(skb)->dccpd_ack_seq =
+		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
+			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
+			  "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
+			  "sending SYNC...\n",  dccp_packet_name(dh->dccph_type),
+			  (unsigned long long) lswl,
+			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq,
+			  (unsigned long long) dp->dccps_swh,
+			  (DCCP_SKB_CB(skb)->dccpd_ack_seq =
 			        DCCP_PKT_WITHOUT_ACK_SEQ) ? "doesn't exist" : "exists",
-			       (unsigned long long) lawl,
-			       (unsigned long long)
-			       DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			       (unsigned long long) dp->dccps_awh);
+			  (unsigned long long) lawl,
+			  (unsigned long long) DCCP_SKB_CB(skb)->dccpd_ack_seq,
+			  (unsigned long long) dp->dccps_awh);
 		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq, DCCP_PKT_SYNC);
 		return -1;
 	}
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -747,7 +747,7 @@ int dccp_invalid_packet(struct sk_buff *
 
 	/* If the packet is shorter than 12 bytes, drop packet and return */
 	if (!pskb_may_pull(skb, sizeof(struct dccp_hdr))) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: pskb_may_pull failed\n");
+		DCCP_WARN("pskb_may_pull failed\n");
 		return 1;
 	}
 
@@ -755,7 +755,7 @@ int dccp_invalid_packet(struct sk_buff *
 
 	/* If P.type is not understood, drop packet and return */
 	if (dh->dccph_type >= DCCP_PKT_INVALID) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: invalid packet type\n");
+		DCCP_WARN("invalid packet type\n");
 		return 1;
 	}
 
@@ -763,16 +763,14 @@ int dccp_invalid_packet(struct sk_buff *
 	 * If P.Data Offset is too small for packet type, drop packet and return
 	 */
 	if (dh->dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too small\n", dh->dccph_doff);
+		DCCP_WARN("P.Data Offset(%u) too small\n", dh->dccph_doff);
 		return 1;
 	}
 	/*
 	 * If P.Data Offset is too too large for packet, drop packet and return
 	 */
 	if (!pskb_may_pull(skb, dh->dccph_doff * sizeof(u32))) {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.Data Offset(%u) "
-					    "too large\n", dh->dccph_doff);
+		DCCP_WARN("P.Data Offset(%u) too large\n", dh->dccph_doff);
 		return 1;
 	}
 
@@ -782,9 +780,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 */
 	if (dh->dccph_type >= DCCP_PKT_DATA    &&
 	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x = 0)  {
-		LIMIT_NETDEBUG(KERN_WARNING "DCCP: P.type (%s) not Data||Ack||"
-					    "DataAck, while P.X = 0\n",
-			       dccp_packet_name(dh->dccph_type));
+		DCCP_WARN("P.type (%s) not Data || [Data]Ack, while P.X = 0\n",
+			  dccp_packet_name(dh->dccph_type));
 		return 1;
 	}
 
@@ -794,9 +791,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 */
 	cscov = dccp_csum_coverage(skb);
 	if (cscov > skb->len) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "DCCP: P.CsCov %u exceeds packet length %d\n",
-			       dh->dccph_cscov, skb->len);
+		DCCP_WARN("P.CsCov %u exceeds packet length %d\n",
+			  dh->dccph_cscov, skb->len);
 		return 1;
 	}
 
@@ -823,9 +819,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 
 	/* Step 1: If header checksum is incorrect, drop packet and return */
 	if (dccp_v4_csum_finish(skb, skb->nh.iph->saddr, skb->nh.iph->daddr)) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "%s: dropped packet with invalid checksum\n",
-			       __FUNCTION__);
+		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
 
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -828,9 +828,7 @@ static int dccp_v6_rcv(struct sk_buff **
 	/* Step 1: If header checksum is incorrect, drop packet and return. */
 	if (dccp_v6_csum_finish(skb, &skb->nh.ipv6h->saddr,
 				     &skb->nh.ipv6h->daddr)) {
-		LIMIT_NETDEBUG(KERN_WARNING
-			       "%s: dropped packet with invalid checksum\n",
-			       __FUNCTION__);
+		DCCP_WARN("dropped packet with invalid checksum\n");
 		goto discard_it;
 	}
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -257,7 +257,7 @@ int dccp_parse_options(struct sock *sk, 
 out_invalid_option:
 	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
-	pr_info("DCCP(%p): invalid option %d, len=%d\n", sk, opt, len);
+	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
 	return -1;
 }
 
@@ -447,8 +447,7 @@ static int dccp_insert_feat_opt(struct s
 	u8 *to;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 3 > DCCP_MAX_OPT_LEN) {
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: packet too small"
-			       " to insert feature %d option!\n", feat);
+		DCCP_WARN("packet too small for feature %d option!\n", feat);
 		return -1;
 	}
 
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -587,8 +587,10 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 		/* p should be 0 unless there is a bug in my code */
 		index = 0;
 
-	if (R = 0)
+	if (R = 0) {
+		DCCP_WARN("RTT=0, setting to 1\n");
 		R = 1; /* RTT can't be zero or else divide by zero */
+	}
 
 	DCCP_BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -84,8 +84,7 @@ void dccp_time_wait(struct sock *sk, int
 		 * socket up.  We've got bigger problems than
 		 * non-graceful socket closings.
 		 */
-		LIMIT_NETDEBUG(KERN_INFO "DCCP: time wait bucket "
-					 "table overflow\n");
+		DCCP_WARN("time wait bucket table overflow\n");
 	}
 
 	dccp_done(sk);
