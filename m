From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Jun 2007 14:41:04 +0000
Subject: [PATCH 3/3]: Update copyrights of CCID3/TFRC files
Message-Id: <200706181541.04407@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update copyrights of CCID3/TFRC files

 1. A substantial amount of time has gone into improving CCID3/TFRC.  
    Funding for this work was provided by The Unversity of Aberdeen, UK, which 
    is hereby acknowledged as sponsor.

 2. All copyrights of work contributed WAND research group have been updated, 
    using a recen patch by Ian McDonald. 


Please verify that copyright changes have indeed been updated correctly.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    1 +
 net/dccp/ccids/ccid3.h              |    3 ++-
 net/dccp/ccids/lib/loss_interval.c  |    1 +
 net/dccp/ccids/lib/loss_interval.h  |    1 +
 net/dccp/ccids/lib/packet_history.c |    3 ++-
 net/dccp/ccids/lib/packet_history.h |    5 ++---
 net/dccp/ccids/lib/tfrc.h           |    9 +++++----
 net/dccp/ccids/lib/tfrc_module.c    |    2 ++
 8 files changed, 16 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -3,7 +3,8 @@
 /*
  *  net/dccp/ccids/ccid3.h
  *
- *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,7 +1,8 @@
 /*
  *  net/dccp/packet_history.c
  *
- *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *
  *  An implementation of the DCCP protocol
  *
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -3,10 +3,11 @@
 /*
  *  net/dccp/ccids/lib/tfrc.h
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
- *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *  Copyright (c) 2005   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *  Copyright (c) 2003   Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
--- a/net/dccp/ccids/lib/tfrc_module.c
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -1,5 +1,7 @@
 /*
  * TFRC: main module holding the pieces of the TFRC library together
+ *
+ * Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  */
 #include <linux/module.h>
 #include <linux/moduleparam.h>
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -1,12 +1,11 @@
 #ifndef _DCCP_PKT_HIST_
 #define _DCCP_PKT_HIST_
 /*
- *  net/dccp/packet_history.h
+ *  Packet RX/TX history data structures and routines for TFRC-based protocols.
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *
- *  An implementation of the DCCP protocol
- *
  *  This code has been developed by the University of Waikato WAND
  *  research group. For further information please see http://www.wand.net.nz/
  *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1,6 +1,7 @@
 /*
  *  net/dccp/ccids/ccid3.c
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -1,6 +1,7 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.c
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -3,6 +3,7 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.h
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
