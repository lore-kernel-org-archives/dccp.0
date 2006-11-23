From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Nov 2006 14:53:06 +0000
Subject: [PATCH v2 - RESEND]:  [CCID 3]: Track RX/TX packet size `s' using moving-average
Message-Id: <200611231453.06708@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am resending this since I have checked this against possible cases and fixed 
the following cases:
	* the packet size `s' has to be seeded when the first packet is sent, since
          several calculations later depend on `s'
          This is now done, and an analysis has been added that this is safe.

	* It is perfectly ok and not a bug condition for a receiver to receive packets
          with a zero packet size. I have therefore removed the BUG_ON conditions and
          replaced them with ccid3_pr_debug messages - these can be switched off at will

	* has been uploaded to replace the previous version on 
          http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/12e_CCID3_packet_size_EWMA.diff

--------------> Commit message <------------------------------------------------------

[CCID 3]: Track RX/TX packet size `s' using moving-average


Problem:
--------
 Currently, the receiver/sender packet size `s' of the TCP throughput
 equation [RFC 3448, 3.1] has to be communicated manually via socket options
 to the CCID 3 module. This has been discussed on dccp@vger, see e.g.
 http://www.mail-archive.com/dccp@vger.kernel.org/msg00582.html

Solution 
--------
 This patch implements automatically tracking the packet size `s', for receiver and
 sender. Socket options to commmunicate the packet size are then no longer needed.
 It implements the strategy presented on 
       http://www.mail-archive.com/dccp@vger.kernel.org/msg00581.html

 
Assumptions:
------------
 Several other bits of code rely on the value of `s' being set. This patch has been verified to 
 ensure that `s' is not unset (i.e. 0) when other functions try to use it:
  * ccid3_hc_tx_send_packet only sends packets with a payload size > 0
  * the `s' value is seeded upon first sending (state NO_SENT)
  * the functions which access `s' are 
	ccid3_hc_tx_no_feedback_timer  - safe, since first started at the time where `s' is seeded
	ccid3_hc_tx_packet_recv        - safe, since this is after `s' has been seeded
  	ccid3_calc_new_t_ipi           - safe, since first called after sending or upon feedback
        ccid3_hc_tx_update_x           - safe, since first called upon feedback or within 
	                                       ccid3_hc_tx_no_feedback_timer

    --all apart from no_feedback_timer are safe since the first time that these are called is
      when the first feedback arrives (i.e. after `s' bytes have been sent and s is not 0)
    --ccid3_hc_tx_no_feedback_timer has an issue if 


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   59 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 40 insertions(+), 19 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -151,6 +151,24 @@ static void ccid3_hc_tx_update_x(struct 
 	}
 }
 
+/*
+ * 	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
+ * 	@len: DCCP packet payload size in bytes
+ */
+static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
+{
+	if(len = 0)
+		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
+	else
+		hctx->ccid3hctx_s = (hctx->ccid3hctx_s = 0)?	len
+				  : (9 * hctx->ccid3hctx_s + len) / 10;
+
+	/* Note: We could do a potential optimisation here - when `s' changes,
+	         recalculate sending rate and consequently t_ipi, t_delta, and
+		 t_now. This is however non-standard, and the benefits are not
+		 clear, so it is currently left out.                          */
+}
+
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -297,6 +315,10 @@ static int ccid3_hc_tx_send_packet(struc
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
+		/* Set initial sending rate to 1 packet per second */
+		ccid3_hc_tx_update_s(hctx, len);
+		hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
+
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
 		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
 		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
@@ -348,6 +370,8 @@ static void ccid3_hc_tx_packet_sent(stru
 		unsigned long quarter_rtt;
 		struct dccp_tx_hist_entry *packet;
 
+		ccid3_hc_tx_update_s(hctx, len);
+
 		packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 		if (unlikely(packet = NULL)) {
 			DCCP_WARN("packet doesn't exist in history!\n");
@@ -626,17 +650,9 @@ static int ccid3_hc_tx_parse_options(str
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hctx->ccid3hctx_s = dp->dccps_packet_size;
-	else
-		hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
-
-	/* Set transmission rate to 1 packet per second */
-	hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
+	hctx->ccid3hctx_s     = 0;
 	hctx->ccid3hctx_t_rto = USEC_PER_SEC;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
@@ -691,6 +707,15 @@ static void ccid3_hc_rx_set_state(struct
 	hcrx->ccid3hcrx_state = state;
 }
 
+static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
+{
+	if(len = 0)		/* don't update on empty packets (e.g. ACKs) */
+		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
+	else
+		hcrx->ccid3hcrx_s = (hcrx->ccid3hcrx_s = 0)?	len
+				  : (9 * hcrx->ccid3hcrx_s + len) / 10;
+}
+
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -967,7 +992,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
-	int loss;
+	int loss, payload_size;
 
 	BUG_ON(hcrx = NULL);
 
@@ -1022,6 +1047,9 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
 
+	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	ccid3_hc_rx_update_s(hcrx, payload_size);
+
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		ccid3_pr_debug("%s, sk=%p(%s), skb=%p, sending initial "
@@ -1032,8 +1060,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
 	case TFRC_RSTATE_DATA:
-		hcrx->ccid3hcrx_bytes_recv += skb->len -
-					      dccp_hdr(skb)->dccph_doff * 4;
+		hcrx->ccid3hcrx_bytes_recv += payload_size;
 		if (loss)
 			break;
 
@@ -1073,22 +1100,16 @@ static void ccid3_hc_rx_packet_recv(stru
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
-	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
-	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
-		hcrx->ccid3hcrx_s = dp->dccps_packet_size;
-	else
-		hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
-
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
 	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
+	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 5000; /* XXX 5ms for now... */
 	return 0;
 }
