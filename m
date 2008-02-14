From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:24 +0000
Subject: [PATCH 3/5] [DCCP]: Empty the write queue when disconnecting
Message-Id: <1202996906-29652-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_disconnect() can be called due to several reasons:

 1. when the connection setup failed (inet_stream_connect());
 2. when shutting down (inet_shutdown(), inet_csk_listen_stop());
 3. when aborting the connection (dccp_close() with 0 linger time).

In case (1) the write queue is empty. This patch empties the write queue,
if in case (2) or (3) it was not yet empty.

This avoids triggering the write-queue BUG_TRAP in sk_stream_kill_queues()
later on.

It also seems natural to do: when breaking an association, to delete all
packets that were originally intended for the soon-disconnected end (compare
with call to tcp_write_queue_purge in tcp_disconnect()).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -277,7 +277,9 @@ int dccp_disconnect(struct sock *sk, int flags)
 		sk->sk_err = ECONNRESET;
 
 	dccp_clear_xmit_timers(sk);
+
 	__skb_queue_purge(&sk->sk_receive_queue);
+	__skb_queue_purge(&sk->sk_write_queue);
 	if (sk->sk_send_head != NULL) {
 		__kfree_skb(sk->sk_send_head);
 		sk->sk_send_head = NULL;
