From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Feb 2008 09:52:02 +0000
Subject: [PATCH 2/2] [ACKVEC]: Schedule Sync as out-of-band mechanism
Message-Id: <1203933122-27140-3-git-send-email-gerrit@erg.abdn.ac.uk>
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
length from the MPS (previous patch), and to defer any larger Ack Vectors onto
a separate Sync - but only if indeed there is no space left on the skb.

This patch provides the infrastructure to schedule Sync-packets for transporting
(urgent) out-of-band data. Its signalling is quicker than scheduling an Ack, since
it does not need to wait for new application data.

It can thus serve other parts of the DCCP code as well.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    2 ++
 net/dccp/options.c   |   24 ++++++++++++++++++++----
 net/dccp/output.c    |    8 ++++++++
 3 files changed, 30 insertions(+), 4 deletions(-)

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
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -428,6 +428,7 @@ int dccp_insert_option_ackvec(struct soc
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
 	const u16 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
@@ -436,10 +437,25 @@ int dccp_insert_option_ackvec(struct soc
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
@@ -480,7 +496,7 @@ int dccp_insert_option_ackvec(struct soc
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
@@ -292,6 +292,8 @@ void dccp_write_xmit(struct sock *sk, in
 			if (err)
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
+			if (dp->dccps_sync_scheduled)
+				dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
 		} else {
 			dccp_pr_debug("packet discarded due to err=%d\n", err);
 			kfree_skb(skb);
@@ -564,6 +566,12 @@ void dccp_send_sync(struct sock *sk, con
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
 
