From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Thu, 02 Mar 2006 00:28:32 +0000
Subject: Re: net-2.6.17 rebased...
Message-Id: <cbec11ac0603011628r662dbe19oc1abf02a1b6b0a2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/2/06, David S. Miller <davem@davemloft.net> wrote:
>
> This tree was getting crufty, so I rebased it today.
> It was actually a lot easier than I had anticipated.
>
>         master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.17.git
>
Dave,

If you get a chance can you push the ccid3 divide by zero fix upstream
to Linus for 2.6.16 as it has no functionality changed and eliminates
a nasty little bug...

The commit for this is b6da19617f4ab610d3d90bcbdf65fa7e2b3d7b53 in your tree

I have also put at end of this e-mail after reapplying on linus tree
so above commit doesn't have fuzz...

[DCCP] ccid3: Divide by zero fix

In rare circumstances 0 is returned by dccp_li_hist_calc_i_mean which leads to
a divide by zero in ccid3_hc_rx_packet_recv. Explicitly check for zero return
now. Update copyright notice at same time.

Found by Arnaldo.

Signed-off-by: Ian McDonald <imcdnzl@gmail.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

--- 2b82f96f1291c42ee9485465801f5f51897bec64
+++ ff426a9009993445a15cfcac6c88be1e39e07913
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
-		hcrx->ccid3hcrx_p = 1000000 /
dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
+		if (i_mean != 0)
+			hcrx->ccid3hcrx_p = 1000000 / i_mean;
+	}

 	if (hcrx->ccid3hcrx_p > p_prev) {
 		ccid3_hc_rx_send_feedback(sk);
