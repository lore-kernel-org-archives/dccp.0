From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Aug 2010 05:19:36 +0000
Subject: dccp test-tree [Patch 1/1] ccid-3: use per-route min-RTO and/or
Message-Id: <20100816051936.GD3571@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch relates to the similar one submitted last week for CCID-2.

It replaces the hardcoded (Kconfig) value of the minimum RTO value with
a reconfigurable, per-route value which falls back to the TCP minimum
RTO value.

Leando, Ivo, can you please have a look and indicate whether you are ok
with this? If yes I would like to also update the CCID-4 tree to make it
consistent with the test tree - for this reason the test tree has not yet
been updated.

>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp ccid-3: use per-route RTO or TCP RTO as fallback

This makes the TCP (per-route) RTO value also available to CCID-3, hence it
is now possible to influence this value at runtime rather than, as before,
via Kconfig.

The same effect as the default Kconfig option of 100ms is now achieved by

> ip route replace to unicast 192.168.0.0/24 rto_min 100j dev eth0
 
(assuming HZ00).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |   31 -------------------------------
 net/dccp/ccids/ccid3.c |    9 ++++-----
 2 files changed, 4 insertions(+), 36 deletions(-)

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
@@ -461,12 +461,11 @@ done_computing_x:
 
 	/*
 	 * Update timeout interval for the nofeedback timer.
-	 * We use a configuration option to increase the lower bound.
-	 * This can help avoid triggering the nofeedback timer too
-	 * often ('spinning') on LANs with small RTTs.
+	 * We use the current (per-route) value of the TCP RTO as lower bound
+	 * to slow down rate-halving on networks with small RTTs (loopback,
+	 * running DCCP in a virtual machine, Gbit ethernet, etc).
 	 */
-	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
-						       (USEC_PER_SEC / 1000)));
+	hc->tx_t_rto = max(4 * hc->tx_rtt, USEC_PER_SEC/HZ * tcp_rto_min(sk));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
