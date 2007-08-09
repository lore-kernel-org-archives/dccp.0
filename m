From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Aug 2007 14:03:59 +0000
Subject: [PATCH 4 / 3]: Remove redundant dependency on IP_DCCP
Message-Id: <200708091503.59992@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hm, forgot it was 4, not, 3 patches. But this one is tiny anyhow:
------------------------------------------------------------------
[DCCP]: Remove redundant dependency on IP_DCCP

This cleans up the consequences of an earlier patch which 
introduced the `if IP_DCCP' clause into net/dccp/Kconfig.

The CCID Kconfig menu is sourced within this clause; as a
consequence, all tests of type `depends on IP_DCCP' are now
redundant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,9 +1,8 @@
 menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
-	depends on IP_DCCP && EXPERIMENTAL
+	depends on EXPERIMENTAL
 
 config IP_DCCP_CCID2
 	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
-	depends on IP_DCCP
 	def_tristate IP_DCCP
 	---help---
 	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
@@ -37,7 +36,6 @@ config IP_DCCP_CCID2_DEBUG
 
 config IP_DCCP_CCID3
 	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
-	depends on IP_DCCP
 	def_tristate IP_DCCP
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
