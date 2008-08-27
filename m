From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Aug 2008 05:35:20 +0000
Subject: [PATCH 1/6] dccp: Always generate a Reset in response to option errors
Message-Id: <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

RFC4340 states that if a packet is received with an option error (such as a
Mandatory Option as the last byte of the option list), the endpoint should
repond with a Reset.

In the LISTEN and RESPOND states, the endpoint correctly reponds with Reset,
while in the REQUEST/OPEN states, packets with option errors are just ignored.

The packet sequence is as follows:

Case 1:

  Endpoint A                           Endpoint B
  (CLOSED)                             (CLOSED)

               <----------------       REQUEST

  RESPONSE     ----------------->      (*1)
  (with invalid option)
               <----------------       RESET
                                       (with Reset Code 5, "Option Error")

  (*1) currently just ignored, no Reset is sent

Case 2:

  Endpoint A                           Endpoint B
  (OPEN)                               (OPEN)

  DATA-ACK     ----------------->      (*2)
  (with invalid option)
               <----------------       RESET
                                       (with Reset Code 5, "Option Error")

  (*2) currently just ignored, no Reset is sent

This patch fixes the problem, by generating a Reset instead of silently
ignoring option errors.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -370,7 +370,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 
 	if (dccp_parse_options(sk, NULL, skb))
-		goto discard;
+		return 1;
 
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_event_ack_recv(sk, skb);
@@ -610,7 +610,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Step 8: Process options and mark acknowledgeable
 		 */
 		if (dccp_parse_options(sk, NULL, skb))
-			goto discard;
+			return 1;
 
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);

