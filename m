From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 17:53:39 +0000
Subject: [PATCH 1/4] CCID4: Provides improvements/organization to the initial entries for CCID 4 and net/dccp
Message-Id: <5bc4c4570709201053h6fbdaea6u72cc406675020715@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>

Organize the help for ccid-4 menu with a more apropriate description,
the correct
URL for CCID-4 draft and remove the code duplication for TFRC by using
"depends on CCID3 || CCID4" in the IP_DCCP_TFRC_LIB config.

diff -uprN dccp-ccid4.base/net/dccp/ccids/Kconfig
dccp-ccid4/net/dccp/ccids/Kconfig
--- dccp-ccid4.base/net/dccp/ccids/Kconfig	2007-09-20 11:45:30.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/Kconfig	2007-09-20 13:53:13.000000000 -0300
@@ -106,9 +106,9 @@ config IP_DCCP_CCID3_RTO
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.

-# The TFRC Library: currently only has CCID 3 as customer
+# The TFRC Library: currently has CCID 3 and CCID 4 as customer
 config IP_DCCP_TFRC_LIB
-	depends on IP_DCCP_CCID3
+	depends on IP_DCCP_CCID3 || IP_DCCP_CCID4
 	def_tristate IP_DCCP_CCID3

 config IP_DCCP_TFRC_DEBUG
@@ -116,86 +116,80 @@ config IP_DCCP_TFRC_DEBUG
 	default y if IP_DCCP_CCID3_DEBUG

 config IP_DCCP_CCID4
-	tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"
-	depends on IP_DCCP
-	def_tristate IP_DCCP
-	---help---
-	  CCID 4 denotes the Small-Packet variant of TCP-Friendly Rate Control
-	  (TFRC-SP), an equation-based rate-controlled congestion control
-	  mechanism.  TFRC-SP is designed to be reasonably fair when competing
-	  for bandwidth with TCP-like flows, where a flow is "reasonably fair"
-	  if its sending rate is generally within a factor of two of the
-	  sending rate of a TCP flow under the same conditions.  However,
-	  TFRC-SP has a much lower variation of throughput over time compared
-	  with TCP, which makes CCID 4 more suitable than CCID 2 for
-	  applications such streaming media where a relatively smooth sending
-	  rate is of importance.
-
-	  CCID 4 is further described in RFC xxxx,
-	  http://www.ietf.org/rfc/rfcXXXX.txt
-
-	  The TFRC-SP congestion control algorithms were initially described in
-	  RFC 4828.
+       tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"
+       depends on IP_DCCP
+       def_tristate IP_DCCP
+       ---help---
+          CCID-4 denotes Congestion Control Identifier 4, the Small-Packet
+          variant of TCP-Friendly Rate Control (TFRC), in the Datagram
+          Congestion Control Protocol (DCCP).  CCID 4 is for experimental use,
+          and uses TFRC-SP [RFC4828], a variant of TFRC designed for
applications
+          that send small packets.  The goal for TFRC-SP is to
achieve roughly the
+          same bandwidth in bits per second (bps) as a TCP flow using
packets of up
+          to 1500 bytes but experiencing the same level of
congestion.  CCID 4 is for
+          experimental use for senders that send small packets and would like a
+          TCP-friendly sending rate, possibly with Explicit Congestion
+          Notification (ECN), while minimizing abrupt rate changes.
+
+          CCID-4 is a Internet-Draft and it can be found at:
+          https://datatracker.ietf.org/drafts/draft-floyd-dccp-ccid4/

-	  This text was extracted from RFC 4340 (sec. 10.2),
-	  http://www.ietf.org/rfc/rfc4340.txt, and modified to match CCID4.
+          The TFRC-SP congestion control algorithms were initially described in
+          RFC 4828.

-	  To compile this CCID as a module, choose M here: the module will be
-	  called dccp_ccid4.
+          To compile this CCID as a module, choose M here: the module will be
+          called dccp_ccid4.

-	  If in doubt, say M.
+          If in doubt, say M.

 config IP_DCCP_CCID4_DEBUG
-	  bool "CCID4 debugging messages"
-	  depends on IP_DCCP_CCID4
-	  ---help---
-	    Enable CCID4-specific debugging messages.
-
-	    When compiling CCID4 as a module, this debugging output can
-	    additionally be toggled by setting the ccid4_debug module
-	    parameter to 0 or 1.
+         bool "CCID4 debugging messages"
+         depends on IP_DCCP_CCID4
+         ---help---
+           Enable CCID4-specific debugging messages.
+
+           When compiling CCID4 as a module, this debugging output can
+           additionally be toggled by setting the ccid4_debug module
+           parameter to 0 or 1.

-	    If in doubt, say N.
+           If in doubt, say N.

 config IP_DCCP_CCID4_RTO
-	  int "Use higher bound for nofeedback timer"
-	  default 100
-	  depends on IP_DCCP_CCID4 && EXPERIMENTAL
-	  ---help---
-	    FIXME
-	    Use higher lower bound for nofeedback timer expiration.
-
-	    The TFRC-SP nofeedback timer normally expires after the maximum of 4
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
-# The TFRC-SP Library: currently only has CCID 4 as customer
-config IP_DCCP_TFRC_SP_LIB
-	depends on IP_DCCP_CCID4
-	def_tristate IP_DCCP_CCID4
+         int "Use higher bound for nofeedback timer"
+         default 100
+         depends on IP_DCCP_CCID4 && EXPERIMENTAL
+         ---help---
+           This help is a copy of CCID3 RTO option. It must be updated, if
+           necessary, according to the CCID-4 internet draft.
+
+           Use higher lower bound for nofeedback timer expiration.
+
+           The TFRC-SP nofeedback timer normally expires after the maximum of 4
+           RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
+           with a small RTT this can mean a high processing load and reduced
+           performance, since then the nofeedback timer is triggered very
+           frequently.
+
+           This option enables to set a higher lower bound for the nofeedback
+           value. Values in units of milliseconds can be set here.
+
+           A value of 0 disables this feature by enforcing the value specified
+           in RFC 3448. The following values have been suggested as bounds for
+           experimental use:
+               * 16-20ms to match the typical multimedia inter-frame interval
+               * 100ms as a reasonable compromise [default]
+               * 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
+
+           The default of 100ms is a compromise between a large value for
+           efficient DCCP implementations, and a small value to avoid
disrupting
+           the network in times of congestion.
+
+           The purpose of the nofeedback timer is to slow DCCP down when there
+           is serious network congestion: experimenting with larger
values should
+           therefore not be performed on WANs.

 config IP_DCCP_TFRC_SP_DEBUG
-	bool
-	default y if IP_DCCP_CCID4_DEBUG
+       bool
+       default y if IP_DCCP_CCID4_DEBUG

 endmenu
