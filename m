From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:18:36 +0000
Subject: [PATCH 1/7] [DCCP]: Fix typo
Message-Id: <200608241518.37099.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a small typo in net/dccp/libs/packet_history.c

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index ad98d6a..6739be1 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,5 +1,5 @@
 /*
- *  net/dccp/packet_history.h
+ *  net/dccp/packet_history.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *
