From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:31 +0000
Subject: [PATCH 09/11] [DCCP]: Remove redundant dependency on IP_DCCP
Message-Id: <1195658913-24840-10-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This cleans up the consequences of an earlier patch which
introduced the `if IP_DCCP' clause into net/dccp/Kconfig.

The CCID Kconfig menu is sourced within this clause; as a
consequence, all tests of type `depends on IP_DCCP' are now
redundant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/Kconfig |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index f37af17..3d7d867 100644
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
 	select IP_DCCP_ACKVEC
 	---help---
@@ -38,7 +37,6 @@ config IP_DCCP_CCID2_DEBUG
 
 config IP_DCCP_CCID3
 	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
-	depends on IP_DCCP
 	def_tristate IP_DCCP
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
-- 
1.5.3.4

