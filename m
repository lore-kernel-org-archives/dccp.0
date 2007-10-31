From: Leandro <leandroal@gmail.com>
Date: Wed, 31 Oct 2007 23:18:36 +0000
Subject: [PATCH 1/25] CCID-4 Kconfig and Makefile
Message-Id: <200710312018.36512.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] CCID-4 Kconfig and Makefile

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
Signed-off-by: Tommi Saviranta <wnd@iki.fi>

Index: leandro.new/net/dccp/ccids/Kconfig
=================================--- leandro.new.orig/net/dccp/ccids/Kconfig
+++ leandro.new/net/dccp/ccids/Kconfig
@@ -106,9 +106,82 @@ config IP_DCCP_CCID3_RTO
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.
 
-# The TFRC Library: currently only has CCID 3 as customer
+config IP_DCCP_CCID4
+       tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"
+       depends on IP_DCCP
+       def_tristate IP_DCCP
+       ---help---
+          CCID-4 denotes Congestion Control Identifier 4, the Small-Packet
+          variant of TCP-Friendly Rate Control (TFRC), in the Datagram
+          Congestion Control Protocol (DCCP).  CCID 4 is for experimental use,
+          and uses TFRC-SP [RFC4828], a variant of TFRC designed for applications
+          that send small packets.  The goal for TFRC-SP is to achieve roughly the
+          same bandwidth in bits per second (bps) as a TCP flow using packets of up
+          to 1500 bytes but experiencing the same level of congestion.  CCID 4 is for
+          experimental use for senders that send small packets and would like a
+          TCP-friendly sending rate, possibly with Explicit Congestion
+          Notification (ECN), while minimizing abrupt rate changes.
+
+          CCID-4 is a Internet-Draft and it can be found at:
+          https://datatracker.ietf.org/drafts/draft-floyd-dccp-ccid4/
+
+          The TFRC-SP congestion control algorithms were initially described in
+          RFC 4828.
+
+          To compile this CCID as a module, choose M here: the module will be
+          called dccp_ccid4.
+
+          If in doubt, say M.
+
+config IP_DCCP_CCID4_DEBUG
+         bool "CCID4 debugging messages"
+         depends on IP_DCCP_CCID4
+         ---help---
+           Enable CCID4-specific debugging messages.
+
+           When compiling CCID4 as a module, this debugging output can
+           additionally be toggled by setting the ccid4_debug module
+           parameter to 0 or 1.
+
+           If in doubt, say N.
+
+config IP_DCCP_CCID4_RTO
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
+           efficient DCCP implementations, and a small value to avoid disrupting
+           the network in times of congestion.
+
+           The purpose of the nofeedback timer is to slow DCCP down when there
+           is serious network congestion: experimenting with larger values should
+           therefore not be performed on WANs.
+
+# The TFRC Library: currently has CCID 3 and CCID 4 as customer
 config IP_DCCP_TFRC_LIB
-	depends on IP_DCCP_CCID3
+	depends on IP_DCCP_CCID3 || IP_DCCP_CCID4
 	def_tristate IP_DCCP_CCID3
 
 config IP_DCCP_TFRC_DEBUG
Index: leandro.new/net/dccp/ccids/Makefile
=================================--- leandro.new.orig/net/dccp/ccids/Makefile
+++ leandro.new/net/dccp/ccids/Makefile
@@ -1,3 +1,7 @@
+obj-$(CONFIG_IP_DCCP_CCID4) += dccp_ccid4.o
+
+dccp_ccid4-y := ccid4.o
+
 obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid3.o
 
 dccp_ccid3-y := ccid3.o
