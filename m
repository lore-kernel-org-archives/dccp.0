From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 14:29:20 +0000
Subject: [PATCHv3] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612011429.21131@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is version three of the patch to increase the minimum
bound of the nofeedback timer. It now features
 * millisecond granularity for increased testing comfort
 * a more informative configuration menu

This patch is against the very latest tree by acme-2.6.20

===> For testing against 2.6.19 one would need to use 
        a value of 1000 since this was the default in 2.6.19
        calculation of nofeedback timeout.

----------------------> Patchv3 <---------------------------
[DCCP]: Use higher RTO default for CCID3

The TFRC nofeedback timer normally expires after the maximum of 4
RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
with a small RTT this can mean a high processing load and reduced
performance, since then the nofeedback timer is triggered very
frequently. As a result, the sending rate quickly converges towards
zero.

This patch provides a configuration option to set the bound for the
nofeedback timer, using as default the TCP lower bound of 1 second.

By setting the configuration option to 0, strict RFC 3448 behaviour
can be enforced for the nofeedback timer.

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/ccids/Kconfig |   23 ++++++++++++++++-------
 net/dccp/ccids/ccid3.c |   16 +++++++---------
 2 files changed, 23 insertions(+), 16 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index d29713c..80f4698 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -92,8 +92,8 @@ config IP_DCCP_CCID3_DEBUG
 
 config IP_DCCP_CCID3_RTO
 	  int "Use higher bound for nofeedback timer"
-	  default 1
-	  depends on IP_DCCP_CCID3
+	  default 100
+	  depends on IP_DCCP_CCID3 && EXPERIMENTAL
 	  ---help---
 	    Use higher lower bound for nofeedback timer expiration.
 
@@ -104,13 +104,22 @@ config IP_DCCP_CCID3_RTO
 	    frequently.
 
 	    This option enables to set a higher lower bound for the nofeedback
-	    value. Values in units of seconds can be set here.
+	    value. Values in units of milliseconds can be set here.
 
 	    A value of 0 disables this feature by enforcing the value specified
-	    in RFC 3448. It is recommended to use the default value of 1 second,
-	    as this is also the suggested lower bound for TCP (RFC 2988, 2.4).
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
 
-	    Using a value of 2 seconds corresponds to the initial timeout (RFC
-	    3448, 4.2); higher values than this should not normally be necessary.
 
 endmenu
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2e43cbf..846af6f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -246,7 +246,7 @@ static void ccid3_hc_tx_no_feedback_time
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
-		 * See comments above regarding the value of t_RTO.
+		 * See comments in packet_recv() regarding the value of t_RTO.
 		 */
 		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 		break;
@@ -514,16 +514,14 @@ static void ccid3_hc_tx_packet_recv(stru
 		sk->sk_write_space(sk);
 
 		/*
-		 * Update timeout interval for the nofeedback timer:
-		 *
-		 * A value of CONFIG_IP_DCCP_CCID3_RTO=0 lets the nofeedback
-		 * timer expire as per [RFC 3448, 4]; a value of 1 second
-		 * corresponds to the lower bound suggested for TCP  (see RFC
-		 * 2988, 2.4).
+		 * Update timeout interval for the nofeedback timer.
+		 * We use a configuration option to increase the lower bound.
+		 * This can help avoid triggering the nofeedback timer too often
+		 * ('spinning') on LANs with small RTTs.
 		 */
 		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					           (CONFIG_IP_DCCP_CCID3_RTO *
-						    USEC_PER_SEC));
+						   CONFIG_IP_DCCP_CCID3_RTO *
+						   (USEC_PER_SEC/1000)	     );
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)

