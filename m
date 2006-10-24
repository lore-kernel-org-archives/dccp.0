From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:00:59 +0000
Subject: [PATCH 13/17] [DCCP]: Fix DCCP Probe typo by Ian McDonald
Message-Id: <200610241500.59486@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix DCCP Probe typo

Fixes a typo in Kconfig, patch is by Ian McDonald and is
re-sent from http://www.mail-archive.com/dccp@vger.kernel.org/msg00579.html


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 313795a..dd6249c 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -49,7 +49,7 @@ config NET_DCCPPROBE
 	DCCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 
-	Documentation on how to use the packet generator can be found
+	Documentation on how to use DCCP connection probing can be found
 	at http://linux-net.osdl.org/index.php/DccpProbe
 
 	To compile this code as a module, choose M here: the
