From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 08 Dec 2006 11:50:06 +0000
Subject: [Patchv2 4/12]: Deprecate ccid3_hc_tx_insert_options
Message-Id: <200612081150.06793@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > [CCID 3]: In-line ccid3_hc_tx_insert_options
<snip, quoting Ian: >
|  A couple of points here:
|  - the whole ccid3_hc_tx_insert_options could actually be removed with
|  a little work as there is no ccid2 equivalent and so the whole thing
|  isn't needed!
Many thanks for this information.
I currently hesitate to remove it from the CCID interface, it may be that we can
make use of it later (I am for instance thinking of the yet unresolved issue of 
communicating MSS values between CCID module and main DCCP module). 

But I have taken your comments on board, please find below the revised patch which
removes the tx_insert_options within ccid3.c, 
uploaded as 16d_deprecate_tx_insert_options.diff

-------------------> Revised Patch v2 <-------------------------------------------
[CCID 3]: Deprecate ccid3_hc_tx_insert_options

The function ccid3_hc_tx_insert_options only does a redundant no-op, 
as the operation 

  DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;

is already performed _unconditionally_ in ccid3_hc_tx_send_packet.

Since there is further no current need for this function, it is removed
entirely. Many thanks for Ian McDonald for collaboration on this issue.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   12 ------------
 1 file changed, 12 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -551,17 +551,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 }
 
-static int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	BUG_ON(hctx = NULL);
-
-	if (sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN)
-		DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
-	return 0;
-}
-
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 				     unsigned char len, u16 idx,
 				     unsigned char *value)
@@ -1216,7 +1205,6 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
-	.ccid_hc_tx_insert_options = ccid3_hc_tx_insert_options,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
