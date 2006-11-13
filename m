From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:27:31 +0000
Subject: [PATCH 1/7]: Update retransmit timer comments
Message-Id: <200611131327.32131@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 [DCCP]: Update retransmit timer comments

 This updates program documentation: spell out precise conditions about
 which packets are eligible for retransmission (which is actually quite
 hard to extract from RFC 4340).

 It is based on the following table derived from RFC 4340:

 +-----------+---------------------------------+---------------------+
 |   Type    | Retransmit?                     |  Remark             |
 +-----------+---------------------------------+---------------------+
 | Request   |  in client-REQUEST state        | sec. 8.1.1          |
 | Response  |  NEVER                          | SHOULD NOT, 8.1.3   |                  
 | Data      |  NEVER                          | unreliable protocol |
 | Ack       |  possible in client-PARTOPEN    | sec. 8.1.5          |
 | DataAck   |  NEVER                          | unreliable protocol |
 | CloseReq  |  only in server-CLOSEREQ state  | MUST, sec. 8.3      | 
 | Close     |  in node-CLOSING state          | MUST, sec. 8.3      |     
 +-----------+-------------------------------------------------------+
 | Reset     |  only in response to other packets                    |
 | Sync      |  only in response to sequence-invalid packets (7.5.4) | 
 | SyncAck   |  only in response to Sync packets                     |
 +-----------+-------------------------------------------------------+

 Hence the only packets eligible for retransmission are:
	* Requests in client-REQUEST  state (sec. 8.1.1)
	* Acks     in client-PARTOPEN state (sec. 8.1.5)
	* CloseReq in server-CLOSEREQ state (sec. 8.3)
	* Close    in   node-CLOSING  state (sec. 8.3)

 I had meant to put in a check for these types too, but have left that
 for later.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 net/dccp/timer.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -142,7 +142,7 @@ static void dccp_retransmit_timer(struct
 
 	/* retransmit timer is used for feature negotiation throughout
 	 * connection.  In this case, no packet is re-transmitted, but rather an
-	 * ack is generated and pending changes are splaced into its options.
+	 * ack is generated and pending changes are placed into its options.
 	 */
 	if (sk->sk_send_head = NULL) {
 		dccp_pr_debug("feat negotiation retransmit timeout %p\n", sk);
@@ -154,9 +154,11 @@ static void dccp_retransmit_timer(struct
 	/*
 	 * sk->sk_send_head has to have one skb with
 	 * DCCP_SKB_CB(skb)->dccpd_type set to one of the retransmittable DCCP
-	 * packet types (REQUEST, RESPONSE, the ACK in the 3way handshake
-	 * (PARTOPEN timer), etc).
-	 */
+	 * packet types. The only packets eligible for retransmission are:
+	 * 	-- Requests in client-REQUEST  state (sec. 8.1.1)
+	 * 	-- Acks     in client-PARTOPEN state (sec. 8.1.5)
+	 * 	-- CloseReq in server-CLOSEREQ state (sec. 8.3)
+	 * 	-- Close    in   node-CLOSING  state (sec. 8.3)                */
 	BUG_TRAP(sk->sk_send_head != NULL);
 
 	/* 

