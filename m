From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 15:31:18 +0000
Subject: [PATCH 9/10][DCCP]: Fix DCCP Probe Typo
Message-Id: <20061110153117.GM23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Fixes a typo in Kconfig, patch is by Ian McDonald and is re-sent from
http://www.mail-archive.com/dccp@vger.kernel.org/msg00579.html

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index ef8919c..2fc5e55 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -49,7 +49,7 @@ config NET_DCCPPROBE
 	DCCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 
-	Documentation on how to use the packet generator can be found
+	Documentation on how to use DCCP connection probing can be found
 	at http://linux-net.osdl.org/index.php/DccpProbe
 
 	To compile this code as a module, choose M here: the
