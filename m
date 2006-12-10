From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 02:59:56 +0000
Subject: [PATCH 2/22] [DCCP]: Update documentation
Message-Id: <20061210025955.GD17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As Eddie Kohler points out the RFC is Proposed Standard not experimental.
Also removed documentation about deprecated socket option.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 Documentation/networking/dccp.txt |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

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
-- 
1.4.2.1.g3d5c

