From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 08 Dec 2006 01:25:43 +0000
Subject: [PATCH 1/1] DCCP: Update documentation
Message-Id: <200612081425.46312.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As Eddie Kohler points out the RFC is Proposed Standard not experimental.

Also remove removed socket option.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index dda1588..387482e 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -19,7 +19,8 @@ for real time and multimedia traffic.
 
 It has a base protocol and pluggable congestion control IDs (CCIDs).
 
-It is at experimental RFC status and the homepage for DCCP as a protocol is at:
+It is at proposed standard RFC status and the homepage for DCCP as a protocol
+is at:
 	http://www.read.cs.ucla.edu/dccp/
 
 Missing features
@@ -34,9 +35,6 @@ The known bugs are at:
 Socket options
 =======
 
-DCCP_SOCKOPT_PACKET_SIZE is used for CCID3 to set default packet size for
-calculations.
-
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
 the socket will fall back to 0 (which means that no meaningful service code
