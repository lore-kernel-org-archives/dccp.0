From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:29 +0000
Subject: [PATCH 07/11] [DCCP]: Update documentation
Message-Id: <1195658913-24840-8-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This updates the DCCP documentation, following input from Ian McDonald,
clarifiying the status of DCCP, and adding a note about the test tree.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index f771034..fdc93be 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -19,19 +19,23 @@ for real time and multimedia traffic.
 
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
 
-- 
1.5.3.4

