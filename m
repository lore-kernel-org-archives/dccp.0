From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:12:46 +0000
Subject: [Patch 4/12]: In-line ccid3_hc_tx_insert_options
Message-Id: <200612072112.46742@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: In-line ccid3_hc_tx_insert_options

The function ccid3_hc_tx_insert_options currently only does a no-op, 
since the operation 

  DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;

is already performed _unconditionally_ in ccid3_hc_tx_send_packet.

This redundancy is removed and the remaining stub function inlined.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -551,14 +551,8 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 }
 
-static int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
+static inline int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	BUG_ON(hctx = NULL);
-
-	if (sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN)
-		DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
 	return 0;
 }
 
