From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:57:48 +0000
Subject: [PATCH 8/9] [DCCP]: Update Documentation
Message-Id: <20061120205748.GI5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch just updates DCCP documentation a bit.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 Documentation/networking/dccp.txt |   23 ++++++++---------------
 1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index c2328c8..1910d09 100644
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
@@ -107,9 +103,6 @@ seq_window = 100
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
-- 
1.4.2.1.g3d5c

