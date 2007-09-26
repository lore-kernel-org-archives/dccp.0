From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 23:07:43 +0000
Subject: [PATCH 1/2] [DCCP]: Reduce the number of writable states
Message-Id: <20070926230743.GP10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since DCCP requires to close both ends of a connection simultaneously,
permission to write in state DCCP_CLOSING is removed in dccp_sendmsg():
 * if the sending end closed, it would encounter a write error anyhow;
 * if the other end has closed the connection, it accepts no more data.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/proto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 604de8b..7e4f54a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -664,7 +664,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 * so that the trick in dccp_rcv_request_sent_state_process.
 	 */
 	/* Wait for a connection to finish. */
-	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN | DCCPF_CLOSING))
+	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
 		if ((rc = sk_stream_wait_connect(sk, &timeo)) != 0)
 			goto out_release;
 
-- 
1.5.2.2

