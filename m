From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:42 +0000
Subject: [PATCH 17/18] [DCCP]: Check for unread data on close
Message-Id: <1195950103-18102-18-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This removes one FIXME with regard to close when there is still unread data.
The mechanism is implemented similar to TCP: with regard to DCCP-specifics,
a Reset with Code 2, "Aborted" is sent to the peer.

This corresponds in part to RFC 4340, 8.1.1 and 8.1.5.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/proto.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d48005f..5f47b45 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -891,6 +891,7 @@ void dccp_close(struct sock *sk, long timeout)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
+	u32 data_was_unread = 0;
 	int state;
 
 	lock_sock(sk);
@@ -913,12 +914,17 @@ void dccp_close(struct sock *sk, long timeout)
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
 	} else if (dccp_close_state(sk)) {
-- 
1.5.3.4

