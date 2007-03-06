From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 09:36:58 +0000
Subject: [PATCH 2/2]: Set RTO for child socket
Message-Id: <200703060936.58488@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Set RTO for newly created child socket

This mirrors a recent change in tcp_open_req_child, whereby the
icsk_rto of the newly created child socket was not set (but rather
on the parent socket). Same fix for DCCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/minisocks.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -103,7 +103,7 @@ struct sock *dccp_create_openreq_child(s
 
 	if (newsk != NULL) {
 		const struct dccp_request_sock *dreq = dccp_rsk(req);
-		struct inet_connection_sock *newicsk = inet_csk(sk);
+		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
 		struct dccp_minisock *newdmsk = dccp_msk(newsk);
 
