From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:32:02 +0000
Subject: [PATCH 21/25] Share ccid3_rx_state_name function via tfrc_ccids
Message-Id: <200710312132.02429.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_rx_state_name function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -601,22 +601,6 @@ static int ccid3_hc_tx_getsockopt(struct
 	return 0;
 }
 
-/*
- *	Receiver Half-Connection Routines
- */
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static const char *ccid3_rx_state_name(enum tfrc_hc_rx_states state)
-{
-	static char *ccid3_rx_state_names[] = {
-	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
-	[TFRC_RSTATE_DATA]    = "DATA",
-	[TFRC_RSTATE_TERM]    = "TERM",
-	};
-
-	return ccid3_rx_state_names[state];
-}
-#endif
-
 static void ccid3_hc_rx_set_state(struct sock *sk,
 				  enum tfrc_hc_rx_states state)
 {
@@ -624,8 +608,8 @@ static void ccid3_hc_rx_set_state(struct
 	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
-		       ccid3_rx_state_name(state));
+		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
+		       tfrc_rx_state_name(state));
 	WARN_ON(state = oldstate);
 	hcrx->tfrchcrx_state = state;
 }
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -630,22 +630,6 @@ static int ccid4_hc_tx_getsockopt(struct
 	return 0;
 }
 
-/*
- *	Receiver Half-Connection Routines
- */
-#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
-static const char *ccid4_rx_state_name(enum tfrc_hc_rx_states state)
-{
-	static char *ccid4_rx_state_names[] = {
-	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
-	[TFRC_RSTATE_DATA]    = "DATA",
-	[TFRC_RSTATE_TERM]    = "TERM",
-	};
-
-	return ccid4_rx_state_names[state];
-}
-#endif
-
 static void ccid4_hc_rx_set_state(struct sock *sk,
 				  enum tfrc_hc_rx_states state)
 {
@@ -653,8 +637,8 @@ static void ccid4_hc_rx_set_state(struct
 	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid4_rx_state_name(oldstate),
-		       ccid4_rx_state_name(state));
+		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
+		       tfrc_rx_state_name(state));
 	WARN_ON(state = oldstate);
 	hcrx->tfrchcrx_state = state;
 }
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -172,6 +172,23 @@ static const char *tfrc_tx_state_name(en
 }
 #endif
 
+/**
+ *  Receiver Half-Connection Routines
+ */
+#if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
+static const char *tfrc_rx_state_name(enum tfrc_hc_rx_states state)
+{
+	static char *tfrc_rx_state_names[] = {
+	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
+	[TFRC_RSTATE_DATA]    = "DATA",
+	[TFRC_RSTATE_TERM]    = "TERM",
+	};
+
+	return tfrc_rx_state_names[state];
+}
+#endif
+
+
 extern u64 rfc3390_initial_rate(struct sock *sk);
 
 extern u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now);
