From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Jul 2007 15:23:02 +0000
Subject: [PATCH 1/2]:  Check for unread data on close
Message-Id: <200707131623.02331@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Check for unread data on close

This removes one FIXME with regard to close when there is still unread data.
The mechanism is implemented similar to TCP: with regard to DCCP-specifics,
a Reset with Code 2, "Aborted" is sent to the peer.

This corresponds in part to RFC 4340, 8.1.1 and 8.1.5.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>    
---
 net/dccp/proto.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -920,6 +920,7 @@ void dccp_close(struct sock *sk, long ti
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
+	u32 data_was_unread = 0;
 	int state;
 
 	lock_sock(sk);
@@ -942,12 +943,17 @@ void dccp_close(struct sock *sk, long ti
 	 * descriptor close, not protocol-sourced closes, because the
 	  *reader process may not have drained the data yet!
 	 */
-	/* FIXME: check for unread data */
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		data_was_unread += skb->len;
 		__kfree_skb(skb);
 	}
 
-	if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+	if (data_was_unread) {
+		/* Unread data was tossed, send an appropriate Reset Code */
+		DCCP_WARN("DCCP: ABORT -- %u bytes unread\n", data_was_unread);
+		dccp_send_reset(sk, DCCP_RESET_CODE_ABORTED);
+		dccp_set_state(sk, DCCP_CLOSED);
+	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
 	} else	/* Passive/active close after all data has been read. */
