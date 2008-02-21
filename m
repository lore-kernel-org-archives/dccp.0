From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:26 +0000
Subject: [PATCH 08/10] [ACKVEC]: Schedule SyncAck when running out of space
Message-Id: <1203584968-8957-9-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The problem with Ack Vectors is that

  i) their length is variable and can in principle grow quite large,
 ii) it is hard to predict exactly how large they will be.

 Due to the second point it seems not a good idea to reduce the MPS;
i particular when on average there is enough room for the Ack Vector
and an increase in length is momentarily due to some burst loss, after
which the Ack Vector returns to its normal/average length.

The solution taken by this patch to address the outstanding FIXME is
to schedule a separate Sync when running out of space on the skb, and to
log a warning into the syslog.

The mechanism can also be used for other out-of-band signalling: it does
quicker signalling than scheduling an Ack, since it does not need to wait
for new data.

 Additional Note regarding MPS:
 -----------------------------
 It is possible to lower MPS according to the average length of Ack Vectors;
 the following argues why this does not seem to be a good idea.

 When determining the average Ack Vector length, a moving-average is more
 useful than a normal average, since sudden peaks (burst losses) are better
 dampened. The Ack Vector buffer would have a field `av_avg_len' which tracks
 this moving average and MPS would be reduced by this value (plus 2 bytes for
 type/value for each full Ack Vector).

 However, this means that the MPS decreases in the middle of an established
 connection. For a user who has tuned his/her application to work with the
 MPS taken at the beginning of the connection this can be very counter-
 intuitive and annoying.

 (Over the long term there should be some adjustment to reduce MPS at least
  by a minimum when Ack Vectors are used; some applications may rely on the
  exact value of the MPS).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    2 ++
 net/dccp/options.c   |   23 +++++++++++++++++++----
 net/dccp/output.c    |    8 ++++++++
 3 files changed, 29 insertions(+), 4 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -475,6 +475,7 @@ struct dccp_ackvec;
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
  * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
+ * @dccps_sync_scheduled - flag which signals "send out-of-band message soon"
  * @dccps_xmit_timer - timer for when CCID is not ready to send
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
@@ -515,6 +516,7 @@ struct dccp_sock {
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
 	__u8				dccps_server_timewait:1;
+	__u8				dccps_sync_scheduled:1;
 	struct timer_list		dccps_xmit_timer;
 };
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -290,6 +290,8 @@ void dccp_write_xmit(struct sock *sk, int block)
 			if (err)
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
+			if (dp->dccps_sync_scheduled)
+				dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
 		} else {
 			dccp_pr_debug("packet discarded due to err=%d\n", err);
 			kfree_skb(skb);
@@ -562,6 +564,12 @@ void dccp_send_sync(struct sock *sk, const u64 ackno,
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
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -428,6 +428,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
 	const u16 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
@@ -436,10 +437,24 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
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
+	if (dcb->dccpd_opt_len + skb->len + len > dp->dccps_mss_cache) {
+		DCCP_WARN("No space left for Ack Vector (%u) on skb (%u+%u), "
+			  "MPS=%u => reduce payload size?\n", len, skb->len,
+			  dcb->dccpd_opt_len, dp->dccps_mss_cache);
+		dp->dccps_sync_scheduled = 1;
+		return 0;
+	}
+	dcb->dccpd_opt_len += len;
 
 	to   = skb_push(skb, len);
 	len  = buflen;
@@ -480,7 +495,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Each sent Ack Vector is recorded in the list, as per A.2 of RFC 4340.
 	 */
-	if (dccp_ackvec_update_records(av, DCCP_SKB_CB(skb)->dccpd_seq, nonce))
+	if (dccp_ackvec_update_records(av, dcb->dccpd_seq, nonce))
 		return -ENOBUFS;
 	return 0;
 }
 
