From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 15 Nov 2006 23:30:54 +0000
Subject: [PATCH 1/1][PATCH] [DCCP]: Introduce DCCP_{BUG{_ON},CRIT} macros, use enum:8 for the ccid3 states
Message-Id: <20061115233053.GA8975@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.20.git

Best Regards,

- Arnaldo

This patch tackles the following problem:
       * the ccid3_hc_{t,r}x_sock define ccid3hc{t,r}x_state as `u8', but
         in reality there can only be a few, pre-defined enum names
       * this necessitates addiditional checking for unexpected values
         which would otherwise be caught by the compiler

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   45 ++++++++++++---------------------------------
 net/dccp/ccids/ccid3.h |   19 +++++++++++++++++--
 net/dccp/dccp.h        |    8 ++++++++
 3 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index cec23ad..2fa0c6d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -75,14 +75,6 @@ static struct dccp_tx_hist *ccid3_tx_his
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
-/* TFRC sender states */
-enum ccid3_hc_tx_states {
-       	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
-};
-
 #ifdef CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
@@ -251,9 +243,8 @@ static void ccid3_hc_tx_no_feedback_time
 						      hctx->ccid3hctx_x));
 		break;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
+			 hctx->ccid3hctx_state);
 		goto out;
 	}
 
@@ -329,9 +320,8 @@ static int ccid3_hc_tx_send_packet(struc
 		rc = delay > 0 ? delay : 0;
 		break;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
+			 hctx->ccid3hctx_state);
 		rc = -EINVAL;
 		break;
 	}
@@ -423,9 +413,8 @@ static void ccid3_hc_tx_packet_sent(stru
 		}
 		break;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
+			 hctx->ccid3hctx_state);
 		break;
 	}
 }
@@ -568,9 +557,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		hctx->ccid3hctx_idle = 1;   
 		break;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
+			 hctx->ccid3hctx_state);
 		break;
 	}
 }
@@ -688,13 +676,6 @@ static void ccid3_hc_tx_exit(struct sock
  * RX Half Connection methods
  */
 
-/* TFRC receiver states */
-enum ccid3_hc_rx_states {
-       	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
-};
-
 #ifdef CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
@@ -744,9 +725,8 @@ static void ccid3_hc_rx_send_feedback(st
 	}
 		break;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hcrx->ccid3hcrx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
+			 hcrx->ccid3hcrx_state);
 		return;
 	}
 
@@ -1088,9 +1068,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		}
 		return;
 	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hcrx->ccid3hcrx_state);
-		dump_stack();
+		DCCP_BUG("%s, sk=%p, Illegal state (%d)!",  dccp_role(sk), sk,
+			 hcrx->ccid3hcrx_state);
 		return;
 	}
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 0a2cb75..c122e75 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -73,6 +73,14 @@ struct ccid3_options_received {
 	u32 ccid3or_receive_rate;
 };
 
+/* TFRC sender states */
+enum ccid3_hc_tx_states {
+       	TFRC_SSTATE_NO_SENT = 1,
+	TFRC_SSTATE_NO_FBACK,
+	TFRC_SSTATE_FBACK,
+	TFRC_SSTATE_TERM,
+};
+
 /** struct ccid3_hc_tx_sock - CCID3 sender half connection sock
  *
   * @ccid3hctx_state - Sender state
@@ -103,7 +111,7 @@ #define ccid3hctx_p			ccid3hctx_tfrc.tfr
 #define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
 #define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
 	u16				ccid3hctx_s;
-  	u8				ccid3hctx_state;
+  	enum ccid3_hc_tx_states 	ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	u8				ccid3hctx_idle;
 	struct timeval			ccid3hctx_t_last_win_count;
@@ -115,6 +123,13 @@ #define ccid3hctx_t_ipi			ccid3hctx_tfrc
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
+/* TFRC receiver states */
+enum ccid3_hc_rx_states {
+       	TFRC_RSTATE_NO_DATA = 1,
+	TFRC_RSTATE_DATA,
+	TFRC_RSTATE_TERM    = 127,
+};
+
 struct ccid3_hc_rx_sock {
 	struct tfrc_rx_info	ccid3hcrx_tfrc;
 #define ccid3hcrx_x_recv	ccid3hcrx_tfrc.tfrcrx_x_recv
@@ -122,8 +137,8 @@ #define ccid3hcrx_rtt		ccid3hcrx_tfrc.tf
 #define ccid3hcrx_p		ccid3hcrx_tfrc.tfrcrx_p
   	u64			ccid3hcrx_seqno_nonloss:48,
 				ccid3hcrx_ccval_nonloss:4,
-				ccid3hcrx_state:8,
 				ccid3hcrx_ccval_last_counter:4;
+	enum ccid3_hc_rx_states	ccid3hcrx_state:8;
   	u32			ccid3hcrx_bytes_recv;
   	struct timeval		ccid3hcrx_tstamp_last_feedback;
   	struct timeval		ccid3hcrx_tstamp_last_ack;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 363fa52..ecb4e7b 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -18,6 +18,14 @@ #include <net/sock.h>
 #include <net/tcp.h>
 #include "ackvec.h"
 
+#define DCCP_CRIT(fmt, a...) LIMIT_NETDEBUG(KERN_CRIT fmt " at %s:%d/%s()\n",  \
+ 					 ##a, __FILE__, __LINE__, __FUNCTION__)
+#define DCCP_BUG(fmt, a...)  do { DCCP_CRIT(fmt, ##a); dump_stack(); } while (0)
+#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) = 0))                   \
+					DCCP_BUG("BUG: condition \"%s\" fails",\
+						 __stringify((cond)));	       \
+			     } while (0)
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern int dccp_debug;
 
-- 
1.4.2.1.g3d5c

