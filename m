From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:25 +0000
Subject: [PATCH 4/5] [CCID2]: Stop polling
Message-Id: <1202996906-29652-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates CCID2 to use the CCID dequeuing mechanism, converting from
previous constant-polling to a now event-driven mechanism.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   21 +++++++++++++--------
 net/dccp/ccids/ccid2.h |    5 +++++
 2 files changed, 18 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -70,6 +70,11 @@ struct ccid2_hc_tx_sock {
 	struct list_head	ccid2hctx_parsed_ackvecs;
 };
 
+static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hctx)
+{
+	return (hctx->ccid2hctx_pipe >= hctx->ccid2hctx_cwnd);
+}
+
 struct ccid2_hc_rx_sock {
 	int	ccid2hcrx_data;
 };
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -124,12 +124,9 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 
 static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
-	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd)
-		return 0;
-
-	return 1; /* XXX CCID should dequeue when ready instead of polling */
+	if (ccid2_cwnd_network_limited(ccid2_hc_tx_sk(sk)))
+		return CCID_PACKET_WILL_DEQUEUE_LATER;
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
@@ -169,6 +166,7 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid2_cwnd_network_limited(hctx);
 	long s;
 
 	bh_lock_sock(sk);
@@ -189,8 +187,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	if (s > 60)
 		hctx->ccid2hctx_rto = 60 * HZ;
 
-	ccid2_start_rto_timer(sk);
-
 	/* adjust pipe, cwnd etc */
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
 	if (hctx->ccid2hctx_ssthresh < 2)
@@ -207,6 +203,11 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hctx->ccid2hctx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
 	ccid2_hc_tx_check_sanity(hctx);
+
+	/* if we were blocked before, we may now send cwnd=1 packet */
+	if (sender_was_blocked)
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
+	ccid2_start_rto_timer(sk);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -461,6 +462,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid2_cwnd_network_limited(hctx);
 	struct dccp_ackvec_parsed *avp;
 	u64 ackno, seqno;
 	struct ccid2_seq *seqp;
@@ -646,6 +648,9 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	ccid2_hc_tx_check_sanity(hctx);
 done:
+	/* check if incoming Acks allow pending packets to be sent */
+	if (sender_was_blocked && !ccid2_cwnd_network_limited(hctx))
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
 	dccp_ackvec_parsed_cleanup(&hctx->ccid2hctx_parsed_ackvecs);
 }
 
