From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:05 +0000
Subject: [PATCH 1/7] [BUG-FIX] [CCID-3]: Don't interpret feedback when nothing has been sent
Message-Id: <1206462011-24907-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a BUG-Fix for CCID-3 which, on a server, lead to such messages:

  ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-281971487
  ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-2664160693
  ccid3_hc_tx_packet_recv: server(e7b7d030): DATAACK with bogus ACK-2775299822
  ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-3035830110
  ccid3_hc_tx_packet_recv: server(e7b7d030): DATAACK with bogus ACK-3436194561

The cause was that the (passive) server hadn't sent anything, i.e. its TX
history was empty. This patch adds the missing test for an empty TX history,
i.e. packets carrying Ack information are ignored if nothing has been sent.

I wanted to keep this generic, i.e. use a "hist_empty()" function instead of
"hctx->hist = NULL". Also replaced multiple occurrences of DCCP_SKB_CB.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   16 +++++++++-------
 net/dccp/ccids/lib/packet_history.h |    4 ++++
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index ec7424c..38273dc 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -384,13 +384,15 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	ktime_t now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
-	/* we are only interested in ACKs */
-	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
-	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
+	/* Ignore if nothing has been sent; feedback is on Ack/DataAck only */
+	if (tfrc_tx_hist_is_empty(hctx->ccid3hctx_hist) ||
+	    !(dcb->dccpd_type = DCCP_PKT_ACK ||
+	      dcb->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
 	if (hctx->ccid3hctx_state != TFRC_SSTATE_FBACK &&
@@ -402,11 +404,11 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Estimate RTT from history if ACK number is valid */
 	r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
-				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
+				    dcb->dccpd_ack_seq, now);
 	if (r_sample = 0) {
-		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
-			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
-			  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
+		DCCP_WARN("%s(%p): %s with bogus ACK #%llu\n",
+			  dccp_role(sk), sk, dccp_packet_name(dcb->dccpd_type),
+			  (unsigned long long)dcb->dccpd_ack_seq);
 		return;
 	}
 
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index c7eeda4..732b07e 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -42,6 +42,10 @@
 
 struct tfrc_tx_hist_entry;
 
+static inline bool tfrc_tx_hist_is_empty(const struct tfrc_tx_hist_entry *head)
+{
+	return head = NULL;
+}
 extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
 extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
 extern u32  tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head,
-- 
1.5.3.GIT

