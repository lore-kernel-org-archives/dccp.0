From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 02 Aug 2007 14:46:30 +0000
Subject: [RFC][PATCH 2/2]: Promote CCID2 as default CCID
Message-Id: <200708021546.30471@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Promote CCID2 as default CCID

This patch addresses the following problems:

 1. DCCP relies for its proper functioning on having at least one CCID module
    enabled (as in TCP plugable congestion control). Currently it is possible to
    disable both CCIDs and thus leave the DCCP module in a compiled, but entirely
    non-functional state: no sockets can be created when no CCID is available.
    Furthermore, the protocol is (again like TCP) not intended to be used without
    CCIDs.

 2. Internally the default CCID that is advertised by the Linux host is set to CCID2
    (DCCPF_INITIAL_CCID in include/linux/dccp.h). Disabling CCID2 in the Kconfig
    menu without changing the defaults leads to a failure `module not found' when
    trying to load the dccp module (which internally tries to load the default CCID).

 3. The specification (RFC 4340, sec. 10) treats CCID2 somewhat like a 
    `minimum common denominator', the specification says that:

      * "New connections start with CCID 2 for both endpoints"

      * "A DCCP implementation intended for general use, such as an implementation in a
         general-purpose operating system kernel, SHOULD implement at least CCID 2.
         The intent is to make CCID 2 broadly available for interoperability [...]"

    Providing CCID2 as minimum-required CCID (like Reno/Cubic in TCP) seems reasonable.


This patch, then,

 * makes CCID2  default, compiled in the same format as DCCP 
  (either both are modules,  or both are built-in);
 * moves Kconfig option for debugging into the `DCCP kernel hacking' menu
   => This could be changed, I would appreciate suggestions;
 * adds documentation which explains the way CCIDs are used by the current implementation.
 
The patch arose from discussions with Ian McDonald, whose input is gratefully acknowledged.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   17 +++++++++-----
 net/dccp/Kconfig                  |   11 +++++++++
 net/dccp/ccids/Kconfig            |   44 --------------------------------------
 net/dccp/ccids/Makefile           |    2 -
 4 files changed, 23 insertions(+), 51 deletions(-)

--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid
 
 dccp_ccid3-y := ccid3.o
 
-obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid2.o
+obj-$(CONFIG_IP_DCCP) += dccp_ccid2.o
 
 dccp_ccid2-y := ccid2.o
 
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -14,15 +14,20 @@ Introduction
 ======
 
 Datagram Congestion Control Protocol (DCCP) is an unreliable, connection
-based protocol designed to solve issues present in UDP and TCP particularly
-for real time and multimedia traffic.
+oriented protocol designed to solve issues present in UDP and TCP, particularly
+for real-time and multimedia (streaming) traffic.
+It divides into a base protocol (RFC 4340) and plugable congestion control
+modules called CCIDs. Like plugable TCP congestion control, at least one CCID
+needs to be enabled in order for the protocol to function properly. In the Linux
+implementation, this is the TCP-like CCID2 (RFC 4341). Additional CCIDs, such as
+the TCP-friendly CCID3 (RFC 4342), are optional.
+For a brief introduction to CCIDs and suggestions for choosing a CCID to match
+given applications, see section 10 of RFC 4340.
 
-It has a base protocol and pluggable congestion control IDs (CCIDs).
-
-It is at proposed standard RFC status and the homepage for DCCP as a protocol
-is at:
+DCCP is a proposed IETF standard, and the homepage for DCCP as a protocol is at:
 	http://www.read.cs.ucla.edu/dccp/
 
+
 Missing features
 ========
 
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -42,6 +42,17 @@ config IP_DCCP_DEBUG
 
 	  Just say N.
 
+config IP_DCCP_CCID2_DEBUG
+	  bool "CCID2 debugging messages"
+	  ---help---
+	  Enable CCID2-specific debugging messages.
+
+	  CCID2 is the default congestion control module for DCCP. This
+	  option facilitates verbose debugging output for CCID2. To enable,
+	  answer Y here and set the ccid2_debug module parameter to 1.
+
+	  If in doubt, say N.
+
 config NET_DCCPPROBE
 	tristate "DCCP connection probing"
 	depends on PROC_FS && KPROBES
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,50 +1,6 @@
 menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
 	depends on IP_DCCP && EXPERIMENTAL
 
-config IP_DCCP_CCID2
-	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
-	depends on IP_DCCP
-	def_tristate IP_DCCP
-	select IP_DCCP_ACKVEC
-	---help---
-	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
-	  Multiplicative Decrease (AIMD) congestion control with behavior
-	  modelled directly on TCP, including congestion window, slow start,
-	  timeouts, and so forth [RFC 2581].  CCID 2 achieves maximum
-	  bandwidth over the long term, consistent with the use of end-to-end
-	  congestion control, but halves its congestion window in response to
-	  each congestion event.  This leads to the abrupt rate changes
-	  typical of TCP.  Applications should use CCID 2 if they prefer
-	  maximum bandwidth utilization to steadiness of rate.  This is often
-	  the case for applications that are not playing their data directly
-	  to the user.  For example, a hypothetical application that
-	  transferred files over DCCP, using application-level retransmissions
-	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
-	  also prefer CCID 2.
-
-	  CCID 2 is further described in RFC 4341,
-	  http://www.ietf.org/rfc/rfc4341.txt
-
-	  This text was extracted from RFC 4340 (sec. 10.1),
-	  http://www.ietf.org/rfc/rfc4340.txt
-
-	  To compile this CCID as a module, choose M here: the module will be
-	  called dccp_ccid2.
-
-	  If in doubt, say M.
-
-config IP_DCCP_CCID2_DEBUG
-	  bool "CCID2 debugging messages"
-	  depends on IP_DCCP_CCID2
-	  ---help---
-	    Enable CCID2-specific debugging messages.
-
-	    When compiling CCID2 as a module, this debugging output can
-	    additionally be toggled by setting the ccid2_debug module
-	    parameter to 0 or 1.
-
-	    If in doubt, say N.
-
 config IP_DCCP_CCID3
 	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
 	depends on IP_DCCP
