From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:39 +0000
Subject: [PATCH 14/18] [CCID2]: Remove redundant synchronisation variable
Message-Id: <1195950103-18102-15-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This removes the synchronisation variable `ccid2hctx_sendwait', which is set to 1
when the CCID2 sender may send a new packet, and which is set to 0 otherwise

The variable is redundant, since it is only used in combination with the hc_tx_send_packet/
hc_tx_packet_sent function pair. Both functions are called under socket lock, so the
following happens when the CCID2 may send a new packet:

 * it sets sendwait = 1 in tx_send_packet and returns 0;
 * the subsequent call to tx_packet_sent clears the sendwait flag;
 * since tx_send_packet returns 0 if and only if sendwait = 1, the BUG_ON condition
   in tx_packet_sent is never satisfied, since that function is never called when
   tx_send_packet returns a value different from 0 (cf. dccp_write_xmit);
 * the call to tx_packet_sent clears the flag so that the condition "!sendwait" is
   true the next time tx_packet_sent is called.

In other words, it is sufficient to just return 0 / not-0 to synchronise tx_send_packet
and tx_packet_sent -- which is what the patch does.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   11 ++---------
 net/dccp/ccids/ccid2.h |    1 -
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 2d1b7e3..4f6c352 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,13 +126,8 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd) {
-		/* OK we can send... make sure previous packet was sent off */
-		if (!hctx->ccid2hctx_sendwait) {
-			hctx->ccid2hctx_sendwait = 1;
-			return 0;
-		}
-	}
+	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd)
+		return 0;
 
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
 }
@@ -236,8 +231,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	struct ccid2_seq *next;
 	u64 seq;
 
-	BUG_ON(!hctx->ccid2hctx_sendwait);
-	hctx->ccid2hctx_sendwait = 0;
 	hctx->ccid2hctx_pipe++;
 
 	/* There is an issue.  What if another packet is sent between
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index bc659f0..2671f8e 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -66,7 +66,6 @@ struct ccid2_hc_tx_sock {
 	struct timer_list	ccid2hctx_rtotimer;
 	u64			ccid2hctx_rpseq;
 	int			ccid2hctx_rpdupack;
-	int			ccid2hctx_sendwait;
 	unsigned long		ccid2hctx_last_cong;
 	u64			ccid2hctx_high_ack;
 };
-- 
1.5.3.4

