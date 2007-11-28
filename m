From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 Nov 2007 08:35:11 +0000
Subject: [PATCH 4/4]: Remove duplicate test for CloseReq
Message-Id: <11962389121810-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove duplicate test for CloseReq

This removes a redundant test for unexpected packet types. In dccp_rcv_state_process
it is tested twice whether a DCCP-server has received a CloseReq (Step 7):

 * first in the combined if-statement,
 * then in the call to dccp_rcv_closereq().

The latter is necesssary since dccp_rcv_closereq() is also called from
__dccp_rcv_established().

This patch removes the duplicate test.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -616,16 +616,14 @@ int dccp_rcv_state_process(struct sock *
 		return 0;
 		/*
 		 *   Step 7: Check for unexpected packet types
-		 *      If (S.is_server and P.type = CloseReq)
-		 *	    or (S.is_server and P.type = Response)
+		 *      If (S.is_server and P.type = Response)
 		 *	    or (S.is_client and P.type = Request)
 		 *	    or (S.state = RESPOND and P.type = Data),
 		 *	  Send Sync packet acknowledging P.seqno
 		 *	  Drop packet and return
 		 */
 	} else if ((dp->dccps_role != DCCP_ROLE_CLIENT &&
-		    (dh->dccph_type = DCCP_PKT_RESPONSE ||
-		     dh->dccph_type = DCCP_PKT_CLOSEREQ)) ||
+		    dh->dccph_type = DCCP_PKT_RESPONSE) ||
 		    (dp->dccps_role = DCCP_ROLE_CLIENT &&
 		     dh->dccph_type = DCCP_PKT_REQUEST) ||
 		    (sk->sk_state = DCCP_RESPOND &&
