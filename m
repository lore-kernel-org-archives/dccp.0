From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:32:04 +0000
Subject: [PATCH 22/25] Minor adjustments to probe.c to use tfrc_ccids
Message-Id: <200710312132.04423.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP] Minor adjustments to probe.c to use ccid34_lib

This will also facilitate the implementation of ccid-4 debug.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/probe.c
=================================--- leandro.new.orig/net/dccp/probe.c
+++ leandro.new/net/dccp/probe.c
@@ -34,7 +34,7 @@
 
 #include "dccp.h"
 #include "ccid.h"
-#include "ccids/ccid3.h"
+#include "ccids/lib/tfrc_ccids.h"
 
 static int port;
 
