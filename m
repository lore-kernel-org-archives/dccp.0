From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:45:39 +0000
Subject: [PATCH 5/6]: Track RX/TX packet size `s' using moving-average
Message-Id: <200611211545.40156@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>


	 	J u s t i f i c a t i o n  [not meant as commit message]
		============================

 The packet size `s' is one of the main parameters of the TFRC mechanism. The TFRC sender uses
 `s' in the (i) throughput equation, in the setting of the (ii) maximum receive rate, 
 (iii) minimum sending rate, and (iv) the nofeedback timer;  the TFRC receiver `s' (aka segment
  size) to  compute the initial loss history, after the first loss event. 
 
 Hence using socket options to communicate `s' is error-prone whenever the user-space program
 communicates values of `s' to the CCID 3 module that differ from the real value of `s';
 ultimately such differences not only increase the possibility of error but can also decrease 
 the performance. 
 
 Using the mean value of the packet size is an accepted practice, supported e.g. by 
  * RFC 4342, sec. 5.3:
     "A CCID 3 implementation MAY calculate s as the segment size averaged over 
      multiple round trip times [...]."
 
  * RFC 3448, sec. 4.1:
     "It should normally be safe to use an estimate of the mean packet size for s."

  * draft-ietf-dccp-rfc3448bis-00.txt, sec. 
    "[... ] where the segment size varies depending on the data, the sender MAY estimate
     the segment size s as the average segment size over the last four loss intervals. The
     sender MAY also estimate the average segment size over longer time intervals [...]."

 This solution is robust: if packet sizes are varying, the moving average is a reliable
 predictor of the (long-term) mean value; if packet sizes are fixed then s stays constant.

 The solution uses DCCP payload packet sizes, i.e.  IP payload size minus DCCP Data Offset
 value. This is consistent with the recommendations in RFC 4342, section 5.3: 
     "Alternately, a CCID 3 implementation MAY use the Maximum Packet Size
      to derive s.  In this case, s is set to the Maximum Segment Size
      (MSS), the maximum size in bytes for the data segment, not including
      the default DCCP and IP packet headers."
 It is further consistent with the definition of MSS in RFC 879 and the use of payload size
 as length value in the DCCP module.
 [See also http://www.mail-archive.com/dccp@vger.kernel.org/msg00534.html ]

---
 net/dccp/ccids/ccid3.c |   48 +++++++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 19 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -151,6 +151,18 @@ static void ccid3_hc_tx_update_x(struct 
 	}
 }
 
+/*
+ * 	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
+ * 	@len: DCCP packet payload size in bytes
+ */
+static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
+{
+	DCCP_BUG_ON(len = 0);
+
+	hctx->ccid3hctx_s = (hctx->ccid3hctx_s = 0)?    len
+			  : (9 * hctx->ccid3hctx_s + len) / 10;
+}
+
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -347,6 +359,8 @@ static void ccid3_hc_tx_packet_sent(stru
 		unsigned long quarter_rtt;
 		struct dccp_tx_hist_entry *packet;
 
+		ccid3_hc_tx_update_s(hctx, len);
+
 		packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 		if (unlikely(packet = NULL)) {
 			DCCP_WARN("packet doesn't exist in history!\n");
@@ -625,17 +639,9 @@ static int ccid3_hc_tx_parse_options(str
 
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
@@ -690,6 +696,14 @@ static void ccid3_hc_rx_set_state(struct
 	hcrx->ccid3hcrx_state = state;
 }
 
+static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
+{
+	DCCP_BUG_ON(len = 0);
+
+	hcrx->ccid3hcrx_s = (hcrx->ccid3hcrx_s = 0)?  len
+			  : (9 * hcrx->ccid3hcrx_s + len) / 10;
+}
+
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -966,7 +980,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
-	int loss;
+	int loss, payload_size;
 
 	BUG_ON(hcrx = NULL);
 
@@ -1021,6 +1035,9 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
 
+	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	ccid3_hc_rx_update_s(hcrx, payload_size);
+
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		ccid3_pr_debug("%s, sk=%p(%s), skb=%p, sending initial "
@@ -1031,8 +1048,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
 	case TFRC_RSTATE_DATA:
-		hcrx->ccid3hcrx_bytes_recv += skb->len -
-					      dccp_hdr(skb)->dccph_doff * 4;
+		hcrx->ccid3hcrx_bytes_recv += payload_size;
 		if (loss)
 			break;
 
@@ -1072,22 +1088,16 @@ static void ccid3_hc_rx_packet_recv(stru
 
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
