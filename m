From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 13:18:46 +0000
Subject: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200611301318.46685@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the patch which stops the nofeedback timer from spinning
every couple of microseconds, triggered by small RTTs. 

However, there are a few more bugs in CCID 3; this is work in progress.

-----------------> Commit Message <-----------------------------------
[DCCP]: Use higher RTO default for CCID3 

The TFRC nofeedback timer normally expires after the maximum of 4
RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
with a small RTT this can mean a high processing load and reduced
performance, since then the nofeedback timer is triggered very
frequently. As a result, the sending rate quickly converges towards
zero.

This patch provides a configuration option to set the bound for the
nofeedback timer, using as default the TCP RTO timeout of 1 second.

By setting the configuration option to 0, RFC 3448 behaviour can
be enforced for the nofeedback timer.

Has been tested to compile and work.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |   22 ++++++++++++++++++++++
 net/dccp/ccids/ccid3.c |   20 +++++++++++---------
 2 files changed, 33 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -89,4 +89,26 @@ config IP_DCCP_CCID3_DEBUG
 	    parameter to 0 or 1.
 
 	    If in doubt, say N.
+
+config IP_DCCP_CCID3_RTO
+	  int "Use higher (TCP) RTO for nofeedback timer"
+	  default 1
+	  depends on IP_DCCP_CCID3
+	  ---help---
+	    Use higher (TCP) RTO value for nofeedback expiration.
+
+	    The TFRC nofeedback timer normally expires after the maximum of 4
+	    RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
+	    with a small RTT this can mean a high processing load and reduced
+	    performance, since then the nofeedback timer is triggered very
+	    frequently. As a result, the sending rate quickly converges towards
+	    zero.
+
+	    This option enables to set a higher upper bound for the nofeedback
+	    value. Values in units of seconds can be set here.
+
+	    A value of 0 disables this feature by enforcing the value specified
+	    in RFC 3448. It is recommended to use the default value of 1 second,
+	    as this is also the suggested TCP RTO default (RFC 2988, 2.4).
+
 endmenu
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -245,9 +245,10 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
+		 * See comments above regarding the value of t_RTO.
 		 */
-		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
@@ -481,7 +482,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		}
 
 		ccid3_pr_debug("%s, sk=%p, New RTT estimate=%uus, "
-			       "r_sample=%us\n", dccp_role(sk), sk,
+			       "r_sample=%uus\n", dccp_role(sk), sk,
 			       hctx->ccid3hctx_rtt, r_sample);
 
 		/* Update receive rate */
@@ -512,16 +513,17 @@ static void ccid3_hc_tx_packet_recv(stru
 		 */
 		sk->sk_write_space(sk);
 
-		/* Update timeout interval. We use the alternative variant of
-		 * [RFC 3448, 3.1] which sets the upper bound of t_rto to one
-		 * second, as it is suggested for TCP (see RFC 2988, 2.4). */
+		/* Update timeout interval. A value of IP_DCCP_CCID3_RTO=0
+		 * lets the nofeedback timer expire as per [RFC 3448, 3.1];
+		 * a value of 1 second corresponds to the RTO suggested for
+		 * TCP (see RFC 2988, 2.4). */
 		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					      	   USEC_PER_SEC            );
+					CONFIG_IP_DCCP_CCID3_RTO * USEC_PER_SEC);
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 		 */
-		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 			
 		ccid3_pr_debug("%s, sk=%p, Scheduled no feedback timer to "
 			       "expire in %lu jiffies (%luus)\n",
