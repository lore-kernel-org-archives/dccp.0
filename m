From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:36:54 +0000
Subject: [PATCH 35/43]: Reduce the number of writable states
Message-Id: <200704051636.54136@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Reduce the number of writable states

Since DCCP requires to close both ends of a connection simultaneously,
permission to write in state DCCP_CLOSING is removed in dccp_sendmsg():
 * if the sending end closed, it would encounter a write error anyhow; 
 * if the other end has closed the connection, it accepts no more data.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -674,7 +674,7 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	 * so that the trick in dccp_rcv_request_sent_state_process.
 	 */
 	/* Wait for a connection to finish. */
-	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN | DCCPF_CLOSING))
+	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
 		if ((rc = sk_stream_wait_connect(sk, &timeo)) != 0)
 			goto out_release;
 
