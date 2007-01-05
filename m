From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Jan 2007 14:55:16 +0000
Subject: [PATCH-UPDATE]: 3f_CCID3_refactor_loss_interval_code_McDonald.diff
Message-Id: <200701051455.16936@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I would like to retract the change in the interface of update_li which we discussed recently. 

The reason is that the caller supplies `loss' parameters (a loss sequence number and a loss
CCVal); the fact that in the current implementation this coincides with the fields 

       hccrx->ccid3hcrx_seqno_nonloss and
       hcrx->ccid3hcrx_ccval_nonloss

in ccid3_hc_rx_detect_loss is more of a coincidence. I have been going over this code several
times and come to the conclusion that not changing the interface of update_li is the cleanest
way. I have uploaded this to the online directory, below are the differences to Ian's original.


==> This is the `meta-diff' between original diff and the new diff:

--- b/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -842,7 +842,8 @@
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		dccp_li_update_li(sk);
+		dccp_li_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
+		                      hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
--- b/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -248,13 +248,11 @@
 		return 1000000 / p;
 }
 
-void dccp_li_update_li(struct sock *sk)
+void dccp_li_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
-	u64 seq_loss = hcrx->ccid3hcrx_seqno_nonloss;
-	u8 win_loss = hcrx->ccid3hcrx_ccval_nonloss;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
 		if (!dccp_li_hist_interval_new(&hcrx->ccid3hcrx_li_hist,
--- b/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -36,3 +36,3 @@
 
-extern void dccp_li_update_li(struct sock *sk);
+extern void dccp_li_update_li(struct sock *sk, u64 seq_loss, u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
