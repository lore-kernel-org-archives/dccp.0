From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:10 +0000
Subject: [PATCH 3/6] dccp ccid-3: Dependency without effect
Message-Id: <1217340373-12620-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes a menu-item dependency which is without effect since the
enclosing menu "DCCP CCIDs Configuration (EXPERIMENTAL)" already has
this dependency.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -98,7 +98,6 @@ endchoice
 config IP_DCCP_CCID3_RTO
 	  int "Use higher bound for nofeedback timer"
 	  default 100
-	  depends on EXPERIMENTAL
 	  ---help---
 	    Use higher lower bound for nofeedback timer expiration.
 
