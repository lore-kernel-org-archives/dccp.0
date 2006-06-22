From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:53:10 +0000
Subject: [PATCH 02/11] DCCP: Fix how DCCP_ACKVEC_STATE_NOT_RECEIVED is used
Message-Id: <20060622175310.GB4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Fix the way state is masked out.  DCCP_ACKVEC_STATE_NOT_RECEIVED is defined as
appears in the packet, therefore bit shifting is not required.  This fix allows
CCID2 to correctly detect losses.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 8dab723..bc5ff12 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -436,8 +436,7 @@ static void dccp_ackvec_check_rcv_ackvec
 		break;
 found:
 		if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
-			const u8 state = (*vector &
-					  DCCP_ACKVEC_STATE_MASK) >> 6;
+			const u8 state = *vector & DCCP_ACKVEC_STATE_MASK;
 			if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED) {
 #ifdef CONFIG_IP_DCCP_DEBUG
 				struct dccp_sock *dp = dccp_sk(sk);
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index d4f9e2d..6fe9cb9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -583,8 +583,8 @@ static void ccid2_hc_tx_packet_recv(stru
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = (*vector &
-						  DCCP_ACKVEC_STATE_MASK) >> 6;
+				const u8 state = *vector &
+						 DCCP_ACKVEC_STATE_MASK;
 
 				/* new packet received or marked */
 				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
