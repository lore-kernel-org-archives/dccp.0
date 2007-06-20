From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:56:12 +0000
Subject: [PATCH 5/5]: Send Reset upon Sync in state REQUEST
Message-Id: <200706201056.12089@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Send Reset upon Sync in state REQUEST

This fixes the code to correspond to RFC 4340, 7.5.4, which states the
exception that a Sync received in state REQUEST generates a Reset (not
a SyncAck).

To achieve this, only a small change is required. Since
dccp_rcv_request_sent_state_process() already uses the correct Reset Code
number 4 ("Packet Error"), we only need to shift the if-statement a few
lines further down.

(To test this case: replace DCCP_PKT_RESPONSE with DCCP_PKT_SYNC 
                    in dccp_make_response.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>     
---
 net/dccp/input.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -551,11 +551,6 @@ int dccp_rcv_state_process(struct sock *
 		return 0;
 	}
 
-	if (unlikely(dh->dccph_type = DCCP_PKT_SYNC)) {
-		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNCACK);
-		goto discard;
-	}
-
 	switch (sk->sk_state) {
 	case DCCP_CLOSED:
 		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
@@ -586,6 +581,9 @@ int dccp_rcv_state_process(struct sock *
 			sk_wake_async(sk, 0, POLL_OUT);
 			break;
 		}
+	} else if (unlikely(dh->dccph_type = DCCP_PKT_SYNC)) {
+		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNCACK);
+		goto discard;
 	}
 
 	if (!queued) {
