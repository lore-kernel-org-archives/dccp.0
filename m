From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:02 +0000
Subject: [PATCH 11/25] Share TFRC sender states via tfrc_ccids
Message-Id: <200710312131.03012.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share TFRC sender states via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -52,7 +52,7 @@ DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
  *	Transmitter Half-Connection Routines
  */
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
+static const char *ccid3_tx_state_name(enum tfrc_hc_tx_states state)
 {
 	static char *ccid3_state_names[] = {
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
@@ -66,16 +66,16 @@ static const char *ccid3_tx_state_name(e
 #endif
 
 static void ccid3_hc_tx_set_state(struct sock *sk,
-				  enum ccid3_hc_tx_states state)
+				  enum tfrc_hc_tx_states state)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	enum ccid3_hc_tx_states oldstate = hctx->ccid3hctx_state;
+	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
 		       ccid3_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->ccid3hctx_state = state;
+	hctx->tfrchctx_state = state;
 }
 
 /*
@@ -229,11 +229,11 @@ static void ccid3_hc_tx_no_feedback_time
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->ccid3hctx_state));
+		       ccid3_tx_state_name(hctx->tfrchctx_state));
 
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_FBACK)
+	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+	else if (hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
 		goto out;
 
 	/*
@@ -312,7 +312,7 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->ccid3hctx_state) {
+	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 			       (jiffies +
@@ -401,7 +401,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		return;
 
 	/* ... and only in the established state */
-	switch (hctx->ccid3hctx_state) {
+	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_FBACK:	/* fall through */
 	case TFRC_SSTATE_FBACK:		break;
 	default:			return;
@@ -439,7 +439,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	/*
 	 *	Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
+	if (hctx->tfrchctx_state = TFRC_SSTATE_NO_FBACK) {
 
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
@@ -573,7 +573,7 @@ static int ccid3_hc_tx_init(struct ccid 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
+	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
 	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
 
 	hctx->ccid3hctx_no_feedback_timer.function Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -39,14 +39,6 @@
 #include "lib/tfrc_ccids.h"
 #include "../ccid.h"
 
-/* TFRC sender states */
-enum ccid3_hc_tx_states {
-	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
-};
-
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
  * @ccid3hctx_x - Current sending rate in 64 * bytes per second
@@ -57,7 +49,7 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_s - Packet size in bytes
  * @ccid3hctx_t_rto - Nofeedback Timer setting in usecs
  * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
+ * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
  * @ccid3hctx_last_win_count - Last window counter sent
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
  *				 with last_win_count value sent
@@ -78,7 +70,7 @@ struct ccid3_hc_tx_sock {
 #define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
 #define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
 	u16				ccid3hctx_s;
-	enum ccid3_hc_tx_states		ccid3hctx_state:8;
+	enum tfrc_hc_tx_states	tfrchctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -62,7 +62,7 @@ DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
  *	Transmitter Half-Connection Routines
  */
 #ifdef CONFIG_IP_DCCP_CCID4_DEBUG
-static const char *ccid4_tx_state_name(enum ccid4_hc_tx_states state)
+static const char *ccid4_tx_state_name(enum tfrc_hc_tx_states state)
 {
 	static char *ccid4_state_names[] = {
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
@@ -76,16 +76,16 @@ static const char *ccid4_tx_state_name(e
 #endif
 
 static void ccid4_hc_tx_set_state(struct sock *sk,
-				  enum ccid4_hc_tx_states state)
+				  enum tfrc_hc_tx_states state)
 {
 	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
-	enum ccid4_hc_tx_states oldstate = hctx->ccid4hctx_state;
+	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid4_tx_state_name(oldstate),
 		       ccid4_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->ccid4hctx_state = state;
+	hctx->tfrchctx_state = state;
 }
 
 /*
@@ -255,11 +255,11 @@ static void ccid4_hc_tx_no_feedback_time
 	}
 
 	ccid4_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid4_tx_state_name(hctx->ccid4hctx_state));
+		       ccid4_tx_state_name(hctx->tfrchctx_state));
 
-	if (hctx->ccid4hctx_state = TFRC_SSTATE_FBACK)
+	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
 		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->ccid4hctx_state != TFRC_SSTATE_NO_FBACK)
+	else if (hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
 		goto out;
 
 	/*
@@ -338,7 +338,7 @@ static int ccid4_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->ccid4hctx_state) {
+	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
 			       (jiffies +
@@ -427,7 +427,7 @@ static void ccid4_hc_tx_packet_recv(stru
 		return;
 
 	/* ... and only in the established state */
-	switch (hctx->ccid4hctx_state) {
+	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_FBACK:	/* fall through */
 	case TFRC_SSTATE_FBACK:		break;
 	default:			return;
@@ -465,7 +465,7 @@ static void ccid4_hc_tx_packet_recv(stru
 	/*
 	 *	Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->ccid4hctx_state = TFRC_SSTATE_NO_FBACK) {
+	if (hctx->tfrchctx_state = TFRC_SSTATE_NO_FBACK) {
 
 		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
@@ -599,7 +599,7 @@ static int ccid4_hc_tx_init(struct ccid 
 {
 	struct ccid4_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid4hctx_state = TFRC_SSTATE_NO_SENT;
+	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
 	tfrc_tx_hist_init(&hctx->ccid4hctx_hist, ccid4_tx_hist);
 
 	hctx->ccid4hctx_no_feedback_timer.function Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -62,14 +62,6 @@
  */
 #define CCID4HCTX_H    36
 
-/* TFRC sender states */
-enum ccid4_hc_tx_states {
-	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
-};
-
 /** struct ccid4_hc_tx_sock - CCID4 sender half-connection socket
  *
  * @ccid4hctx_x - Current sending rate in 64 * bytes per second
@@ -80,7 +72,7 @@ enum ccid4_hc_tx_states {
  * @ccid4hctx_s - Packet size in bytes
  * @ccid4hctx_t_rto - Nofeedback Timer setting in usecs
  * @ccid4hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @ccid4hctx_state - Sender state, one of %ccid4_hc_tx_states
+ * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
  * @ccid4hctx_last_win_count - Last window counter sent
  * @ccid4hctx_t_last_win_count - Timestamp of earliest packet
  *				 with last_win_count value sent
@@ -101,7 +93,7 @@ struct ccid4_hc_tx_sock {
 #define ccid4hctx_t_rto			ccid4hctx_tfrc.tfrctx_rto
 #define ccid4hctx_t_ipi			ccid4hctx_tfrc.tfrctx_ipi
 	u16				ccid4hctx_s;
-	enum ccid4_hc_tx_states		ccid4hctx_state:8;
+	enum tfrc_hc_tx_states	tfrchctx_state:8;
 	u8				ccid4hctx_last_win_count;
 	ktime_t				ccid4hctx_t_last_win_count;
 	struct timer_list		ccid4hctx_no_feedback_timer;
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -45,3 +45,12 @@ struct tfrc_options_received {
 	u32 tfrcor_loss_event_rate;
 	u32 tfrcor_receive_rate;
 };
+
+/* TFRC sender states */
+enum tfrc_hc_tx_states {
+	TFRC_SSTATE_NO_SENT = 1,
+	TFRC_SSTATE_NO_FBACK,
+	TFRC_SSTATE_FBACK,
+	TFRC_SSTATE_TERM,
+};
+
