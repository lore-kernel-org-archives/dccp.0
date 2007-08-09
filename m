From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Aug 2007 13:59:53 +0000
Subject: [PATCH 3/3]:  Update documentation
Message-Id: <200708091459.53303@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update documentation

This updates the DCCP documentation, following input from Ian McDonald,
clarifiying the status of DCCP, and adding a note about the test tree.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -26,19 +26,23 @@ given applications, see section 10 of RF
 
 It has a base protocol and pluggable congestion control IDs (CCIDs).
 
-It is at proposed standard RFC status and the homepage for DCCP as a protocol
-is at:
-	http://www.read.cs.ucla.edu/dccp/
+DCCP is a Proposed Standard (RFC 2026), and the homepage for DCCP as a protocol
+is at http://www.ietf.org/html.charters/dccp-charter.html
 
 Missing features
 ========
 
-The DCCP implementation does not currently have all the features that are in
-the RFC.
+The Linux DCCP implementation does not currently support all the features that are
+specified in RFCs 4340...42.
 
 The known bugs are at:
 	http://linux-net.osdl.org/index.php/TODO#DCCP
 
+For more up-to-date versions of the DCCP implementation, please consider using
+the experimental DCCP test tree; instructions for checking this out are on:
+http://linux-net.osdl.org/index.php/DCCP_Testing#Experimental_DCCP_source_tree
+
+
 Socket options
 =======
 
