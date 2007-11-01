From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:24 +0000
Subject: [PATCH 7/25] Initial lib for sharing common code between ccid-3/ccid-4
Message-Id: <200710312130.24513.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4 lib] Initial lib for sharing common code between ccid-3/ccid-4

The lib is called tfrc_ccids.o

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/lib/Makefile
=================================--- leandro.new.orig/net/dccp/ccids/lib/Makefile
+++ leandro.new/net/dccp/ccids/lib/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
 
 dccp_tfrc_lib-y := tfrc_module.o    tfrc_equation.o \
-                   packet_history.o loss_interval.o
+                   packet_history.o loss_interval.o \
+		   tfrc_ccids.o
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- /dev/null
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
@@ -0,0 +1,14 @@
+/*
+ *  net/dccp/ccids/lib/tfrc_ccids.c
+ *
+ *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+#include "tfrc_ccids.h"
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- /dev/null
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -0,0 +1,24 @@
+/*
+ *  net/dccp/ccids/lib/tfrc_ccids.h
+ *
+ *  Copyright (c) 2007 Leandro Melo de Sales <leandroal@gmail.com>
+ *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+#ifndef _TFRC_CCIDS_H_
+#define _TFRC_CCIDS_H_
+
+#include <linux/ktime.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/tfrc.h>
+#include <asm/unaligned.h>
+#include "tfrc.h"
+
+#endif /* _TFRC_CCIDS_H_ */
