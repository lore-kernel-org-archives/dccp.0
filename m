From: Leandro <leandroal@gmail.com>
Date: Wed, 31 Oct 2007 23:21:53 +0000
Subject: [PATCH 3/25] Adjustments of the ccid-4 copyright and kernel module authors
Message-Id: <200710312021.53536.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Adjustments of the ccid-4 copyright and kernel module authors

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
Signed-off-by: Tommi Saviranta <wnd@iki.fi>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -1,14 +1,26 @@
 /*
  *  net/dccp/ccids/ccid4.c
  *
+ *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
+ *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *  An implementation of the DCCP protocol
  *
- *  This code has been developed by the University of Waikato WAND
+ *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
+ *  Science at the University of Helsinki. For further information please see
+ *  http://embedded.ufcg.edu.br/ <leandroal@gmail.com>
+ *  http://www.iki.fi/ <wnd@iki.fi>
+ *
+ *  Copyrithg (c) 2005-7 Ian McDonald
+ *
+ *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
  *  authors:
@@ -960,8 +972,8 @@ static __exit void ccid4_module_exit(voi
 }
 module_exit(ccid4_module_exit);
 
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
+MODULE_AUTHOR("Leandro Melo de Sales <leandroal@gmail.com>, "
+	      "Tommi Saviranta <wnd@iki.fi>");
 MODULE_DESCRIPTION("DCCP TFRC CCID4 CCID");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("net-dccp-ccid-4");
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -1,14 +1,26 @@
 #ifndef _DCCP_CCID4_H_
 #define _DCCP_CCID4_H_
 /*
- *  net/dccp/ccids/ccid4.h
+ *  net/dccp/ccids/ccid4.c
  *
+ *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
+ *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
- *  This code has been developed by the University of Waikato WAND
+ *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
+ *  Science at the University of Helsinki. For further information please see
+ *  http://embedded.ufcg.edu.br/ <leandroal@gmail.com>
+ *  http://www.iki.fi/ <wnd@iki.fi>
+ *
+ *  Copyrithg (c) 2005-7 Ian McDonald
+ *
+ *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
