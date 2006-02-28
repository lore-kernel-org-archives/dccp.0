From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Feb 2006 22:09:02 +0000
Subject: [PATCH 4/4] [DCCP] ccid3: Divide by zero fix
Message-Id: <11411645423461-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In rare circumstances 0 is returned by dccp_li_hist_calc_i_mean which leads to
a divide by zero in ccid3_hc_rx_packet_recv. Explicitly check for zero return
now. Update copyright notice at same time.

Found by Arnaldo.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ccids/ccid3.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

8135f5c98f27d04094f7931495a917d856192f6a
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2b82f96..ff426a9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -2,7 +2,7 @@
  *  net/dccp/ccids/ccid3.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005-6 Ian McDonald <imcdnzl@gmail.com>
  *
  *  An implementation of the DCCP protocol
  *
@@ -1014,9 +1014,13 @@ static void ccid3_hc_rx_packet_recv(stru
 	p_prev = hcrx->ccid3hcrx_p;
 	
 	/* Calculate loss event rate */
-	if (!list_empty(&hcrx->ccid3hcrx_li_hist))
+	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
+		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+
 		/* Scaling up by 1000000 as fixed decimal */
-		hcrx->ccid3hcrx_p = 1000000 / dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+		if (i_mean != 0)
+			hcrx->ccid3hcrx_p = 1000000 / i_mean;
+	}
 
 	if (hcrx->ccid3hcrx_p > p_prev) {
 		ccid3_hc_rx_send_feedback(sk);
-- 
1.2.2.gd27d


