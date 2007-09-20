From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:20:21 +0000
Subject: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to
Message-Id: <20070920112021.GB1288@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Adds Kconfig-entries, modified Makefile, and adds DCCP_CCID enum for for
CCID 4. Kconfig-entries are derived from CCID 3, and are probably
invalid.


Signed-off-by: Tommi Saviranta <wnd@iki.fi>

---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index b569947..dc19d6b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -173,6 +173,7 @@ enum {
 enum {
 	DCCPC_CCID2 = 2,
 	DCCPC_CCID3 = 3,
+	DCCPC_CCID4 = 4,
 };
 
 /* DCCP features (RFC 4340 section 6.4) */
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index a0c42d7..e402869 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -115,4 +115,87 @@ config IP_DCCP_TFRC_DEBUG
 	bool
 	default y if IP_DCCP_CCID3_DEBUG
 
+config IP_DCCP_CCID4
+	tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"
+	depends on IP_DCCP
+	def_tristate IP_DCCP
+	---help---
+	  CCID 4 denotes the Small-Packet variant of TCP-Friendly Rate Control
+	  (TFRC-SP), an equation-based rate-controlled congestion control
+	  mechanism.  TFRC-SP is designed to be reasonably fair when competing
+	  for bandwidth with TCP-like flows, where a flow is "reasonably fair"
+	  if its sending rate is generally within a factor of two of the
+	  sending rate of a TCP flow under the same conditions.  However,
+	  TFRC-SP has a much lower variation of throughput over time compared
+	  with TCP, which makes CCID 4 more suitable than CCID 2 for
+	  applications such streaming media where a relatively smooth sending
+	  rate is of importance.
+
+	  CCID 4 is further described in RFC xxxx,
+	  http://www.ietf.org/rfc/rfcXXXX.txt
+
+	  The TFRC-SP congestion control algorithms were initially described in
+	  RFC 4828.
+
+	  This text was extracted from RFC 4340 (sec. 10.2),
+	  http://www.ietf.org/rfc/rfc4340.txt, and modified to match CCID4.
+	  
+	  To compile this CCID as a module, choose M here: the module will be
+	  called dccp_ccid4.
+
+	  If in doubt, say M.
+
+config IP_DCCP_CCID4_DEBUG
+	  bool "CCID4 debugging messages"
+	  depends on IP_DCCP_CCID4
+	  ---help---
+	    Enable CCID4-specific debugging messages.
+
+	    When compiling CCID4 as a module, this debugging output can
+	    additionally be toggled by setting the ccid4_debug module
+	    parameter to 0 or 1.
+
+	    If in doubt, say N.
+
+config IP_DCCP_CCID4_RTO
+	  int "Use higher bound for nofeedback timer"
+	  default 100
+	  depends on IP_DCCP_CCID4 && EXPERIMENTAL
+	  ---help---
+	    FIXME
+	    Use higher lower bound for nofeedback timer expiration.
+
+	    The TFRC-SP nofeedback timer normally expires after the maximum of 4
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
+# The TFRC-SP Library: currently only has CCID 4 as customer
+config IP_DCCP_TFRC_SP_LIB
+	depends on IP_DCCP_CCID4
+	def_tristate IP_DCCP_CCID4
+
+config IP_DCCP_TFRC_SP_DEBUG
+	bool
+	default y if IP_DCCP_CCID4_DEBUG
+
 endmenu
diff --git a/net/dccp/ccids/Makefile b/net/dccp/ccids/Makefile
index 438f20b..fa21407 100644
--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -5,5 +5,9 @@ dccp_ccid3-y := ccid3.o
 obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid2.o
 
 dccp_ccid2-y := ccid2.o
+ 
+obj-$(CONFIG_IP_DCCP_CCID4) += dccp_ccid4.o
+
+dccp_ccid4-y := ccid4.o
 
 obj-y += lib/
