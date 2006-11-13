From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 13 Nov 2006 15:42:07 +0000
Subject: [PATCH 2/7][DCCP]: Increment sequence numbers on retransmitted Response packets
Message-Id: <20061113154206.GG6947@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Problem:
--------
  If DCCP B receives a retransmitted Request from DCCP A (with an
  increased sequence number), DCCP A sends one or more Responses
  without incrementing A's sent sequence number.

  This problem was first identified thanks to  Vladimir M. in
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00570.html

RFC 4340 says:
 * sec. 4.2: "Every DCCP packet increments the sequence number,
              whether or not it contains application data."
 * sec. 7  : "Even DCCP-Ack and DCCP-Sync packets, and other
              packets that don't carry user data, increment the
              Sequence Number. [...] retransmissions, such as
              retransmissions of DCCP-Request packets, also increment
              the Sequence Number."
Cause:
------
The cause is that make_response keeps the ISS on each retransmission; only
Responses to retransmitted Requests have ISS incremented in dccp_check_req(),
keep-alive Responses triggered via dccp_response_timer() retain initial ISS.

Solution:
---------
This patch uses the unused `acked' field in the inet_request_sock() associated
with the connection request: to remember whether an incoming Request has already
been ack(nowledg)ed by way of sending a Response.
This helps to distinguish initial from retransmitted Responses, and is used to
increment the sequence numbers accordingly.

In addition, to protect against Request floods, the number of
retransmissions is also incremented when sending further Responses in
reply to retransmitted (i.e., non-initial) Requests.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 minisocks.c |   16 +++++++++-------
 output.c    |    4 ++++
 2 files changed, 13 insertions(+), 7 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index d3de696..5b2773e 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -196,15 +196,17 @@ struct sock *dccp_check_req(struct sock 
 
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type = DCCP_PKT_REQUEST) {
-		if (after48(DCCP_SKB_CB(skb)->dccpd_seq,
-			    dccp_rsk(req)->dreq_isr)) {
-			struct dccp_request_sock *dreq = dccp_rsk(req);
+		struct dccp_request_sock *dreq = dccp_rsk(req);
 
+		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
-			/* Send another RESPONSE packet */
-			dccp_set_seqno(&dreq->dreq_iss, dreq->dreq_iss + 1);
-			dccp_set_seqno(&dreq->dreq_isr,
-				       DCCP_SKB_CB(skb)->dccpd_seq);
+			dreq->dreq_isr = DCCP_SKB_CB(skb)->dccpd_seq;
+			/*
+			 * Send another RESPONSE packet
+			 * To protect against Request floods, increment retrans
+			 * counter (backoff, monitored by dccp_response_timer).
+			 */
+			req->retrans++;
 			req->rsk_ops->rtx_syn_ack(sk, req, NULL);
 		}
 		/* Network Duplicate, discard packet */
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 992caed..08ee554 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -332,6 +332,8 @@ struct sk_buff *dccp_make_response(struc
 	skb->dst = dst_clone(dst);
 
 	dreq = dccp_rsk(req);
+	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
+		dccp_inc_seqno(&dreq->dreq_iss);
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
 	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
 
@@ -354,6 +356,8 @@ struct sk_buff *dccp_make_response(struc
 
 	dccp_csum_outgoing(skb);
 
+	/* We use `acked' to remember that a Response was already sent. */
+	inet_rsk(req)->acked = 1;
 	DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
 	return skb;
 }
