From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Jan 2009 14:42:13 +0000
Subject: dccp test tree [RFC/RFT] [Patch 1/3] dccp: minor Kconfig cosmetics
Message-Id: <20090105144213.GB3773@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp ccid-3: Reformat Kconfig option for RTO timeout

Apart from fixing indenting, it also updates the references 
(RFC 5348 has replaced RFC 3448).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |   58 ++++++++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -48,35 +48,35 @@ config IP_DCCP_CCID3_DEBUG
 	  If in doubt, say N.
 
 config IP_DCCP_CCID3_RTO
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
-	    	* 16-20ms to match the typical multimedia inter-frame interval
-	    	* 100ms as a reasonable compromise [default]
-	    	* 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
-
-	    The default of 100ms is a compromise between a large value for
-	    efficient DCCP implementations, and a small value to avoid disrupting
-	    the network in times of congestion.
-
-	    The purpose of the nofeedback timer is to slow DCCP down when there
-	    is serious network congestion: experimenting with larger values should
-	    therefore not be performed on WANs.
+	int "Use higher bound for nofeedback timer"
+	default 100
+	depends on IP_DCCP_CCID3
+	---help---
+	  Use higher lower bound for nofeedback timer expiration.
+
+	  The TFRC nofeedback timer normally expires after the maximum of 4
+	  RTTs and twice the current send interval (RFC 5448, 4.3). On LANs
+	  with a small RTT this can mean a high processing load and reduced
+	  performance, since then the nofeedback timer is triggered very
+	  frequently.
+
+	  This option enables to set a higher lower bound for the nofeedback
+	  value. Values in units of milliseconds can be set here.
+
+	  A value of 0 disables this feature by enforcing the value specified
+	  in RFC 5448. The following values have been suggested as bounds for
+	  experimental use:
+	    * 16-20ms to match the typical multimedia inter-frame interval
+	    * 100ms as a reasonable compromise [default]
+	    * 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
+
+	  The default of 100ms is a compromise between a large value for
+	  efficient DCCP implementations, and a small value to avoid disrupting
+	  the network in times of congestion.
+
+	  The purpose of the nofeedback timer is to slow DCCP down when there
+	  is serious network congestion: experimenting with larger values should
+	  therefore not be performed on WANs.
 
 config IP_DCCP_TFRC_LIB
 	def_bool y if IP_DCCP_CCID3
