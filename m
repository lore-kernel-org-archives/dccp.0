From: joe@perches.com
Date: Mon, 13 Aug 2007 06:26:04 +0000
Subject: [PATCH] [148/2many] MAINTAINERS - DCCP PROTOCOL
Message-Id: <46bff97c.9avHEM3TinhF1DrA%joe@perches.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 7f54480..c786066 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1434,6 +1434,8 @@ M:	acme@ghostprotocols.net
 L:	dccp@vger.kernel.org
 W:	http://linux-net.osdl.org/index.php/DCCP
 S:	Maintained
+F:	include/linux/dccp.h
+F:	net/dccp/
 
 DECnet NETWORK LAYER
 P:	Patrick Caulfield
