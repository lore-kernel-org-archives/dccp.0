From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Nov 2006 17:48:42 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <200611151748.42634@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo  
|  Well, I'd rather prefer a WARN_ON type, probably rate limiting the
|  printks, so that we can receive reports that something is fishy but
|  don't panic the machine.

I have implemented such a macro and have changed the patch to use it.
If it is acceptable, I would like to propose it for general use.

Just as I was checking the patch again, Ian's answer arrived -- now I
understand why dump_stack() is used and WARN_ON preferred; the macros
support this use.

Also implemented the enum bit fields suggestion by Eddie. It compiles
fine on gcc 4.0.4; however, I am not sure about portability.
And I don't have your tool either :-(

The following is the revised patch with three macros added, I liked the
DCCP_BUG_ON():

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -18,6 +18,15 @@
 #include <net/tcp.h>
 #include "ackvec.h"
 
+#define DCCP_CRIT(fmt, args...) LIMIT_NETDEBUG(KERN_CRIT fmt "at %s:%d/%s()\n",\
+				       __FILE__, __LINE__, __FUNCTION__, ##args)
+
+#define DCCP_BUG()	  do { DCCP_CRIT("DCCP BUG"); dump_stack(); } while (0)
+
+#define DCCP_BUG_ON(cond) do { if (unlikely((cond) != 0))	\
+					DCCP_BUG();		\
+			  } while (0)
+
 #ifdef MODULE
 #define DCCP_PRINTK(enable, fmt, args...)	do { if (enable)	     \
 							printk(fmt, ##args); \
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
@@ -103,7 +111,7 @@ struct ccid3_hc_tx_sock {
 #define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
 #define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
 	u16				ccid3hctx_s;
-  	u8				ccid3hctx_state;
+  	enum ccid3_hc_tx_states 	ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	u8				ccid3hctx_idle;
 	struct timeval			ccid3hctx_t_last_win_count;
@@ -115,6 +123,13 @@ struct ccid3_hc_tx_sock {
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
@@ -122,8 +137,8 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_p		ccid3hcrx_tfrc.tfrcrx_p
   	u64			ccid3hcrx_seqno_nonloss:48,
 				ccid3hcrx_ccval_nonloss:4,
-				ccid3hcrx_state:8,
 				ccid3hcrx_ccval_last_counter:4;
+	enum ccid3_hc_rx_states	ccid3hcrx_state:8;
   	u32			ccid3hcrx_bytes_recv;
   	struct timeval		ccid3hcrx_tstamp_last_feedback;
   	struct timeval		ccid3hcrx_tstamp_last_ack;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -73,14 +73,6 @@ static struct dccp_tx_hist *ccid3_tx_his
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
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
@@ -248,11 +240,8 @@ static void ccid3_hc_tx_no_feedback_time
 					2 * usecs_div(hctx->ccid3hctx_s,
 						      hctx->ccid3hctx_x));
 		break;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
-		goto out;
+	case TFRC_SSTATE_NO_SENT:
+		DCCP_BUG();	/* can't wait for feedback without having sent */
 	}
 
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer, 
@@ -273,7 +262,7 @@ static int ccid3_hc_tx_send_packet(struc
 	long delay;
 	int rc = -ENOTCONN;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* Check if pure ACK or Terminating*/
 	/*
@@ -326,12 +315,8 @@ static int ccid3_hc_tx_send_packet(struc
 		/* divide by -1000 is to convert to ms and get sign right */
 		rc = delay > 0 ? delay : 0;
 		break;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
-		rc = -EINVAL;
-		break;
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG();
 	}
 
 	/* Can we send? if so add options and add to packet history */
@@ -353,7 +338,7 @@ static void ccid3_hc_tx_packet_sent(stru
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	dccp_timestamp(sk, &now);
 
@@ -420,11 +405,8 @@ static void ccid3_hc_tx_packet_sent(stru
 					  hctx->ccid3hctx_t_ipi);
 		}
 		break;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
-		break;
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG();
 	}
 }
 
@@ -441,7 +423,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	u32 x_recv;
 	u32 r_sample;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -457,6 +439,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		/* FIXME: what to do here? */
+		DCCP_CRIT("action not implemented for state NO_SENT");
 		return;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -565,11 +548,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
 		break;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hctx->ccid3hctx_state);
-		dump_stack();
-		break;
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG();
 	}
 }
 
@@ -686,13 +666,6 @@ static void ccid3_hc_tx_exit(struct sock
  * RX Half Connection methods
  */
 
-/* TFRC receiver states */
-enum ccid3_hc_rx_states {
-       	TFRC_RSTATE_NO_DATA = 1,
-	TFRC_RSTATE_DATA,
-	TFRC_RSTATE_TERM    = 127,
-};
-
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
@@ -741,11 +714,8 @@ static void ccid3_hc_rx_send_feedback(st
 						   delta);
 	}
 		break;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hcrx->ccid3hcrx_state);
-		dump_stack();
-		return;
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG();
 	}
 
 	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
@@ -1004,9 +974,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
-	BUG_ON(hcrx = NULL ||
-	       !(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA ||
-		 hcrx->ccid3hcrx_state = TFRC_RSTATE_DATA));
+	BUG_ON(hcrx = NULL);
 
 	opt_recv = &dccp_sk(sk)->dccps_options_received;
 
@@ -1085,11 +1053,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			ccid3_hc_rx_send_feedback(sk);
 		}
 		return;
-	default:
-		printk(KERN_CRIT "%s: %s, sk=%p, Illegal state (%d)!\n",
-		       __FUNCTION__, dccp_role(sk), sk, hcrx->ccid3hcrx_state);
-		dump_stack();
-		return;
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG();
 	}
 
 	/* Dealing with packet loss */



