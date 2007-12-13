From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:05:54 +0000
Subject: [PATCH 01/12] [DCCP]: Perform SHUT_RD and SHUT_WR on receiving close
Message-Id: <1197558365-31134-2-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This patch performs two changes:

1) Close the write-end in addition to the read-end when a fin-like segment
  (Close or CloseReq) is received by DCCP. This accounts for the fact that DCCP,
  in contrast to TCP, does not have a half-close. RFC 4340 says in this respect
  that when a fin-like segment has been sent there is no guarantee at all that
  any   further data will be processed.
  Thus this patch performs SHUT_WR in addition to the SHUT_RD when a fin-like
  segment is encountered.

2) Minor change: I noted that code appears twice in different places and think it
   makes sense to put this into a self-contained function (dccp_enqueue()).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/input.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index decf2f2..dacd4fd 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -22,16 +22,27 @@
 /* rate-limit for syncs in reply to sequence-invalid packets; RFC 4340, 7.5.4 */
 int sysctl_dccp_sync_ratelimit	__read_mostly = HZ / 8;
 
-static void dccp_fin(struct sock *sk, struct sk_buff *skb)
+static void dccp_enqueue_skb(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_shutdown |= RCV_SHUTDOWN;
-	sock_set_flag(sk, SOCK_DONE);
 	__skb_pull(skb, dccp_hdr(skb)->dccph_doff * 4);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	skb_set_owner_r(skb, sk);
 	sk->sk_data_ready(sk, 0);
 }
 
+static void dccp_fin(struct sock *sk, struct sk_buff *skb)
+{
+	/*
+	 * On receiving Close/CloseReq, both RD/WR shutdown are performed.
+	 * RFC 4340, 8.3 says that we MAY send further Data/DataAcks after
+	 * receiving the closing segment, but there is no guarantee that such
+	 * data will be processed at all.
+	 */
+	sk->sk_shutdown = SHUTDOWN_MASK;
+	sock_set_flag(sk, SOCK_DONE);
+	dccp_enqueue_skb(sk, skb);
+}
+
 static int dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
 	int queued = 0;
@@ -282,10 +293,7 @@ static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 		 * - sk_shutdown = RCV_SHUTDOWN, use Code 1, "Not Listening"
 		 * - sk_receive_queue is full, use Code 2, "Receive Buffer"
 		 */
-		__skb_pull(skb, dh->dccph_doff * 4);
-		__skb_queue_tail(&sk->sk_receive_queue, skb);
-		skb_set_owner_r(skb, sk);
-		sk->sk_data_ready(sk, 0);
+		dccp_enqueue_skb(sk, skb);
 		return 0;
 	case DCCP_PKT_ACK:
 		goto discard;
-- 
1.5.3.4

