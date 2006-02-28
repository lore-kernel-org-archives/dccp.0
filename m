From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Tue, 28 Feb 2006 21:24:33 +0000
Subject: Resend: [PATCH] DCCP: Divide by zero fix
Message-Id: <cbec11ac0602281324i6e1ff681m752c06c3b7fa7b97@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo,

Haven't seen this going in so resending...

Ian

---------- Forwarded message ----------
From: Ian McDonald <imcdnzl@gmail.com>
Date: Feb 17, 2006 3:17 PM
Subject: [PATCH] DCCP: Divide by zero fix
To: DCCP Mailing List <dccp@vger.kernel.org>, Arnaldo Carvalho de Melo
<acme@mandriva.com>


In rare circumstances 0 is returned by dccp_li_hist_calc_i_mean which
leads to a divide by zero in ccid3_hc_rx_packet_recv. Explicitly check
for zero return now. Update copyright notice at same time.

Found by Arnaldo

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
----
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 165fc40..fb4db88 100644
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
@@ -925,7 +925,7 @@ static void ccid3_hc_rx_packet_recv(stru
        struct dccp_rx_hist_entry *packet;
        struct timeval now;
        u8 win_count;
-       u32 p_prev, r_sample, t_elapsed;
+       u32 p_prev, r_sample, t_elapsed, i_mean;
        int ins;

        BUG_ON(hcrx = NULL ||
@@ -1025,9 +1025,11 @@ static void ccid3_hc_rx_packet_recv(stru
        p_prev = hcrx->ccid3hcrx_p;

        /* Calculate loss event rate */
-       if (!list_empty(&hcrx->ccid3hcrx_li_hist))
+       if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
+               i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+               if (i_mean)
                /* Scaling up by 1000000 as fixed decimal */
-               hcrx->ccid3hcrx_p = 1000000 /
dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+                       hcrx->ccid3hcrx_p = 1000000 / i_mean;

        if (hcrx->ccid3hcrx_p > p_prev) {
                ccid3_hc_rx_send_feedback(sk);


--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
