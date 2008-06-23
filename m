From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Jun 2008 14:16:28 +0000
Subject: [Announce]: Test Tree updated to allow ECN support in Ack Vectors
Message-Id: <20080623141628.GA1249@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a small change in the internal Ack Vector API of the test tree.

The reason is that dccp_ackvec_input() needs a reference to the @skb, since
otherwise it will later not be able to 
 * detect whether the @skb was ECN-marked or
 * what the value of the ECN-Nonce is on the @skb.

The following two patches were updated, the combined inter-diff is below:
 * "dccp ccid-2: Update code for the Ack Vector input/registration routine"
 * "dccp ccid-2: Consolidate Ack-Vector processing within main DCCP module"

--- b/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -106,7 +106,7 @@
 extern struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
 extern void dccp_ackvec_free(struct dccp_ackvec *av);
 
-extern void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state);
+extern void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb);
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
 extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
--- b/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -246,12 +246,12 @@
 
 /**
  * dccp_ackvec_input  -  Register incoming packet in the buffer
- * @av:		buffer/records to update
- * @seqno:	sequence number to register as received
- * @state:	how packet with @seqno was received, one of %dccp_ackvec_states
  */
-void dccp_ackvec_input(struct dccp_ackvec *av, u64 seqno, u8 state)
+void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb)
 {
+	u64 seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	enum dccp_ackvec_states state = DCCPAV_RECEIVED;
+
 	if (dccp_ackvec_is_empty(av)) {
 		dccp_ackvec_add_new(av, 1, seqno, state);
 		av->av_tail_ackno = seqno;
--- b/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -162,13 +162,12 @@
 static void dccp_handle_ackvec_processing(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_ackvec *av = dccp_sk(sk)->dccps_hc_rx_ackvec;
-	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 
-	if (av != NULL) {
-		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-			dccp_ackvec_clear_state(av, dcb->dccpd_ack_seq);
-		dccp_ackvec_input(av, dcb->dccpd_seq, DCCPAV_RECEIVED);
-	}
+	if (av = NULL)
+		return;
+	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
+		dccp_ackvec_clear_state(av, DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	dccp_ackvec_input(av, skb);
 }
 
 static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
-- 
