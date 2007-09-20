From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:31:58 +0000
Subject: [PATCH] CCID 4: Add copyright/module author
Message-Id: <20070920113158.GE26233@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Adds copyright-entries and additional module author.

This was supposed to be part of the patch-set, but somehow I managed to
forget it until 4/5 was already out.


Signed-off-by: Tommi Saviranta <wnd@iki.fi>
---
diff -Nrup a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
--- a/net/dccp/ccids/ccid4.c	2007-09-20 13:32:42.000000000 +0300
+++ b/net/dccp/ccids/ccid4.c	2007-09-20 13:54:36.000000000 +0300
@@ -1,13 +1,14 @@
 /*
  *  net/dccp/ccids/ccid4.c
  *
+ *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *  An implementation of the DCCP protocol
  *
- *  This code has been developed by the University of Waikato WAND
+ *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
@@ -977,7 +978,8 @@ static __exit void ccid4_module_exit(voi
 }
 module_exit(ccid4_module_exit);
 
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
+MODULE_AUTHOR("Tommi Saviranta <wnd@iki.fi>, "
+	      "Ian McDonald <ian.mcdonald@jandi.co.nz>, "
 	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
 MODULE_DESCRIPTION("DCCP TFRC CCID4 CCID");
 MODULE_LICENSE("GPL");
diff -Nrup a/net/dccp/ccids/ccid4.h b/net/dccp/ccids/ccid4.h
--- a/net/dccp/ccids/ccid4.h	2007-09-20 13:32:42.000000000 +0300
+++ b/net/dccp/ccids/ccid4.h	2007-09-20 13:54:53.000000000 +0300
@@ -3,12 +3,13 @@
 /*
  *  net/dccp/ccids/ccid4.h
  *
+ *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
- *  This code has been developed by the University of Waikato WAND
+ *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
