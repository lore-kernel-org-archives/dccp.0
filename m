From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Mon, 22 Nov 2021 10:16:22 +0000
Subject: [PATCH net-next 2/2] dccp: Inline dccp_listen_start().
Message-Id: <20211122101622.50572-3-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch inlines dccp_listen_start() and removes a stale comment in
inet_dccp_listen() so that it looks like inet_listen().

Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
---
 net/dccp/proto.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 55b8f958cdd2..a976b4d29892 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -238,17 +238,6 @@ void dccp_destroy_sock(struct sock *sk)
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);
 
-static inline int dccp_listen_start(struct sock *sk)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	dp->dccps_role = DCCP_ROLE_LISTEN;
-	/* do not start to listen if feature negotiation setup fails */
-	if (dccp_feat_finalise_settings(dp))
-		return -EPROTO;
-	return inet_csk_listen_start(sk);
-}
-
 static inline int dccp_need_reset(int state)
 {
 	return state != DCCP_CLOSED && state != DCCP_LISTEN &&
@@ -931,11 +920,17 @@ int inet_dccp_listen(struct socket *sock, int backlog)
 	 * we can only allow the backlog to be adjusted.
 	 */
 	if (old_state != DCCP_LISTEN) {
-		/*
-		 * FIXME: here it probably should be sk->sk_prot->listen_start
-		 * see tcp_listen_start
-		 */
-		err = dccp_listen_start(sk);
+		struct dccp_sock *dp = dccp_sk(sk);
+
+		dp->dccps_role = DCCP_ROLE_LISTEN;
+
+		/* do not start to listen if feature negotiation setup fails */
+		if (dccp_feat_finalise_settings(dp)) {
+			err = -EPROTO;
+			goto out;
+		}
+
+		err = inet_csk_listen_start(sk);
 		if (err)
 			goto out;
 	}
-- 
2.30.2
