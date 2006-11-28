From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 21:31:41 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611282131.41490@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > > In short: my suggestion is to keep an experimental patch for this and I would even offer to
|  > >           keep one up-to-date and online, if in return we can simplify the socket API. Does
|  > >           this sound like a more convincing argument?
|  >
|  > Fair enough, I think we should go this way for now, please post here
|  > the patch that provides the experimental feature of explicitely
|  > setting the packet size, interested people can try and use it and
|  > report their findings, later we can get back and possibly merge the
|  > patch if it proves useful.
|  >
|  Basically my patches from a month or two ago would do this with a  few
|  changes. I'd say merge average patch, I'll update mine to go on top
|  (tomorrow??) and allow a mechanism to switch to use it.
To make your work a trifle easier, I have performed and combined the two patches I have sent
to give a reverse patch. The one below works on top of the current tree and basically restores
the state of before the moving-average.

------------------------here is the patch-----------------------------------------------------
[DCCP]: Experimental Patch -- Set packet size `s' via socket options

This patch is for experimentation and research and makes it possible to 
explicitly set the CCID 3 packet size `s' via socket options. 

This feature overrides the in-kernel automatic tracking of packet sizes in the
CCID 3 module. 

To make use of this feature, use e.g.

  int psizd = 512;        /* your fixed application payload size */

  setsockopt(fd, SOL_DCCP, DCCP_SOCKOPT_PACKET_SIZE, &psize, sizeof(psize));

and a corresponding getsockopt() call.

---
 include/linux/dccp.h   |    4 ++-
 net/dccp/ccids/ccid3.c |   54 +++++++++++++++----------------------------------
 net/dccp/ccids/ccid3.h |    4 +++
 net/dccp/proto.c       |    8 +++----
 4 files changed, 28 insertions(+), 42 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -161,24 +161,6 @@ static void ccid3_hc_tx_update_x(struct 
 		ccid3_update_send_time(hctx);
 }
 
-/*
- * 	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
- * 	@len: DCCP packet payload size in bytes
- */
-static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
-{
-	if(len = 0)
-		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
-	else
-		hctx->ccid3hctx_s = (hctx->ccid3hctx_s = 0)?	len
-				  : (9 * hctx->ccid3hctx_s + len) / 10;
-
-	/* Note: We could do a potential optimisation here - when `s' changes,
-	         recalculate sending rate and consequently t_ipi, t_delta, and
-		 t_now. This is however non-standard, and the benefits are not
-		 clear, so it is currently left out.                          */
-}
-
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -317,7 +299,6 @@ static int ccid3_hc_tx_send_packet(struc
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
 		/* Set initial sending rate to 1 packet per second */
-		ccid3_hc_tx_update_s(hctx, skb->len);
 		hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
@@ -368,8 +349,6 @@ static void ccid3_hc_tx_packet_sent(stru
 
 	dccp_timestamp(sk, &now);
 
-	ccid3_hc_tx_update_s(hctx, len);
-
 	packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("packet doesn't exist in history!\n");
@@ -612,9 +591,15 @@ static int ccid3_hc_tx_parse_options(str
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_s     = 0;
+	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
+	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
+		hctx->ccid3hctx_s = dp->dccps_packet_size;
+	else
+		hctx->ccid3hctx_s = TFRC_STD_PACKET_SIZE;
+
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
@@ -668,15 +653,6 @@ static void ccid3_hc_rx_set_state(struct
 	hcrx->ccid3hcrx_state = state;
 }
 
-static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
-{
-	if(len = 0)		/* don't update on empty packets (e.g. ACKs) */
-		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
-	else
-		hcrx->ccid3hcrx_s = (hcrx->ccid3hcrx_s = 0)?	len
-				  : (9 * hcrx->ccid3hcrx_s + len) / 10;
-}
-
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -953,7 +929,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
-	int loss, payload_size;
+	int loss;
 
 	BUG_ON(hcrx = NULL);
 
@@ -1008,9 +984,6 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
 		return;
 
-	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-	ccid3_hc_rx_update_s(hcrx, payload_size);
-
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		ccid3_pr_debug("%s, sk=%p(%s), skb=%p, sending initial "
@@ -1021,7 +994,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
 	case TFRC_RSTATE_DATA:
-		hcrx->ccid3hcrx_bytes_recv += payload_size;
+		hcrx->ccid3hcrx_bytes_recv += skb->len -
+					      dccp_hdr(skb)->dccph_doff * 4;
 		if (loss)
 			break;
 
@@ -1061,16 +1035,22 @@ static void ccid3_hc_rx_packet_recv(stru
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
+	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
+	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
+		hcrx->ccid3hcrx_s = dp->dccps_packet_size;
+	else
+		hcrx->ccid3hcrx_s = TFRC_STD_PACKET_SIZE;
+
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
 	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
-	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 5000; /* XXX 5ms for now... */
 	return 0;
 }
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -200,7 +200,7 @@ struct dccp_so_feat {
 };
 
 /* DCCP socket options */
-#define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
+#define DCCP_SOCKOPT_PACKET_SIZE	1
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
@@ -460,6 +460,7 @@ struct dccp_ackvec;
  * @dccps_service_list - second .. last service code on passive socket
  * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
+ * @dccps_packet_size - Set thru setsockopt
  * @dccps_l_ack_ratio -
  * @dccps_r_ack_ratio -
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
@@ -494,6 +495,7 @@ struct dccp_sock {
 	struct dccp_service_list	*dccps_service_list;
 	struct timeval			dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
+	__u32				dccps_packet_size;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
 	__u16				dccps_pcslen;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -42,6 +42,10 @@
 #include <linux/tfrc.h>
 #include "../ccid.h"
 
+#define TFRC_MIN_PACKET_SIZE	   16
+#define TFRC_STD_PACKET_SIZE	  256
+#define TFRC_MAX_PACKET_SIZE	65535
+
 /* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -470,8 +470,7 @@ static int do_dccp_setsockopt(struct soc
 	lock_sock(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
-		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		err = -EINVAL;
+		dp->dccps_packet_size = val;
 		break;
 	case DCCP_SOCKOPT_CHANGE_L:
 		if (optlen != sizeof(struct dccp_so_feat))
@@ -582,8 +581,9 @@ static int do_dccp_getsockopt(struct soc
 
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
-		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		return -EINVAL;
+		val = dp->dccps_packet_size;
+		len = sizeof(dp->dccps_packet_size);
+		break;
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);


