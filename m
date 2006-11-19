From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 19 Nov 2006 02:50:54 +0000
Subject: [PATCH 2/3] DCCP: Update documentation
Message-Id: <200611191550.55568.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch just updates the documentation a bit.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index b452ff8..dda1588 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -19,21 +19,17 @@ for real time and multimedia traffic.
 
 It has a base protocol and pluggable congestion control IDs (CCIDs).
 
-It is at draft RFC status and the homepage for DCCP as a protocol is at:
-	http://www.icir.org/kohler/dcp/
+It is at experimental RFC status and the homepage for DCCP as a protocol is at:
+	http://www.read.cs.ucla.edu/dccp/
 
 Missing features
 ========
 
 The DCCP implementation does not currently have all the features that are in
-the draft RFC.
+the RFC.
 
-In particular the following are missing:
-- CCID2 support
-- feature negotiation
-
-When testing against other implementations it appears that elapsed time
-options are not coded compliant to the specification.
+The known bugs are at:
+	http://linux-net.osdl.org/index.php/TODO#DCCP
 
 Socket options
 =======
@@ -111,9 +107,6 @@ tx_qlen = 5
 Notes
 == 
-SELinux does not yet have support for DCCP. You will need to turn it off or
-else you will get EACCES.
-
-DCCP does not travel through NAT successfully at present. This is because
-the checksum covers the psuedo-header as per TCP and UDP. It should be
-relatively trivial to add Linux NAT support for DCCP.
+DCCP does not travel through NAT successfully at present on many boxes. This is
+because the checksum covers the psuedo-header as per TCP and UDP. Linux NAT
+support for DCCP has been added.
