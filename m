From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:49 +0000
Subject: [PATCH 08/14] [ACKVEC]: Use enum to enumerate Ack Vector states
Message-Id: <1198074355-18842-9-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This replaces 3 #defines with an enum containing all possible
Ack Vector states as per RFC 4340, 11.4. This helps to reduce
the length of several expressions.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c      |    7 +++----
 net/dccp/ackvec.h      |   10 ++++++----
 net/dccp/ccids/ccid2.c |    7 +++----
 net/dccp/input.c       |    9 +++------
 4 files changed, 15 insertions(+), 18 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -26,10 +26,12 @@
 #define DCCPAV_NUM_ACKVECS	2
 #define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
 
-#define DCCP_ACKVEC_STATE_RECEIVED	0
-#define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
-#define DCCP_ACKVEC_STATE_NOT_RECEIVED	(3 << 6)
-
+enum dccp_ackvec_states {
+	DCCPAV_RECEIVED =	0x00,
+	DCCPAV_ECN_MARKED =	0x40,
+	DCCPAV_RESERVED =	0x80,
+	DCCPAV_NOT_RECEIVED =	0xC0
+};
 #define DCCPAV_MAX_RUNLEN	0x3F
 
 static inline u8 dccp_ackvec_runlen(const u8 *cell)
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -124,7 +124,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 
 	if (new_head < 0) {
 		if (gap > 0) {
-			memset(av->av_buf, DCCP_ACKVEC_STATE_NOT_RECEIVED,
+			memset(av->av_buf, DCCPAV_NOT_RECEIVED,
 			       gap + new_head + 1);
 			gap = -new_head;
 		}
@@ -135,7 +135,7 @@ static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
 
 	if (gap > 0)
 		memset(av->av_buf + av->av_buf_head + 1,
-		       DCCP_ACKVEC_STATE_NOT_RECEIVED, gap);
+		       DCCPAV_NOT_RECEIVED, gap);
 
 	av->av_buf[av->av_buf_head] = state;
 	av->av_vec_len += packets;
@@ -205,8 +205,7 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 			 * valid packets not yet in av_buf have a reserved
 			 * entry, with a len equal to 0.
 			 */
-			if (*cur_head = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
-			    delta = 0) {
+			if (*cur_head = DCCPAV_NOT_RECEIVED && delta = 0) {
 				dccp_pr_debug("Found %llu reserved seat!\n",
 					      (unsigned long long)ackno);
 				*cur_head = state;
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -605,13 +605,12 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				const u8 state = dccp_ackvec_state(vector);
 
 				/* new packet received or marked */
-				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
+				if (state != DCCPAV_NOT_RECEIVED &&
 				    !seqp->ccid2s_acked) {
-					if (state =
-					    DCCP_ACKVEC_STATE_ECN_MARKED) {
+					if (state = DCCPAV_ECN_MARKED)
 						ccid2_congestion_event(sk,
 								       seqp);
-					} else
+					else
 						ccid2_new_ack(sk, seqp,
 							      &maxincr);
 
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -377,8 +377,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 	if (dp->dccps_hc_rx_ackvec != NULL &&
 	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-			    DCCP_SKB_CB(skb)->dccpd_seq,
-			    DCCP_ACKVEC_STATE_RECEIVED))
+			    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
 		goto discard;
 	dccp_deliver_input_to_ccids(sk, skb);
 
@@ -511,8 +510,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 
 		if (dp->dccps_hc_rx_ackvec != NULL &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
+				    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
 			goto unable_to_proceed;
 
 		dccp_send_ack(sk);
@@ -639,8 +637,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 		if (dp->dccps_hc_rx_ackvec != NULL &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq,
-				    DCCP_ACKVEC_STATE_RECEIVED))
+				    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
 			goto discard;
 
 		dccp_deliver_input_to_ccids(sk, skb);
-- 
1.5.3.GIT

