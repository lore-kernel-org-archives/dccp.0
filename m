From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 30 Sep 2006 05:42:08 +0000
Subject: [PATCH 1/1] DCCP: Fix DCCP Probe typo
Message-Id: <200609301742.08319.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This mirrors commit 82fe7c924e61f9444b376498496942d41fbe9d26

DCCP probe was a copy of TCP probe complete with this bug.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index e2a095d..a40e0b0 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -49,7 +49,7 @@ config NET_DCCPPROBE
 	DCCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 
-	Documentation on how to use the packet generator can be found
+	Documentation on how to use DCCP connection probing can be found
 	at http://linux-net.osdl.org/index.php/DccpProbe
 
 	To compile this code as a module, choose M here: the
