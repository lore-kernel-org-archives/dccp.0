From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 27 Nov 2006 14:46:50 +0000
Subject: [PATCH 8/8] [NET]: Add documentation for TFRC structures
Message-Id: <20061127144649.GS11605@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds documentation for the TFRC structure fields.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/tfrc.h |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/tfrc.h b/include/linux/tfrc.h
index 7dab783..31a9b25 100644
--- a/include/linux/tfrc.h
+++ b/include/linux/tfrc.h
@@ -1,7 +1,8 @@
 #ifndef _LINUX_TFRC_H_
 #define _LINUX_TFRC_H_
 /*
- *  include/linux/tfrc.h
+ *  TFRC - Data Structures for the TCP-Friendly Rate Control congestion
+ *         control mechanism as specified in RFC 3448.
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
@@ -13,15 +14,30 @@ #define _LINUX_TFRC_H_
  *  the Free Software Foundation; either version 2 of the License, or
  *  (at your option) any later version.
  */
-
 #include <linux/types.h>
 
+/** 	tfrc_rx_info    -    TFRC Receiver Data Structure
+ *
+ * 	@tfrcrx_x_recv:	receiver estimate of sending rate (3.2.2)
+ * 	@tfrcrx_rtt:	round-trip-time (communicated by sender)
+ * 	@tfrcrx_p:	current estimate of loss event rate (3.2.2)
+ */
 struct tfrc_rx_info {
   	__u32 tfrcrx_x_recv;
 	__u32 tfrcrx_rtt;
   	__u32 tfrcrx_p;
 };
 
+/** 	tfrc_tx_info    -    TFRC Sender Data Structure
+ *
+ * 	@tfrctx_x:	computed transmit rate (4.3 (4))
+ * 	@tfrctx_x_recv: receiver estimate of send rate (4.3)
+ * 	@tfrctx_x_calc:	return value of throughput equation (3.1)
+ * 	@tfrctx_rtt:	(moving average) estimate of RTT (4.3)
+ * 	@tfrctx_p:	current loss event rate (5.4)
+ * 	@tfrctx_rto:	estimate of RTO, equals 4*RTT (4.3)
+ * 	@tfrctx_ipi:	inter-packet interval (4.6)
+ */
 struct tfrc_tx_info {
 	__u32 tfrctx_x;
 	__u32 tfrctx_x_recv;
-- 
1.4.2.1.g3d5c

