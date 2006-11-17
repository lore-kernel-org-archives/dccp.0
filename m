From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 15:58:33 +0000
Subject: [PATCH 2/7]: Simplified conditions due to use of enum:8 states
Message-Id: <200611171558.33421@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]:  Simplified conditions due to use of enum:8 states

This reaps the benefit of the earlier patch, which changed the type of
CCID 3 states to use enums, in that many conditions are now simplified
and the number of possible (unexpected) values is greatly reduced.

In a few instances, this also allowed to simplify pre-conditions; where
care has been taken to retain logical equivalence.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   44 ++++++++++++++++++--------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -176,8 +176,6 @@ static void ccid3_hc_tx_no_feedback_time
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 	
 	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_TERM:
-		goto out;
 	case TFRC_SSTATE_NO_FBACK:
 		/* Halve send rate */
 		hctx->ccid3hctx_x /= 2;
@@ -240,9 +238,10 @@ static void ccid3_hc_tx_no_feedback_time
 					2 * usecs_div(hctx->ccid3hctx_s,
 						      hctx->ccid3hctx_x));
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_NO_SENT:
+		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
+		/* fall through */
+	case TFRC_SSTATE_TERM:
 		goto out;
 	}
 
@@ -264,7 +263,7 @@ static int ccid3_hc_tx_send_packet(struc
 	long delay;
 	int rc = -ENOTCONN;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* Check if pure ACK or Terminating*/
 	/*
@@ -317,9 +316,8 @@ static int ccid3_hc_tx_send_packet(struc
 		/* divide by -1000 is to convert to ms and get sign right */
 		rc = delay > 0 ? delay : 0;
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		rc = -EINVAL;
 		break;
 	}
@@ -343,7 +341,7 @@ static void ccid3_hc_tx_packet_sent(stru
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	dccp_timestamp(sk, &now);
 
@@ -410,9 +408,8 @@ static void ccid3_hc_tx_packet_sent(stru
 					  hctx->ccid3hctx_t_ipi);
 		}
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		break;
 	}
 }
@@ -430,7 +427,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	u32 x_recv;
 	u32 r_sample;
 
-	BUG_ON(hctx = NULL || hctx->ccid3hctx_state = TFRC_SSTATE_TERM);
+	BUG_ON(hctx = NULL);
 
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
@@ -554,9 +551,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hctx->ccid3hctx_state);
+	case TFRC_SSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		break;
 	}
 }
@@ -722,9 +718,8 @@ static void ccid3_hc_rx_send_feedback(st
 						   delta);
 	}
 		break;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!", dccp_role(sk), sk,
-			 hcrx->ccid3hcrx_state);
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		return;
 	}
 
@@ -984,9 +979,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	u32 p_prev, rtt_prev, r_sample, t_elapsed;
 	int loss;
 
-	BUG_ON(hcrx = NULL ||
-	       !(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA ||
-		 hcrx->ccid3hcrx_state = TFRC_RSTATE_DATA));
+	BUG_ON(hcrx = NULL);
 
 	opt_recv = &dccp_sk(sk)->dccps_options_received;
 
@@ -1065,9 +1058,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			ccid3_hc_rx_send_feedback(sk);
 		}
 		return;
-	default:
-		DCCP_BUG("%s, sk=%p, Illegal state (%d)!",  dccp_role(sk), sk,
-			 hcrx->ccid3hcrx_state);
+	case TFRC_RSTATE_TERM:
+		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
 		return;
 	}
 
