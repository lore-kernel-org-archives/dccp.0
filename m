From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 27 Oct 2007 11:34:32 +0000
Subject: [PATCH 4/6]: Don't assign negative values to Ack Ratio
Message-Id: <200710271234.32415@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Don't process Ack twice in Respond state

This fixes a bug in the feature negotiation code: the problem is that the Ack which leads
from RESPOND to OPEN state is processed twice, causing the following problems:

 * options are parsed on request_sock in dccp_check_req and on the child socket in 
   dccp_rcv_state_process (called via dccp_child_process);
 * redundant sequence-validity test (the one in dccp_check_req is more stringent);
 * input is delivered to CCIDs in RESPOND state, while it should only be delivered in 
   OPEN/PARTOPEN state;
 * since Ack Vectors (if enabled) are already loaded at that time, Ack vector accounting
   counts the Ack which completes the initial handshake, which is confusing, since it 
   should really start in state OPEN/PARTOPEN.

Note: The only states that the CCIDs/AckVecs will get input now in dccp_rcv_state_process
      are the closing states - do we really need to feed the input to CCIDs/AckVec when
      the connection is closing anyway???

                           D e t a i l e d   A n a l y s i s
	       	           ---------------------------------
Assume that the Request has already arrived, so that a request socket is stored
in the hash tables, and that the subsequent Response has already been sent.

 1. Ack arrives via dccp_v{4,6}_do_rcv
 2. backlog handler calls dccp_v{4,6}_hnd_req
 3. we found request_sock => call dccp_check_req
 4. dccp_check_req 
 	- checks whether Ackno = ISS 
	- parses options on the request sock (contains the Confirm Feature-Negotiation
          options for the Change options the server put on the Response packet)
	- calls dccp_v{4,6}_request_recv_sock 
		* this calls dccp_create_open_req_child (child socket in RESPOND state)
		* and adds the request_sock to the accept queue
	- dccp_check_req returns pointer to child socket		
 5. since nsk != sk, dccp_v{4,6}_do_rcv call dccp_child_process
 6. child has just been created, not locked, so call dccp_rcv_state_process, where the
    test  "sk->sk_state != DCCP_REQUESTING" is true (sk_state = DCCP_RESPOND). Now,
    	- seqno is tested again and redundantly
	- dccp_parse_options is called the second time for the same packet (this time on sk)
	- dccp_event_ack_recv is called => triggers Ack Vector processing
	- if Feature Negotiation is enabled, the Ack is marked as "received" on the Ack Vector
	- the Ack is -- unnecessarily -- handed down to the TX and RX CCIDs.
    Further down, the important processing then happens in dccp_rcv_respond_partopen_state_process,
    where the only significant action is to move from RESPOND to OPEN.
	 
This patch avoids the steps listed as bullet-points in (6), since these are all redundant and
not necessary; and in the worst case will confuse internal processing.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -583,7 +583,7 @@ int dccp_rcv_state_process(struct sock *
 		return 1;
 	}
 
-	if (sk->sk_state != DCCP_REQUESTING) {
+	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
 		if (dccp_check_seqno(sk, skb))
 			goto discard;
 
[CCID2]: Don't assign negative values to Ack Ratio

Since it makes not sense to assign negative values to Ack Ratio, this
patch disallows this possibility.

As a consequence, a Bug test for negative Ack Ratio values becomes obsolete.

Furthermore, a check against overflow (as Ack Ratio may not exceed 2 bytes,
due to RFC 4340, 11.3) has been added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -140,7 +140,7 @@ static int ccid2_hc_tx_send_packet(struc
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
 }
 
-static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
+static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	/*
@@ -159,9 +159,10 @@ static void ccid2_change_l_ack_ratio(str
 		if (val > max)
 			val = max;
 	}
+	if (val > 0xFFFF)		/* RFC 4340, 11.3 */
+		val = 0xFFFF;
 
-	ccid2_pr_debug("changing local ack ratio to %d\n", val);
-	WARN_ON(val <= 0);
+	ccid2_pr_debug("changing local ack ratio to %u\n", val);
 	dp->dccps_l_ack_ratio = val;
 }
 
@@ -572,7 +573,7 @@ static void ccid2_hc_tx_packet_recv(stru
 				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
 				hctx->ccid2hctx_rpseq = 0;
 
-				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio << 1);
+				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
 			}
 		}
 	}
