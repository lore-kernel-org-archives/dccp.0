From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:39:16 +0000
Subject: [PATCH 1/8] [DCCP]: Send Reset upon Sync in state REQUEST
Message-Id: <20070926183916.GC10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/input.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index cde0e70..86ad3ba 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -540,11 +540,6 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
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
@@ -575,6 +570,9 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			sk_wake_async(sk, 0, POLL_OUT);
 			break;
 		}
+	} else if (unlikely(dh->dccph_type = DCCP_PKT_SYNC)) {
+		dccp_send_sync(sk, dcb->dccpd_seq, DCCP_PKT_SYNCACK);
+		goto discard;
 	}
 
 	if (!queued) {
-- 
1.5.2.2

