From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Jul 2007 14:26:42 +0000
Subject: [PATCH 5/10]: Perform SHUT_RD and SHUT_WR on receiving close
Message-Id: <200707121526.42144@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Perform SHUT_RD and SHUT_WR on receiving close

The first change is to close the write-end in addition to the read-end when
a fin-like segment (Close or CloseReq) is received by DCCP. This accounts
for the fact that DCCP, in contrast to TCP, does not have a half-close. I
checked the specification - when a fin-like segment has been sent there is
no guarantee at all that any further data will be processed.

Thus this patch performs SHUT_WR in addition to the SHUT_RD when a fin-like
segment is encountered.

The second change is minor; I noted that code appears twice in different
places and think it makes sense to put this into a self-contained function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -19,16 +19,27 @@
 #include "ccid.h"
 #include "dccp.h"
 
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
 static void dccp_rcv_close(struct sock *sk, struct sk_buff *skb)
 {
 	if (sk->sk_state = DCCP_CLOSEREQ) {
@@ -187,10 +198,7 @@ static int __dccp_rcv_established(struct
 		 * FIXME: check if sk_receive_queue is full, schedule DATA_DROPPED
 		 * option if it is.
 		 */
-		__skb_pull(skb, dh->dccph_doff * 4);
-		__skb_queue_tail(&sk->sk_receive_queue, skb);
-		skb_set_owner_r(skb, sk);
-		sk->sk_data_ready(sk, 0);
+		dccp_enqueue_skb(sk, skb);
 		return 0;
 	case DCCP_PKT_ACK:
 		goto discard;
