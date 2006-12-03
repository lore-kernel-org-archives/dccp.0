From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 03 Dec 2006 22:07:20 +0000
Subject: [PATCH 1/10] [DCCP]: Use higher RTO default for CCID3
Message-Id: <20061203220720.GG17803@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The TFRC nofeedback timer normally expires after the maximum of 4
RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
with a small RTT this can mean a high processing load and reduced
performance, since then the nofeedback timer is triggered very
frequently.

This patch provides a configuration option to set the bound for the
nofeedback timer, using as default 100 milliseconds.

By setting the configuration option to 0, strict RFC 3448 behaviour
can be enforced for the nofeedback timer.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/Kconfig |   33 +++++++++++++++++++++++++++++++++
 net/dccp/ccids/ccid3.c |   21 +++++++++++++--------
 2 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index dac8916..80f4698 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -89,4 +89,37 @@ config IP_DCCP_CCID3_DEBUG
 	    parameter to 0 or 1.
 
 	    If in doubt, say N.
+
+config IP_DCCP_CCID3_RTO
+	  int "Use higher bound for nofeedback timer"
+	  default 100
+	  depends on IP_DCCP_CCID3 && EXPERIMENTAL
+	  ---help---
+	    Use higher lower bound for nofeedback timer expiration.
+
+	    The TFRC nofeedback timer normally expires after the maximum of 4
+	    RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
+	    with a small RTT this can mean a high processing load and reduced
+	    performance, since then the nofeedback timer is triggered very
+	    frequently.
+
+	    This option enables to set a higher lower bound for the nofeedback
+	    value. Values in units of milliseconds can be set here.
+
+	    A value of 0 disables this feature by enforcing the value specified
+	    in RFC 3448. The following values have been suggested as bounds for
+	    experimental use:
+	    	* 16-20ms to match the typical multimedia inter-frame interval
+	    	* 100ms as a reasonable compromise [default]
+	    	* 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
+
+	    The default of 100ms is a compromise between a large value for
+	    efficient DCCP implementations, and a small value to avoid disrupting
+	    the network in times of congestion.
+
+	    The purpose of the nofeedback timer is to slow DCCP down when there
+	    is serious network congestion: experimenting with larger values should
+	    therefore not be performed on WANs.
+
+
 endmenu
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 70ebe70..9980778 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -245,9 +245,10 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
+		 * See comments in packet_recv() regarding the value of t_RTO.
 		 */
-		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
@@ -512,16 +513,20 @@ static void ccid3_hc_tx_packet_recv(stru
 		 */
 		sk->sk_write_space(sk);
 
-		/* Update timeout interval. We use the alternative variant of
-		 * [RFC 3448, 3.1] which sets the upper bound of t_rto to one
-		 * second, as it is suggested for TCP (see RFC 2988, 2.4). */
+		/*
+		 * Update timeout interval for the nofeedback timer.
+		 * We use a configuration option to increase the lower bound.
+		 * This can help avoid triggering the nofeedback timer too often
+		 * ('spinning') on LANs with small RTTs.
+		 */
 		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					      	   USEC_PER_SEC            );
+						   CONFIG_IP_DCCP_CCID3_RTO *
+						   (USEC_PER_SEC/1000)	     );
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 		 */
-		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 			
 		ccid3_pr_debug("%s, sk=%p, Scheduled no feedback timer to "
 			       "expire in %lu jiffies (%luus)\n",
-- 
1.4.2.1.g3d5c

