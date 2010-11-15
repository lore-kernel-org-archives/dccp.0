From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 06:29:05 +0000
Subject: [PATCH 4/6] dccp ccid-2: Schedule Sync as out-of-band mechanism
Message-Id: <1289802547-5617-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The problem with Ack Vectors is that
  i) their length is variable and can in principle grow quite large,
 ii) it is hard to predict exactly how large they will be.

Due to the second point it seems not a good idea to reduce the MPS; in
particular when on average there is enough room for the Ack Vector and an
increase in length is momentarily due to some burst loss, after which the
Ack Vector returns to its normal/average length.

The solution taken by this patch is to subtract a minimum-expected Ack Vector
length from the MPS, and to defer any larger Ack Vectors onto a separate
Sync - but only if indeed there is no space left on the skb.

This patch provides the infrastructure to schedule Sync-packets for transporting
(urgent) out-of-band data. Its signalling is quicker than scheduling an Ack, since
it does not need to wait for new application data.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    2 ++
 net/dccp/options.c   |   24 ++++++++++++++++++++----
 net/dccp/output.c    |   15 +++++++++++++++
 3 files changed, 37 insertions(+), 4 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -462,6 +462,7 @@ struct dccp_ackvec;
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
  * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
+ * @dccps_sync_scheduled - flag which signals "send out-of-band message soon"
  * @dccps_xmitlet - tasklet scheduled by the TX CCID to dequeue data packets
  * @dccps_xmit_timer - used by the TX CCID to delay sending (rate-based pacing)
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
@@ -503,6 +504,7 @@ struct dccp_sock {
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
 	__u8				dccps_server_timewait:1;
+	__u8				dccps_sync_scheduled:1;
 	struct tasklet_struct		dccps_xmitlet;
 	struct timer_list		dccps_xmit_timer;
 };
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -427,6 +427,7 @@ static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
 	const u8 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
@@ -435,10 +436,25 @@ static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	const unsigned char *tail, *from;
 	unsigned char *to;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
+	if (dcb->dccpd_opt_len + len > DCCP_MAX_OPT_LEN) {
+		DCCP_WARN("Lacking space for %u bytes on %s packet\n", len,
+			  dccp_packet_name(dcb->dccpd_type));
 		return -1;
-
-	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
+	}
+	/*
+	 * Since Ack Vectors are variable-length, we can not always predict
+	 * their size. To catch exception cases where the space is running out
+	 * on the skb, a separate Sync is scheduled to carry the Ack Vector.
+	 */
+	if (len > DCCPAV_MIN_OPTLEN &&
+	    len + dcb->dccpd_opt_len + skb->len > dp->dccps_mss_cache) {
+		DCCP_WARN("No space left for Ack Vector (%u) on skb (%u+%u), "
+			  "MPS=%u => reduce payload size?\n", len, skb->len,
+			  dcb->dccpd_opt_len, dp->dccps_mss_cache);
+		dp->dccps_sync_scheduled = 1;
+		return 0;
+	}
+	dcb->dccpd_opt_len += len;
 
 	to   = skb_push(skb, len);
 	len  = buflen;
@@ -479,7 +495,7 @@ static int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Each sent Ack Vector is recorded in the list, as per A.2 of RFC 4340.
 	 */
-	if (dccp_ackvec_update_records(av, DCCP_SKB_CB(skb)->dccpd_seq, nonce))
+	if (dccp_ackvec_update_records(av, dcb->dccpd_seq, nonce))
 		return -ENOBUFS;
 	return 0;
 }
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -283,6 +283,15 @@ static void dccp_xmit_packet(struct sock *sk)
 	 * any local drop will eventually be reported via receiver feedback.
 	 */
 	ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);
+
+	/*
+	 * If the CCID needs to transfer additional header options out-of-band
+	 * (e.g. Ack Vectors or feature-negotiation options), it activates this
+	 * flag to schedule a Sync. The Sync will automatically incorporate all
+	 * currently pending header options, thus clearing the backlog.
+	 */
+	if (dp->dccps_sync_scheduled)
+		dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
 }
 
 /**
@@ -636,6 +645,12 @@ void dccp_send_sync(struct sock *sk, const u64 ackno,
 	DCCP_SKB_CB(skb)->dccpd_type = pkt_type;
 	DCCP_SKB_CB(skb)->dccpd_ack_seq = ackno;
 
+	/*
+	 * Clear the flag in case the Sync was scheduled for out-of-band data,
+	 * such as carrying a long Ack Vector.
+	 */
+	dccp_sk(sk)->dccps_sync_scheduled = 0;
+
 	dccp_transmit_skb(sk, skb);
 }
 
