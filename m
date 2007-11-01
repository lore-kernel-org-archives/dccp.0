From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:52 +0000
Subject: [PATCH 17/25] Share ccid3_tx_state_name function via tfrc_ccids
Message-Id: <200710312131.52573.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_tx_state_name function via tfrc_ccids

ccid3_tx_state_name is now tfrc_tx_state_name

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -48,23 +48,6 @@ static int ccid3_debug;
 
 DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
 
-/*
- *	Transmitter Half-Connection Routines
- */
-#if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
-static const char *ccid3_tx_state_name(enum tfrc_hc_tx_states state)
-{
-	static char *ccid3_state_names[] = {
-	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
-	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
-	[TFRC_SSTATE_FBACK]    = "FBACK",
-	[TFRC_SSTATE_TERM]     = "TERM",
-	};
-
-	return ccid3_state_names[state];
-}
-#endif
-
 /**
  * Each of the following #define aims at maintain the current
  * dccp code nomenclature unchanged while still share
@@ -113,8 +96,8 @@ static void ccid3_hc_tx_set_state(struct
 	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
-		       ccid3_tx_state_name(state));
+		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
+		       tfrc_tx_state_name(state));
 	WARN_ON(state = oldstate);
 	hctx->tfrchctx_state = state;
 }
@@ -270,7 +253,7 @@ static void ccid3_hc_tx_no_feedback_time
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->tfrchctx_state));
+		       tfrc_tx_state_name(hctx->tfrchctx_state));
 
 	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -58,23 +58,6 @@ static int ccid4_debug;
 
 DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
 
-/*
- *	Transmitter Half-Connection Routines
- */
-#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
-static const char *ccid4_tx_state_name(enum tfrc_hc_tx_states state)
-{
-	static char *ccid4_state_names[] = {
-	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
-	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
-	[TFRC_SSTATE_FBACK]    = "FBACK",
-	[TFRC_SSTATE_TERM]     = "TERM",
-	};
-
-	return ccid4_state_names[state];
-}
-#endif
-
 /**
  * Each of the following #define aims at maintain the current
  * dccp code nomenclature unchanged while still share
@@ -123,8 +106,8 @@ static void ccid4_hc_tx_set_state(struct
 	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
-		       dccp_role(sk), sk, ccid4_tx_state_name(oldstate),
-		       ccid4_tx_state_name(state));
+		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
+		       tfrc_tx_state_name(state));
 	WARN_ON(state = oldstate);
 	hctx->tfrchctx_state = state;
 }
@@ -296,7 +279,7 @@ static void ccid4_hc_tx_no_feedback_time
 	}
 
 	ccid4_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid4_tx_state_name(hctx->tfrchctx_state));
+		       tfrc_tx_state_name(hctx->tfrchctx_state));
 
 	if (hctx->tfrchctx_state = TFRC_SSTATE_FBACK)
 		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -154,3 +154,21 @@ static inline struct tfrc_hc_rx_sock *tf
     BUG_ON(hcrx = NULL);
     return hcrx;
 }
+
+/**
+ *  Transmitter Half-Connection Routines
+ */
+#if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
+static const char *tfrc_tx_state_name(enum tfrc_hc_tx_states state)
+{
+       static char *tfrc_state_names[] = {
+       [TFRC_SSTATE_NO_SENT]  = "NO_SENT",
+       [TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
+       [TFRC_SSTATE_FBACK]    = "FBACK",
+       [TFRC_SSTATE_TERM]     = "TERM",
+       };
+
+       return tfrc_state_names[state];
+}
+#endif
+
