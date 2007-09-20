From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 17:54:32 +0000
Subject: [PATCH 2/4] CCID4: Provides organization to the initial entries for CCID 4 to net/dccp/ccids/Makefil
Message-Id: <5bc4c4570709201054n1beda2d8x6bfdcda0cbcbaa35@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>

Just to maintain the order or declarion 4, 3, 2 instead of 3 4 2, which can
facilitate either future identification and addition of new ccids on top of the
Makefile.

diff -uprN dccp-ccid4.base/net/dccp/ccids/Makefile
dccp-ccid4/net/dccp/ccids/Makefile
--- dccp-ccid4.base/net/dccp/ccids/Makefile	2007-09-20 11:45:30.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/Makefile	2007-09-20 11:55:23.000000000 -0300
@@ -1,3 +1,7 @@
+obj-$(CONFIG_IP_DCCP_CCID4) += dccp_ccid4.o
+
+dccp_ccid4-y := ccid4.o
+
 obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid3.o

 dccp_ccid3-y := ccid3.o
@@ -6,8 +10,4 @@ obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid

 dccp_ccid2-y := ccid2.o

-obj-$(CONFIG_IP_DCCP_CCID4) += dccp_ccid4.o
-
-dccp_ccid4-y := ccid4.o
-
 obj-y += lib/
