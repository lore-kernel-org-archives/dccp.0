From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:20:10 +0000
Subject: [PATCH 9/10]: Add documentation for TFRC structures
Message-Id: <200611241620.11129@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[NET]: Add documentation for TFRC structures

This adds documentation for the TFRC structure fields.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>      
---
 include/linux/tfrc.h |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

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
@@ -13,15 +14,30 @@
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
