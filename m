From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 22 Feb 2006 21:38:41 +0000
Subject: [PATCH 2/4] [DCCP]: Kconfig tidy up
Message-Id: <11406443212156-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Make CCID2 and CCID3 default to what was selected for DCCP and use the standard
short description for the CCIDs (TCP-Like & TCP-Friendly).

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ccids/Kconfig |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

a28388caffd72cfbc92d2504344f24af59b7ed77
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 422af19..ca00191 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -2,8 +2,9 @@ menu "DCCP CCIDs Configuration (EXPERIME
 	depends on IP_DCCP && EXPERIMENTAL
 
 config IP_DCCP_CCID2
-	tristate "CCID2 (TCP) (EXPERIMENTAL)"
+	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
 	depends on IP_DCCP
+	def_tristate IP_DCCP
 	select IP_DCCP_ACKVEC
 	---help---
 	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
@@ -30,8 +31,9 @@ config IP_DCCP_CCID2
 	  If in doubt, say M.
 
 config IP_DCCP_CCID3
-	tristate "CCID3 (TFRC) (EXPERIMENTAL)"
+	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
 	depends on IP_DCCP
+	def_tristate IP_DCCP
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
-- 
1.1.GIT


