From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Aug 2007 13:59:33 +0000
Subject: [PATCH 2/3]: Promote CCID2 as default CCID
Message-Id: <200708091459.33988@strip-the-willow>
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
    CCIDs. Last, a non-empty CCID list is needed for doing CCID feature negotiation.

 2. Internally the default CCID that is advertised by the Linux host is set to CCID2
    (DCCPF_INITIAL_CCID in include/linux/dccp.h). Disabling CCID2 in the Kconfig
    menu without changing the defaults leads to a failure `module not found' when
    trying to load the dccp module (which internally tries to load the default CCID).

 3. The specification (RFC 4340, sec. 10) treats CCID2 somewhat like a 
    `minimum common denominator'; the specification says that:

    * "New connections start with CCID 2 for both endpoints"

    * "A DCCP implementation intended for general use, such as an implementation in a
       general-purpose operating system kernel, SHOULD implement at least CCID 2.
       The intent is to make CCID 2 broadly available for interoperability [...]"

    Providing CCID2 as minimum-required CCID (like Reno/Cubic in TCP) thus seems reasonable.

Hence this patch automatically selects CCID2 when DCCP is enabled. Documentation also added.

This patch grew out of fruitful discussions with Ian McDonald whose input is gratefully 
acknowledged.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   11 +++++++++--
 net/dccp/Kconfig                  |    1 +
 net/dccp/ccids/Kconfig            |   13 ++-----------
 3 files changed, 12 insertions(+), 13 deletions(-)

--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -1,6 +1,7 @@
 menuconfig IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
+	select IP_DCCP_CCID2
 	---help---
 	  Datagram Congestion Control Protocol (RFC 4340)
 
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -20,18 +20,9 @@ config IP_DCCP_CCID2
 	  to the user.  For example, a hypothetical application that
 	  transferred files over DCCP, using application-level retransmissions
 	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
-	  also prefer CCID 2.
+	  also prefer CCID 2.  See RFC 4341 for further details.
 
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
+	  CCID2 is the default CCID used by DCCP.
 
 config IP_DCCP_CCID2_DEBUG
 	  bool "CCID2 debugging messages"
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -14,8 +14,15 @@ Introduction
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
 
 It has a base protocol and pluggable congestion control IDs (CCIDs).
 
