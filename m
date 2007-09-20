From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 17:54:54 +0000
Subject: [PATCH 3/4] CCID4: Signs off patch #2 submitted by Tommi and it organize the copyright and comments
Message-Id: <5bc4c4570709201054t564cf7aak2cf4cfcd41623c55@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>

diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.c
dccp-ccid4/net/dccp/ccids/ccid4.c
--- dccp-ccid4.base/net/dccp/ccids/ccid4.c	2007-09-20 11:45:30.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/ccid4.c	2007-09-20 13:57:32.000000000 -0300
@@ -1,15 +1,26 @@
 /*
  *  net/dccp/ccids/ccid4.c
  *
+ *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
  *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *  An implementation of the DCCP protocol
  *
+ *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab and University of Helsinki
+ *  For further information please see
+ *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
+ *  http://www.iki.fi/ <wnd@iki.fi>
+ *
+ *  Copyrithg (c) 2005-7 Ian McDonald
+ *
  *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
  *  authors:
diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.h
dccp-ccid4/net/dccp/ccids/ccid4.h
--- dccp-ccid4.base/net/dccp/ccids/ccid4.h	2007-09-20 11:45:30.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/ccid4.h	2007-09-20 13:55:52.000000000 -0300
@@ -3,12 +3,23 @@
 /*
  *  net/dccp/ccids/ccid4.h
  *
+ *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
  *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
+ *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *
+ *  This code has been developed by the Federal University of Campina Grande
+ *  Embedded Systems and Pervasive Computing Lab and University of Helsinki
+ *  For further information please see
+ *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
+ *  http://www.iki.fi/ <wnd@iki.fi>
+ *
+ *  Copyrithg (c) 2005-7 Ian McDonald
+ *
  *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
