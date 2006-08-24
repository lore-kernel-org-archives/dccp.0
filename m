From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:20:09 +0000
Subject: [PATCH 2/7] [DCCP]: Update contact details and copyright
Message-Id: <200608241520.10570.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just updating copyright and contacts

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/CREDITS b/CREDITS
index 29be6d1..0fe904e 100644
--- a/CREDITS
+++ b/CREDITS
@@ -2209,7 +2209,7 @@ S: (address available on request)
 S: USA
 
 N: Ian McDonald
-E: iam4@cs.waikato.ac.nz
+E: ian.mcdonald@jandi.co.nz
 E: imcdnzl@gmail.com
 W: http://wand.net.nz/~iam4
 W: http://imcdnzl.blogspot.com
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c39bff7..0f85970 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -2,7 +2,7 @@
  *  net/dccp/ccids/ccid3.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005-6 Ian McDonald <imcdnzl@gmail.com>
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *  An implementation of the DCCP protocol
  *
@@ -1230,7 +1230,7 @@ static __exit void ccid3_module_exit(voi
 }
 module_exit(ccid3_module_exit);
 
-MODULE_AUTHOR("Ian McDonald <iam4@cs.waikato.ac.nz>, "
+MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
 	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
 MODULE_DESCRIPTION("DCCP TFRC CCID3 CCID");
 MODULE_LICENSE("GPL");
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 5ade4f6..22cb9f8 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -1,13 +1,13 @@
 /*
  *  net/dccp/ccids/ccid3.h
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
- *  or e-mail Ian McDonald - iam4@cs.waikato.ac.nz
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
  *  authors:
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 5d7b7d8..b93d9fc 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -2,7 +2,7 @@
  *  net/dccp/ccids/lib/loss_interval.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
  *  This program is free software; you can redistribute it and/or modify
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 43bf782..dcb370a 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -4,7 +4,7 @@ #define _DCCP_LI_HIST_
  *  net/dccp/ccids/lib/loss_interval.h
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
  *  This program is free software; you can redistribute it and/or modify it
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 6739be1..7b6b03e 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,13 +1,13 @@
 /*
  *  net/dccp/packet_history.c
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
- *  or e-mail Ian McDonald - iam4@cs.waikato.ac.nz
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
  *  authors:
@@ -391,7 +391,7 @@ void dccp_tx_hist_purge(struct dccp_tx_h
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
 
-MODULE_AUTHOR("Ian McDonald <iam4@cs.waikato.ac.nz>, "
+MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
 	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
 MODULE_DESCRIPTION("DCCP TFRC library");
 MODULE_LICENSE("GPL");
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 673c209..27c4309 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -1,13 +1,13 @@
 /*
  *  net/dccp/packet_history.h
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
- *  or e-mail Ian McDonald - iam4@cs.waikato.ac.nz
+ *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
  *
  *  This code also uses code from Lulea University, rereleased as GPL by its
  *  authors:
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index 130c4c4..45f30f5 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -4,7 +4,7 @@ #define _TFRC_H_
  *  net/dccp/ccids/lib/tfrc.h
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
  *
diff --git a/net/dccp/ccids/lib/tfrc_equation.c b/net/dccp/ccids/lib/tfrc_equation.c
index 4fd2ebe..44076e0 100644
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -2,7 +2,7 @@
  *  net/dccp/ccids/lib/tfrc_equation.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
  *
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index d00a2f4..b8931d3 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -5,7 +5,7 @@ #define _DCCP_H
  *
  *  An implementation of the DCCP protocol
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License version 2 as
diff --git a/net/dccp/options.c b/net/dccp/options.c
index daf72bb..07a3469 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -4,7 +4,7 @@
  *  An implementation of the DCCP protocol
  *  Copyright (c) 2005 Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *      This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
