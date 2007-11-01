From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:13 +0000
Subject: [PATCH 12/25] Share TFRC receiver states via tfrc_ccids
Message-Id: <200710312131.13219.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share TFRC receiver states via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -654,7 +654,7 @@ static int ccid4_hc_tx_getsockopt(struct
  *	Receiver Half-Connection Routines
  */
 #ifdef CONFIG_IP_DCCP_CCID4_DEBUG
-static const char *ccid4_rx_state_name(enum ccid4_hc_rx_states state)
+static const char *ccid4_rx_state_name(enum tfrc_hc_rx_states state)
 {
 	static char *ccid4_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
@@ -667,16 +667,16 @@ static const char *ccid4_rx_state_name(e
 #endif
 
 static void ccid4_hc_rx_set_state(struct sock *sk,
-				  enum ccid4_hc_rx_states state)
+				  enum tfrc_hc_rx_states state)
 {
 	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
-	enum ccid4_hc_rx_states oldstate = hcrx->ccid4hcrx_state;
+	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid4_rx_state_name(oldstate),
 		       ccid4_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->ccid4hcrx_state = state;
+	hcrx->tfrchcrx_state = state;
 }
 
 static inline void ccid4_hc_rx_update_s(struct ccid4_hc_rx_sock *hcrx, int len)
@@ -693,7 +693,7 @@ static void ccid4_hc_rx_send_feedback(st
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hcrx->ccid4hcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_TERM))
 		return;
 
 	switch (fbtype) {
@@ -810,7 +810,7 @@ static void ccid4_hc_rx_packet_recv(stru
 
 	spin_lock(&hcrx->ccid4hcrx_hist.lock);
 
-	if (unlikely(hcrx->ccid4hcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
 			ccid4_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
@@ -886,7 +886,7 @@ static int ccid4_hc_rx_init(struct ccid 
 	ccid4_pr_debug("entry\n");
 
 	tfrc_lh_init(&hcrx->ccid4hcrx_li_hist);
-	hcrx->ccid4hcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
 
 	return tfrc_rx_hist_init(&hcrx->ccid4hcrx_hist);
 }
@@ -903,7 +903,7 @@ static void ccid4_hc_rx_exit(struct sock
 
 static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid4_hc_rx_sk(sk)->ccid4hcrx_state;
+	info->tcpi_ca_state = ccid4_hc_rx_sk(sk)->tfrchcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
 	info->tcpi_rcv_rtt  = ccid4_hc_rx_sk(sk)->ccid4hcrx_rtt;
 }
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -111,13 +111,6 @@ static inline struct ccid4_hc_tx_sock *c
     return hctx;
 }
 
-/* CCID4 receiver states */
-enum ccid4_hc_rx_states {
-	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
-};
-
 /* CCID4 feedback types */
 enum ccid4_fback_type {
 	FBACK_NONE = 0,
@@ -129,7 +122,7 @@ enum ccid4_fback_type {
 /** struct ccid4_hc_rx_sock - CCID4 receiver half-connection socket
  *
  *  @ccid4hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid4hcrx_state  -  Receiver state, one of %ccid4_hc_rx_states
+ *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
  *  @ccid4hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid4hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @ccid4hcrx_rtt  -  Receiver estimate of RTT
@@ -141,7 +134,7 @@ enum ccid4_fback_type {
  */
 struct ccid4_hc_rx_sock {
 	u8				ccid4hcrx_last_counter:4;
-	enum ccid4_hc_rx_states		ccid4hcrx_state:8;
+	enum tfrc_hc_rx_states	tfrchcrx_state:8;
 	u32				ccid4hcrx_bytes_recv;
 	u32				ccid4hcrx_x_recv;
 	u32				ccid4hcrx_rtt;
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -54,3 +54,10 @@ enum tfrc_hc_tx_states {
 	TFRC_SSTATE_TERM,
 };
 
+/* TFRC receiver states */
+enum tfrc_hc_rx_states {
+	TFRC_RSTATE_NO_DATA = 1,
+	TFRC_RSTATE_DATA,
+	TFRC_RSTATE_TERM    = 127,
+};
+
Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -628,7 +628,7 @@ static int ccid3_hc_tx_getsockopt(struct
  *	Receiver Half-Connection Routines
  */
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
+static const char *ccid3_rx_state_name(enum tfrc_hc_rx_states state)
 {
 	static char *ccid3_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
@@ -641,16 +641,16 @@ static const char *ccid3_rx_state_name(e
 #endif
 
 static void ccid3_hc_rx_set_state(struct sock *sk,
-				  enum ccid3_hc_rx_states state)
+				  enum tfrc_hc_rx_states state)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_hc_rx_states oldstate = hcrx->ccid3hcrx_state;
+	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
 		       ccid3_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->ccid3hcrx_state = state;
+	hcrx->tfrchcrx_state = state;
 }
 
 static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
@@ -667,7 +667,7 @@ static void ccid3_hc_rx_send_feedback(st
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_TERM))
 		return;
 
 	switch (fbtype) {
@@ -784,7 +784,7 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	spin_lock(&hcrx->ccid3hcrx_hist.lock);
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
@@ -859,7 +859,7 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	ccid3_pr_debug("entry\n");
 
-	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
 	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
 	return tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist);
 }
@@ -876,7 +876,7 @@ static void ccid3_hc_rx_exit(struct sock
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->ccid3hcrx_state;
+	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->tfrchcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
 	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->ccid3hcrx_rtt;
 }
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -88,13 +88,6 @@ static inline struct ccid3_hc_tx_sock *c
     return hctx;
 }
 
-/* CCID3 receiver states */
-enum ccid3_hc_rx_states {
-	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
-};
-
 /* CCID3 feedback types */
 enum ccid3_fback_type {
 	FBACK_NONE = 0,
@@ -106,7 +99,7 @@ enum ccid3_fback_type {
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
+ *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
@@ -118,7 +111,7 @@ enum ccid3_fback_type {
  */
 struct ccid3_hc_rx_sock {
 	u8				ccid3hcrx_last_counter:4;
-	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
+	enum tfrc_hc_rx_states	        tfrchcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
 	u32				ccid3hcrx_x_recv;
 	u32				ccid3hcrx_rtt;
