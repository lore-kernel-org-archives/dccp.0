From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Oct 2010 05:16:25 +0000
Subject: [PATCH 1/4] dccp: Return-value convention of hc_tx_send_packet()
Message-Id: <1288242988-5333-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch reorganises the return value convention of the CCID TX sending
function, to permit more flexible schemes, as required by subsequent patches.

Currently the convention is
 * values < 0     mean error,
 * a value = 0   means "send now", and
 * a value x > 0  means "send in x milliseconds".

The patch provides symbolic constants and a function to interpret return values.

In addition, it caps the maximum positive return value to 0xFFFF milliseconds,
corresponding to 65.535 seconds.  This is possible since in CCID-3/4 the
maximum possible inter-packet gap is fixed at t_mbi = 64 sec.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |   34 +++++++++++++++++++++++++++++++---
 net/dccp/ccids/ccid3.c |   12 ++++++------
 2 files changed, 37 insertions(+), 9 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -134,13 +134,41 @@ static inline int ccid_get_current_tx_ccid(struct dccp_sock *dp)
 extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
+/*
+ * Congestion control of queued data packets via CCID decision.
+ *
+ * The TX CCID performs its congestion-control by indicating whether and when a
+ * queued packet may be sent, using the return code of ccid_hc_tx_send_packet().
+ * The following modes are supported via the symbolic constants below:
+ * - timer-based pacing    (CCID returns a delay value in milliseconds);
+ * - autonomous dequeueing (CCID internally schedules dccps_xmitlet).
+ */
+
+enum ccid_dequeueing_decision {
+	CCID_PACKET_SEND_AT_ONCE =	 0x00000,  /* "green light": no delay */
+	CCID_PACKET_DELAY_MAX =		 0x0FFFF,  /* maximum delay in msecs  */
+	CCID_PACKET_DELAY =		 0x10000,  /* CCID msec-delay mode */
+	CCID_PACKET_WILL_DEQUEUE_LATER = 0x20000,  /* CCID autonomous mode */
+	CCID_PACKET_ERR =		 0xF0000,  /* error condition */
+};
+
+static inline int ccid_packet_dequeue_eval(const int return_code)
+{
+	if (return_code < 0)
+		return CCID_PACKET_ERR;
+	if (return_code = 0)
+		return CCID_PACKET_SEND_AT_ONCE;
+	if (return_code <= CCID_PACKET_DELAY_MAX)
+		return CCID_PACKET_DELAY;
+	return return_code;
+}
+
 static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
 					 struct sk_buff *skb)
 {
-	int rc = 0;
 	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
-		rc = ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
-	return rc;
+		return ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -268,11 +268,11 @@ out:
 	sock_put(sk);
 }
 
-/*
- * returns
- *   > 0: delay (in msecs) that should pass before actually sending
- *   = 0: can send immediately
- *   < 0: error condition; do not send packet
+/**
+ * ccid3_hc_tx_send_packet  -  Delay-based dequeueing of TX packets
+ * @skb: next packet candidate to send on @sk
+ * This function uses the convention of ccid_packet_dequeue_eval() and
+ * returns a millisecond-delay value between 0 and t_mbi = 64000 msec.
  */
 static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
@@ -348,7 +348,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 
 	/* set the nominal send time for the next following packet */
 	hc->tx_t_nom = ktime_add_us(hc->tx_t_nom, hc->tx_t_ipi);
-	return 0;
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
