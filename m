From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:26:12 +0000
Subject: Re: [PATCHv2 2/4] Implement loss counting on TFRC-SP receiver
Message-Id: <20091019052612.GE3366@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="9zSXsLTf0vkW971A"
List-Id: <dccp.vger.kernel.org>
References: <4AD4B67F.8040208@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B67F.8040208@embedded.ufcg.edu.br>
To: dccp@vger.kernel.org


--9zSXsLTf0vkW971A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| --- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:58:21.418908270 -0300
| +++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:59:07.442411383 -0300
| @@ -243,6 +243,7 @@
|  {
|  	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
|  	    s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
| +	    n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp,
|  	    s2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_seqno,
|  	    s3 = DCCP_SKB_CB(skb)->dccpd_seq;
I have removed the old definition of n1, which was further below and which caused this warning.

net/dccp/ccids/lib/packet_history_sp.c:276:7: warning: symbol 'n1' shadows an earlier 
net/dccp/ccids/lib/packet_history_sp.c:247:6: originally declared here


I thought again about the earlier suggestion to make 'num_losses' u64. Since li_losses sums the values
stored in num_losses, it needs to have the same size (currently it is u32). But then another thought is
that if there are so many losses that u32 overflows, then the performance is so bad anyway that it is
better to turn off the receiver. Hence I have reverted it to u32, as per your original patch.

Please find attached a patch of the changes I made. As per posting, I have separated out the dccp.h part,
since it is also useful in general.

--9zSXsLTf0vkW971A
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="2.diff"

--- a/net/dccp/ccids/lib/packet_history_sp.c
+++ b/net/dccp/ccids/lib/packet_history_sp.c
@@ -272,7 +272,6 @@ static int __two_after_loss(struct tfrc_
 	/* S0  <  S3  <  S1 */
 
 	if (dccp_loss_free(s0, s3, n3)) {
-		u64 n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp;
 
 		if (dccp_loss_free(s3, s1, n1)) {
 			/* hole between S0 and S1 filled by S3 */
--- a/net/dccp/ccids/lib/packet_history_sp.h
+++ b/net/dccp/ccids/lib/packet_history_sp.h
@@ -117,7 +117,7 @@ struct tfrc_rx_hist {
 	u32			  packet_size,
 				  bytes_recvd;
 	ktime_t			  bytes_start;
-	u64			  num_losses;
+	u32			  num_losses;
 };
 
 /**
--- a/net/dccp/ccids/lib/loss_interval_sp.c
+++ b/net/dccp/ccids/lib/loss_interval_sp.c
@@ -203,7 +203,8 @@ bool tfrc_sp_lh_interval_add(struct tfrc
 	cur->li_seqno	  = cong_evt_seqno;
 	cur->li_ccval	  = cong_evt->tfrchrx_ccval;
 	cur->li_is_closed = false;
-	cur->li_losses    = rh->num_losses;
+
+	cur->li_losses = rh->num_losses;
 	rh->num_losses = 0;
 
 	if (++lh->counter == 1)

--9zSXsLTf0vkW971A--
