From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 05:23:14 +0000
Subject: [PATCH 5/5] dccp ccid-3: use per-route RTO or TCP RTO as fallback
Message-Id: <1283145794-5615-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This makes RTAX_RTO_MIN also available to CCID-3, replacing the compile-time
RTO lower bound with a per-route tunable value.

The original Kconfig option solved the problem that a very low RTT (in the
order of HZ) can trigger too frequent and unnecessary reductions of the
sending rate.

This tunable does not affect the initial RTO value of 2 seconds specified in
RFC 5348, section 4.2 and Appendix B. But like the hardcoded Kconfig value,
it allows to adapt to network conditions.

The same effect as the original Kconfig option of 100ms is now achieved by

> ip route replace to unicast 192.168.0.0/24 rto_min 100j dev eth0

(assuming HZ00).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig            |   31 -------------------------------
 net/dccp/ccids/ccid3.c            |   11 +++++------
 net/dccp/ccids/ccid3.h            |    2 +-
 Documentation/networking/dccp.txt |    3 +++
 4 files changed, 9 insertions(+), 38 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -47,37 +47,6 @@ config IP_DCCP_CCID3_DEBUG
 
 	  If in doubt, say N.
 
-config IP_DCCP_CCID3_RTO
-	  int "Use higher bound for nofeedback timer"
-	  default 100
-	  depends on IP_DCCP_CCID3 && EXPERIMENTAL
-	  ---help---
-	    Use higher lower bound for nofeedback timer expiration.
-
-	    The TFRC nofeedback timer normally expires after the maximum of 4
-	    RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
-	    with a small RTT this can mean a high processing load and reduced
-	    performance, since then the nofeedback timer is triggered very
-	    frequently.
-
-	    This option enables to set a higher lower bound for the nofeedback
-	    value. Values in units of milliseconds can be set here.
-
-	    A value of 0 disables this feature by enforcing the value specified
-	    in RFC 3448. The following values have been suggested as bounds for
-	    experimental use:
-		* 16-20ms to match the typical multimedia inter-frame interval
-		* 100ms as a reasonable compromise [default]
-		* 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
-
-	    The default of 100ms is a compromise between a large value for
-	    efficient DCCP implementations, and a small value to avoid disrupting
-	    the network in times of congestion.
-
-	    The purpose of the nofeedback timer is to slow DCCP down when there
-	    is serious network congestion: experimenting with larger values should
-	    therefore not be performed on WANs.
-
 config IP_DCCP_TFRC_LIB
 	def_bool y if IP_DCCP_CCID3
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -460,13 +460,12 @@ done_computing_x:
 	sk->sk_write_space(sk);
 
 	/*
-	 * Update timeout interval for the nofeedback timer.
-	 * We use a configuration option to increase the lower bound.
-	 * This can help avoid triggering the nofeedback timer too
-	 * often ('spinning') on LANs with small RTTs.
+	 * Update timeout interval for the nofeedback timer. In order to control
+	 * rate halving on networks with very low RTTs (<= 1 ms), use per-route
+	 * tunable RTAX_RTO_MIN value as the lower bound.
 	 */
-	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
-						       (USEC_PER_SEC / 1000)));
+	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt,
+				  USEC_PER_SEC/HZ * tcp_rto_min(sk));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -42,7 +42,7 @@
 #include "lib/tfrc.h"
 #include "../ccid.h"
 
-/* Two seconds as per RFC 3448 4.2 */
+/* Two seconds as per RFC 5348, 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
 /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -174,6 +174,9 @@ Per-route rto_min support
 		> ip route change 10.0.0.0/24   rto_min 250j dev wlan0
 		> ip route add    10.0.0.254/32 rto_min 800j dev wlan0
 		> ip route show dev wlan0
+	CCID-3 also supports the rto_min setting: it is used to define the lower
+	bound for the expiry of the nofeedback timer. This can be useful on LANs
+	with very low RTTs (e.g., loopback, Gbit ethernet).
 
 
 Notes
