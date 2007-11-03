From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:04:23 +0000
Subject: [PATCH 9/9] [CCID2]: Remove misleading comment
Message-Id: <200711031324.02949@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes a comment which identifies an `issue' with dccp_write_xmit() where there is none.
The comment assumes it is possible that a packet is sent between the calls to

	ccid_hc_tx_send_packet(),
	dccp_transmit_skb(),
	ccid_hc_tx_packet_sent()

(in the above order) in dccp_write_xmit().

I think that this is impossible, since dccp_write_xmit() is always called under lock:

 * when called as dccp_write_xmit(sk, 1) from dccp_send_close(), the socket is locked
   (see code comment above dccp_send_close());
 * when called as dccp_write_xmit(sk, 0) from dccp_send_msg(), it is after lock_sock() has been called;
 * when called as dccp_write_xmit(sk, 0) from dccp_write_xmit_timer(), bh_lock_sock() has been called
   and the if/else statement has made sure that sk_lock.owner is not set;
 * there are no other places where dccp_write_xmit() is called.

Furthermore, the debug statement for printing the sequence number of the packet just sent has been
removed, since the entire list is being printed anyway and so the entry of that number appears last.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 839e705..34c6285 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -228,18 +228,10 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	struct ccid2_seq *next;
-	u64 seq;
 
 	hctx->ccid2hctx_pipe++;
 
-	/* There is an issue.  What if another packet is sent between
-	 * packet_send() and packet_sent().  Then the sequence number would be
-	 * wrong.
-	 * -sorbo.
-	 */
-	seq = dp->dccps_gss;
-
-	hctx->ccid2hctx_seqh->ccid2s_seq   = seq;
+	hctx->ccid2hctx_seqh->ccid2s_seq   = dp->dccps_gss;
 	hctx->ccid2hctx_seqh->ccid2s_acked = 0;
 	hctx->ccid2hctx_seqh->ccid2s_sent  = jiffies;
 
@@ -313,7 +305,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-	ccid2_pr_debug("Sent: seq=%llu\n", (unsigned long long)seq);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
 
-- 
1.5.2.2.238.g7cbf2f2-dirty

