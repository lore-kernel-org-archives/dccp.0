From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:58:42 +0000
Subject: [PATCH 1/8] Remove unnecessary comments to ccids code
Message-Id: <200712201358.43034.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCIDS] Remove unnecessary comments to ccids code

This patch removes some unnecessary files header comments. This was suggested by Arnaldo. According to Arnaldo there is no need to reference the file name in the header comments. It also commit the misspelling of copyright in ccid-4 code, reported by Ian. Note that this patches just apply to ccids code, not for the hole DCCP code.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4/net/dccp/ccids/ccid2.c
=================================--- ccid4.orig/net/dccp/ccids/ccid2.c
+++ ccid4/net/dccp/ccids/ccid2.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid2.c
- *
  *  Copyright (c) 2005, 2006 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
  *  Changes to meet Linux coding standards, and DCCP infrastructure fixes.
Index: ccid4/net/dccp/ccids/ccid2.h
=================================--- ccid4.orig/net/dccp/ccids/ccid2.h
+++ ccid4/net/dccp/ccids/ccid2.h
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid2.h
- *
  *  Copyright (c) 2005 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
  *
  *  This program is free software; you can redistribute it and/or modify
Index: ccid4/net/dccp/ccids/ccid3.c
=================================--- ccid4.orig/net/dccp/ccids/ccid3.c
+++ ccid4/net/dccp/ccids/ccid3.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid3.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
Index: ccid4/net/dccp/ccids/ccid3.h
=================================--- ccid4.orig/net/dccp/ccids/ccid3.h
+++ ccid4/net/dccp/ccids/ccid3.h
@@ -1,8 +1,6 @@
 #ifndef _DCCP_CCID3_H_
 #define _DCCP_CCID3_H_
 /*
- *  net/dccp/ccids/ccid3.h
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
Index: ccid4/net/dccp/ccids/ccid4.c
=================================--- ccid4.orig/net/dccp/ccids/ccid4.c
+++ ccid4/net/dccp/ccids/ccid4.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/ccid4.c
- *
  *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
  *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
@@ -8,7 +6,7 @@
  *
  *  An implementation of the DCCP protocol
  *
- *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *  Copyright (c) 2007 Leandro Sales, Tommi Saviranta
  *
  *  This code has been developed by the Federal University of Campina Grande
  *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
@@ -16,7 +14,7 @@
  *  http://embedded.ufcg.edu.br/ <leandroal@gmail.com>
  *  http://www.iki.fi/ <wnd@iki.fi>
  *
- *  Copyrithg (c) 2005-7 Ian McDonald
+ *  Copyright (c) 2005-7 Ian McDonald
  *
  *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
Index: ccid4/net/dccp/ccids/ccid4.h
=================================--- ccid4.orig/net/dccp/ccids/ccid4.h
+++ ccid4/net/dccp/ccids/ccid4.h
@@ -1,8 +1,6 @@
 #ifndef _DCCP_CCID4_H_
 #define _DCCP_CCID4_H_
 /*
- *  net/dccp/ccids/ccid4.c
- *
  *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
  *  Copyright (c) 2007   University of Helsinki, Finland.
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
@@ -10,7 +8,7 @@
  *
  *  An implementation of the DCCP protocol
  *
- *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
+ *  Copyright (c) 2007 Leandro Sales, Tommi Saviranta
  *
  *  This code has been developed by the Federal University of Campina Grande
  *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
@@ -18,7 +16,7 @@
  *  http://embedded.ufcg.edu.br/ <leandroal@gmail.com>
  *  http://www.iki.fi/ <wnd@iki.fi>
  *
- *  Copyrithg (c) 2005-7 Ian McDonald
+ *  Copyright (c) 2005-7 Ian McDonald
  *
  *  This code is based on code developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
Index: ccid4/net/dccp/ccids/lib/loss_interval.c
=================================--- ccid4.orig/net/dccp/ccids/lib/loss_interval.c
+++ ccid4/net/dccp/ccids/lib/loss_interval.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/loss_interval.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
Index: ccid4/net/dccp/ccids/lib/loss_interval.h
=================================--- ccid4.orig/net/dccp/ccids/lib/loss_interval.h
+++ ccid4/net/dccp/ccids/lib/loss_interval.h
@@ -1,8 +1,6 @@
 #ifndef _DCCP_LI_HIST_
 #define _DCCP_LI_HIST_
 /*
- *  net/dccp/ccids/lib/loss_interval.h
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
Index: ccid4/net/dccp/ccids/lib/packet_history.c
=================================--- ccid4.orig/net/dccp/ccids/lib/packet_history.c
+++ ccid4/net/dccp/ccids/lib/packet_history.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/packet_history.c
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
Index: ccid4/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4/net/dccp/ccids/lib/tfrc_ccids.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/tfrc_ccids.c
- *
  *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: ccid4/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4/net/dccp/ccids/lib/tfrc_ccids.h
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/tfrc_ccids.h
- *
  *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: ccid4/net/dccp/ccids/lib/tfrc_equation.c
=================================--- ccid4.orig/net/dccp/ccids/lib/tfrc_equation.c
+++ ccid4/net/dccp/ccids/lib/tfrc_equation.c
@@ -1,6 +1,4 @@
 /*
- *  net/dccp/ccids/lib/tfrc_equation.c
- *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Index: ccid4/net/dccp/ccids/lib/tfrc.h
=================================--- ccid4.orig/net/dccp/ccids/lib/tfrc.h
+++ ccid4/net/dccp/ccids/lib/tfrc.h
@@ -1,8 +1,6 @@
 #ifndef _TFRC_H_
 #define _TFRC_H_
 /*
- *  net/dccp/ccids/lib/tfrc.h
- *
  *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
